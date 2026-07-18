extends Node

@export var player_hand: Node

@export var card_scene: PackedScene
@export var card_container: HFlowContainer;
@export var cards_db: CardDB

@export var shop_backdrop: SpineSprite
var animation_state: SpineAnimationState

func _ready() -> void:
	_draw_cards()
	animation_state = shop_backdrop.get_animation_state()
	animation_state.set_animation("store_normal", true, 0)

func _draw_cards() -> void:
	for n in 6:
		var card_visual := card_scene.instantiate() as CardVisual
		card_visual.shop_card = true
		card_visual.clicked_card.connect(on_card_clicked)
		card_visual.card_data = cards_db.cards.pick_random()
		card_container.add_child(card_visual)
	pass

func on_card_clicked(card: CardVisual) -> void:
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

func _on_buy_button_pressed() -> void:
	for card in get_shop_cards():
		if card.selected_shop_card == card:
			if CurrencyManager.subtract_money(card.card_data.cost):
				# Set shop card to false, reset selected states
				animation_state.set_animation("store_purchase", false, 0)
				animation_state.add_animation("store_normal", 1, true, 0)
				card.set_shop_card(false)
				card.set_casette_highlighted(false)
				card.selected_shop_card = null
				card.clicked_card.disconnect(on_card_clicked)
				card.reparent(player_hand)
			else:
				animation_state.set_animation("store_no_money", false, 0)
				animation_state.add_animation("store_normal", 1, true, 0)

