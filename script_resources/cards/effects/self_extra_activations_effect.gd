class_name SelfExtraActivationsEffect
extends CardEffect

@export var per_adjacent_color: CardEnums.CardColor = CardEnums.CardColor.RED




func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	if condition == CardEnums.ConditionType.NEXT_IS_COLOR:
		if meets_condition(context, slot):
			slot.activation_count += 1
		return

	var extra: int = context.count_adjacent_same_color(slot.slot_index, per_adjacent_color)
	slot.activation_count += extra
