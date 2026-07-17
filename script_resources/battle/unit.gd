extends RefCounted

class_name Unit

signal died
signal health_changed(health: int)
signal block_changed(block: int)
signal status_changed(status: String, stacks: int)

var id: int
var name: String
var description: String
var image: Texture2D
var health: int
var max_health: int
var block: int

var statuses: Dictionary[String, int] = {
    "vulnerable": 0, "weakness": 0, "protection": 0, "strength": 0
    }

func take_damage(damage: int):
    health -= damage
    emit_signal("health_changed", health)
    if health <= 0:
        die()

func apply_status(status: String):
    statuses[status] += 1
    emit_signal("status_changed", status, statuses[status])

func gain_block(block_amount: int):
    block += block_amount
    emit_signal("block_changed", block)

func lose_block(block_amount: int):
    block -= block_amount
    emit_signal("block_changed", block)


func die():
    print(name + " died")
    statuses.clear()
    health = 0
    max_health = 0
    block = 0
    emit_signal("died")