class_name Slot
extends PanelContainer

signal card_changed(card: CardVisual)

@export var highlight_color: Color = Color.WHITE

@onready var _anchor: CenterContainer = $CardAnchor

var _outline_material: ShaderMaterial
var _base_panel_style: StyleBoxFlat
var _activation_panel_style: StyleBoxFlat


func _ready() -> void:
	add_to_group("card_slots")
	mouse_filter = Control.MOUSE_FILTER_STOP
	if material is ShaderMaterial:
		_outline_material = (material as ShaderMaterial).duplicate()
	material = null

	var panel_style := get_theme_stylebox("panel")
	if panel_style is StyleBoxFlat:
		_base_panel_style = (panel_style as StyleBoxFlat).duplicate()
		_activation_panel_style = _base_panel_style.duplicate()
		_activation_panel_style.border_color = Color(1.0, 0.85, 0.35, 1)
		_activation_panel_style.border_width_left = 3
		_activation_panel_style.border_width_top = 3
		_activation_panel_style.border_width_right = 3
		_activation_panel_style.border_width_bottom = 3

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

	set_highlighted(true)


func set_highlighted(active: bool) -> void:
	if _outline_material == null:
		return
	if active:
		_outline_material.set_shader_parameter("line_color", highlight_color)
		_outline_material.set_shader_parameter("line_thickness", 2)
		material = _outline_material
	else:
		material = null


func set_activation_highlighted(active: bool) -> void:
	if _base_panel_style == null:
		return
	add_theme_stylebox_override("panel", _activation_panel_style if active else _base_panel_style)
