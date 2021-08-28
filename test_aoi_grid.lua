package.path = package.path .. ";./?.lua"

local WgAoi = require "wg_aoi_grid"

local function print_r (msg, t )
    print(msg)

    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

local tb_area = WgAoi.new_area({
    cap       = 100,
    min_x     = 0,
    min_y     = 0,
    max_x     = 99,
    max_y     = 99,
    grid_size = 10,
})

for i=1,10 do
    tb_area:set(i, i*10 - 5, i*10 - 5)
end

tb_area:set(11, 0, 0)
tb_area:set(12, 3, 0)
tb_area:set(13, 3, 1)
tb_area:set(14, 10, 10)
tb_area:set(16, 100, 10)

tb_area:leave(12)

tb_area:print_aoi()

local d_cur_grid, d_old_grid, new_vision, appears, disappears = tb_area:set(15, 9, 9)
print_r(" == d_cur_grid ==", d_cur_grid)
print_r(" == d_old_grid ==", d_old_grid)
print_r(" == new_vision ==", new_vision)
print_r(" == appears ==", appears)
print_r(" == disappears ==", disappears)

print("== end ==")

--[[

+----+----+----+----+----+----+----+----+----+----+
+-01-+-02-+-03-+-04-+-05-+-06-+-07-+-08-+-09-+-10-+
+----+----+----+----+----+----+----+----+----+----+
+-11-+-12-+-13-+-14-+-15-+-16-+-17-+-18-+-19-+-20-+
+----+----+----+----+----+----+----+----+----+----+
+-21-+-22-+-23-+-24-+-25-+-26-+-27-+-28-+-29-+-30-+
+----+----+----+----+----+----+----+----+----+----+
+-31-+-32-+-33-+-34-+-35-+-36-+-37-+-38-+-39-+-40-+
+----+----+----+----+----+----+----+----+----+----+
+-41-+-42-+-43-+-44-+-45-+-46-+-47-+-48-+-49-+-50-+
+----+----+----+----+----+----+----+----+----+----+
+-51-+-52-+-53-+-54-+-55-+-56-+-57-+-58-+-59-+-60-+
+----+----+----+----+----+----+----+----+----+----+
+-61-+-62-+-63-+-64-+-65-+-66-+-67-+-68-+-69-+-70-+
+----+----+----+----+----+----+----+----+----+----+
+-71-+-72-+-73-+-74-+-75-+-76-+-77-+-78-+-79-+-80-+
+----+----+----+----+----+----+----+----+----+----+
+-81-+-82-+-83-+-84-+-85-+-86-+-87-+-88-+-89-+-90-+
+----+----+----+----+----+----+----+----+----+----+
+-91-+-92-+-93-+-94-+-95-+-96-+-97-+-98-+-99-+100-+
+----+----+----+----+----+----+----+----+----+----+

]]
