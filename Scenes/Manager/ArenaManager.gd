extends Spatial
class_name ArenaManager

signal party_end(victorId)

export (float) var matchDuration #180
export (float) var tankScale #0.5


var TANK_SCENE := preload("res://Scenes/Tank/Tank.tscn")

var MAP_1 := preload("res://Scenes/Arenas/Arena2.tscn")
var MAP_2 := preload("res://Scenes/Arenas/Arena3.tscn")
var MAP_3 := preload("res://Scenes/Arenas/Arena4.tscn")
var MAP_LIST = [MAP_1,MAP_2, MAP_3]

var active_map
var tank1 : Tank
var tank2 : Tank


onready var healthP1 : TextureProgress = $UI/Health_P1
onready var healthP2 : TextureProgress = $UI/Health_P2
onready var dashP1 : AnimatedSprite = $UI/DashControlP1/Dash_P1
onready var dashP2 : AnimatedSprite = $UI/DashControlP2/Dash_P2
onready var clock : AnimatedSprite = $UI/TimerControl/Clock

func inistanciateTank(tankOne : TankData, tankTwo : TankData) -> void:
	tank1 = TANK_SCENE.instance() 
	add_child(tank1)
	tank1.loadData(tankOne, 1)
	
	tank2 = TANK_SCENE.instance() 
	add_child(tank2)
	tank2.loadData(tankTwo, 2)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, 2)
	active_map=MAP_LIST[num].instance()
	add_child(active_map)
	
	#scale down tank
	tank1.scale = Vector3(tankScale, tankScale, tankScale)
	tank2.scale = Vector3(tankScale, tankScale, tankScale)
	
	#We spawn the tanks at the appropriate place :
	tank1.translation = active_map.get_node("SpawnPoints/SpawnPoint1").translation
	tank2.translation = active_map.get_node("SpawnPoints/SpawnPoint2").translation
	
	#connect signals
	tank1.connect("tank_killed", self, "on_tank1_killed")
	tank2.connect("tank_killed", self, "on_tank2_killed")
	
	clock.speed_scale = 60 / matchDuration
	clock.frame = 0
	
	return


func _process(delta):
	healthP1.value = 100 * tank1.getHealthRatio()
	healthP2.value = 100 * tank2.getHealthRatio()

	var timingDashP1 = tank1.getDashDuration()
	# print("T1 : ", timingDashP1)
	dashP1.frame = int(4 * timingDashP1)
	var timingDashP2 = tank2.getDashDuration()
	dashP2.frame = int(4 * timingDashP2)

func getTankPositionByID(id : int) -> Vector3:
	if id == 1:
		return tank1.translation
	return tank2.translation


func on_tank1_killed()-> void:
	emit_signal("party_end", 2)
	tank1.queue_free()
	tank2.queue_free()
	active_map.queue_free()
	pass

func on_tank2_killed()-> void:
	emit_signal("party_end", 1)
	tank1.queue_free()
	tank2.queue_free()
	active_map.queue_free()
	pass


func _on_Clock_animation_finished():
	SoundManager.play_gong()
	if tank1.getHealthRatio() == tank2.getHealthRatio():
		emit_signal("party_end", 0)
	elif tank1.getHealthRatio() > tank2.getHealthRatio():
		emit_signal("party_end", 1)
	elif tank1.getHealthRatio() < tank2.getHealthRatio():
		emit_signal("party_end", 2)
	pass 
