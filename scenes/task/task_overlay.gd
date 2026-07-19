extends Node2D

@onready var task_description_label: Label = %TaskDescription

var _last_task_state: BattleTask.State = BattleTask.State.ACTIVE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.next_level.connect(_on_next_level)
	LevelManager.task_state_changed.connect(_task_state)

func _on_next_level() -> void:
	_last_task_state = BattleTask.State.ACTIVE
	if LevelManager.current_level.task:
		task_description_label.text = LevelManager.current_level.task.description
	else:
		task_description_label.text = ""

func _task_state(state: BattleTask.State):
	print('called??' + BattleTask.State.keys()[state])
	if state == BattleTask.State.COMPLETED and _last_task_state != BattleTask.State.COMPLETED:
		AudioManager.play_task_succeed()
	_last_task_state = state
	if state == BattleTask.State.COMPLETED:
		task_description_label.label_settings.font_color = '#00ff00'
	else:
		task_description_label.label_settings.font_color = '#fff'

