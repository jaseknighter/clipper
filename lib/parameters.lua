params:add{type = "number", id = "cv_delay_tap_1", name = "cv delay tap 1",
min = 1, max = 2000, default = 1, 
action = function(x) 
  cv_player.set_cv_delay(1)
end}

params:add{type = "number", id = "cv_delay_tap_2", name = "cv delay tap 2",
min = 1, max = 2000, default = 1, 
action = function(x) 
  cv_player.set_cv_delay(2)
end}

params:add{type = "number", id = "cv_delay_tap_3", name = "cv delay tap 3",
min = 1, max = 2000, default = 1, 
action = function(x) 
  cv_player.set_cv_delay(3)
end}

params:add{type = "number", id = "cv_delay_tap_4", name = "cv delay tap 4",
min = 1, max = 2000, default = 1, 
action = function(x) 
  cv_player.set_cv_delay(4)
end}


params:add{
  type = "option", id = "cv_recorder_state", name = "cv recorder state", 
  options = {"off","on"},
  default = 2,
  action = function(value) 
    local val
    if value == 1 then
      val = "off"
    elseif value == 2 then
      val = "on"
    end
    print("value",value, val, value == 1)
    cv_player.set_cv_recorder_state(val)  
  end
}


params:add{type = "number", id = "cv_loop_length", name = "cv loop length",
min = 1, max = 2000, default = 2000, 
action = function(x) 
  cv_player.set_cv_loop_length()
  for i=1,4,1 do
    local cvd = params:lookup_param("cv_delay_tap_" .. i)
    if cvd.max > x then cvd.max = x 
    elseif cvd.max < x then cvd.max = x end
    if cvd.value > x then params:set("cv_delay_tap_" .. i,x) end

  end
  
end}
