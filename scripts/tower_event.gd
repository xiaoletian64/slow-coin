extends Node3D
signal appeared(count:int)
signal prize_appeared(count:int)
var prize_pending:=false
var prize_ready:Callable
const COIN_COUNT:=50
const COLUMNS:=5
const LAYERS:=10
const RING_RADIUS:=0.405
var machine:Node3D
var wait_seconds:=randf_range(60,100)
var inputs:=0
var mist:=0.0
var revealed:=false
var site:=Vector3.ZERO
var clouds:Array=[]
var fog_material:ShaderMaterial
func build(owner_machine:Node3D)->void:
	machine=owner_machine
	name="CoinTowerEvent"
	fog_material=ShaderMaterial.new()
	var shader:=Shader.new()
	shader.code="""shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform float opacity=0.0;
void fragment(){vec2 p=UV*2.0-1.0;float d=length(p);ALBEDO=vec3(0.70,0.85,0.98);ALPHA=pow(max(0.0,1.0-d),1.7)*opacity;}
"""
	fog_material.shader=shader
	var quad:=QuadMesh.new()
	quad.size=Vector2(1.25,1.25)
	for i in range(20):
		var cloud:=MeshInstance3D.new()
		cloud.mesh=quad
		cloud.material_override=fog_material
		add_child(cloud)
		cloud.visible=false
		clouds.append(cloud)
func input_accepted()->void:inputs=mini(inputs+1,12)
func has_room()->bool:
	return machine.coins.get_child_count()+machine.pending.size()+COIN_COUNT<=machine.CAPACITY-12
func find_site(keep_position:=false)->bool:
	# Five coins per layer, ten layers, safely ahead of every pusher and inside side losses.
	var candidates:Array=[Vector3(-1.2,0,1.65),Vector3(1.2,0,1.65),Vector3(0,0,1.65)]
	if machine.mechanism=="sweep":candidates=[Vector3(-1.8,0,2.22),Vector3(1.8,0,2.22)]
	if keep_position:candidates=[Vector3(site.x,0,site.z)]
	candidates.shuffle()
	for candidate in candidates:
		if not mechanism_clear(candidate):continue
		var top:=0.01
		for coin in machine.coins.get_children():
			if coin.in_pinboard:continue
			if Vector2(coin.position.x-candidate.x,coin.position.z-candidate.z).length()>0.90:continue
			var b:Basis=coin.transform.basis
			var extent:float=absf(b.y.y)*0.0475+0.235*sqrt(b.x.y*b.x.y+b.z.y*b.z.y)
			top=maxf(top,coin.position.y+extent)
		if top>0.42:continue
		site=Vector3(candidate.x,top+0.052,candidate.z)
		return true
	return false
func tick(delta:float)->void:
	if mist>0:
		mist=maxf(0,mist-delta)
		if not revealed and mist<=1.25:
			if has_room() and find_site(true) and (not prize_pending or (prize_ready.is_valid() and prize_ready.call())):
				revealed=true
				inputs=0
				wait_seconds=randf_range(60,100)
				spawn_tower()
			else:
				mist=0
				prize_pending=false
				wait_seconds=10
		update_fog()
		return
	wait_seconds=maxf(0,wait_seconds-delta)
	if wait_seconds>0 or inputs<12:return
	if not has_room() or not find_site():
		wait_seconds=10
		return
	mist=2.6
	revealed=false
	update_fog()
func spawn_tower()->void:
	var is_prize:=prize_pending
	prize_pending=false
	for layer in range(LAYERS):
		for column in range(COLUMNS):
			var angle:float=(column+0.5*(layer%2))*TAU/COLUMNS
			var coin=machine.spawn_coin(site+Vector3(cos(angle)*RING_RADIUS,layer*0.098,sin(angle)*RING_RADIUS))
			coin.rotation.y=randf()*TAU
			coin.bonus_coin=is_prize
	if is_prize:prize_appeared.emit(COIN_COUNT)
	appeared.emit(COIN_COUNT)
func update_fog()->void:
	var age:=2.6-mist
	fog_material.set_shader_parameter("opacity",minf(0.85,minf(age*2,mist)*0.85))
	for i in range(clouds.size()):
		var cloud:MeshInstance3D=clouds[i]
		cloud.visible=mist>0
		var t:float=i/float(clouds.size())
		var a:float=t*TAU*2+age*5
		var radius:float=0.28+t*0.55+maxf(0,age-1.5)*0.35
		cloud.position=site+Vector3(cos(a)*radius,0.05+t*0.95,sin(a)*radius)
		cloud.look_at(machine.camera.global_position)
		cloud.rotate_object_local(Vector3.FORWARD,a*0.2)
func snapshot()->Dictionary:
	return {"prize_pending":prize_pending,"wait":wait_seconds,"inputs":inputs,"mist":mist,"revealed":revealed,"site":[site.x,site.y,site.z]}
static func valid(data)->bool:
	if not data is Dictionary or not data.get("prize_pending",false) is bool:return false
	for key in ["wait","inputs","mist"]:
		var n=data.get(key)
		if not (n is int or n is float) or not is_finite(float(n)):return false
	if data.wait<0 or data.wait>100 or data.inputs<0 or data.inputs>12 or float(data.inputs)!=floor(float(data.inputs)) or data.mist<0 or data.mist>2.6:return false
	if not data.get("revealed") is bool:return false
	if data.get("prize_pending",false) and (data.revealed or data.mist<=0):return false
	var p=data.get("site")
	if not p is Array or p.size()!=3:return false
	for n in p:
		if not (n is int or n is float) or not is_finite(float(n)) or absf(float(n))>4:return false
	return absf(p[0])<=1.801 and p[1]>=0 and p[1]<=0.5 and p[2]>=0 and p[2]<=2.421
func restore(data:Dictionary)->void:
	prize_pending=false
	wait_seconds=randf_range(60,100)
	inputs=0
	mist=0
	revealed=false
	site=Vector3.ZERO
	if valid(data):
		prize_pending=data.get("prize_pending",false)
		wait_seconds=float(data.wait)
		inputs=int(data.inputs)
		mist=float(data.mist)
		revealed=data.revealed
		site=Vector3(data.site[0],data.site[1],data.site[2])
	update_fog()

func mechanism_clear(at:Vector3)->bool:
	var bodies:Array=[machine.pusher]
	if machine.mechanism=="split":bodies.append(machine.second_pusher)
	if machine.mechanism=="sweep":bodies.append(machine.sweep_bar)
	for body in bodies:
		var half:Vector3=Vector3(2.4,0.11,0.09) if body==machine.sweep_bar else Vector3(3,0.24,1.65)
		for i in range(COLUMNS*2):
			var a:float=i*PI/COLUMNS
			var point:Vector3=body.to_local(Vector3(at.x+cos(a)*RING_RADIUS,body.position.y,at.z+sin(a)*RING_RADIUS))
			var margin_x:float=0.235/body.scale.x
			if absf(point.x)<half.x+margin_x and absf(point.z)<half.z+0.235:return false
	return true

func request_prize_tower()->bool:
	if prize_pending:return true
	if mist>0 or not has_room() or not find_site():return false
	prize_pending=true
	mist=2.6
	revealed=false
	update_fog()
	return true
func cancel_prize()->void:
	if not prize_pending:return
	prize_pending=false
	mist=0
	update_fog()
