class_name CardVisual
extends Control

const HAND_SIZE := Vector2(128, 180)
const CHAIN_SIZE := Vector2(122, 79)
const ACTIVATION_DURATION := 0.5
const ACTIVATION_HIGHLIGHT := Color(1.45, 1.35, 1.0)

@export var card_data: CardData

@onready var casette: Control = $Casette
@onready var paper: Control = $Paper
@onready var _description_label: RichTextLabel = $Paper/MarginContainer3/DescriptionLabel
@onready var _sticker: TextureRect = $Casette/Sticker
@onready var _name_label: Label = $Casette/MarginContainer2/CardName

var owner_slot: Slot
var shop_card: bool = false
var cost_label: Label
var tween: Tween
var img_metadata_regex: RegEx
var start_x: int

signal clicked_card(CardVisual)

func _ready() -> void:
	# Pivot point is for the animation so it's centered
	self.pivot_offset = self.get_rect().size/2
	cost_label = get_node("CostLabel")
	if shop_card:
		cost_label.text = str(card_data.cost) + "$"
	else:
		set_shop_card(false)

	add_to_group("cards")
	_bind_card_data()
	_apply_display_mode(false)
	casette.mouse_entered.connect(_on_casette_mouse_entered)
	casette.mouse_exited.connect(_on_casette_mouse_exited)
	_description_label.meta_hover_started.connect(_on_description_meta_hover_started)
	_description_label.meta_hover_ended.connect(_on_description_meta_hover_ended)

func set_shop_card(is_shop_card: bool):
	shop_card = is_shop_card
	if !is_shop_card:
		cost_label.visible = false
	else:
		cost_label.visible = true


func _gui_input(event):
	if shop_card and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			clicked_card.emit(self)
			set_casette_highlighted(true)

func _bind_card_data() -> void:
	if card_data == null:
		return
	_description_label.text = icon_metadata(card_data.description)
	_sticker.texture = card_data.art
	_name_label.text = card_data.display_name


func icon_metadata(description: String) -> String:
	if img_metadata_regex == null:
		img_metadata_regex = RegEx.new()
		img_metadata_regex.compile("\\[img([^\\]]*)\\](res://[^\\[]+)\\[/img\\]")
	var result := description
	for match in img_metadata_regex.search_all(description):
		var full := match.get_string()
		var path := match.get_string(2)
		var key := path.get_file().get_basename()
		result = result.replace(full, "[url=%s]%s[/url]" % [key, full])
	return result


func get_icon_tooltip() -> IconTooltip:
	return get_tree().get_first_node_in_group("icon_tooltip") as IconTooltip


func _on_description_meta_hover_started(meta: Variant) -> void:
	var tooltip := get_icon_tooltip()
	if tooltip == null:
		return
	tooltip.show_for(str(meta))


func _on_description_meta_hover_ended(_meta: Variant) -> void:
	var tooltip := get_icon_tooltip()
	if tooltip != null:
		tooltip.hide_tooltip()


func set_owner_slot(slot: Slot) -> void:
	owner_slot = slot
	_apply_display_mode(owner_slot != null)


func _apply_display_mode(in_chain: bool) -> void:
	$Paper.visible = not in_chain # copies doesnt run _ready() so we need to set the refs here
	custom_minimum_size = CHAIN_SIZE if in_chain else HAND_SIZE


func _get_drag_data(_at_position: Vector2) -> Variant:
	if(shop_card):
		return
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
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.1, .2).set_trans(Tween.TRANS_SINE)

	self.z_index = 100

	set_casette_highlighted(true)


func _on_casette_mouse_exited() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, .1).set_trans(Tween.TRANS_SINE)

	if owner_slot != null:
		paper.visible = false

	self.z_index = 10
	set_casette_highlighted(false)
	var tooltip := get_icon_tooltip()
	if tooltip != null:
		tooltip.hide_tooltip()
