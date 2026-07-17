class_name ModifyBlockEffect
extends CardEffect

@export var percent: float = 0.5


func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver: ChainEffectResolver,
) -> void:
	pass
