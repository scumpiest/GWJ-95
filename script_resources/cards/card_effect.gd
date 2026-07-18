class_name CardEffect
extends Resource

# PRE will run before the chain is resolved and ACTIVE will run after
enum Timing { PRE, ACTIVE }

@export var timing: Timing = Timing.ACTIVE
@export var condition: CardEnums.ConditionType = CardEnums.ConditionType.NONE
@export var base_value: int = 0
@export var condition_color: CardEnums.CardColor = CardEnums.CardColor.RED


func get_timing() -> Timing:
	return timing

## Compute the value of the effect based on the condition.
func compute_value(context: BattleContext, slot: ChainSlotState) -> int:
	match condition:
		CardEnums.ConditionType.NONE:
			return base_value
		CardEnums.ConditionType.COLOR_AFTER_COUNT:
			return base_value + context.count_color_after_index(slot.slot_index, condition_color)
		_:
			push_error("Condition type %s not implemented" % condition)
			return 0

## Check if the condition is met for the given slot.
func meets_condition(context: BattleContext, slot: ChainSlotState) -> bool:
	match condition:
		CardEnums.ConditionType.NONE:
			return true
		CardEnums.ConditionType.NEXT_IS_COLOR:
			return context.get_next_slot_color(slot.slot_index) == condition_color
		_:
			push_error("Condition type %s not implemented" % condition)
			return false

## Base class for all card effects.
func resolve(
	context: BattleContext,
	slot: ChainSlotState,
	resolver: ChainEffectResolver,
) -> void:
	push_error("%s.resolve() not implemented" % get_script().resource_path)
