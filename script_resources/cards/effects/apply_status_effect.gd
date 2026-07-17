class_name ApplyStatusEffect
extends CardEffect

enum Target { ENEMY, PLAYER }

@export var status_type: CardEnums.StatusType = CardEnums.StatusType.VULNERABLE
@export var stacks: int = 1
@export var target: Target = Target.ENEMY


func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver,
) -> void:
	pass
