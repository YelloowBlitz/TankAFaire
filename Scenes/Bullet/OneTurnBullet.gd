extends Bullet

export(float) var speed

#La valeur de l'ID de la cible
var _target : int

#Est-ce que la balle peut encore tourner (faux si la balle  déjà effectué un tournant)
var _canTurn : bool = true

#Tolérance sur le produit scalaire (si trop grand, on va tourner pas exactement à 90°, si trop petit, on va pas tourner du tout)
var _tolerance : float = 1

func initBullet(pos : Vector3, dir : Vector3, playerNumber : int) -> void :
	.initBullet(pos, dir, playerNumber)
	_target = 3-playerNumber


## On tourne si on croise l'ennemi et sinon, on avance  
func _process(delta):
	var bulletToEnemy : Vector3 = get_parent().get_node("ArenaManager").getTankPositionByID(_target) - translation
	if _canTurn and abs(_dir.dot(bulletToEnemy)) < _tolerance :
		_canTurn = false
		print("On tourne !")
		if _dir.rotated(Vector3.UP, deg2rad(90)).dot(bulletToEnemy) > 0:
			_dir = _dir.rotated(Vector3.UP, deg2rad(90))
		else :
			_dir = _dir.rotated(Vector3.UP, deg2rad(-90))
	translate(_dir * speed * delta)


# La fonction appelée lorsque la balle sort de l'écran
func _on_VisibilityNotifier_screen_exited():
	queue_free()


func _on_OneTurnBullet_body_entered(body):
	if body.has_method("damage")==true:
		body.damage(1)
	queue_free()
