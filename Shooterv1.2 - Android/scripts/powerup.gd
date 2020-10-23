extends Area2D

var type = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("powerup")
	$expl.emitting=true
	$blink.play()
	if type == 0:
		$Sprite.region_rect.position = Vector2(11,153)
	elif type == 1:
		$Sprite.region_rect.position = Vector2(79,220)
	elif type == 2:
		$Sprite.region_rect.position = Vector2(147,220)
	elif type == 3:
		$Sprite.region_rect.position = Vector2(79,153)
	elif type == 4:
		$Sprite.region_rect.position = Vector2(147,153)

func _on_powerup_body_entered(body):
	if body.is_in_group("player"):
		if type == 0:
			body.fire_rate += 10
		elif type == 1:
			body.SPEED += 5
			body.BULLET_SPEED += 5
		elif type == 2:
			body.BULLET_SPEED += 10
		elif type == 3:
			body.bounces += 1
		elif type == 4:
			body.maxBulls += 1
		body.pickup_sound()
		queue_free()
	
