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
		CardEnums.ConditionType.ADJACENT_COUNT_COLOR:
			return base_value * context.count_adjacent_same_color(slot.slot_index, condition_color)
		CardEnums.ConditionType.NEXT_IS_COLOR:
			return base_value if meets_condition(context, slot) else 0
		CardEnums.ConditionType.CARD_BEFORE_COUNT:
			return base_value * context.count_card_before_index(slot.slot_index)
		CardEnums.ConditionType.ENEMY_INTENTS_DAMAGE, CardEnums.ConditionType.ENEMY_INTENTS_BLOCK:
			return base_value if meets_condition(context, slot) else 0
		_:
			push_error("Condition type %s not implemented" % condition)
			return 0

## Check if the condition is met for the given slot.
func meets_condition(context: BattleContext, slot: ChainSlotState) -> bool:
	match condition:
		CardEnums.ConditionType.NONE:
			return true
		CardEnums.ConditionType.COLOR_AFTER_COUNT, CardEnums.ConditionType.ADJACENT_COUNT_COLOR:
			return true
		CardEnums.ConditionType.NEXT_IS_COLOR:
			return context.get_next_slot_color(slot.slot_index) == condition_color
		CardEnums.ConditionType.ENEMY_INTENTS_DAMAGE:
			return context.enemy_intents_damage()
		CardEnums.ConditionType.ENEMY_INTENTS_BLOCK:
			return context.enemy_intents_block()
		_:
			push_error("Condition type %s not implemented" % condition)
			return false

## Base class for all card effects.
func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
) -> void:
	push_error("%s.resolve() not implemented" % get_script().resource_path)
