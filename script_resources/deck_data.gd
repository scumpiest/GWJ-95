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
	for i in range(count):
		if cards.is_empty() and not reshuffle_discard_into_draw():
			break
		drawn.append(cards.pop_front())
	return drawn

func reshuffle_discard_into_draw() -> bool:
	if discard_pile.is_empty():
		return false
	cards.clear()
	for card in discard_pile:
		cards.append(card)
	discard_pile.clear()
	shuffle()
	return true

func add_to_discard_pile(card: CardData) -> void:
	discard_pile.append(card)
