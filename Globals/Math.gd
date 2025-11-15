extends Node
## Helper functions that solve math problems


## What's the closest of the 8 basic cardinal directions that the given direction is in?
## The 0 direction is Vector2i.UP.
##NOTE: Odd numbers return the cross cardinals, even numbers are diagonal cardinals.
func cardinal_direction(dir:=Vector2i.UP) -> int:
	const cardinals = [
		-90,  # North
		-135,  # NW
		180,  # West
		135,  # SW
		90,  # South
		45,  # SE
		0,  # East
		-45  # NE
	]
	var theta = rad_to_deg( atan2(dir.y, dir.x) )
	theta = snappedi(theta, 45)
	return cardinals.find( theta )

## Return a list of the grid coordinates surrounding the given tile.
## Optionally, rotates the list to have the cell at a certain direction as the first element.
func adjacent_cells(center : Vector2i, first_cardinal:int=0, include_diagonal:=true) -> Array[Vector2i]:
	const cardinals = [
		Vector2i(0,-1),  # North
		Vector2i(-1,-1),  # NW
		Vector2i(-1,0),  # West
		Vector2i(-1,1),  # SW
		Vector2i(0,1),  # South
		Vector2i(1,1),  # SE
		Vector2i(1,0),  # East
		Vector2i(1,-1),  # NE
	]
	
	var rotated_list : Array[Vector2i]
	for n in range(cardinals.size()):
		if include_diagonal or n % 2 == 0:
			rotated_list.append( cardinals[(n + first_cardinal) % 8] + center )
	
	return rotated_list

## Returns all the grid coordinates in a straight line between two points.
func line_on_grid(start:Vector2i, stop:Vector2i) -> Array[Vector2i]:
	#NOTE Kinda just the Bresenham's Algorithm
	var solution : Array[Vector2i]
	var delta : Vector2i = start - stop
	var N = max(abs(delta.x), abs(delta.y))
	for n in range(N + 1):
		var t = float(n) / float(N)
		var point = Vector2i( roundi(lerp(start.x, stop.x, t)), roundi(lerp(start.y, stop.y, t)) )
		solution.append(point)
	return solution

## Find all cells within a circular area.
func circle_on_grid(center:Vector2i, radius:int) -> Array[Vector2i]:
	var solution : Array[Vector2i]
	var edge : Dictionary
	
	var x : int = 0
	var y : int = -radius
	var p : int = -radius
	
	while x < -y:
		if p > 0:
			y+=1
			p += 2 * (x+y) + 1
		else:
			p += 2 * x + 1
		
		# All octants that make the right half a circle
		edge[y] = max(edge.get(y, 0), x)
		edge[-y] = max(edge.get(-y, 0), x)
		edge[x] = max(edge.get(x, 0), -y)
		edge[-x] = max(edge.get(-x, 0), -y)
		
		x += 1
	
	for Y in edge:
		for X in range(-edge[Y], edge[Y] + 1):
			solution.append( Vector2i(X, Y) + center )
	return solution


## Find area of a polygon with given vertex coordinates.
func polygon_area(verts:PackedVector2Array) -> float:
	var accum : float = 0
	for i in range(verts.size()):
		var ini := Vector2(verts[i].x, verts[i].y)
		var next = wrapi(i+1, 0, verts.size())
		var fin := Vector2(verts[next].x, verts[next].y)
		accum += ini.x * fin.y - fin.x * ini.y
	return accum * 0.5


## Find the center of mass of collection of points.
func centroid(verts:PackedVector2Array) -> Vector2:
	if verts.size() == 0:
		return Vector2.INF
		
	var center := Vector2.ZERO
	for each in verts:
		center.x += each.x
		center.y += each.y
	center /= verts.size()
	return center
