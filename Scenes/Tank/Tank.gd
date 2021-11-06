extends KinematicBody
class_name Tank

onready var chassi = $Chassi
onready var track = $Chassi/Track
onready var turret = $Turret
onready var gun = $Turret/Canon
onready var muzzle = $Turret/Canon/muzzle


var _playerNumber : int

var _speed : float
var _health : int
var _target : Vector3

#chassi
var _chassiDirection : Vector3

#turret
var _baseTurretOffset : Vector3

# Main gun
var _bulletData : BulletData
var _mainReloadTimer : float 
var _mainRealoadCooldown:float

#bullet
var _projectile : PackedScene

#dash
var _isDashing : bool
var _dashSpeed : float
var _dashDuration : float
var _dashTimer : float
var _dashCooldown : float
var _dashDirection : Vector3


func loadData(data : TankData, player : int) -> void:
	_playerNumber = player
	
	_speed = computeSpeed(data)
	_health = computeHealth(data)
	
	_chassiDirection = Vector3.ZERO
	
	_baseTurretOffset = data.chassi.turretPos
	
	_mainReloadTimer = 0
	_mainRealoadCooldown= data.gun.realoadTime
	
	muzzle.translation = data.gun.relativeMuzzlePosition
	_bulletData = data.gun.bulletData 
	_projectile = _bulletData.bulletScene
	
	_isDashing = false
	_dashSpeed = data.engine.dashSpeed
	_dashDuration = data.engine.dashDistance / _dashSpeed
	_dashTimer = 0
	_dashCooldown = data.engine.dashCooldown

	#On donne au tank ses collisions :
	self.set_collision_layer_bit(_playerNumber,true)
	self.set_collision_mask_bit(_playerNumber, true)
	
	self.set_collision_layer_bit(0,true)
	self.set_collision_mask_bit(0, true)
	
	#meshes
	chassi.mesh = data.chassi.chassiMesh
	chassi.translation = data.chassi.chassiPos
	chassi.scale = data.chassi.chassiScale
	
	track.mesh = data.track.trackMesh
	track.translation = data.track.trackPos
	track.scale = data.track.trackScale
	
	turret.mesh = data.turret.turretMesh
	turret.translation = data.chassi.turretPos
	turret.scale = data.turret.turretScale
	
	gun.mesh = data.gun.gunMesh
	gun.translation = data.turret.gunPos
	gun.scale = data.gun.gunScale
	
	return

func computeSpeed(data : TankData) -> float:
	#need implementation
	return 10.0

func computeHealth(data : TankData) -> float:
	return data.turret.healthPoints + data.chassi.healthPoints



func _process(delta):
	processChassi(delta)
	processTurret(delta)
	_mainReloadTimer += delta
	_dashTimer += delta
	_target = get_parent().getTankPositionByID(3-_playerNumber)
	pass


func processChassi(delta) -> void:
	
	var inputPressed : bool = false
	
	if _playerNumber == 1:
		if Input.is_action_pressed("player1_right"):
			_chassiDirection.x = 1
			inputPressed = true
		if Input.is_action_pressed("player1_left"):
			_chassiDirection.x = -1
			inputPressed = true
		if Input.is_action_pressed("player1_up"):
			_chassiDirection.z = -1
			inputPressed = true
		if Input.is_action_pressed("player1_down"):
			_chassiDirection.z = 1
			inputPressed = true
	
	if _playerNumber == 2:
		if Input.is_action_pressed("player2_right"):
			_chassiDirection.x = 1
			inputPressed = true
		if Input.is_action_pressed("player2_left"):
			_chassiDirection.x = -1
			inputPressed = true
		if Input.is_action_pressed("player2_up"):
			_chassiDirection.z = -1
			inputPressed = true
		if Input.is_action_pressed("player2_down"):
			_chassiDirection.z = 1
			inputPressed = true
	
	_chassiDirection = _chassiDirection.normalized()
	
	if _playerNumber == 1 :
		if Input.is_action_just_pressed("player1_dash") && !_isDashing && _dashTimer > _dashCooldown:
			_isDashing = true
			_dashTimer = 0
			_dashDirection = _chassiDirection
	
	if _playerNumber == 2 :
		if Input.is_action_just_pressed("player2_dash") && !_isDashing && _dashTimer > _dashCooldown:
			_isDashing = true
			_dashTimer = 0
			_dashDirection = _chassiDirection
	
	if _isDashing :
		processDash()
	elif inputPressed :
		move_and_slide(_chassiDirection * _speed)
	
	chassi.rotation.y = acos(_chassiDirection.z)
	if _chassiDirection.x != 0 :
		chassi.rotation *= sign(_chassiDirection.x)
	return

func processDash() -> void:
	if _dashTimer > _dashDuration :
		_isDashing = false
		return
	move_and_slide(_dashDirection * _dashSpeed )
	pass

func processTurret(delta) -> void:
	var positionOffset : Vector3 = _baseTurretOffset.rotated(Vector3.UP, chassi.rotation.y)
	turret.translation = positionOffset
	var direction : Vector3 = _target - translation
	direction = direction.normalized()
	turret.rotation.y = acos(direction.z)
	if direction.x != 0 :
		turret.rotation *= sign(direction.x)
	#On gère le tir des tanks :
	if _playerNumber == 1:
		if Input.is_action_pressed("player1_shoot"):
			if _mainReloadTimer > _mainRealoadCooldown:
				_mainReloadTimer=0 #Permet de gérer le reload
				shoot() 
	if _playerNumber == 2:
		if Input.is_action_pressed("player2_shoot"):
			if _mainReloadTimer > _mainRealoadCooldown:
				_mainReloadTimer=0
				shoot() 
	return

#This function handles the firing event
func shoot() -> void:
	var bullet : Bullet = _projectile.instance()
	if !_bulletData.relativeToGun:
		get_tree().current_scene.add_child(bullet)
		bullet.initBullet(muzzle.global_transform.origin, gun.global_transform.basis.z, _playerNumber, _bulletData)
	else:
		gun.add_child(bullet)
		bullet.initBullet(muzzle.translation, Vector3.BACK, _playerNumber, _bulletData)
		bullet.scale.x *= (1 / turret.scale.x) * (1 / gun.scale.x)
		bullet.scale.y *= (1 / turret.scale.y) * (1 / gun.scale.y)
		bullet.scale.z *= (1 / turret.scale.z) * (1 / gun.scale.z)


#This function IS CALLED BY THE PROJECTILE THAT HIT THE TANK
func damage(dmg) -> void:
	_health = _health-dmg
	if _health<=0:
		queue_free()
		get_tree().reload_current_scene() #POUR LE MOMENT SI UN TANK MEURE LE JEU CRASH - DONC ON QUITTE
	pass
