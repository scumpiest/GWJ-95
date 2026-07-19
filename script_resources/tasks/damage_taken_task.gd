class_name DamageTakenTask
extends BattleTask

var damage_dealt := 0

func _init() -> void:
	description = "Do not lose more than 20 hp in this battle";

func on_event(event: EventType, data = null) -> State:
	if current_state == State.COMPLETED:
		return State.COMPLETED

	if event == EventType.DAMAGE_TAKEN:
		damage_dealt += data
	
	if event == EventType.BATTLE_END:
		if damage_dealt >= 20:
			current_state = State.COMPLETED
			return current_state

	current_state = State.ACTIVE
	return current_state
