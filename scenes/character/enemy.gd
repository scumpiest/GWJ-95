class_name Enemy
extends Node2D

@export var starting_health: int = 30

@onready var _sprite: SpineSprite = $SpineSprite

var unit: Unit


func _ready() -> void:
	_init_unit()
	_sprite.get_animation_state().set_animation("idle", true, 0)


func _init_unit() -> void:
	unit = Unit.new()
	unit.id = 1
	unit.name = "Enemy 1"
	unit.health = starting_health
	unit.max_health = starting_health
	unit.block = 0
	unit.power = 0
	unit.statuses = {}


func play_idle_pose() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)
