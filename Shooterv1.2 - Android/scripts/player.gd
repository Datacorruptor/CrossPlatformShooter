extends KinematicBody2D
export var SPEED = 50
export var BULLET_SPEED = 60
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bullet = preload("res://bullet.tscn")
export var fire_rate = 100
export var bounces = 2
export var maxBulls = 3
export var bulls = 0

onready var labe = get_node("../../../Label")
onready var cam = get_node("../../../Camera2D")
onready var Jstick = get_node("../../../Cj/Jstick/JButton")
onready var Jstick2 = get_node("../../../Cj2/Jstick2/JButton")


func _ready():
	
	if is_network_master():
		$Ammo.visible=true
		$Label.text = gamestate.get_player_name()
		rpc("name",gamestate.get_player_name())
	pass
	
func _process(delta):
	if is_network_master():
		$Ammo.rect_size.y=40-(float(bulls)/maxBulls)*40
		
		$Base/Turret.global_rotation = Jstick2.get_value().angle()+PI/2
		
		rpc_unreliable("update_turret_pos", $Base/Turret.get_rotation())
		if bulls<maxBulls:
			$ProgressBar.value+=fire_rate*delta
		if $ProgressBar.value >= 100:
			$ProgressBar.visible =false
			
		if Jstick2.get_value() != Vector2(0,0) and $ProgressBar.value >= 100 and bulls<maxBulls:
			var bname = str(randi())
			rpc("make_bullet",bname)
			cam.add_trauma(0.2)
			$ProgressBar.value = 0
			$ProgressBar.visible = true
		
	else:
		pass
	
func pickup_sound():
	scale = scale *1.02
	$pickup.play()
	
func _physics_process(delta):
	if is_network_master():
		var direction = Jstick.get_value()
		var ang = direction.angle()
		
		$Base.rotation = $Base.rotation + (ang + PI/2-$Base.rotation) * direction.length()
		
		move_and_slide(direction*SPEED)
		rpc_unreliable("update_base_pos", position, $Base.rotation)
		
	else:
		pass
	
sync func free_bullets():
	if  is_network_master():
		labe.text = gamestate.get_player_name() + " was shoot!"
		rpc("labe",gamestate.get_player_name())
	for n in get_node("/root/gamescreen/TextureRect/Boundaries").get_children():
		if n.is_in_group("bullet"):
			if n.OwnerID != "0":
				get_node("/root/gamescreen/TextureRect/Boundaries/"+n.OwnerID).bulls-=1
			n.queue_free()
	remove_from_group("player")
	bulls = maxBulls
	position = Vector2(-9999,-9999)
					
puppet func update_base_pos(p_pos,p_rot):
	position = p_pos
	$Base.rotation = p_rot
puppet func update_turret_pos(p_rot):
	$Base/Turret.rotation = p_rot
	
sync func make_bullet(sd):
	cam.add_trauma(0.1)
	var bullet_instance = bullet.instance()
	bullet_instance.rotation_degrees = $Base/Turret.get_global_rotation_degrees()
	bullet_instance.vel = Vector2(BULLET_SPEED,0).rotated($Base/Turret.get_global_rotation()-PI/2)
	bullet_instance.bounce = bounces
	bullet_instance.OwnerID = name
	bullet_instance.name = "BULLET@"+sd
	bulls+=1
	get_node("/root/gamescreen/TextureRect/Boundaries").add_child(bullet_instance)
	get_node("/root/gamescreen/TextureRect/Boundaries/"+bullet_instance.name).global_position = $Base/Turret/FirePoint.get_global_position()
	$shoot.play()
	
puppet func name(n):
	$Label.text = n
puppet func labe(n):
	labe.text = n + " was shoot!"
