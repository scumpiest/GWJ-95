class_name SkipAfterEffect
extends CardEffect



func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	for i in range(slot.slot_index + 2, context.chain_slot_states.size()):
		var next_slot: ChainSlotState = context.chain_slot_states[i]
		if next_slot.is_active():
			next_slot.skip_activation = true
