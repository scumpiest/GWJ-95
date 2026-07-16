class_name SelfExtraActivationsEffect
extends CardEffect

@export var per_adjacent_color: CardEnums.CardColor = CardEnums.CardColor.RED


func get_timing() -> Timing:
	return Timing.PRE


func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver: ChainEffectResolver,
) -> void:
	pass
