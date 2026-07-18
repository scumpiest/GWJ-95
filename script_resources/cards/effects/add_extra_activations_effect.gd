class_name AddExtraActivationsEffect
extends CardEffect

# target the next slot
@export var extra_count: int = 1




func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
) -> void:
	pass
