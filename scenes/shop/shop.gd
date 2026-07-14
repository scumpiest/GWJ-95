extends Node

signal purchase_card(card: CardData)

@export var player_hand: Node

@export var card_scene: PackedScene
@export var card_container: HFlowContainer;
@export var cards_db: CardDB

func _ready() -> void:
	_draw_cards()

func _draw_cards() -> void:
	for n in 9:
		var card_visual := card_scene.instantiate() as CardVisual
		card_visual.shop_card = true
		card_visual.clicked_card.connect(on_card_clicked)
		card_visual.card_data = cards_db.cards.pick_random()
		card_container.add_child(card_visual)
	pass

func on_card_clicked(card: CardVisual) -> void:
	print(card)
	for otherCard: CardVisual in get_shop_cards():
		otherCard.selected_shop_card = card
		if otherCard == card:
			otherCard.set_casette_highlighted(true)
		else:
			otherCard.set_casette_highlighted(false)

func get_shop_cards() -> Array[CardVisual]:
	return card_container.get_children() as Array[CardVisual]

func _on_leave_button_pressed() -> void:
	self.visible = false

# TODO: add currency and subtract money amount from 'bought' card
func _on_buy_button_pressed() -> void:
	for card in get_shop_cards():
		if card.selected_shop_card == card:
			card.reparent(player_hand)
