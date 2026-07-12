class_name CardVisual
extends Control

@export var card_data: CardData

var owner_slot: Slot

@onready var sticker: TextureRect = $Sticker
@onready var name_label: Label = $MarginContainer2/NameLabel
@onready var description_label: RichTextLabel = $MarginContainer3/DescriptionLabel

func _ready() -> void:
	add_to_group("cards")
	name_label.text = card_data.display_name
	description_label.text = card_data.description
	sticker.texture = card_data.art
	custom_minimum_size = Vector2(128, 180)


func set_owner_slot(slot: Slot) -> void:
	owner_slot = slot


func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := duplicate() as Control
	preview.modulate.a = 0.75
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_set_slots_highlighted(false)



func _set_slots_highlighted(active: bool) -> void:
	for slot in get_tree().get_nodes_in_group("card_slots"):
		if slot is Slot:
			slot.set_highlighted(active)
