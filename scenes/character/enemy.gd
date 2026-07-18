class_name Enemy
extends Node2D

@export var move_list: Dictionary = { "damage": 10, "block": 3 }
@export var move_chance: Dictionary = {
	"damage": 0.75,
	"block": 0.25,
}

@onready var _sprite: SpineSprite = $SpineSprite
@onready var _hp: Label = $HP

var unit: Unit


func _ready() -> void:
	unit.health_changed.connect(_on_health_changed)
	unit.status_changed.connect(_on_status_changed)
	unit.block_changed.connect(_on_block_changed)

	if _sprite.skeleton_data_res.find_animation("appear"):
		_sprite.get_animation_state().set_animation("appear", false, 0)
		_sprite.get_animation_state().add_animation("idle", 4, true, 0)
	else:
		_sprite.get_animation_state().set_animation("idle", true, 0)
	_update_hp_display()

func roll_intent() -> String:
	var roll: float = randf()
	var accumulator: float = 0.0
	for intent: String in move_list:
		accumulator += move_chance[intent]
		if roll <= accumulator:
			return intent
	return "damage"

func play_idle_pose() -> void:
	_sprite.get_animation_state().set_animation("idle", true, 0)


func _on_health_changed(_health: int) -> void:
	_update_hp_display()


func _on_status_changed(_status: String, _stacks: int) -> void:
	_update_hp_display()


func _on_block_changed(_block: int) -> void:
	_update_hp_display()


func _update_hp_display() -> void:
	var lines: PackedStringArray = ["HP: %s/%s" % [unit.health, unit.max_health]]
	if unit.block > 0:
		lines.append("BLK: %s" % unit.block)
	for status_name: String in unit.statuses:
		var stacks: int = unit.statuses[status_name]
		if stacks > 0:
			lines.append("%s: %s" % [status_name.substr(0, 3).to_upper(), stacks])
	_hp.text = "\n".join(lines)
