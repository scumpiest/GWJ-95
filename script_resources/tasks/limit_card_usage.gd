class_name LimitCardUsage
extends BattleTask

var limited_cards_to_color := false
var card_color: CardEnums.CardColor

func _init() -> void:
	var card_color_label = random_card_color()
	description = "Use only " + card_color_label + " casettes during 1 turn";

func random_card_color() -> String:
	var values = CardEnums.CardColor.values()
	card_color = values[randi() % values.size()]
	return CardEnums.CardColor.keys()[card_color].capitalize()

func on_event(event: EventType, data = null) -> State:
	if current_state == State.COMPLETED:
		return State.COMPLETED

	if event == EventType.TURN_START:
		var local_limited_cards_to_color = true
		for slot: Slot in data:
			var card = slot.get_card()
			if card and card.card_data and card.card_data.card_color != card_color:
				local_limited_cards_to_color = false

		limited_cards_to_color = local_limited_cards_to_color
	
	if event == EventType.TURN_END:
		if limited_cards_to_color:
			current_state = State.COMPLETED
			return State.COMPLETED

	current_state = State.ACTIVE
	return State.ACTIVE
