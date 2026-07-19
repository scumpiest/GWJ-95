extends Node

var levels_resource: Levels = load("res://resources/levels/levels.tres")
var levels: Array[Level]
var current_level: Level
var main: Main

# Set by the main menu right before switching to the game scene so the first
# level starts in tutorial mode.
var start_as_tutorial: bool = false

signal next_level
signal task_state_changed(state: BattleTask.State)

func _ready() -> void:
	main = get_node_or_null("/root/Main")
	levels = levels_resource.levels
	next_level.connect(_next_level)


# Called when returning to the main menu (after a win or a loss) so the next
# run starts back at the first level instead of indexing past LBOSS.
func reset() -> void:
	current_level = null

func send_task_event(event, data = null):
	if current_level and current_level.task:
		var current_task_state = current_level.task.on_event(event, data)
		current_level.task.current_state = current_task_state
		print(current_task_state)
		task_state_changed.emit(current_task_state)

func _next_level() -> void:
	# Rewards for next level :)
	if current_level and current_level.type == Level.LevelType.GAME:
		var money_to_add = 20
		if current_level.task and current_level.task.current_state == BattleTask.State.COMPLETED:
			money_to_add += 10
			AudioManager.play_task_completed()
		CurrencyManager.add_money(money_to_add)
	if !current_level:
		current_level = levels[0]
	else:
		var current_level_index := levels.find(current_level)
		var new_level_index = current_level_index + 1
		if current_level_index != -1 and new_level_index < (levels.size() + 1):
			current_level = levels[new_level_index]

	AudioManager.play_music_for_level(current_level.type)

func get_current_enemy() -> Unit:
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
