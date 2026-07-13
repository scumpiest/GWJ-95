class_name CardVisual
extends Control

const HAND_SIZE := Vector2(128, 180)
const CHAIN_SIZE := Vector2(122, 79)
const ACTIVATION_DURATION := 0.35
const ACTIVATION_HIGHLIGHT := Color(1.45, 1.35, 1.0)

@export var card_data: CardData

@onready var casette: Control = $Casette
@onready var paper: Control = $Paper
@onready var _description_label: RichTextLabel = $Paper/MarginContainer3/DescriptionLabel
@onready var _sticker: TextureRect = $Casette/Sticker
@onready var _name_label: Label = $Casette/MarginContainer2/CardName

var owner_slot: Slot


func _ready() -> void:
	add_to_group("cards")
	_bind_card_data()
	_apply_display_mode(false)
	casette.mouse_entered.connect(_on_casette_mouse_entered)
	casette.mouse_exited.connect(_on_casette_mouse_exited)


func _bind_card_data() -> void:
	if card_data == null:
		return
	_description_label.text = card_data.description
	_sticker.texture = card_data.art
	_name_label.text = card_data.display_name


func set_owner_slot(slot: Slot) -> void:
	owner_slot = slot
	_apply_display_mode(owner_slot != null)


func _apply_display_mode(in_chain: bool) -> void:
	$Paper.visible = not in_chain # copies doesnt run _ready() so we need to set the refs here
	custom_minimum_size = CHAIN_SIZE if in_chain else HAND_SIZE


func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := duplicate() as CardVisual
	preview.modulate.a = 0.75
	preview.set_owner_slot(owner_slot)
	set_drag_preview(preview)
	_set_slots_highlighted(true)
	return {
		"card": self,
		"from_slot": owner_slot,
		"from_container": get_parent(),
	}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if owner_slot == null:
		return false
	var card: CardVisual = data.get("card") if data is Dictionary else null
	return card != null and card != self


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	owner_slot._drop_data(_at_position, data)

func activate() -> void:
	if owner_slot != null:
		owner_slot.set_activation_highlighted(true)
	set_activation_highlighted(true)
	await get_tree().create_timer(ACTIVATION_DURATION).timeout
	set_activation_highlighted(false)
	if owner_slot != null:
		owner_slot.set_activation_highlighted(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_set_slots_highlighted(false)


func _set_slots_highlighted(active: bool) -> void:
	for slot in get_tree().get_nodes_in_group("card_slots"):
		if slot is Slot:
			slot.set_highlighted(active)

func set_casette_highlighted(active: bool) -> void:
	var tint := Color(1.2, 1.15, 1.0) if active else Color.WHITE
	casette.modulate = tint
	_sticker.modulate = tint


func set_activation_highlighted(active: bool) -> void:
	var tint := ACTIVATION_HIGHLIGHT if active else Color.WHITE
	casette.modulate = tint
	_sticker.modulate = tint
	modulate = Color(1.08, 1.08, 1.02) if active else Color.WHITE

func _on_casette_mouse_entered() -> void:
	if owner_slot != null:
		paper.visible = true
	set_casette_highlighted(true)

func _on_casette_mouse_exited() -> void:
	if owner_slot != null:
		paper.visible = false
	set_casette_highlighted(false)
