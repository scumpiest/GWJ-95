extends Control

@export var deck: DeckData
@export var cards_per_draw: int = 5
@export var initial_hand_size: int = 5
@export var card_scene: PackedScene

@onready var deck_button: TextureButton = %Deck
@onready var shop_button: Button = %Shop
@onready var hand: HBoxContainer = %Hand
@onready var chain: HBoxContainer = %Chain
@onready var end_turn: Button = %EndTurnButton
@onready var discard_pile_label: Label = %DiscardPileLabel
@onready var deck_card_label: Label = %DeckCardLabel
@onready var player: Player = %Player
@onready var enemy: Enemy = %Enemy1
@onready var shopContainer: MarginContainer = self.get_node("Shop");
@onready var mainContainer: MarginContainer = self.get_node("MarginContainer");


func _ready() -> void:
	var battle_context := BattleContext.new(
		player.unit,
		enemy.unit,
		deck,
		chain.get_child_count(),
	)
	GameManager.start_battle(battle_context)
	GameManager.deck_count_changed.connect(_on_deck_count_changed)
	GameManager.discard_count_changed.connect(_on_discard_count_changed)

	shop_button.pressed.connect(func(): shopContainer.visible = true)
	shopContainer.visibility_changed.connect(func(): mainContainer.visible = !shopContainer.visible)

	_spawn_cards(GameManager.draw_cards(initial_hand_size))
	end_turn.pressed.connect(_on_end_turn_button_pressed)


func _spawn_cards(cards: Array[CardData]) -> void:
	for card_data in cards:
		var card_visual := card_scene.instantiate() as CardVisual
		card_visual.card_data = card_data
		hand.add_child(card_visual)


func _on_end_turn_button_pressed() -> void:
	end_turn.disabled = true

	await _trigger_chain_sequentially()

	var hand_cards: Array[CardData] = []
	for card in hand.get_children():
		hand_cards.append(card.card_data)
		card.queue_free()

	_spawn_cards(GameManager.end_player_turn(hand_cards, cards_per_draw))

	end_turn.disabled = false


func _trigger_chain_sequentially() -> void:
	for slot_node in chain.get_children():
		if slot_node is not Slot:
			continue

		var card = slot_node.get_card()
		if card == null:
			continue

		player.play_next_pose()
		slot_node.make_slot_jiggle()
		print("Activating card: ", slot_node.color)
		await card.activate()
		slot_node.stop_slot_jiggle()
	player.play_idle_pose()


func _on_deck_count_changed(count: int) -> void:
	deck_card_label.text = str(count)


func _on_discard_count_changed(count: int) -> void:
	discard_pile_label.text = str(count)
