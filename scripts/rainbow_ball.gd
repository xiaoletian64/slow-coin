extends Node3D
signal started
signal impacted
const IMPACT_TIME:=1.3
const DURATION:=2.6
var machine
var queued:=0
var age:=-1.0
var hit:=false
var site:=Vector3.ZERO
var ball:MeshInstance3D
var ring:MeshInstance3D
var ring_material:StandardMaterial3D

static func wins(roll:int)->bool:return roll>=0 and roll<100

func build(owner_machine)->void:
	machine=owner_machine
	ball=MeshInstance3D.new()
	var sphere:=SphereMesh.new();sphere.radius=0.44;sphere.height=0.88
	sphere.radial_segments=48;sphere.rings=24;ball.mesh=sphere
	var shader:=Shader.new()
	shader.code="""shader_type spatial;
varying vec3 local_point;
void vertex(){local_point=VERTEX;}
void fragment(){
float h=fract(atan(local_point.z,local_point.x)/6.28318+local_point.y*0.9);
vec3 c=clamp(abs(fract(h+vec3(0.0,0.6667,0.3333))*6.0-3.0)-1.0,0.0,1.0);
ALBEDO=mix(vec3(0.15),c,0.85);METALLIC=0.45;ROUGHNESS=0.18;EMISSION=c*0.5;
}"""
	var mat:=ShaderMaterial.new();mat.shader=shader;ball.material_override=mat
	add_child(ball)
	ring=MeshInstance3D.new()
	var torus:=TorusMesh.new();torus.inner_radius=0.48;torus.outer_radius=0.55;ring.mesh=torus
	ring_material=StandardMaterial3D.new();ring_material.albedo_color=Color(1,0.75,0.25,0.8)
	ring_material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.emission_enabled=true;ring_material.emission=Color(1,0.4,0.1)
	ring.material_override=ring_material;add_child(ring)
	update_visual()

func input_accepted(roll:=-1)->bool:
	if roll<0:roll=randi_range(0,9999)
	if not wins(roll):return false
	queued+=1
	if age<0:begin()
	return true

func begin()->void:
	queued-=1;age=0;hit=false
	site=Vector3(randf_range(-1.8,1.8),0.6,randf_range(0.5,2.1))
	started.emit();update_visual()

func tick(delta:float)->void:
	if age<0:
		if queued>0:begin()
		return
	age=minf(DURATION,age+delta)
	if not hit and age>=IMPACT_TIME:
		hit=true
		for coin in machine.coins.get_children():
			if coin.in_pinboard or coin.guide_distance>=0:continue
			var offset:Vector3=coin.position-site
			var distance:float=Vector2(offset.x,offset.z).length()
			if distance>2.8:continue
			var direction:=Vector3(offset.x+randf_range(-0.8,0.8),0,offset.z+randf_range(-0.8,0.8)).normalized()
			var power:float=randf_range(0.022,0.05)*(1.0-distance/4.0)
			coin.sleeping=false
			coin.apply_central_impulse(direction*power+Vector3(0,randf_range(0.009,0.025),0))
		impacted.emit()
	if age>=DURATION:age=-1
	update_visual()

func update_visual()->void:
	if ball==null:return
	ball.visible=age>=0;ring.visible=age>=0
	if age<0:return
	var fall:float=clampf((age-0.45)/(IMPACT_TIME-0.45),0,1)
	ball.position=site+Vector3(0,3.5*(1-fall*fall),0)
	ball.rotation=Vector3(age*3,age*5,age*2)
	var fade:float=clampf((DURATION-age)/(DURATION-IMPACT_TIME),0,1)
	ball.scale=Vector3.ONE*(fade if hit else minf(1,age*5+0.1))
	if hit:ball.position.y+=sin((age-IMPACT_TIME)*PI/1.3)*0.8
	ring.position=Vector3(site.x,0.48,site.z)
	ring.scale=Vector3.ONE*(1+(age-IMPACT_TIME)*4 if hit else 1+sin(age*15)*0.12)
	ring_material.albedo_color.a=fade*0.8

func snapshot()->Dictionary:return {"queued":queued,"age":age,"hit":hit,"site":[site.x,site.y,site.z]}
static func valid(data)->bool:
	if not data is Dictionary:return false
	if data.is_empty():return true
	var q=data.get("queued");var t=data.get("age");var p=data.get("site")
	if not (q is int or q is float) or not is_finite(float(q)) or q<0 or q>1000000 or floor(float(q))!=float(q):return false
	if not (t is int or t is float) or not is_finite(float(t)) or (t!=-1 and (t<0 or t>=DURATION)):return false
	if not data.get("hit") is bool or not p is Array or p.size()!=3:return false
	for v in p:
		if not (v is int or v is float) or not is_finite(float(v)):return false
	if absf(p[0])>1.801 or p[1]<0 or p[1]>0.601 or p[2]<0 or p[2]>2.101:return false
	return t<0 or data.hit==(t>=IMPACT_TIME)
func restore(data:Dictionary)->void:
	queued=int(data.get("queued",0));age=float(data.get("age",-1));hit=data.get("hit",false)
	var p:Array=data.get("site",[0,0,0]);site=Vector3(p[0],p[1],p[2]);update_visual()
