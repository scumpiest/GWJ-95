class_name StatusIconRow
extends HBoxContainer

const STATUS_ICON_SIZE := Vector2(48, 48)

const ICON_BLOCK := preload("res://assets/sprites/icons/block.png")
const ICON_VULNERABLE := preload("res://assets/sprites/icons/vulnerability.png")
const ICON_WEAKNESS := preload("res://assets/sprites/icons/weakness.png")
const ICON_PROTECTION := preload("res://assets/sprites/icons/protection.png")
const ICON_STRENGTH := preload("res://assets/sprites/icons/strength.png")

const STATUS_ICONS := {
	"vulnerable": ICON_VULNERABLE,
	"weakness": ICON_WEAKNESS,
	"protection": ICON_PROTECTION,
	"strength": ICON_STRENGTH,
}

const STATUS_TOOLTIP_KEYS := {
	"vulnerable": "vulnerability",
	"weakness": "weakness",
	"protection": "protection",
	"strength": "strength",
}

var _unit: Unit


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 4)


func bind_unit(unit: Unit) -> void:
	if _unit != null:
		if _unit.block_changed.is_connected(_on_block_changed):
			_unit.block_changed.disconnect(_on_block_changed)
		if _unit.status_changed.is_connected(_on_status_changed):
			_unit.status_changed.disconnect(_on_status_changed)

	_unit = unit
	if _unit == null:
		_clear_icons()
		visible = false
		return

	_unit.block_changed.connect(_on_block_changed)
	_unit.status_changed.connect(_on_status_changed)
	refresh()


func refresh() -> void:
	_clear_icons()
	if _unit == null:
		visible = false
		return

	var has_any := false

	if _unit.block > 0:
		_add_entry(ICON_BLOCK, str(_unit.block), "block")
		has_any = true

	for status_key in ["vulnerable", "weakness", "protection", "strength"]:
		var stacks: int = _unit.statuses.get(status_key, 0)
		if stacks <= 0:
			continue
		var texture: Texture2D = STATUS_ICONS.get(status_key)
		var tooltip_key: String = STATUS_TOOLTIP_KEYS.get(status_key, status_key)
		var label := str(stacks) if stacks > 1 else ""
		_add_entry(texture, label, tooltip_key)
		has_any = true

	visible = has_any


func _on_block_changed(_block: int) -> void:
	refresh()


func _on_status_changed(_status: String, _stacks: int) -> void:
	refresh()


func _clear_icons() -> void:
	for child in get_children():
		child.free()


func _add_entry(texture: Texture2D, value_text: String, tooltip_key: String) -> void:
	var entry := Control.new()
	entry.custom_minimum_size = STATUS_ICON_SIZE
	entry.mouse_filter = Control.MOUSE_FILTER_STOP
	entry.mouse_entered.connect(_on_entry_mouse_entered.bind(tooltip_key))
	entry.mouse_exited.connect(_on_entry_mouse_exited)

	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_child(icon)

	if not value_text.is_empty():
		var label := Label.new()
		label.text = value_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.offset_right = 2.0
		label.offset_bottom = 1.0
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 5)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		entry.add_child(label)

	add_child(entry)


func _on_entry_mouse_entered(tooltip_key: String) -> void:
	var tooltip := _get_icon_tooltip()
	if tooltip != null:
		tooltip.show_for(tooltip_key)


func _on_entry_mouse_exited() -> void:
	var tooltip := _get_icon_tooltip()
	if tooltip != null:
		tooltip.hide_tooltip()


func _get_icon_tooltip() -> IconTooltip:
	return get_tree().get_first_node_in_group("icon_tooltip") as IconTooltip
