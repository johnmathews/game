@tool
extends Node
## Generates a Spaarndam village layout on the TileMapLayers.
## Attach to Village node, then in the editor: click the node,
## check the "generate" export in the Inspector, and it will build the map.

@export var generate: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_generate_village()
			generate = false

# Ground tileset (source 0) atlas coordinates
const GRASS := Vector2i(4, 3)
const GRASS_FULL := Vector2i(5, 3)
const DIRT := Vector2i(4, 2)

# Roads
const ROAD := Vector2i(4, 6)
const ROAD_EW := Vector2i(6, 6)
const ROAD_NS := Vector2i(6, 7)
const ROAD_ES := Vector2i(5, 6)
const ROAD_NE := Vector2i(5, 7)
const ROAD_NW := Vector2i(7, 7)
const ROAD_SW := Vector2i(8, 7)
const CROSSROAD := Vector2i(9, 1)
const CROSS_ESW := Vector2i(0, 2)
const CROSS_NES := Vector2i(1, 2)
const CROSS_NEW := Vector2i(2, 2)
const CROSS_NSW := Vector2i(3, 2)
const END_E := Vector2i(6, 2)
const END_N := Vector2i(7, 2)
const END_S := Vector2i(8, 2)
const END_W := Vector2i(9, 2)

# Lots (empty building plots with road edge)
const LOT_E := Vector2i(4, 4)
const LOT_N := Vector2i(6, 4)
const LOT_S := Vector2i(9, 4)
const LOT_W := Vector2i(1, 5)

# Water
const WATER := Vector2i(3, 8)
const WATER_E := Vector2i(8, 8)
const WATER_W := Vector2i(5, 9)
const WATER_N := Vector2i(0, 9)
const WATER_S := Vector2i(3, 9)
const WATER_NE := Vector2i(1, 9)
const WATER_NW := Vector2i(2, 9)
const WATER_ES := Vector2i(9, 8)
const WATER_SW := Vector2i(4, 9)
const WATER_CORNER_ES := Vector2i(4, 8)
const WATER_CORNER_NE := Vector2i(5, 8)
const WATER_CORNER_NW := Vector2i(6, 8)
const WATER_CORNER_SW := Vector2i(7, 8)

# River (banked)
const RIVER_EW := Vector2i(3, 5)
const RIVER_NS := Vector2i(5, 5)
const RIVER_ES := Vector2i(2, 5)
const RIVER_NE := Vector2i(4, 5)
const RIVER_NW := Vector2i(6, 5)
const RIVER_SW := Vector2i(7, 5)

# Bridges
const BRIDGE_EW := Vector2i(3, 1)
const BRIDGE_NS := Vector2i(4, 1)
const BRIDGE_HIGH_EW := Vector2i(8, 9)
const BRIDGE_HIGH_NS := Vector2i(9, 9)

# Trees
const TREE_SHORT := Vector2i(1, 8)
const TREE_TALL := Vector2i(2, 8)
const CONIFER_SHORT := Vector2i(7, 1)
const CONIFER_TALL := Vector2i(8, 1)

# Map dimensions
const MAP_W := 35
const MAP_H := 30

# Building tileset (source 1) - selected building types
# Small houses (roof tiles - flat/simple)
const HOUSE_SMALL_1 := Vector2i(0, 0)  # small flat roof
const HOUSE_SMALL_2 := Vector2i(7, 0)  # small flat roof variant
const HOUSE_SMALL_3 := Vector2i(8, 0)  # small flat roof variant
const HOUSE_SMALL_4 := Vector2i(2, 2)  # small with detail

# Medium houses (with colored roofs)
const HOUSE_MED_1 := Vector2i(1, 0)  # red roof
const HOUSE_MED_2 := Vector2i(2, 0)  # red roof variant
const HOUSE_MED_3 := Vector2i(3, 0)  # beige roof
const HOUSE_MED_4 := Vector2i(4, 0)  # beige roof variant
const HOUSE_MED_5 := Vector2i(9, 1)  # another style
const HOUSE_MED_6 := Vector2i(0, 2)  # another style

