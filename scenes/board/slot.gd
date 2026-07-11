class_name Slot
extends PanelContainer

signal card_changed(card: CardVisual)

@export var highlight_color: Color = Color(1.0, 0.5, 0.0, 1.0)

@onready var _anchor: CenterContainer = $CardAnchor


func _ready() -> void:
	add_to_group("card_slots")
	mouse_filter = Control.MOUSE_FILTER_STOP


func get_card() -> CardVisual:
	for child in _anchor.get_children():
		if child is CardVisual:
			return child as CardVisual
	return null


func clear_card() -> CardVisual:
	var card := get_card()
	if card == null:
		return null

	_anchor.remove_child(card)
	card.set_owner_slot(null)
	card_changed.emit(null)
	return card


func set_card(card: CardVisual) -> void:
	if card == null:
		return

	var existing := get_card()
	if existing == card:
		return

	if existing:
		_anchor.remove_child(existing)
		existing.set_owner_slot(null)

	if card.get_parent():
		card.get_parent().remove_child(card)

	_anchor.add_child(card)
	card.set_owner_slot(self)
	card_changed.emit(card)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("card") is CardVisual


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var card: CardVisual = data.card
	var from_slot: Slot = data.get("from_slot")
	var from_container: Node = data.get("from_container")

	if card == get_card():
		return

	var displaced := get_card()
	set_card(card)

	if from_slot:
		if displaced:
			from_slot.set_card(displaced)
	elif displaced and from_container:
		from_container.add_child(displaced)
		displaced.set_owner_slot(null)

	set_highlighted(false)


func set_highlighted(active: bool) -> void:
	self_modulate = highlight_color if active else Color.WHITE
