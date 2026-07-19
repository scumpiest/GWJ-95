extends Node2D

const MAIN_SCENE_PATH := "res://main.tscn"

@onready var _sprite: SpineSprite = $SpineSprite

func _ready() -> void:
	_sprite.get_animation_state().set_animation("animation", true, 0)
	AudioManager.play_menu_music()


func _on_texture_button_pressed() -> void:
	AudioManager.play_ui_click()
	LevelManager.start_as_tutorial = true
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
