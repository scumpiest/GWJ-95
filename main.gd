extends Control

@export var deck: DeckData
@export var cards_per_draw: int = 1
@export var initial_hand_size: int = 5
@export var card_scene: PackedScene

var max_handsize: int = 7

@onready var deck_button: TextureButton = %Deck
@onready var hand: HBoxContainer = %Hand
@onready var chain: HBoxContainer = %Chain
@onready var end_turn: Button = %EndTurnButton
@onready var discard_pile_label: Label = %DiscardPileLabel
@onready var deck_card_label: Label = %DeckCardLabel
@onready var player: Player = %Player
@onready var enemy: Enemy = %Enemy1


func _ready() -> void:
	deck.shuffle()
	_draw_cards(initial_hand_size)
	deck_button.pressed.connect(_on_deck_pressed)
	end_turn.pressed.connect(_on_end_turn_button_pressed)


func _draw_cards(count: int) -> void:
	for card_data in deck.draw(count):
		var card_visual := card_scene.instantiate() as CardVisual
		card_visual.card_data = card_data
		hand.add_child(card_visual)
	deck_card_label.text = str(deck.cards.size())


func _on_deck_pressed() -> void:
	if hand.get_children().size() < max_handsize:
		if deck.cards.is_empty():
			return

		_draw_cards(cards_per_draw)


func _trigger_chain_sequentially() -> void:
	for slot_node in chain.get_children():
		if slot_node is not Slot:
			continue

		var card = slot_node.get_card()
		if card == null:
			continue

		player.play_next_pose()
		print("Activating card: ", slot_node.color)
		await card.activate()
	player.play_idle_pose()


func _on_end_turn_button_pressed() -> void:
	end_turn.disabled = true
	deck_button.disabled = true

	await _trigger_chain_sequentially()

	for card in hand.get_children():
		deck.add_to_discard_pile(card.card_data)
		card.queue_free()

	if deck.cards.size() == 0:
		deck.cards.assign(deck.discard_pile)
		deck.discard_pile.clear()
		deck_card_label.text = str(deck.cards.size())

	discard_pile_label.text = str(deck.discard_pile.size())
	deck.shuffle()
	_draw_cards(cards_per_draw)

	end_turn.disabled = false
	deck_button.disabled = false
