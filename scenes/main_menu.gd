extends Control

const MAIN_SCENE_PATH := "res://main.tscn"
const DESIGN_SIZE := Vector2(1152, 648)
const SPRITE_BASE_SCALE := 0.6

@onready var _sprite: SpineSprite = $SpineSprite

func _ready() -> void:
	_sprite.get_animation_state().set_animation("animation", true, 0)
	AudioManager.play_menu_music()
	_fit_to_viewport()
	get_viewport().size_changed.connect(_fit_to_viewport)


func _fit_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	_sprite.position = Vector2.ZERO
	_sprite.scale = Vector2(SPRITE_BASE_SCALE, SPRITE_BASE_SCALE) * scale_factor


func _on_texture_button_pressed() -> void:
	AudioManager.play_ui_click()
	LevelManager.start_as_tutorial = true
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
