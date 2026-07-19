class_name BattleResultScreen
extends Control

signal continue_pressed

const VICTORY_ANIMATION := "victory"
const DEFEAT_ANIMATION := "defeat"

@onready var _sprite: SpineSprite = $SpineSprite
@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	visible = false
	_continue_button.pressed.connect(_on_continue_pressed)
	_continue_button.mouse_entered.connect(AudioManager.play_ui_hover)


func show_victory() -> void:
	_show_result(VICTORY_ANIMATION)


func show_defeat() -> void:
	_show_result(DEFEAT_ANIMATION)


func _show_result(animation_name: String) -> void:
	_sprite.get_animation_state().set_animation(animation_name, false, 0)
	visible = true


func _on_continue_pressed() -> void:
	AudioManager.play_ui_click()
	visible = false
	continue_pressed.emit()
