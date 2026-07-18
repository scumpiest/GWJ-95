class_name Stage
extends Node2D

@onready var _sprite: SpineSprite = $SpineSprite


func _ready() -> void:
	LevelManager.next_level.connect(_check_boss_level)
	_sprite.get_animation_state().set_animation("normal_level", true, 0)

func _check_boss_level() -> void:
	if LevelManager.current_level.type == Level.LevelType.BOSS:
		_sprite.get_animation_state().set_animation("boss_cutscene", false, 0)
		_sprite.get_animation_state().add_animation("bossl_level", 4, true, 0)
