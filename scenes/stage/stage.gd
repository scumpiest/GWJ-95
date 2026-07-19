class_name Stage
extends Node2D

const DESIGN_SIZE := Vector2(1152, 648)
const BASE_SCALE := 0.56

@onready var _sprite: SpineSprite = $SpineSprite


func _ready() -> void:
	LevelManager.next_level.connect(_check_boss_level)
	_sprite.get_animation_state().set_animation("normal_level", true, 0)
	_fit_to_viewport()
	get_viewport().size_changed.connect(_fit_to_viewport)


func _fit_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	scale = Vector2(BASE_SCALE, BASE_SCALE) * scale_factor


func _check_boss_level() -> void:
	if LevelManager.current_level.type == Level.LevelType.BOSS:
		_sprite.get_animation_state().set_animation("boss_cutscene", false, 0)
		_sprite.get_animation_state().add_animation("bossl_level", 4, true, 0)
