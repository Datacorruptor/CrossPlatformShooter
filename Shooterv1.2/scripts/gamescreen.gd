extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var GX =$TextureRect/Boundaries.global_position.x
onready var GY =$TextureRect/Boundaries.global_position.y

var selfPeerID
# Called when the node enters the scene tree for the first time.
func _ready():
	
	selfPeerID = get_tree().get_network_unique_id()
	var my_player = preload("res://player.tscn").instance()
	
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID)
	my_player.position = Vector2(selfPeerID*1337  % 750 +50  , selfPeerID*42069 % 550 +50 )
	my_player.add_to_group("player")
	my_player.scale = Vector2(0.5,0.5)
	get_node("/root/gamescreen/TextureRect/Boundaries").add_child(my_player)
	
	for p in get_tree().get_network_connected_peers():
		var player = preload("res://player.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p) 
		player.position = Vector2(selfPeerID*1337 % 750 +50, selfPeerID*42069 % 550 +50)
		player.add_to_group("player")
		player.scale = Vector2(0.5,0.5)
		
		get_node("/root/gamescreen/TextureRect/Boundaries").add_child(player)
		
	if get_tree().is_network_server():
		randomize()
		var sd = randi()
		seed(sd)
		for i in range(60):
			var obstacle = preload("res://obstacle.tscn").instance()
			obstacle.position = Vector2(randi()%800+ GX,randi()%600+ GY)
			obstacle.scale.x = randf()*0.3+0.1
			obstacle.scale.y = obstacle.scale.x
			obstacle.name = "obstacle@"+str(i)
			get_node("/root/gamescreen").add_child(obstacle)

		rpc("make_obstacles",sd)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var c=0
	for i in get_node("/root/gamescreen/TextureRect/Boundaries").get_children():
		if i.is_in_group("player"):
			c+=1
	if c <=1:
		$Button.visible = true
	else :
		$Button.visible = false
		
puppet func make_obstacles(rseed):
	seed(rseed)
	for i in range(60):
		var obstacle = preload("res://obstacle.tscn").instance()
		obstacle.position = Vector2(randi()%800+ GX,randi()%600+ GY)
		obstacle.scale.x = randf()*0.3+0.1
		obstacle.scale.y = obstacle.scale.x
		obstacle.name = "obstacle@"+str(i)
		get_node("/root/gamescreen").add_child(obstacle)
	pass


func _on_Button_pressed():
	
	rpc("end_it",selfPeerID)
	gamestate.emit_signal("game_error", "You restarted the game")
	gamestate.end_game()

remote func end_it(id):
	gamestate.emit_signal("game_error", "Player " + gamestate.players[id] + " restarted the game")
	gamestate.end_game()
