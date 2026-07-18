class_name ChainModifierEffect
extends CardEffect

# only used for P5(Butterfly)

# require adjacent color to be red
@export var require_adjacent_color: CardEnums.CardColor = CardEnums.CardColor.RED
#if next color is red, skip it
@export var skip_color_after: CardEnums.CardColor = CardEnums.CardColor.RED
# if next color is green, double it
@export var double_color_after: CardEnums.CardColor = CardEnums.CardColor.GREEN




func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	if context.coun_adjacent_same_color(slot.slot_index, require_adjacent_color) <= 0:
		slot.skip_activation = true
		return

	for i in range(slot.slot_index + 1, context.chain_slot_states.size()):
		var other_slot: ChainSlotState = context.chain_slot_states[i]
		if not other_slot.is_active():
			continue

		if other_slot.color == skip_color_after:
			other_slot.skip_activation = true
		elif other_slot.color == double_color_after:
			other_slot.activation_count = 2
