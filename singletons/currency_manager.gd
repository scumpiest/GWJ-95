extends Node

var player_money: int = 25
signal money_change

func add_money(count: int) -> void:
	player_money += count
	if count > 0:
		AudioManager.play_shop_money_gained()
	money_change.emit(player_money)

func subtract_money(count: int) -> bool:
	if count > player_money:
		return false
	else:
		player_money -= count
		money_change.emit(player_money)
		return true

