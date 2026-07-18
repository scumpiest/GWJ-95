class_name ApplyStatusEffect
extends CardEffect

enum Target { ENEMY, PLAYER }

@export var status_type: CardEnums.StatusType = CardEnums.StatusType.VULNERABLE
@export var stacks: int = 1
@export var target: Target = Target.ENEMY


func resolve(
	context: BattleContext,
	slot: ChainSlotState,
	resolver,
) -> void:
	if not meets_condition(context, slot):
		return
	
	# Get the unit to apply the status to based on the target
	var unit: Unit = context.enemy if target == Target.ENEMY else context.player
	var key : String = get_status_key(status_type)
	for i in stacks:
		unit.apply_status(key)

func get_status_key(status: CardEnums.StatusType) -> String:
	match status:
		CardEnums.StatusType.VULNERABLE:
			return "vulnerable"
		CardEnums.StatusType.WEAKNESS:
			return "weakness"
		CardEnums.StatusType.PROTECTION:
			return "protection"
		CardEnums.StatusType.STRENGTH:
			return "strength"
		_:
			push_error("Status type %s not implemented" % status)
			return ""