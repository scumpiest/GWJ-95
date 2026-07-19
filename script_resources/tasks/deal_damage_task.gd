class_name DealDamageTask
extends BattleTask

var damage_taken := 0

func _init() -> void:
	description = "Deal 20 damage in 1 turn";

func on_event(event: EventType, data = null) -> State:
	if current_state == State.COMPLETED:
		return State.COMPLETED

	if event == EventType.DAMAGE_TAKEN:
		damage_taken += data
	
	if event == EventType.BATTLE_END:
		if damage_taken <= 20:
			current_state = State.COMPLETED
			return current_state

	current_state = State.ACTIVE
	return current_state
