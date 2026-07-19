class_name GainBlockTask
extends BattleTask

var block_gained := 0

func _init() -> void:
	description = "Gain 20 block in 1 turn"

func on_event(event: EventType, data = null) -> State:
	if current_state == State.COMPLETED:
		return State.COMPLETED

	if event == EventType.BLOCK_GAINED:
		block_gained += data
	
	if event == EventType.TURN_END:
		if block_gained >= 20:
			current_state = State.COMPLETED
			return current_state
		else:
			block_gained = 0

	current_state = State.ACTIVE
	return current_state
