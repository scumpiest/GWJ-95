class_name ChainModifierEffect
extends CardEffect

# only used for P5(Butterfly)

# require adjacent color to be red
@export var require_adjacent_color: CardEnums.CardColor = CardEnums.CardColor.RED
#if next color is red, skip it
@export var skip_color_after: CardEnums.CardColor = CardEnums.CardColor.RED
# if next color is green, double it
@export var double_color_after: CardEnums.CardColor = CardEnums.CardColor.GREEN




func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver,
) -> void:
	pass
