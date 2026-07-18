class_name AddBlockEqualToDamageEffect
extends CardEffect


func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	if not meets_condition(context, slot):
		return

	var damage_dealt: int = slot.last_damage_dealt
	if damage_dealt <= 0:
		return

	context.player.gain_block(damage_dealt)
