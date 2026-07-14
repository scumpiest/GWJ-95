extends RefCounted

class_name Unit

signal died
signal health_changed(health: int)
signal block_changed(block: int)
signal power_changed(power: int)
signal status_changed

var id: int
var name: String
var description: String
var image: Texture2D
var health: int
var max_health: int
var block: int
var power: int

var statuses: Dictionary

func take_damage(damage: int):
    health -= damage
    emit_signal("health_changed", health)
    if health <= 0:
        die()

func apply_status(status: String):
    statuses[status] = true
    emit_signal("status_changed")

func gain_block(block_amount: int):
    self.block += block_amount
    emit_signal("block_changed", block)

func gain_power(power_amount: int):
    self.power += power_amount
    emit_signal("power_changed", power)

func lose_block(block_amount: int):
    self.block -= block_amount
    emit_signal("block_changed", block)

func lose_power(power_amount: int):
    self.power -= power_amount
    emit_signal("power_changed", power)

func die():
    print(name + " died")
    statuses.clear()
    health = 0
    max_health = 0
    block = 0
    power = 0
    emit_signal("died")