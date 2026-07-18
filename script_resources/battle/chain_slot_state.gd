class_name ChainSlotState
extends RefCounted

# if the slot is not a repeat target, the value is -1
const NO_REPEAT_TARGET: int = -1

var slot_index: int
var activation_count: int = 1
var card: CardData
# color after mutation
var card_color: CardEnums.CardColor = CardEnums.CardColor.RED
var power: int
var destroyed: bool
var skip_activation: bool = false
var repeat_target_index: int = NO_REPEAT_TARGET


func from_slot(index: int, slot: Slot) -> ChainSlotState:
	var state := ChainSlotState.new()
	state.slot_index = index

	var card_visual := slot.get_card()
	if card_visual == null:
		return state

	var card_data := card_visual.card_data
	state.card = card_data
	state.card_color = card_data.card_color
	state.power = 0
	state.destroyed = false
	return state


func is_empty() -> bool:
	return card == null


func is_active() -> bool:
	return card != null and not destroyed


func get_previous_slot(index: int) -> int:
	return index - 1


func get_next_slot(index: int) -> int:
	return index + 1
