        -- crow.output[1].action = "oscillate(440,5,'sine')"
        -- crow.output[1].action = "oscillate(" .. note_to_play .. "+ dyn{freq=" .. 800 .. "}:mul(" .. 0.8 .. "), dyn{lev=" .. 5 .. "}:mul(" .. 0.98 .. ") )"
        -- crow.output[1].execute()

--------------------------
-- play cv
--------------------------

local left_side = 10
local right_side = 120

cv_player = {}

cv_player.nav_labels = {
  "cv delay",
  "cv player/recorder controls",
  "reset loop"
  -- "play mode",
  -- "adj cut ends",
  -- "move cutter",
  -- "rate",
  -- "sample level",
  -- "autogenerate clips"
}

cv_player.play_mode_text = {
  "stop",
  "full loop",
  "all cuts",
  "sel cut",
}

cv_player.nav_active_control = 1

cv_player.screen1 = {}
cv_player.screen1.selected_delay_tap = 1
cv_player.screen2 = {}
cv_player.screen2.selected_control_num = 1

P = norns.crow.public

-- local BOWERYPATH = norns.state.path .. "crow/"
norns.crow.loadscript("cvdelay.lua")

function cv_player.set_cv_delay(output_num)
  -- alt_param = "false"
  local new_tap_amount = params:get("cv_delay_tap_"..output_num)
  -- P.delta(output_num, delta, alt_param)
  crow.public["tap"..output_num] = math.ceil(new_tap_amount/2)
  -- P.update("tap"..output_num, new_tap_amount)
  -- cv_player["tap"..output_num] = cv_player["tap"..output_num] + delta
end

function cv_player.set_cv_loop_length()
  local new_loop_length = params:get("cv_loop_length")
  crow.public.loop_length = math.ceil(new_loop_length/2)
  -- P.update("loop_length", new_tap_amount)
end

function cv_player.set_cv_recorder_state(state) 
  print("set state ", state)
  crow.public.recorder_state = state
end

function cv_player.reset_loop()
  print("reset loop")

  crow.public.reset = 1
end

function cv_player.draw_sub_nav ()
  screen.level(10)
  screen.rect(2,10, screen_size.x-2, 3)
  screen.fill()
  screen.level(0)
  local num_field_menu_areas = #cv_player.nav_labels
  local area_menu_width = (screen_size.x-5)/num_field_menu_areas
  screen.rect(2+(area_menu_width*(cv_player.nav_active_control-1)),10, area_menu_width, 3)
  screen.fill()
  screen.level(4)
  for i=1, num_field_menu_areas+1,1
  do
    if i < num_field_menu_areas+1 then
      screen.rect(2+(area_menu_width*(i-1)),10, 1, 3)
    else
      screen.rect(2+(area_menu_width*(i-1))-1,10, 1, 3)
    end
  end
  screen.fill()
end

function cv_player.draw_top_nav (msg)
  subnav_title = cv_player.nav_labels[cv_player.nav_active_control] 
  if msg == nil then
    if cv_player.nav_active_control == 1 then  
    elseif cv_player.nav_active_control == 2 then
    elseif cv_player.nav_active_control == 3 then
    elseif cv_player.nav_active_control == 4 then
    elseif cv_player.nav_active_control == 5 then
    elseif cv_player.nav_active_control == 6 then
    elseif cv_player.nav_active_control == 7 then
    end

    screen.level(15)
    screen.stroke()
    screen.rect(0,0,screen_size.x,10)
    screen.fill()
    screen.level(0)
    screen.move(4,7)
    screen.text(subnav_title)
    cv_player.draw_sub_nav()
    -- if file_selected then
    -- end
  end
  -- navigation marks
  screen.level(0)
  screen.rect(0,(pages.index-1)/NUM_PAGES*10,2,math.floor(10/NUM_PAGES))
  screen.fill()
end

function cv_player.play()

end

function cv_player.draw_delay_ui()
  local tap_num = cv_player.screen1.selected_delay_tap
  local sl1 = tap_num == 1 and 10 or 5
  local sl2 = tap_num == 2 and 10 or 5
  local sl3 = tap_num == 3 and 10 or 5
  local sl4 = tap_num == 4 and 10 or 5

  screen.level(sl1)
  screen.move(10,30)
  screen.text("delay tap 1: " .. params:get("cv_delay_tap_1"))
  screen.level(sl2)
  screen.move(10,40)
  screen.text("delay tap 2: " .. params:get("cv_delay_tap_2"))
  screen.level(sl3)
  screen.move(10,50)
  screen.text("delay tap 3: " .. params:get("cv_delay_tap_3"))
  screen.level(sl4)
  screen.move(10,60)
  screen.text("delay tap 4: " .. params:get("cv_delay_tap_4"))
  -- screen.level(5)
  -- screen.move(10,60)
  -- screen.text("loop: " .. "??")
end

function cv_player.draw_player_recorder_controls()
  local control_num = cv_player.screen2.selected_control_num
  local sl1 = control_num == 1 and 10 or 5
  local sl2 = control_num == 2 and 10 or 5
  screen.level(sl1)
  screen.move(10,30)
  local recorder_state = params:get("cv_recorder_state") == 1 and "off" or "on"
  screen.text("cv recorder: " .. recorder_state)
  screen.level(sl2)
  screen.move(10,40)
  local loop_length = params:get("cv_loop_length")
  screen.text("cv loop length: " .. loop_length)
end

function cv_player.draw_reset_loop_ui()
  screen.level(10)
  screen.move(10,30)
  screen.text("press k2 to reset loop")
end

function cv_player.update()
  screen.clear()
  if menu_status == false and selecting == false then
    if show_instructions == true then 
      instructions.display() 
    else
      screen.level(10)
      cv_player.play()
    end
  end
  if saving == false then
    cv_player.draw_top_nav()
  else
    cv_player.draw_top_nav("saving")
  end
  if cv_player.nav_active_control == 1 then  
    cv_player.draw_delay_ui()
  elseif cv_player.nav_active_control == 2 then  
    cv_player.draw_player_recorder_controls()
  elseif cv_player.nav_active_control == 3 then  
    cv_player.draw_reset_loop_ui()
  end
  screen.update()
end


return cv_player