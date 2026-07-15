class_name DeckData
extends Resource

@export var cards: Array[CardData] = []
@export var shop_cards: Array[CardData] = []
@export var discard_pile: Array[CardData] = []

func shuffle() -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j := randi_range(0, i)
		var temp := cards[i]
		cards[i] = cards[j]
		cards[j] = temp

func draw(count: int) -> Array[CardData]:
	var drawn: Array[CardData] = []
	var to_draw := mini(count, cards.size())

	for i in range(to_draw):
		drawn.append(cards.pop_front())
	return drawn

func add_to_discard_pile(card: CardData) -> void:
	discard_pile.append(card)
