extends Node

@export var deck: DeckData
@export var card_db: CardDB

func add_card_to_deck(card: CardData) -> void:
    deck.cards.append(card)