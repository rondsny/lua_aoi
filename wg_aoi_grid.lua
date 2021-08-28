-- @Author: weiyg
-- @Email: rondsny@gmail.com
-- @Date:   2021-08-23 16:00:17
-- @Last Modified by:   weiyg
-- @Last Modified time: 2021-08-23 18:59:20
-- @Doc:

local mt = {}
mt.__index = mt


local M = {}

function M.new_area(args)
    local grid_size = args.grid_size -- 格子长度

    local grid_x = math.ceil((args.max_x - args.min_x + 1) / (grid_size))
    local grid_y = math.ceil((args.max_y - args.min_y + 1) / (grid_size))
    local grid_max = grid_x * grid_y

    -- print("grid_x =", grid_x, grid_y, grid_max)

    local tb_area = {
        cap   = args.cap,

        min_x = args.min_x,
        min_y = args.min_y,
        max_x = args.max_x,
        max_y = args.max_y,

        grid_x    = grid_x,  -- x轴有几段
        grid_y    = grid_y,  -- y轴有几段

        grid_max  = grid_max,
        grid_size = grid_size,

        map_actor = {},  -- 对象列表
        lst_grid  = {},  -- 格子
    }

    for i=1, grid_max do
        tb_area.lst_grid[i] = {}
    end

    return setmetatable(tb_area, mt)
end

-- 返回 d_cur_grid, d_old_grid, new_vision, appears, disappears
-- d_cur_grid --
-- d_old_grid --
-- new_vision -- id的新视野
-- appears    -- 需要被通知id出现了，需要通知id出现了appears
-- disappears -- 需要被通知id消失了，需要通知id消失了disappears
function mt:set(id, x, y)
    if x < self.min_x or x > self.max_x or
        y < self.min_y or y > self.max_y then
    --
        print("not in arean", id, x, y)
        return
    end

    local d_cur_grid = self:get_grid_no(x, y)
    local new_actor = {id = id, x = x, y = y}
    local old_actor = self.map_actor[id]
    self.map_actor[id] = new_actor

    if not old_actor then
        -- 新增
        self:add_grid_member(d_cur_grid, id)
        local appears = self:get_full_vision_grids(d_cur_grid)
        return d_cur_grid, nil, appears, appears, {}
    elseif old_actor.x == x and old_actor.y == y then
        -- 位置不变
        local vision = self:get_full_vision_grids(d_cur_grid)
        return d_cur_grid, d_cur_grid, vision, {}, {}
    else
        local d_old_grid = self:get_grid_no(old_actor.x, old_actor.y)
        if d_cur_grid == d_old_grid then
            -- 格子内移动
            local vision = self:get_full_vision_grids(d_cur_grid)
            return d_cur_grid, d_cur_grid, vision, {}, {}
        else
            -- 跨格子移动
            self:add_grid_member(d_cur_grid, id)
            self:del_grid_member(d_old_grid, id)
            local new_vision = self:get_full_vision_grids(d_cur_grid)
            local old_vision = self:get_full_vision_grids(d_old_grid)
            local appears, disappears = self:diff(new_vision, old_vision)

            return d_cur_grid, d_old_grid, new_vision, appears, disappears
        end
    end
end

function mt:leave(id)
    --
    local cur_actor = self.map_actor[id]
    if not cur_actor then
        return
    end

    local d_cur_grid = self:get_grid_no(cur_actor.x, cur_actor.y)
    self.map_actor[id] = nil
    self:del_grid_member(d_cur_grid, id)

    return d_cur_grid
end

function mt:get_grid_no(x, y)
    local gx = math.ceil((x - self.min_x + 1) / self.grid_size)  -- x轴第几段
    local gy = math.ceil((y - self.min_y + 1) / self.grid_size)  -- y轴第几段
    local no = gx + self.grid_x * (gy - 1)
    return no
end


function mt:get_full_vision_grids(d_grid)
    local lst_z = {}
    local lst_y = {d_grid}

    local b_first_y = d_grid <= self.grid_x
    local b_last_y  = self.grid_y == 1 or d_grid > self.grid_max - self.grid_x

    local b_first_x = self.grid_x == 1 or math.fmod(d_grid, self.grid_x) == 1
    local b_last_x  = math.fmod(d_grid, self.grid_x) == 0

    if not b_first_y and not b_last_y then
        table.insert(lst_y, d_grid - self.grid_x)
        table.insert(lst_y, d_grid + self.grid_x)
    elseif b_first_y and not b_last_y then
        table.insert(lst_y, d_grid + self.grid_x)
    elseif b_last_y and not b_first_y then
        table.insert(lst_y, d_grid - self.grid_x)
    end

    for _, yy in pairs(lst_y) do
        table.insert(lst_z, yy)
        if not b_first_x and not b_last_x then
            table.insert(lst_z, yy+1)
            table.insert(lst_z, yy-1)
        elseif b_first_x and not b_last_x then
            table.insert(lst_z, yy+1)
        elseif b_last_x and not b_first_x then
            table.insert(lst_z, yy-1)
        end
    end
    return lst_z
end

-- appears    = new_vision - old_vison
-- disappears = old_vison - new_vision
-- 优化： 可以一次遍历？如果是有序的，可以
function mt:diff(new_vision, old_vision)
    local appears = {}
    local disappears = {}

    local map_same = {}
    for _,id1 in pairs(new_vision) do
        for _,id2 in pairs(old_vision) do
            if id1 == id2 then
                map_same[id1] = true
            end
        end
    end

    for _, id1 in pairs(new_vision) do
        if not map_same[id1] then
            table.insert(appears, id1)
        end
    end

    for _, id1 in pairs(old_vision) do
        if not map_same[id1] then
            table.insert(disappears, id1)
        end
    end

    return appears, disappears
end

function mt:add_grid_member(d_grid, id)
    local lst_grid = self.lst_grid
    table.insert(lst_grid[d_grid], id)
end

function mt:del_grid_member(d_grid, id)
    local lst_grid = self.lst_grid
    for k,v in pairs(lst_grid[d_grid]) do
        if v == id then
            table.remove(lst_grid[d_grid], k)
        end
    end
end

function mt:print_aoi()
    --
    print("== print aoi == ")

    for grid,lst_id in pairs(self.lst_grid) do
        if #lst_id > 0 then
            local msg = string.format("grid %3d count = %d", grid, #lst_id)
            print(msg)
        end
    end

    print("")
    for grid,lst_id in pairs(self.lst_grid) do
        -- print("grid =", grid, #lst_id)
        for _, id in pairs(lst_id) do
            -- print("grid id", grid, id)
            local actor = self.map_actor[id]
            print(grid, actor.id, actor.x, actor.y)
        end
    end
end

return M
