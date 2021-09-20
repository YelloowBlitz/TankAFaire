extends Spatial
class_name Tank

var _playerNumber : int
var _speed : float
var _target : Vector3


func loadData(data : TankData, player : int) -> void:
	_playerNumber = player
	
	$Chassi.mesh = data.chassi.chassiMesh
	$Chassi.translation = data.chassi.chassiPos
	$Chassi.scale = data.chassi.chassiScale
	
	$Chassi/Track.mesh = data.track.trackMesh
	$Chassi/Track.translation = data.track.trackPos
	$Chassi/Track.scale = data.track.trackScale
	
	$Turret.mesh = data.turret.turretMesh
	$Turret.translation = data.turret.turretPos
	$Turret.scale = data.turret.turretScale
	
	$Turret/Canon.mesh = data.turret.canonMesh
	$Turret/Canon.translation = data.turret.canonPos
	$Turret/Canon.scale = data.turret.canonScale
	
	_speed = computeSpeed(data)
	return

func computeSpeed(data : TankData) -> float:
	#need implementation
	return 10.0



func _process(delta):
	processChassi(delta)
	processTurret(delta)
	pass


func processChassi(delta) -> void:
	var direction : Vector3 = Vector3.ZERO
	if _playerNumber == 1:
		if Input.is_action_pressed("player1_right"):
			direction.x += 1
		if Input.is_action_pressed("player1_left"):
			direction.x -= 1
		if Input.is_action_pressed("player1_up"):
			direction.z -= 1
		if Input.is_action_pressed("player1_down"):
			direction.z += 1
	
	if _playerNumber == 2:
		if Input.is_action_pressed("player2_right"):
			direction.x += 1
		if Input.is_action_pressed("player2_left"):
			direction.x -= 1
		if Input.is_action_pressed("player2_up"):
			direction.z -= 1
		if Input.is_action_pressed("player2_down"):
			direction.z += 1
	
	direction = direction.normalized()
	translate(direction * _speed * delta)
	
	$Chassi.rotation.y = acos(direction.z)
	if direction.x != 0 :
		$Chassi.rotation *= sign(direction.x)
	return

func updateTarget(pos : Vector3) -> void:
	_target = pos
	return

func processTurret(delta) -> void:
	var direction : Vector3 = _target - translation
	direction = direction.normalized()
	$Turret.rotation.y = acos(direction.z)
	if direction.x != 0 :
		$Turret.rotation *= sign(direction.x)
	return
