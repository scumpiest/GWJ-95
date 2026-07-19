class_name Player
extends Node2D

const POSE_COUNT := 7

@export var starting_health: int = 50

@onready var _sprite: SpineSprite = $SpineSprite

var unit: Unit
var _pose_index: int = 0


func _ready() -> void:
	_init_unit()
	unit.block_changed.connect(_handle_block_changed)
	unit.health_changed.connect(_health_decreased)
	_sprite.get_animation_state().set_animation("idle", true, 0)

func _health_decreased(health: int, old_health: int):
	if old_health > health:
		LevelManager.send_task_event(BattleTask.EventType.DAMAGE_TAKEN, old_health - health)

func _handle_block_changed(block: int):
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
