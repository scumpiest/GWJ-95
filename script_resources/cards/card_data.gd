class_name CardData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var art: Texture2D
@export var card_color: CardEnums.CardColor = CardEnums.CardColor.RED
@export var is_instant: bool = false
@export var effects: Array[CardEffect] = []


func get_effect(index: int = 0) -> CardEffect:
	return effects[index] if index >= 0 and index < effects.size() else null
