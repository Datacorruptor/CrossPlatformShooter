extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2

var vel = Vector2()
var bounce=1
var OwnerID = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Explode.rotate(-PI/2)
	$Explode.emitting = true
	$Explode2.emitting = true
	pass # Replace with function body.

func _process(delta):
	
	
	$Explode2.rotate(atan2(vel.y,vel.x))
	
	if is_network_master():
		var collision = move_and_collide(vel * delta)
		rpc_unreliable("bullet_pos_upd",position)
		if collision:
			bounce-=1
			vel = vel.bounce(collision.normal)
			if collision.collider.has_method("shine"):
				collision.collider.shine()
			if collision.collider.is_in_group("player"):
				rpc("bullet_pos_upd",collision.collider.position)
				collision.collider.free_bullets()
				return
			var rem =  collision.remainder.bounce(collision.normal)
			move_and_collide(rem)
			if bounce <=0:
				rpc("remove")
				pass
	else:
		pass
		
sync func remove():
	if OwnerID != "0":
		get_node("/root/gamescreen/TextureRect/Boundaries/"+OwnerID).bulls-=1
	queue_free()
	pass


puppet func bullet_pos_upd(p):
	position = p
	var collision = move_and_collide(Vector2(0,0))
	if collision:
		if collision.collider.is_in_group("player"):
			collision.collider.free_bullets()
			pass
		if collision.collider.has_method("shine"):
			collision.collider.shine()
