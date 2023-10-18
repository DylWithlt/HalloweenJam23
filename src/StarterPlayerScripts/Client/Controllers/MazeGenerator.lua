local wall_offsets = { -- always L -> R or U -> D
	{ x1 = 0, y1 = 0, x2 = 1, y2 = 0 }, -- n
	{ x1 = 1, y1 = 0, x2 = 1, y2 = 1 }, -- e
	{ x1 = 0, y1 = 1, x2 = 1, y2 = 1 }, -- s
	{ x1 = 0, y1 = 0, x2 = 0, y2 = 1 }, -- w
}

local neighbor_offsets = {
	{ x = 0, y = -1 },
	{ x = 1, y = 0 },
	{ x = 0, y = 1 },
	{ x = -1, y = 0 },
}

local function getWallID(x, y, offset)
	return `{x + offset.x1},{y + offset.y1}->{x + offset.x2},{y + offset.y2}`
end

local RNG = Random.new()

local width = 50
local height = 50
local square_size = 20
local wall_height = 100
local wall_thickness = 1

local function getNeighbors(cells, x, y)
	local ret = {}

	for _, neighbor_offset in neighbor_offsets do
		if x + neighbor_offset.x < 1 or x + neighbor_offset.x > width then
			continue
		end
		if y + neighbor_offset.y < 1 or y + neighbor_offset.y > height then
			continue
		end

		table.insert(ret, cells[x + neighbor_offset.x][y + neighbor_offset.y])
	end

	return ret
end

local function drawWall(x1, y1, x2, y2)
	local v1 = Vector3.new((x1 - 1) * square_size, wall_height / 2, (y1 - 1) * square_size)
	local v2 = Vector3.new((x2 - 1) * square_size, wall_height / 2, (y2 - 1) * square_size)

	local part = Instance.new("Part")
	part.Anchored = true
	part.Transparency = 0.5
	part.CFrame = CFrame.lookAt(v2 + (v1 - v2) / 2, v1)
	part.Size = Vector3.new(wall_thickness, wall_height, square_size + wall_thickness)

	return part
end

local function generateMaze()
	local model = Instance.new("Model")
	model.Parent = workspace

	local walls = {}
	local cells = {}

	local function getCommonWall(cell1, cell2)
		for _, id in cell1.walls do
			if table.find(cell2.walls, id) then
				local wall = walls[id]
				return wall
			end
		end

		warn("Should never reach the end of this function.")
	end

	print("Starting grid gen")
	for x = 1, width do
		cells[x] = {}
		for y = 1, height do
			local ws = {}
			for _, offset in wall_offsets do
				local id = getWallID(x, y, offset)
				table.insert(ws, id)

				if walls[id] then
					continue
				end

				local wall = drawWall(x + offset.x1, y + offset.y1, x + offset.x2, y + offset.y2)
				walls[id] = wall
				wall.Parent = model
			end
			cells[x][y] = { x = x, y = y, visited = false, walls = ws }
		end
	end

	print("Starting maze generation...")
	--local cell = {}
	local initCell = cells[1][1]
	initCell.visited = true
	local stack = { initCell }

	local counter = 1
	while #stack > 0 do
		local cur = table.remove(stack)
		--print(cur)

		local neighbors = getNeighbors(cells, cur.x, cur.y)

		local unvisitedNeighbors = {}
		for _, neighbor in neighbors do
			if not neighbor.visited then
				table.insert(unvisitedNeighbors, neighbor)
			end
		end

		if #unvisitedNeighbors <= 0 then
			continue
		end
		table.insert(stack, cur)

		local chosen = unvisitedNeighbors[RNG:NextInteger(1, #unvisitedNeighbors)]
		local wall = getCommonWall(cur, chosen)
		wall.BrickColor = BrickColor.new("Really red")
		task.delay(0.1, function()
			wall:Destroy()
		end)
		chosen.visited = true
		table.insert(stack, chosen)

		counter += 1
		if counter % 30 == 0 then
			task.wait(0.1)
		end
		--task.wait(1)
	end
end

return generateMaze
-- generateMaze()
