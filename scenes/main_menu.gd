extends Node2D

@onready var _sprite: SpineSprite = $SpineSprite

func _ready() -> void:
	_sprite.get_animation_state().set_animation("animation", true, 0)
