class_name AddExtraActivationsEffect
extends CardEffect

# target the next slot
@export var extra_count: int = 1


func get_timing() -> Timing:
	return Timing.PRE


func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver: ChainEffectResolver,
) -> void:
	pass
