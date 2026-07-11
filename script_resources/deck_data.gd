class_name DeckData
extends Resource

@export var cards: Array[CardData] = []


func shuffle() -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j := randi_range(0, i)
		var temp := cards[i]
		cards[i] = cards[j]
		cards[j] = temp

func draw(count: int) -> Array[CardData]:
	var drawn: Array[CardData] = []
	for i in range(min(count, cards.size())):
		drawn.append(cards[i])
		cards.remove_at(i)
	return drawn