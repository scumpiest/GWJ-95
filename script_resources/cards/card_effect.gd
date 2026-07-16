class_name CardEffect
extends Resource

# PRE will run before the chain is resolved and ACTIVE will run after
enum Timing { PRE, ACTIVE }

@export var condition: CardEnums.ConditionType = CardEnums.ConditionType.NONE
@export var base_value: int = 0
@export var condition_color: CardEnums.CardColor = CardEnums.CardColor.RED


func get_timing() -> Timing:
	return Timing.ACTIVE


func compute_value(_context: BattleContext, _slot: ChainSlotState) -> int:
	return base_value


## Base class for all card effects.
func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver: ChainEffectResolver,
) -> void:
	push_error("%s.resolve() not implemented" % get_script().resource_path)
