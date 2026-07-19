extends Control
class_name Main

@export var deck: DeckData
@export var cards_per_draw: int = 5
@export var initial_hand_size: int = 5
@export var card_scene: PackedScene
@export var is_tutorial: bool = false

@onready var hand: HBoxContainer = %Hand
@onready var chain: HBoxContainer = %Chain
@onready var end_turn: Button = %EndTurnButton
@onready var player: Player = %Player
@onready var shop_container: MarginContainer = self.get_node("Shop");
@onready var main_container: MarginContainer = self.get_node("MarginContainer");
@onready var enemy_container: Control = %EnemyContainer
@onready var reward_screen: RewardScreen = %RewardScreen
@onready var tutorial: CanvasLayer = $MarginContainer/CanvasLayer
@onready var bubble_button: Button = $MarginContainer/CanvasLayer/BubbleButton
@onready var text_tutorial: RichTextLabel = $MarginContainer/CanvasLayer/RichTextLabel
@onready var draw_pile_count: Label = %DrawPileCount
@onready var discard_pile_count: Label = %DiscardPileCount
@onready var speech_bubble_pressed: bool = false
@onready var end_turn_button_pressed: bool = false
@onready var timer_arrow: Timer = $MarginContainer/CanvasLayer/TimerArrow
@onready var _battle_ui_nodes: Array[CanvasItem] = [
	main_container.get_node("VBox/ChainLabel"),
	main_container.get_node("VBox/HeaderContainer"),
	main_container.get_node("VBox/DiscardPile"),
	main_container.get_node("VBox/DrawPile"),
	main_container.get_node("VBox/MarginContainer"),
	enemy_container,
]


var step = 0
var scene_animation_duration: float = 0.4
var current_enemy: Node2D
var _battle_won: bool = false
var _battle_lost: bool = false

func _ready() -> void:
	GameManager.phase_changed.connect(_on_phase_changed)
	GameManager.deck_count_changed.connect(_on_deck_count_changed)
	GameManager.discard_count_changed.connect(_on_discard_count_changed)
	player.unit.died.connect(_on_player_died)
	_on_deck_count_changed(deck.cards.size())
	_on_discard_count_changed(deck.discard_pile.size())

	shop_container.visibility_changed.connect(func():
		var tween := create_tween()
		if !shop_container.visible:
			tween.tween_property(main_container, "modulate:a", 1.0, scene_animation_duration)
		else:
			tween.tween_property(main_container, "modulate:a", 0.0, scene_animation_duration)
		main_container.visible = !shop_container.visible
		)
	#deck_button.pressed.connect(_on_deck_pressed)

	end_turn.pressed.connect(_on_end_turn_button_pressed)
	end_turn.mouse_entered.connect(AudioManager.play_ui_hover)
	bubble_button.mouse_entered.connect(AudioManager.play_ui_hover)
	reward_screen.card_chosen.connect(_chosen_card)
	reward_screen.visibility_changed.connect(_on_reward_visibility_changed)
	LevelManager.next_level.connect(next_level)
	LevelManager.next_level.emit()
	
	timer_arrow.start()


func _on_reward_visibility_changed() -> void:
	_set_battle_ui_visible(not reward_screen.visible)


func _set_battle_ui_visible(is_visible: bool) -> void:
	var target_alpha := 1.0 if is_visible else 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	for node in _battle_ui_nodes:
		tween.tween_property(node, "modulate:a", target_alpha, scene_animation_duration)


func _on_deck_count_changed(count: int) -> void:
	draw_pile_count.text = str(count)


func _on_discard_count_changed(count: int) -> void:
	discard_pile_count.text = str(count)


func _chosen_card(card_data: CardData) -> void:
	GameManager.add_card_to_deck(card_data)
	LevelManager.next_level.emit()


func next_level() -> void:
	if LevelManager.current_level.type == Level.LevelType.SHOP:
		shop_container.visible = true
		var tween := create_tween()
		tween.tween_property(shop_container, "modulate:a", 1.0, scene_animation_duration)
		shop_container.health_bought = false
		return
	else:
		shop_container.visible = false

	if current_enemy:
		current_enemy.free()
		current_enemy = null

	var current_level := LevelManager.current_level
	var enemy_scene: Enemy = current_level.enemy_scene.instantiate()
	enemy_scene.position = Vector2(910, 314)
	enemy_scene.scale = Vector2(0.5,0.5)

	enemy_scene.unit = LevelManager.get_current_enemy()
	enemy_scene.enemy_data = current_level.enemy_data
	enemy_container.add_child(enemy_scene)
	enemy_scene.unit.health_changed.connect(_on_enemy_damage_taken)
	enemy_scene.unit.died.connect(_on_enemy_died)
	current_enemy = enemy_scene
	_battle_won = false
	_battle_lost = false

	_return_previous_cards_to_deck()

	var battle_context := BattleContext.new(
		player.unit,
		enemy_scene.unit,
		deck,
		chain.get_child_count(),
		current_level.enemy_data,
	)
	GameManager.start_battle(battle_context)

	GameManager.roll_enemy_intent()
	_spawn_cards(GameManager.draw_cards(initial_hand_size))


# TODO: add animation to spawn cards
func _spawn_cards(cards: Array[CardData]) -> void:
	if cards.is_empty():
		return
	AudioManager.play_card_draw()
	for card_data in cards:
		var card_visual := card_scene.instantiate() as CardVisual
		card_visual.card_data = card_data
		hand.add_child(card_visual)


