extends Node2D

export(PackedScene) var player
export(PackedScene) var tower

# Called when the node enters the scene tree for the first time.
func _ready():
	var p = player.instance()
	p.position = Vector2(300,300)
	add_child(p)

	var t = tower.instance()
	t.position = Vector2(500,400)
	add_child(t)

	var m = tower.instance()
	m.position = Vector2(500,200)
	add_child(m)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
