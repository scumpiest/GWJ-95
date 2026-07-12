extends Control

@export var deck: DeckData
@export var cards_per_draw: int = 1
@export var initial_hand_size: int = 3
@export var card_scene: PackedScene

@onready var deck_button: TextureButton = %Deck
@onready var hand: HBoxContainer = %Hand
@onready var end_turn: Button = %EndTurnButton
@onready var discard_pile_label: Label = %DiscardPileLabel
@onready var deck_card_label: Label = %DeckCardLabel


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
	if deck.cards.is_empty():
		return

	_draw_cards(cards_per_draw)


func _on_end_turn_button_pressed() -> void:
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
