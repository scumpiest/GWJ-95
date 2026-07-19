class_name BattleTask
extends Resource

enum EventType {
    BLOCK_GAINED,
    DEAL_DAMAGE,
    CARD_COLOR_ROW_TASK,
    DAMAGE_TAKEN,
    TURN_START,
    TURN_END,
    BATTLE_END
}

enum State {
    ACTIVE,
    COMPLETED,
    FAILED
}

var description: String
var current_state: State = State.ACTIVE

func on_event(event: EventType, data = null) -> State:
    return State.ACTIVE
