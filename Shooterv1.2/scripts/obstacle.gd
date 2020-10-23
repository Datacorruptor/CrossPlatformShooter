extends StaticBody2D
var powerup = preload("res://powerup.tscn")


func shine():
	scale = scale*0.85
	$blink.play()
	if scale.x>=0.1:
		$shine.visible = true
		yield(get_tree().create_timer(.05), "timeout")
		$shine.visible = false
	
	if scale.x<0.1 and is_network_master():
		var power = powerup.instance()
		randomize()
		var t = randi()%5
		power.type = t
		power.position = position
		get_tree().get_root().add_child(power)
		rpc("create_power",t)
		queue_free()

puppet func create_power(t):
	var power = powerup.instance()
	power.type = t
	power.position = position
	get_tree().get_root().add_child(power)
	queue_free()
