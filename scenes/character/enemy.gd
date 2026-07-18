class_name Enemy
extends Node2D

@export var starting_health: int = 30
@export var move_list: Dictionary = { "damage": 10, "block": 3 }
@export var move_chance: Dictionary = {
	"damage": 0.75,
	"block": 0.25,
}

@onready var _sprite: SpineSprite = $SpineSprite
@onready var _hp: Label = $HP

var unit: Unit


func _ready() -> void:
	_init_unit()
	unit.health_changed.connect(_on_health_changed)
	_sprite.get_animation_state().set_animation("idle", true, 0)
	_hp.text = "HP: %s" % unit.health


func _init_unit() -> void:
	unit = Unit.new()
	unit.id = 1
	unit.name = "Enemy 1"
	unit.health = starting_health
	unit.max_health = starting_health
	unit.block = 0


func play_idle_pose() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)


func _on_health_changed(health: int) -> void:
	_hp.text = "HP: %s" % health
