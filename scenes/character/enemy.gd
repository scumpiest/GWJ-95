class_name Enemy
extends Node2D

const INTENT_ICON_SIZE := Vector2(72, 72)
const StatusIconRowScene := preload("res://scenes/ui/status_icon_row.gd")

const ICON_DAMAGE := preload("res://assets/sprites/icons/damage.png")
const ICON_BLOCK := preload("res://assets/sprites/icons/block.png")
const ICON_WEAKNESS := preload("res://assets/sprites/icons/weakness.png")
const ICON_VULNERABILITY := preload("res://assets/sprites/icons/vulnerability.png")

@onready var _sprite: SpineSprite = $SpineSprite
@onready var _health_bar: ProgressBar = get_node_or_null("HealthBar/ProgressBar")
@onready var _intent_row: HBoxContainer = get_node_or_null("HealthBar/IntentRow")
@onready var _status_row = get_node_or_null("HealthBar/StatusRow")

var unit: Unit
var enemy_data: EnemyResource


func _ready() -> void:
	unit.health_changed.connect(_on_health_changed)
	_ensure_intent_row()
	_ensure_status_row()
	_status_row.bind_unit(unit)
	GameManager.enemy_intent_changed.connect(set_intent)

	if _sprite.skeleton_data_res.find_animation("appear"):
		_sprite.get_animation_state().set_animation("appear", false, 0)
		_sprite.get_animation_state().add_animation("idle", 4, true, 0)
	else:
		_sprite.get_animation_state().set_animation("idle", true, 0)
	_update_health_bar()

	if GameManager.context != null:
		set_intent(GameManager.context.enemy_intent)


func _exit_tree() -> void:
	if GameManager.enemy_intent_changed.is_connected(set_intent):
		GameManager.enemy_intent_changed.disconnect(set_intent)


func roll_intent() -> EnemyMove:
	if enemy_data == null:
		return null
	return enemy_data.roll_move()


func set_intent(move: EnemyMove) -> void:
	_ensure_intent_row()
	_clear_intent_icons()
	if _intent_row == null:
		return

	var has_intent := (
		move != null
		and (move.deals_damage() or move.gains_block() or move.applies_status())
	)
	_intent_row.visible = has_intent
	if not has_intent:
		return

	var turn: int = GameManager.context.current_turn if GameManager.context else 1
	var damage_bonus: int = enemy_data.get_turn_damage_bonus(turn) if enemy_data else 0
	var block_bonus: int = enemy_data.get_turn_block_bonus(turn) if enemy_data else 0

	if move.deals_damage():
		var hit_damage: int = move.damage + damage_bonus
		var label := str(hit_damage)
		if move.hit_count > 1:
			label = "%sx%d" % [hit_damage, move.hit_count]
		_add_intent_entry(ICON_DAMAGE, label)

	if move.gains_block():
		_add_intent_entry(ICON_BLOCK, str(move.block + block_bonus))

	if move.apply_weakness > 0:
		var weakness_label := str(move.apply_weakness) if move.apply_weakness > 1 else ""
		_add_intent_entry(ICON_WEAKNESS, weakness_label)

	if move.apply_vulnerable > 0:
		var vulnerable_label := str(move.apply_vulnerable) if move.apply_vulnerable > 1 else ""
		_add_intent_entry(ICON_VULNERABILITY, vulnerable_label)

func play_idle_pose() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)


func _on_health_changed(_health: int, _old_health: int) -> void:
	_update_health_bar()


func _update_health_bar() -> void:
	if _health_bar != null:
		_health_bar.max_value = unit.max_health
		_health_bar.value = unit.health
		return

	var hp_label := get_node_or_null("HP") as Label
	if hp_label != null:
		hp_label.text = "HP: %d/%d" % [unit.health, unit.max_health]


func _ensure_intent_row() -> void:
	if _intent_row != null:
		return

	var health_bar_root := get_node_or_null("HealthBar") as Control
	_intent_row = HBoxContainer.new()
	_intent_row.name = "IntentRow"
	_intent_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_intent_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intent_row.add_theme_constant_override("separation", 8)

	if health_bar_root != null:
		health_bar_root.add_child(_intent_row)
		_intent_row.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		_intent_row.offset_left = 40.0
		_intent_row.offset_top = -140.0
		_intent_row.offset_right = 0.0
		_intent_row.offset_bottom = -52.0
	else:
		add_child(_intent_row)
		_intent_row.position = Vector2(-80, -700)
		_intent_row.custom_minimum_size = Vector2(160, 64)


func _ensure_status_row() -> void:
	if _status_row != null:
		return

	_status_row = StatusIconRowScene.new()
	_status_row.name = "StatusRow"
	var health_bar_root := get_node_or_null("HealthBar") as Control
	if health_bar_root != null:
		health_bar_root.add_child(_status_row)
		_status_row.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		_status_row.offset_left = 40.0
		_status_row.offset_top = -44.0
		_status_row.offset_right = 0.0
		_status_row.offset_bottom = 8.0
	else:
		add_child(_status_row)
		_status_row.position = Vector2(-80, -560)
		_status_row.custom_minimum_size = Vector2(160, 48)


func _clear_intent_icons() -> void:
	if _intent_row == null:
		return
	for child in _intent_row.get_children():
		child.free()


func _add_intent_entry(texture: Texture2D, value_text: String) -> void:
	var entry := Control.new()
	entry.custom_minimum_size = INTENT_ICON_SIZE
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
		label.offset_right = 4.0
		label.offset_bottom = 2.0
		label.add_theme_font_size_override("font_size", 28)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 6)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		entry.add_child(label)

	_intent_row.add_child(entry)
