class_name Slot
extends PanelContainer

signal card_changed(card: CardVisual)

@export var highlight_color: Color = Color.WHITE

@onready var _anchor: CenterContainer = $CardAnchor
@onready var _inactive_overlay: TextureRect = $InactiveOverlay

var color: CardEnums.CardColor

var _outline_material: ShaderMaterial
var _base_panel_style: StyleBoxFlat
var _activation_panel_style: StyleBoxFlat


#tweens
var tween: Tween
var scale_x_range: float = 1.5 #range?
var scale_x_duration: float = 0.2 #seconds?
var scale_y_range: float = 1.5 #range?
var scale_y_duration: float = 0.2 #seconds?
var rotation_degrees_1: float = 5.0 #degrees
var rotation_degrees_2: float = 1.0 #degrees
var rotation_duration: float = 0.2 #seconds?
var rotation_back_delay: float = 0.3 #seconds


var previous_card_slot: Slot
var next_card_slot: Slot

const CASSETTE_VFX_Z_INDEX := 1 # behind the card (z_index 10) but above the slot panel


func _ready() -> void:
	add_to_group("card_slots")
	var parent := get_parent()
	var siblings := parent.get_children()
	var card_index := siblings.find(self)

	if card_index > 0 and siblings[card_index - 1] is Slot:
		previous_card_slot = siblings[card_index - 1]
	if card_index >= 0 and card_index < siblings.size() - 1 and siblings[card_index + 1] is Slot:
		next_card_slot = siblings[card_index + 1]


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

func next_card() -> CardData:
	if next_card_slot == null:
		return null
	var card_visual := next_card_slot.get_card()
	if card_visual:
		return card_visual.card_data
	return null

func prev_card() -> CardData:
	if previous_card_slot == null:
		return null
	var card_visual := previous_card_slot.get_card()
	if card_visual:
		return card_visual.card_data
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
	if card == null or not is_instance_valid(card):
		return

	var existing := get_card()
	if existing == card:
		return

	if existing:
		_anchor.remove_child(existing)
		existing.set_owner_slot(null)

	if card.get_parent() != _anchor:
		if card.get_parent() != null:
			card.reparent(_anchor, false)
		else:
			_anchor.add_child(card)

	card.set_owner_slot(self)
	color = card.card_data.card_color
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
	_apply_drop.call_deferred(card, displaced, from_slot, from_container)
	set_highlighted(true)


func _apply_drop(
	card: CardVisual,
	displaced: CardVisual,
	from_slot: Slot,
	from_container: Node,
) -> void:
	set_card(card)

	if displaced:
		AudioManager.play_card_swapped()
	else:
		AudioManager.play_card_placed()

	if from_slot:
		if displaced:
			from_slot.set_card(displaced)
	elif displaced and from_container and is_instance_valid(from_container):
		if displaced.get_parent() != from_container:
			if displaced.get_parent() != null:
				displaced.reparent(from_container, false)
			else:
				from_container.add_child(displaced)
		displaced.set_owner_slot(null)


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


func set_skipped(active: bool) -> void:
	if _inactive_overlay == null:
		return
	_inactive_overlay.visible = active


func play_cassette_vfx(card_color: CardEnums.CardColor) -> void:
	var animation_name := TriggerVfx.animation_for_cassette_color(card_color)
	TriggerVfx.spawn(self, animation_name, size * 0.5, CASSETTE_VFX_Z_INDEX)

func _process(_delta: float) -> void:
	
	if  Input.is_action_just_pressed("tweens_in"):
		make_slot_jiggle()
		
	if  Input.is_action_just_pressed("tweens_out"):
		stop_slot_jiggle()
	

func make_slot_jiggle():
	if tween and tween.is_running():
		tween.kill()
		
		
	tween = create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale:x", scale_x_range, scale_x_duration)
	tween.parallel().tween_property(self, "scale:y", scale_y_range, scale_y_duration)
	tween.parallel().tween_property(self, "rotation_degrees", rotation_degrees_1 * rotation_degrees_2 * [-1,0, 1.0].pick_random(), rotation_duration)
	tween.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation_degrees", 0.0, rotation_duration).set_delay(rotation_back_delay)
	
	
func stop_slot_jiggle():
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	
	tween.tween_property(self, "scale:x", 1.0, scale_x_duration)
	tween.parallel().tween_property(self, "scale:y", 1.0, scale_y_duration)
	tween.parallel().tween_property(self, "rotation_degrees", 0.0, rotation_duration)

	