# Larger buildings (shops, church-like)
const BUILDING_LARGE_1 := Vector2i(5, 8)  # large building
const BUILDING_LARGE_2 := Vector2i(4, 11) # large building
const BUILDING_LARGE_3 := Vector2i(9, 9)  # large building
const BUILDING_SHOP := Vector2i(0, 10)    # shop-like

# Dutch-style row houses
const ROW_HOUSE_1 := Vector2i(6, 2)
const ROW_HOUSE_2 := Vector2i(7, 2)
const ROW_HOUSE_3 := Vector2i(8, 2)
const ROW_HOUSE_4 := Vector2i(9, 2)

var ground_layer: TileMapLayer
var building_layer: TileMapLayer
var rng := RandomNumberGenerator.new()


func _generate_village() -> void:
	ground_layer = get_node_or_null("../Ground") as TileMapLayer
	building_layer = get_node_or_null("../Buildings") as TileMapLayer

	if not ground_layer or not building_layer:
		push_error("Village generator needs Ground and Buildings TileMapLayer children")
		return

	rng.seed = 42  # deterministic for reproducibility

	# Clear existing
	ground_layer.clear()
	building_layer.clear()

	# Step 1: Fill with grass
	_fill_grass()

	# Step 2: Draw the Spaarne river (flows north-south through center)
	_draw_river()

	# Step 3: Draw roads
	_draw_roads()

	# Step 4: Place buildings along streets
	_place_buildings()

	# Step 5: Add trees and greenery
	_place_trees()

	print("Village generated!")


func _fill_grass() -> void:
	for x in range(-2, MAP_W + 2):
		for y in range(-2, MAP_H + 2):
			var tile: Vector2i
			if rng.randf() < 0.3:
				tile = GRASS_FULL
			else:
				tile = GRASS
			ground_layer.set_cell(Vector2i(x, y), 0, tile)


func _draw_river() -> void:
	# The Spaarne river runs north-south through the village
	# River at x = 17-18, with some curves
	var river_x := 17

	# North section - straight
	for y in range(-2, 8):
		_set_river_segment(river_x, y, RIVER_NS)

	# Slight bend east
	_set_river_segment(river_x, 8, RIVER_ES)
	river_x = 18
	_set_river_segment(river_x, 8, RIVER_NW)

	# Middle section
	for y in range(9, 18):
		_set_river_segment(river_x, y, RIVER_NS)

	# Bend back west
	_set_river_segment(river_x, 18, RIVER_SW)
	river_x = 17
	_set_river_segment(river_x, 18, RIVER_NE)

	# South section
	for y in range(19, MAP_H + 2):
		_set_river_segment(river_x, y, RIVER_NS)

	# Bridges
	ground_layer.set_cell(Vector2i(17, 5), 0, BRIDGE_HIGH_NS)   # North bridge
	ground_layer.set_cell(Vector2i(18, 13), 0, BRIDGE_HIGH_NS)  # Central bridge
	ground_layer.set_cell(Vector2i(17, 24), 0, BRIDGE_HIGH_NS)  # South bridge


func _set_river_segment(x: int, y: int, tile: Vector2i) -> void:
	ground_layer.set_cell(Vector2i(x, y), 0, tile)


