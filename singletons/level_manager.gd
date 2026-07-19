extends Node

var levels_resource: Levels = load("res://resources/levels/levels.tres")
var levels: Array[Level]
var current_level: Level
var main: Main

signal next_level

func _ready() -> void:
	main = get_node("/root/Main")
	levels = levels_resource.levels
	next_level.connect(_next_level)

func _next_level() -> void:
	# Default reward for next level
	if current_level and current_level.type == Level.LevelType.GAME:
		CurrencyManager.add_money(20)
	if !current_level:
		current_level = levels[0]
	else:
		var current_level_index := levels.find(current_level)
		var new_level_index = current_level_index + 1
		if current_level_index != -1 and new_level_index < (levels.size() + 1):
			current_level = levels[new_level_index]

func _get_current_enemy() -> Unit:
	var enemy_data := current_level.enemy_data
	var unit := Unit.new()
	unit.id = enemy_data.id
	unit.name = enemy_data.name
	unit.description = enemy_data.description
	unit.image = enemy_data.image
	unit.health = enemy_data.health
	unit.max_health = enemy_data.max_health
	unit.block = enemy_data.block

	return unit
