class_name UseThreeCardsTask
extends BattleTask

var used_cards := 0
var card_color: CardEnums.CardColor

func _init() -> void:
	var card_color_label = random_card_color()
	description = "Place 3 " + card_color_label + " casettes in a row";

func random_card_color() -> String:
	var values = CardEnums.CardColor.values()
	card_color = values[randi() % values.size()]
	return CardEnums.CardColor.keys()[card_color].capitalize()

func on_event(event: EventType, data = null) -> State:
	if current_state == State.COMPLETED:
		return State.COMPLETED

	if event == EventType.TURN_START:
		print('TURNSTART')
		for slot: Slot in data:
			var card = slot.get_card()
			if card and card.card_data:
				if card.card_data.card_color == card_color:
					print('ADD 1')
					used_cards += 1
				else:
					if used_cards > 0:
						print('RESET')
						used_cards = 0
	
	if event == EventType.TURN_END:
		print('TURN END')
		print(used_cards)
		if used_cards >= 3:
			current_state = State.COMPLETED
			return State.COMPLETED
		else:
			used_cards = 0

	current_state = State.ACTIVE
	return State.ACTIVE