func _draw_roads() -> void:
	# === WEST SIDE (main village) ===

	# Main north-south road on west bank (Spaarndam's main street)
	for y in range(1, MAP_H - 1):
		ground_layer.set_cell(Vector2i(15, y), 0, ROAD_NS)

	# Secondary north-south road further west
	for y in range(3, 22):
		ground_layer.set_cell(Vector2i(10, y), 0, ROAD_NS)

	# East-west cross streets (connecting to river)
	# Street 1 - north
	for x in range(10, 16):
		ground_layer.set_cell(Vector2i(x, 5), 0, ROAD_EW)
	ground_layer.set_cell(Vector2i(10, 5), 0, CROSS_NES)  # T-junction
	ground_layer.set_cell(Vector2i(15, 5), 0, CROSS_NSW)  # T-junction

	# Street 2 - central (main bridge street)
	for x in range(6, 16):
		ground_layer.set_cell(Vector2i(x, 13), 0, ROAD_EW)
	ground_layer.set_cell(Vector2i(10, 13), 0, CROSSROAD)
	ground_layer.set_cell(Vector2i(15, 13), 0, CROSS_NSW)
	ground_layer.set_cell(Vector2i(6, 13), 0, END_W)

	# Continue bridge street across river
	for x in range(16, 18):
		ground_layer.set_cell(Vector2i(x, 13), 0, ROAD_EW)
	for x in range(19, 24):
		ground_layer.set_cell(Vector2i(x, 13), 0, ROAD_EW)
	ground_layer.set_cell(Vector2i(24, 13), 0, END_E)

	# Street 3 - south
	for x in range(10, 16):
		ground_layer.set_cell(Vector2i(x, 20), 0, ROAD_EW)
	ground_layer.set_cell(Vector2i(10, 20), 0, CROSS_NES)
	ground_layer.set_cell(Vector2i(15, 20), 0, CROSS_NSW)

	# Small lane near church
	for x in range(11, 15):
		ground_layer.set_cell(Vector2i(x, 9), 0, ROAD_EW)
	ground_layer.set_cell(Vector2i(10, 9), 0, CROSS_NES)
	ground_layer.set_cell(Vector2i(15, 9), 0, CROSS_NSW)

	# West dead-end street
	for x in range(6, 10):
		ground_layer.set_cell(Vector2i(x, 9), 0, ROAD_EW)
	ground_layer.set_cell(Vector2i(6, 9), 0, END_W)
	ground_layer.set_cell(Vector2i(10, 9), 0, CROSSROAD)

	# Far west residential lane
	for y in range(6, 13):
		ground_layer.set_cell(Vector2i(6, y), 0, ROAD_NS)
	ground_layer.set_cell(Vector2i(6, 6), 0, END_N)
	ground_layer.set_cell(Vector2i(6, 9), 0, CROSS_NES)

	# Top and bottom caps on main NS roads
	ground_layer.set_cell(Vector2i(15, 1), 0, END_N)
	ground_layer.set_cell(Vector2i(15, MAP_H - 2), 0, END_S)
	ground_layer.set_cell(Vector2i(10, 3), 0, END_N)
	ground_layer.set_cell(Vector2i(10, 22), 0, END_S)

	# === EAST SIDE (across the river) ===
	# Small road network on east bank
	for y in range(10, 17):
		ground_layer.set_cell(Vector2i(22, y), 0, ROAD_NS)
	ground_layer.set_cell(Vector2i(22, 10), 0, END_N)
	ground_layer.set_cell(Vector2i(22, 13), 0, CROSS_NSW)
	ground_layer.set_cell(Vector2i(22, 17), 0, END_S)


