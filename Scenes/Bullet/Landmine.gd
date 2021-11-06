extends Bullet
class_name Landmine

var _detectionRad : float

var _countdown : float

var _delay : float

var _elapsedTime : float = 0

var _triggered : bool = false

func initBullet(pos : Vector3, dir : Vector3, playerNumber : int, data : BulletData) -> void :
	.initBullet(pos, dir, playerNumber, data)
	var bulletData : LandmineData = data as LandmineData
	
	if bulletData == null :
		queue_free()
	else:
		_detectionRad = bulletData.detectionRad
		_countdown = bulletData.countdown
		_delay = bulletData.delay
		
		$CollisionShape.shape.radius = _detectionRad


func _process(delta):
	_elapsedTime += delta
	if !_triggered  && _elapsedTime >= _countdown :
		explode()

# Faut gérer les délais
func _on_Landmine_body_entered(body):
	_triggered = true
	yield(get_tree().create_timer(_delay), "timeout")
	explode()

func explode():
	var overlaps = get_overlapping_bodies()
	for target in overlaps:
		if target.has_method("damage"):
			target.damage(_damage)
	queue_free()
