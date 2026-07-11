class_name CardEffect
extends Resource

@export var effect_type: CardEnums.EffectType = CardEnums.EffectType.DAMAGE
@export var base_value: int = 0
@export var secondary_value: int = 0
@export var condition: CardEnums.ConditionType = CardEnums.ConditionType.NONE
@export var status_type: CardEnums.StatusType = CardEnums.StatusType.VULNERABLE


func get_scaled_base(power: int) -> int:
	return base_value + power


func get_scaled_secondary(power: int) -> int:
	return secondary_value + power
