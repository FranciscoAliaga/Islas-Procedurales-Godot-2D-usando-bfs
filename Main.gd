extends Node2D

export(int) var island_size = 20

# tip : Podrías hacer un grafo con otras posiciones en la grilla. quizás
# solo vecinos diagonales, o vecinos a distancia euclideana mayor.
var neighbouring_directions = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]

# diccionario de visitados bfs.
# Usamos un diccionario key->value === Vector Grilla -> Nodo del Tile.
# ej: (0,0) -> Nodo del tile del centro
var tile_dicc : Dictionary = {} 
# cola bfs, podrías cambiarlo por pila y obtener dfs
var collection = [] # tip: para cambiarlo por pila, modificar bfs_generation().

# otras cositas
var tile = preload("res://Tile.tscn")
var rng = RandomNumberGenerator.new()
onready var tile_allocator = $TileAllocator
var tile_size : Vector2

### methods ###

func _ready():
	# setup
	randomize()
	var example = tile.instance()
	tile_size = example.get_size()
	
	# start 
	bfs_generation(Vector2.ZERO)

# alojamos el tile en el mundo y lo ponemos en nuestro diccionario (cuenta como visitado)
func place_tile(this : Vector2):
	var new_tile = tile.instance()
	new_tile.position = tile_position_from_grid_vec(this)
	tile_allocator.add_child(new_tile)
	tile_dicc[this] = new_tile

# determina de forma al azar si saltarse vecinos.
func skipping_function() -> bool:
	return rng.randi_range(0,20)>10

# determina cuándo forzar la detención del bfs.
func exit_condition() -> bool:
	return tile_dicc.size()>island_size

# classic bfs with tweaks
func bfs_generation(starting_grid_position : Vector2):
	# cola bfs
	collection.push_back(starting_grid_position)
	
	# iteracion
	while(collection.size()>0 and !exit_condition()):
		var current = collection.pop_front()
		
		# calculamos los vecinos (son vectores en direcciones de la grilla)
		var current_neighbors = neighbouring_directions.duplicate()
		current_neighbors.shuffle() # randomization
		
		for n in current_neighbors: # viaje a los vecinos
			var this = n+current
			
			if skipping_function(): # saltarse vecinos al azar
				continue
			
			# visita bfs.
			if !tile_dicc.has(this): 
				collection.push_back(this)
				place_tile(this)

# es para convertir números de grilla (ej: (2,3)) en posiciones en mundo 2D.
# usando el tamaño del elemento a hacer tile.
func tile_position_from_grid_vec(vec : Vector2):
	return Vector2(vec.x*tile_size.x,vec.y*tile_size.y)

# para salir con escape y resetear con R
func _input(event):
	if event.is_action_released("escape"):
		get_tree().quit()
	if event.is_action_released("restart"):
		get_tree().reload_current_scene()
