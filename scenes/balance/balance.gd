extends Node

@onready var balance_label: Label = %BalanceAmount

func _ready() -> void:
	_money_changed(CurrencyManager.player_money)
	CurrencyManager.money_change.connect(_money_changed)

func _money_changed(count: int) -> void:
	balance_label.text = str(count)
	pass
