class_name SelfExtraActivationsEffect
extends CardEffect

@export var per_adjacent_color: CardEnums.CardColor = CardEnums.CardColor.RED




func resolve(
	context: BattleContext,
	slot: ChainSlotState,
	resolver,
) -> void:
	var extra_activations: int = context.count_adjacent_same_color(slot.slot_index, per_adjacent_color)
	slot.activation_count += extra_activations
