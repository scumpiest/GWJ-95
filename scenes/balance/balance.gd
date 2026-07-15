extends Node

@export var balance_label: Label

func _ready() -> void:
	_money_changed(CurrencyManager.player_money)
	CurrencyManager.money_change.connect(_money_changed)
	balance_label = get_node("BalanceAmount")

func _money_changed(count: int) -> void:
	balance_label.text = str(count)
	pass
