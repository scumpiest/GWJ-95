class_name MainCharacter
extends Node2D

const POSE_COUNT := 7

@onready var _sprite: SpineSprite = $SpineSprite

var _pose_index: int = 0

func _ready() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)


func play_idle_pose() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)


func play_next_pose() -> void:
	var next_pose := randi_range(1, POSE_COUNT)
	while next_pose == _pose_index:
		next_pose = randi_range(1, POSE_COUNT)
	_pose_index = next_pose
	_sprite.get_animation_state().set_animation("pose%d" % _pose_index, false, 0)