func _place_buildings() -> void:
	var houses := [HOUSE_MED_1, HOUSE_MED_2, HOUSE_MED_3, HOUSE_MED_4,
					HOUSE_MED_5, HOUSE_MED_6, HOUSE_SMALL_1, HOUSE_SMALL_2,
					HOUSE_SMALL_3, HOUSE_SMALL_4]

	# --- West bank - houses along the main street (x=15) ---
	# West side of main street
	for y in [2, 3, 4, 6, 7, 8, 10, 11, 12, 14, 15, 17, 18, 19, 21, 22, 23, 25]:
		building_layer.set_cell(Vector2i(14, y), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# East side of main street (between road and river)
	for y in [2, 3, 7, 8, 10, 11, 14, 15, 16, 21, 22, 23]:
		building_layer.set_cell(Vector2i(16, y), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# --- Houses along secondary road (x=10) ---
	for y in [4, 6, 7, 8, 10, 11, 12, 14, 15, 16, 17, 18, 19, 21]:
		building_layer.set_cell(Vector2i(9, y), 1, houses[rng.randi_range(0, houses.size() - 1)])
	for y in [4, 6, 7, 8, 10, 11, 12, 14, 15, 16, 17, 18, 19, 21]:
		building_layer.set_cell(Vector2i(11, y), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# --- Houses along cross streets ---
	# Street at y=5
	for x in [7, 8, 11, 12, 13, 14]:
		building_layer.set_cell(Vector2i(x, 4), 1, houses[rng.randi_range(0, houses.size() - 1)])
		building_layer.set_cell(Vector2i(x, 6), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# Street at y=13 (main bridge street)
	for x in [7, 8, 11, 12, 14]:
		building_layer.set_cell(Vector2i(x, 12), 1, houses[rng.randi_range(0, houses.size() - 1)])
		building_layer.set_cell(Vector2i(x, 14), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# Street at y=20
	for x in [11, 12, 13, 14]:
		building_layer.set_cell(Vector2i(x, 19), 1, houses[rng.randi_range(0, houses.size() - 1)])
		building_layer.set_cell(Vector2i(x, 21), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# --- Far west lane (x=6) ---
	for y in [7, 8, 10, 11, 12]:
		building_layer.set_cell(Vector2i(5, y), 1, houses[rng.randi_range(0, houses.size() - 1)])
		building_layer.set_cell(Vector2i(7, y), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# --- Church (larger building near center) ---
	building_layer.set_cell(Vector2i(12, 9), 1, BUILDING_LARGE_1)
	building_layer.set_cell(Vector2i(13, 9), 1, BUILDING_LARGE_2)

	# --- Shop near bridge ---
	building_layer.set_cell(Vector2i(14, 13), 1, BUILDING_SHOP)

	# --- East bank buildings ---
	for y in [11, 12, 14, 15, 16]:
		building_layer.set_cell(Vector2i(21, y), 1, houses[rng.randi_range(0, houses.size() - 1)])
		building_layer.set_cell(Vector2i(23, y), 1, houses[rng.randi_range(0, houses.size() - 1)])

	# East bank - houses along bridge street
	for x in [20, 21, 23]:
		building_layer.set_cell(Vector2i(x, 12), 1, houses[rng.randi_range(0, houses.size() - 1)])
		building_layer.set_cell(Vector2i(x, 14), 1, houses[rng.randi_range(0, houses.size() - 1)])


func _place_trees() -> void:
	var tree_tiles := [TREE_SHORT, TREE_TALL, CONIFER_SHORT, CONIFER_TALL]

	# Park area south of church
	for x in range(12, 15):
		for y in range(16, 19):
			if rng.randf() < 0.5:
				building_layer.set_cell(Vector2i(x, y), 0, tree_tiles[rng.randi_range(0, 3)])

	# Trees along the river bank (west side)
	for y in range(0, MAP_H):
		if rng.randf() < 0.25:
			# Only place if no building already there
			if building_layer.get_cell_source_id(Vector2i(16, y)) == -1:
				building_layer.set_cell(Vector2i(16, y), 0, tree_tiles[rng.randi_range(0, 3)])

	# Trees along river bank (east side)
	for y in range(0, MAP_H):
		if rng.randf() < 0.25:
			var pos := Vector2i(19, y)
			if building_layer.get_cell_source_id(pos) == -1:
				building_layer.set_cell(pos, 0, tree_tiles[rng.randi_range(0, 3)])

	# Scattered trees on outskirts
	for x in range(0, 5):
		for y in range(0, MAP_H):
			if rng.randf() < 0.15:
				building_layer.set_cell(Vector2i(x, y), 0, tree_tiles[rng.randi_range(0, 3)])

	for x in range(25, MAP_W):
		for y in range(0, MAP_H):
			if rng.randf() < 0.15:
				building_layer.set_cell(Vector2i(x, y), 0, tree_tiles[rng.randi_range(0, 3)])

	# Tree-lined path near church
	for y in [8, 10]:
		building_layer.set_cell(Vector2i(13, y), 0, TREE_TALL)
		building_layer.set_cell(Vector2i(11, y), 0, TREE_TALL)
