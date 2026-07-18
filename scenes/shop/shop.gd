extends Node

@export var player_hand: Node

@onready var player: Player = %Player
@onready var buy_health_button: Button = %BuyHealthButton
@export var card_scene: PackedScene
@export var card_container: HFlowContainer;
@export var shop_cards: CardDB

@export var shop_backdrop: SpineSprite
var animation_state: SpineAnimationState
var tween: Tween

var health_bought = true

func _ready() -> void:
	_draw_cards()
	animation_state = shop_backdrop.get_animation_state()
	animation_state.set_animation("store_normal", true, 0)

func _draw_cards() -> void:
	for card in shop_cards.cards:
		var card_visual := card_scene.instantiate() as CardVisual
		card_visual.shop_card = true
		card_visual.clicked_card.connect(on_card_clicked)
		card_visual.card_data = card
		card_container.add_child(card_visual)
	pass

func on_card_clicked(card: CardVisual) -> void:
	_buy_and_handle_animation(
		func():
			card.set_shop_card(false)
			card.set_casette_highlighted(false)
			card.clicked_card.disconnect(on_card_clicked)
			card.reparent(player_hand),
		card.card_data.cost,
		func():
			if tween:
				tween.kill()
			if !card.start_x:
				card.start_x = card.position.x
			tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(card, "position:x", card.start_x + 20, .1).set_trans(Tween.TRANS_SINE)
			tween.tween_property(card, "position:x", card.start_x - 20, .1).set_trans(Tween.TRANS_SINE)
			tween.tween_property(card, "position:x", card.start_x, .1).set_trans(Tween.TRANS_SINE),
		)



func get_shop_cards() -> Array[CardVisual]:
	return card_container.get_children() as Array[CardVisual]

func _on_leave_button_pressed() -> void:
	self.visible = false

func _buy_and_handle_animation(handle_buy: Callable, price: int, handle_reject = null):

	if CurrencyManager.subtract_money(price):
		animation_state.set_animation("store_purchase", false, 0)
		animation_state.add_animation("store_normal", 1, true, 0)
		handle_buy.call()
	else:
		animation_state.set_animation("store_no_money", false, 0)
		animation_state.add_animation("store_normal", 1, true, 0)
		if handle_reject:
			handle_reject.call()


func _on_buy_health_button_pressed() -> void:
	_buy_and_handle_animation(
		func():
			buy_health_button.disabled = true
			player.unit.add_health_percentage(50),
		10
		)
