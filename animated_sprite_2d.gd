extends AnimatedSprite2D

@onready var timer_anim_sprite: Timer = $"../TimerAnimSprite"
@onready var timer_anim_player: Timer = $"../TimerAnimPlayer"

func _ready() -> void:
	timer_anim_sprite.start()
	timer_anim_player.start()


func _on_timer_anim_sprite_timeout() -> void:
	self.play("default")
