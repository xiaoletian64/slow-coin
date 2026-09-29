extends RefCounted
static var cache:Dictionary={}
static func make(size:Vector3)->ArrayMesh:
	var key:=str(size)
	if cache.has(key):return cache[key]
	var h:=size*0.5
	var bevel:float=minf(0.075,minf(h.x,minf(h.y,h.z))*0.35)
	var inner:=h-Vector3.ONE*bevel
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for axis in range(3):
		var u: int=(axis+1)%3
		var v: int=(axis+2)%3
		for sign_value in [-1.0,1.0]:
			var points:Array[Vector3]=[]
			for corner in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
				var p:=Vector3.ZERO
				p[axis]=h[axis]*sign_value
				p[u]=inner[u]*corner.x
				p[v]=inner[v]*corner.y
				points.append(p)
			face(st,points)
	for pair in [Vector2i(0,1),Vector2i(1,2),Vector2i(0,2)]:
		var free_axis:int=3-pair.x-pair.y
		for sx in [-1.0,1.0]:
			for sy in [-1.0,1.0]:
				var points:Array[Vector3]=[]
				for corner in [Vector2(0,-1),Vector2(1,-1),Vector2(1,1),Vector2(0,1)]:
					var p:=Vector3.ZERO
					p[pair.x]=(h[pair.x] if corner.x==0 else inner[pair.x])*sx
					p[pair.y]=(inner[pair.y] if corner.x==0 else h[pair.y])*sy
					p[free_axis]=inner[free_axis]*corner.y
					points.append(p)
				face(st,points)
	for x in [-1.0,1.0]:
		for y in [-1.0,1.0]:
			for z in [-1.0,1.0]:
				var signs:=Vector3(x,y,z)
				var points:Array[Vector3]=[]
				for axis in range(3):
					var p:=inner
					p[axis]=h[axis]
					points.append(p*signs)
				face(st,points)
	var mesh:=st.commit()
	cache[key]=mesh
	return mesh
static func face(st:SurfaceTool,points:Array[Vector3])->void:
	var normal:Vector3=(points[1]-points[0]).cross(points[2]-points[0]).normalized()
	var center:=Vector3.ZERO
	for p in points:center+=p
	if normal.dot(center)<0:normal=-normal
	for i in range(1,points.size()-1):
		var tri:Array[Vector3]=[points[0],points[i],points[i+1]]
		if (tri[1]-tri[0]).cross(tri[2]-tri[0]).dot(normal)>0:tri.reverse()
		for p in tri:
			st.set_normal(normal)
			st.add_vertex(p)
