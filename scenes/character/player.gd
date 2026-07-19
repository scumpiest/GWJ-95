class_name Player
extends Node2D

const POSE_COUNT := 7
const StatusIconRowScene := preload("res://scenes/ui/status_icon_row.gd")

@export var starting_health: int = 50

@onready var _sprite: SpineSprite = $SpineSprite
@onready var _health_bar: ProgressBar = $HealthBar/ProgressBar
@onready var _status_row = get_node_or_null("HealthBar/StatusRow")

var unit: Unit
var _pose_index: int = 0
var _last_block: int = 0


func _ready() -> void:
	_init_unit()
	_ensure_status_row()
	unit.block_changed.connect(_handle_block_changed)
	unit.health_changed.connect(_health_decreased)
	unit.health_changed.connect(_update_health_bar)
	_update_health_bar(unit.health, unit.health)
	_status_row.bind_unit(unit)
	_sprite.get_animation_state().set_animation("idle", true, 0)

func _health_decreased(health: int, old_health: int):
	if old_health > health:
		LevelManager.send_task_event(BattleTask.EventType.DAMAGE_TAKEN, old_health - health)

func _update_health_bar(health: int, _old_health: int) -> void:
	_health_bar.max_value = unit.max_health
	_health_bar.value = health

func _handle_block_changed(block: int):
	if block > _last_block:
		AudioManager.play_player_shield_activate()
	_last_block = block
	LevelManager.send_task_event(BattleTask.EventType.BLOCK_GAINED, block)


func _init_unit() -> void:
	unit = Unit.new()
	unit.id = 0
	unit.name = "Player"
	unit.health = starting_health
	unit.max_health = starting_health
	unit.block = 0


func play_idle_pose() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)


func play_next_pose() -> void:
	var next_pose := randi_range(1, POSE_COUNT)
	while next_pose == _pose_index:
		next_pose = randi_range(1, POSE_COUNT)
	_pose_index = next_pose
	_sprite.get_animation_state().set_animation("pose%d" % _pose_index, false, 0)


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
		_status_row.position = Vector2(-80, -520)
