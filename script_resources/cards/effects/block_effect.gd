class_name BlockEffect
extends CardEffect


func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	var amount: int = compute_value(context, slot)
	if amount <= 0:
		return

	context.player.gain_block(amount)
