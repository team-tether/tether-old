extends Polygon2D

var static_body: StaticBody2D = StaticBody2D.new()

func _ready():
	add_child(static_body)
	
	for i in range(polygon.size()):
		var segment_shape: SegmentShape2D = SegmentShape2D.new()
		segment_shape.a = polygon[i]
		segment_shape.b = polygon[i + 1 if i < polygon.size() - 1 else 0]
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.shape = segment_shape
		static_body.add_child(collision_shape)
