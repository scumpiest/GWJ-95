class_name AddExtraActivationsEffect
extends CardEffect

# target the next slot
@export var extra_count: int = 1




func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	var next_index: int = slot.slot_index + 1

	if next_index >= context.chain_slot_states.size():
		return

	var next_slot: ChainSlotState = context.chain_slot_states[next_index]

	if not next_slot.is_active():
		return

	next_slot.activation_count += extra_count