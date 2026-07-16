class_name SkipAfterEffect
extends CardEffect


func get_timing() -> Timing:
	return Timing.PRE


func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver: ChainEffectResolver,
) -> void:
	pass
