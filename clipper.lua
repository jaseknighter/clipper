---clipper
-- 1.0 @jaseknighter
-- lines: llllllll.co/t/<lines id>
--
-- k1+e3: show instructions

-------------------------
-- code based on softcut studies: https://monome.org/docs/norns/softcut/

-- TODOs
-- make code to determine cutter_start_x_sec and cutter_finish_x_sec more graphically accurrate (in sampler.lua fn: sampler.reset)
-- fix level code (in sampler.lua)
-- why is the magic number 0.034 needed in to tell if a cutter clip is done playing (in sampler.lua fn: sampler.reset)
-- why is the magic number 5 needed to set the clip offset (in sampler.lua fn: sampler.update_cutters_zoom_offset)
-- figure out hot to get "play all cuts" mode working when rate < 0
-------------------------
include "lib/includes"

------------------------------
-- init
------------------------------
function init()

  -- set sensitivity of the encoders
  norns.enc.sens(1,6)
  norns.enc.sens(2,6)
  norns.enc.sens(3,6)

  pages = UI.Pages.new(0, 1)
    
  -- set_redraw_timer()
  -- controller.init()
  sample_player.init()
  page_scroll(1)
  set_redraw_timer()
  set_params()
  
  initializing = false
end

--------------------------
-- saving 
--------------------------
function set_params()
  params:add_trigger("set_", "save samples")
  params:set_action("set_", function(x)
    if Namesizer ~= nil then
      textentry.enter(pre_save,Namesizer.phonic_nonsense().."_"..Namesizer.phonic_nonsense())
    else
      textentry.enter(save_samples)
    end
  end)
end

function pre_save_dir(text)
  print("text",text)
  --[[
  local name_filepath = _path.data.."cheat_codes_2/names/"
  existing_names = {}
  for i in io.popen("ls "..name_filepath):lines() do
    if string.find(i,"%.cc2$") then table.insert(existing_names,name_filepath..i) end
  end
  if text ~= 'cancel' and text ~= nil and not tab.contains(existing_names,"/home/we/dust/data/cheat_codes_2/names/"..text..".cc2") then
    collection_save_clock = clock.run(save_screen,text)
    _norns.key(1,1)
    _norns.key(1,0)
  elseif text == 'cancel' or text == nil then
    print("canceled, nothing saved")
  elseif tab.contains(existing_names,"/home/we/dust/data/cheat_codes_2/names/"..text..".cc2") then
    print(text.." already used, will not overwrite")
    clock.run(save_fail_screen,text)
    _norns.key(1,1)
    _norns.key(1,0)
  end
  ]]
end

function save_samples(dir_name)
  local pathname1 = _path.dust.."audio/clipper/"
  local pathname2 = _path.dust.."audio/clipper/" .. dir_name 
  if os.rename(pathname1, pathname1) == nil then
    print("make dir1")
    os.execute("mkdir " .. pathname1)
  end
  if os.rename(pathname2, pathname2) == nil then
    print("make dir2")
    os.execute("mkdir " .. pathname2)
  end
  
  --[[
  for i=1,#cutters,1
  do
    local start = (cutters[i]:get_start_x()/128) * length
    local finish = (cutters[i]:get_finish_x()/128) * length
    local file = pathname2.."/"..dir_name .. i .. ".wav"
    softcut.buffer_write_stereo(file,start,finish-start)
    print(file,start,finish-start)
  end
  ]]
  sample_player.set_play_mode(0)
  record_to_tape_start(1,dir_name, pathname2)
end

function record_to_tape_pause(next_loop, dir_name, pathname)
  clock.sleep(2)
  record_to_tape_start(next_loop,dir_name,pathname)
end

function record_to_tape_finish(wait, next_loop, dir_name, pathname)
  clock.sleep(wait)
  -- stop the recording
  -- print("loop done",next_loop,dir_name,pathname)
  softcut.play(1,0)
  audio.tape_record_stop ()
  clock.run(record_to_tape_pause,next_loop, dir_name, pathname)
end

function record_to_tape_start(cutter_to_record,dir_name,pathname)
  local loop_length
  if cutter_to_record <= #cutters then
    for i=1,2,1
    do
      softcut.enable(i,1)
      softcut.buffer(i,i)
    
      local cutter_to_record = cutter_to_record
      local file = pathname.."/"..dir_name .. cutter_to_record .. ".wav"
      audio.tape_record_open (file)
      audio.tape_record_start ()
      local rate = cutter_rates[cutter_to_record]
      local start = (cutters[cutter_to_record]:get_start_x()/128) * length
      local finish = (cutters[cutter_to_record]:get_finish_x()/128) * length
      softcut.rate(i,rate)
      softcut.loop_start(i,start)
      softcut.loop_end(i,finish)
      -- softcut.position(1,sample_position*length)
      softcut.rate(cutter_to_record,rate)
      softcut.play(1,1)
      loop_length = (finish - start)/rate
      loop_length = loop_length > 0 and loop_length or loop_length * -1
    end
    -- print("loop start",cutter_to_record,dir_name,pathname,loop_length)
    clock.run(record_to_tape_finish,loop_length, cutter_to_record+1, dir_name, pathname)
  end
end

--------------------------
-- encoders and keys
--------------------------
function enc(n, delta)
  encoders_and_keys.enc(n, delta)
end

function key(n,z)
  encoders_and_keys.key(n, z)
end

--------------------------
-- redraw 
--------------------------
function set_redraw_timer()
  redrawtimer = metro.init(function() 
    menu_status = norns.menu.status()
    -- screen.clear()
    if menu_status == false and initializing == false and screen_dirty == true then
      sample_player.update()
      -- controller.update()
      screen_dirty = false
      clear_subnav = true
    elseif menu_status == true and clear_subnav == true then
      screen_dirty = true
      clear_subnav = false
      screen.clear()
      screen.update()
    end
  end, SCREEN_FRAMERATE, -1)
  redrawtimer:start()  

end


function cleanup ()
  -- add cleanup code
end

