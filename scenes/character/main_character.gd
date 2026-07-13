class_name MainCharacter
extends Node2D

const POSE_COUNT := 4

@onready var _sprite: SpineSprite = $SpineSprite

var _pose_index: int = 0


func _ready() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)


func play_idle_pose() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)

# TODO: this is a temporary function to test the character animation
func play_next_pose() -> void:
	_pose_index = (_pose_index % POSE_COUNT) + 1
	_sprite.get_animation_state().set_animation("pose%d" % _pose_index, false, 0)