func _return_previous_cards_to_deck() -> void:
	for card in hand.get_children():
		deck.cards.append(card.card_data)
		card.queue_free()
	for card_data in clear_chain_slots():
		deck.cards.append(card_data)
	for card_data in deck.discard_pile:
		deck.cards.append(card_data)
	deck.discard_pile.clear()


func _on_end_turn_button_pressed() -> void:
	AudioManager.play_ui_click()
	end_turn.disabled = true
	if _battle_lost:
		return
	if not GameManager.begin_chain_resolve():
		end_turn.disabled = false
		return

	LevelManager.send_task_event(BattleTask.EventType.TURN_START, get_tree().get_nodes_in_group("card_slots"))
	await _trigger_chain_sequentially()
	if _battle_won:
		_finish_battle_won()
		end_turn.disabled = false
		return
	if _battle_lost:
		return

	var discarded := clear_chain_slots()
	#discard cards leftover in hand
	for card in hand.get_children():
		discarded.append(card.card_data)
		card.queue_free()
	if not discarded.is_empty():
		AudioManager.play_card_discard()
	var drawn := GameManager.end_player_turn(discarded, cards_per_draw)
	if _battle_lost:
		return
	_spawn_cards(drawn)
	end_turn.disabled = false

func _on_enemy_damage_taken(health: int, old_health: int):
	if old_health > health:
		LevelManager.send_task_event(BattleTask.EventType.DEAL_DAMAGE, old_health - health)

func _on_enemy_died() -> void:
	AudioManager.play_enemy_dies()
	_battle_won = true
	# Clearing cards mid-resolve frees CardVisuals while activations still await timers.
	if GameManager.phase != GameManager.Phase.CHAIN_RESOLVING:
		_finish_battle_won()


func _on_player_died() -> void:
	if _battle_lost or _battle_won:
		return
	_battle_lost = true
	end_turn.disabled = true
	AudioManager.stop_music()
	AudioManager.play_lose_song()


func _finish_battle_won() -> void:
	AudioManager.play_win_song()
	LevelManager.send_task_event(BattleTask.EventType.TURN_END, null)
	LevelManager.send_task_event(BattleTask.EventType.BATTLE_END, null)
	var won_chain_cards := clear_chain_slots()
	if not won_chain_cards.is_empty():
		AudioManager.play_card_discard()
		GameManager.discard_cards(won_chain_cards)
	if LevelManager.current_level.rewards:
		reward_screen.show_choices(LevelManager.current_level.rewards.cards)
	else:
		LevelManager.next_level.emit()


func _trigger_chain_sequentially() -> void:
	_sync_chain_states()
	var resolver: ChainEffectResolver = ChainEffectResolver.new()

	var slots: Array[Slot] = []
	for slot_node in chain.get_children():
		slots.append(slot_node)

	await resolver.resolve_chain(GameManager.context, slots, _on_card_activated)
	player.play_idle_pose()

func _sync_chain_states() -> void:
	var i: int = 0
	for slot_node in chain.get_children():
		GameManager.context.chain_slot_states[i] = ChainSlotState.new().from_slot(i, slot_node)
		i += 1

func clear_chain_slots() -> Array[CardData]:
	var cards: Array[CardData] = []
	for child in chain.get_children():
		var card := (child as Slot).clear_card()
		if card == null:
			continue
		cards.append(card.card_data)
		card.queue_free()
		child.set_highlighted(false)
	return cards


func _on_phase_changed(phase: GameManager.Phase) -> void:
	print("Phase changed: ", GameManager.Phase.keys()[phase])
	if phase != GameManager.Phase.PLAN:
		end_turn.disabled = true

func _on_card_activated(slot: Slot, card: CardVisual) -> void:
	player.play_next_pose()
	slot.make_slot_jiggle()
	print("Activating card: ", slot.color)
	await card.activate()

func run_tutorial():
	speech_bubble_pressed = false
	tutorial.visible = true
	#for key in Databank.tutorial_dialogue.keys():
	text_tutorial.text = Databank.tutorial_dialogue[step]
	#print(text_tutorial.text)

func _process(_delta: float) -> void:
	match step:
		0, 3, 4, 5, 7, 8:
			if speech_bubble_pressed == true:
				step += 1
				run_tutorial()
		1: 
			for i in range(0, 5):
				if chain.get_child(i).get_child(0).get_child_count() != 0:
					step += 1
					run_tutorial()
		2:
			var slots_filled = 0
			for i in range(0, 5):
				if chain.get_child(i).get_child(0).get_child_count() != 0:
					slots_filled += 1
			if slots_filled == chain.get_child_count():
				step += 1
				run_tutorial()
		6:
			if end_turn_button_pressed == true:
				step += 1
				run_tutorial()
		9:
			is_tutorial = false
			step = 0
	
		
	
	if is_tutorial == false:
		tutorial.visible = false

func _on_speech_bubble_pressed() -> void:
	AudioManager.play_ui_click()
	speech_bubble_pressed = true



func _on_timer_arrow_timeout() -> void:
	timer_arrow.start()
	if step == 1:
		main_container.get_child(0).get_child(1).fill_1_slot()
	if step == 3:
		main_container.get_child(0).get_child(1).switch_cards()
	if step == 6:
		main_container.get_child(0).get_child(1).highlight_end_turn()
	if step == 7:
		main_container.get_child(0).get_child(1).set_visible(false)
