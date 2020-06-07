extends Spatial

export var chunk_size = 8
export var chunk_amount = 8
export var chunk_subdivision = 8


var chunks = {}
var completed_chunks = 0
var unready_chunks = {}
var thread
const ChunkManager = preload("Chunk.gd")
onready var noise = $noisemap.get_texture().get_noise()

func create_key(x, z, LOD):
	var key = str(x) + "," + str(z) + "," + str(LOD)
	return key


func _ready():
	randomize()
	
	print(randi())

	thread = Thread.new()


func add_chunk(x, z, LOD):
	var key = create_key(x, z, LOD)

	if chunks.has(key) or unready_chunks.has(key):
		return

	if not thread.is_active():
		thread.start(self, "load_chunk", [thread, x, z, LOD])
		unready_chunks[key] = 1


func load_chunk(arr):
	var thread = arr[0]
	var x = arr[1]
	var z = arr[2]
	var LOD = arr[3]

	var chunk = ChunkManager.new(noise, x * chunk_size, z * chunk_size, chunk_size, LOD)
	# print(chunk)
	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)

	call_deferred("load_done", chunk, thread, LOD)


func load_done(chunk, thread, LOD):
	add_child(chunk)
	var key = create_key(chunk.x / chunk_size, chunk.z / chunk_size, LOD)
	chunks[key] = chunk
	unready_chunks.erase(key)
	thread.wait_to_finish()
	completed_chunks = completed_chunks + 1
	print(completed_chunks)


func get_chunk(x, z, LOD):
	var key = create_key(x, z, LOD)
	if chunks.has(key):
		return chunks.get(key)

	return null


func _process(delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()


func update_chunks():
	var player_translation = $Player.translation
	var p_x = int(player_translation.x) / chunk_size
	var p_z = int(player_translation.z) / chunk_size

	for x in range(p_x - chunk_amount * .5, p_x + chunk_amount * .5):
		for z in range(p_z - chunk_amount * .5, p_z + chunk_amount * .5):
			# var distance = Vector3($Player.translation.x, 0, $Player.translation.z).distance_to(
			# 	Vector3(x * chunk_size, 0, z * chunk_size)
			# )

			# print(x * chunk_size, " -> ",z* chunk_size," vs ",$Player.translation.x," -> ", $Player.translation.z, " -> distance is, ",distance)
			# print(x," ", z, " " ,distance)
			# change depending on distance from user
			var LOD = chunk_subdivision

			add_chunk(x, z, LOD)
			var chunk = get_chunk(x, z, LOD)
			if chunk != null:
				chunk.should_remove = false

	# print("Completed generating first chunks ->", chunk_amount)


func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)


func reset_chunks():
	for key in chunks:
		var distance = Vector3($Player.translation.x, 0, $Player.translation.z).distance_to(
			Vector3(chunks[key].x * chunk_size, 0, chunks[key].z * chunk_size)
		)

		# if(distance > 200):
		chunks[key].should_remove = true
	pass
