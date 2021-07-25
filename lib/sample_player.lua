-- from softcut study 8: copy
--
saved = "..."
level = 1.0
rec = 1.0
pre = 1.0
-- rate = 1
length = 1
sample_position = 1
last_sample_position = nil
playhead_position = 1
selecting = false
file_selected = false
waveform_loaded = false
subnav_title = ""
playing = 0
cutters = {}
cutter_rates = {1,1}
active_cutter = 1

selected_cutter_group = 1

play_mode = 1 
record_mode = 2
autogen = 5
cutter_start_x_sec, cutter_finish_x_sec = nil
cutter_to_play = 1

left_side = 10
right_side = 120

nav_active_control = 1

local CCDATA_DIR=_path.data.."clipper/"


sample_player_nav_labels = {
  "k2 to select sample",
  "play mode",
  "adj cut ends",
  "move cutter",
  "rate",
  "sample level",
  "autogenerate clips"
}

play_mode_text = {
  "stop",
  "full loop",
  "all cuts",
  "sel cut",
}

-- record_mode_text = {
--   "entire sample",
--   "all clips",
--   "selected clip",
--   "autogenerate",
-- }

sample_player = {}

function sample_player.load_file(file)
  selecting = false
  if file ~= "cancel" then
    file_selected = true
    sample_player_nav_labels[1] = "select/play sample"

    softcut.buffer_clear_region(1,-1)
    local ch, samples = audio.file_info(file)
    length = samples/48000
    -- softcut.buffer_read_mono(file,0,1,-1,1,1)
    -- softcut.buffer_read_mono(file,0,1,-1,1,2)
    softcut.buffer_read_stereo(file,0,1,-1)
    sample_player.init_cutters()
    sample_player.reset()
    waveform_loaded = true
  else
    sample_player.update()
  end
end

function sample_player.reset()
  for i=1,2 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    -- softcut.level(1,1.0)
    softcut.loop(i,1)
    if cutters[1] then
      -- softcut.loop_start(i,1)
      -- softcut.loop_end(i,1+length)
      if play_mode > 1 then
        if play_mode == 3 then cutter_to_play = selected_cutter_group end
        cutter_start_x_sec = util.linlin(10,120,1,length,cutters[cutter_to_play]:get_start_x_updated())
        cutter_finish_x_sec = util.linlin(10,120,1,length,cutters[cutter_to_play]:get_finish_x_updated())      
      else 
        cutter_start_x_sec = 1
        cutter_finish_x_sec = 1+length

      end 
      softcut.loop_start(i,cutter_start_x_sec)
      softcut.loop_end(i,cutter_finish_x_sec)
    else 
      softcut.loop_start(i,1)
      softcut.loop_end(i,1+length)
      softcut.position(i,sample_position)
    end 
    local rate = play_mode < 2 and cutter_rates[1] or cutter_rates[cutter_to_play]
    softcut.rate(i,rate)
    softcut.play(1,1)
    playing = 1
    softcut.fade_time(1,0)
  end
  sample_player.cutters_start_finish_update()
  sample_player.update_content(1,1,length,128)
end

function sample_player.set_play_mode(mode)
-- mode 0: stop
-- mode 1: play entire sample
-- mode 2: play cutters in sequence
-- mode 3: play selected cutter
  play_mode = mode
  if play_mode == 0 then
    playing = 0
    softcut.play(1, playing)
  else
    if play_mode == 1 then
      playing = 1
      softcut.play(1, playing)
    end
    sample_player.reset()
  end
end

-- function sample_player.set_record_mode(mode)
--   -- mode 1: entire sample
--   -- mode 2: all clips
--   -- mode 3: selected clip
--   -- mode 4: autogenerate
--   record_mode = mode
--   if record_mode == 1 then

--   elseif record_mode == 2 then
  
--   elseif record_mode == 3 then

--   elseif record_mode == 4 then

--   end
-- end
  
-- function sample_player.copy_cut()
--   local rand_copy_end = math.random(1,util.round(length))
--   local rand_copy_start = math.random(1,util.round(rand_copy_end - (rand_copy_end/10)))
--   local rand_dest = math.random(1,util.round(length))
--   softcut.buffer_copy_mono(2,1,rand_copy_start,rand_dest,rand_copy_end-rand_copy_start,0.1,math.random(0,1))
--   sample_player.update_content(1,1,length,128)
-- end

-- WAVEFORMS
local interval = 0
waveform_samples = {}
scale = 30

function sample_player.on_render(ch, start, i, s)
  waveform_samples = s
  interval = i
  sample_player.update()
end

function sample_player.cutters_start_finish_update()
  for i=1,#cutters,1
  do
    if cutters[i] then

      local start_x = cutters[i]:get_start_x()
      local finish_x = cutters[i]:get_finish_x()

      start_x = util.linlin(0,128,10,120,cutters[i]:get_start_x())
      finish_x = util.linlin(0,128,10,120,cutters[i]:get_finish_x())
      cutters[i]:cutters_start_finish_update(
        start_x, finish_x
      )
    end
  end
end

local reset_cutter_to_play = false
function sample_player.playhead_position_update(i,pos)
  sample_position = (pos - 1) / length
  -- if play_mode > 1 and cutter_finish_x_sec then
  -- if play_mode > 1 and last_sample_position then
  if cutters[cutter_to_play] then
    -- cutter_start_x_sec = util.linlin(10,120,1,length,cutters[cutter_to_play]:get_start_x_updated())
    -- cutter_finish_x_sec = util.linlin(10,120,1,length,cutters[cutter_to_play]:get_finish_x_updated()) 
    local next_cutter_to_play = util.wrap(cutter_to_play+1,1,#cutters)
    local rate = play_mode < 2 and cutter_rates[1] or cutter_rates[next_cutter_to_play]
    if (rate > 0 and sample_position < last_sample_position) or 
        (rate < 0 and sample_position > last_sample_position) then
      if play_mode == 2 then 
        if  (rate > 0 and sample_position < last_sample_position) then 
          sample_position = last_sample_position - 1
        else
          sample_position = last_sample_position + 1
        end
        -- cutter_to_play = util.wrap(cutter_to_play+1,1,#cutters)
        cutter_to_play = next_cutter_to_play
        cutter_start_x_sec = util.linlin(10,120,1,length,cutters[cutter_to_play]:get_start_x_updated())
        cutter_finish_x_sec = util.linlin(10,120,1,length,cutters[cutter_to_play]:get_finish_x_updated()) 
        sample_player.reset()
      elseif play_mode == 3 then
        sample_player.reset()
      end
    end

    if play_mode > 1 then
      local start = cutters[cutter_to_play]:get_start_x_updated()
      local finish = cutters[cutter_to_play]:get_finish_x_updated()
      local active_cutter_sample_position = (pos - cutter_start_x_sec)/(cutter_finish_x_sec-cutter_start_x_sec)
      playhead_position = util.linlin(0,1,start,finish,active_cutter_sample_position)
    else 
      playhead_position = util.linlin(0,1,10,120,sample_position)
    end
    if selecting == false and menu_status == false then 
      sample_player.update() 
    end  
  end

  last_sample_position = sample_position
end

function sample_player.update_content(buffer,winstart,winend,samples)
  -- render_buffer (ch, start, dur, samples)
  softcut.render_buffer(buffer, winstart, winend - winstart, 128)
end
--/ WAVEFORMS

function sample_player.init()
  softcut.buffer_clear()
  audio.level_adc_cut(1)
  softcut.level_input_cut(1,2,1.0)
  softcut.level_input_cut(2,2,1.0)
  softcut.level(1,1.0)
  softcut.level(2,1.0)
  softcut.phase_quant(1,0.01)
  softcut.event_phase(sample_player.playhead_position_update)
  softcut.poll_start_phase()
  softcut.event_render(sample_player.on_render)
  sample_player.reset()
end

function sample_player.init_cutters()
  cutters = {}
  local cutter1_start_x = 10
  local cutter1_finish_x = 20
  local cutter2_start_x = 40
  local cutter2_finish_x = 50
  cutters[1] = Cutter:new(1,cutter1_start_x,cutter1_finish_x)
  cutters[2] = Cutter:new(2,cutter2_start_x,cutter2_finish_x)
end

function sample_player.autogenerate_cutters(a)
  if waveform_loaded and nav_active_control > 1 then
    cutters = {}
    cutter_rates = {}
    local cutter1_start_x = 0
    local cutter1_finish_x = 128/a
    cutters[1] = Cutter:new(1,cutter1_start_x,cutter1_finish_x)
    cutter_rates[1] = 1

    local cutter_spacing = 128/a
    for i=2,a,1
    do
      local new_cutter_start_x, new_cutter_finish_x
      new_cutter_start_x = cutter_spacing*(i-1)
      new_cutter_finish_x = cutter_spacing*(i)

      -- local new_cutter_finish_x = new_cutter_start_x + (cutters[active_cutter]:get_finish_x() - cutters[active_cutter]:get_start_x())
      table.insert(cutters, i, Cutter:new(i, new_cutter_start_x, new_cutter_finish_x))
      table.insert(cutter_rates, i,1)
    end
    sample_player.cutters_start_finish_update()


    active_cutter = 1
    cutter_to_play = 1
    local display_mode = nav_active_control == 3 and 1 or 2
    cutters[1]:set_display_mode(display_mode)
    sample_player.update()
  end
end

function sample_player.key(n,z)
  if n == 3 and alt_key_active == true and show_instructions == true then
    -- show_instructions = false
    screen.clear() 
  elseif n == 3 and z== 1 and alt_key_active then
    show_instructions = true
  end

  if n == 3 and z== 0 then
    show_instructions = false
  end
  
  if show_instructions == false then
    if n==1 and z==1 then
      -- do something
    elseif n==2 and z==1 then
      if nav_active_control == 1 then
        selecting = true
        fileselect.enter(_path.dust,sample_player.load_file)
      elseif #cutters > 1 and nav_active_control > 1 and nav_active_control < 7 then
        if waveform_loaded and nav_active_control > 1 then
          
          table.remove(cutters, active_cutter)
          table.remove(cutter_rates, active_cutter)
        end
        for i=1,#cutters,1
        do
          cutters[i]:set_cutter_id(i)
          cutters[i]:set_active_edge(1)
          cutters[i]:set_display_mode(0)
        end
        active_cutter = 1
        cutter_to_play = 1

        local display_mode = nav_active_control == 3 and 1 or 2
        -- clock.run(sample_player.set_display_mode,display_mode)
        cutters[active_cutter]:set_display_mode(display_mode)
        sample_player.update()
      elseif nav_active_control == 7 then
        sample_player.autogenerate_cutters(autogen)
      end
      --   sample_player.copy_cut()
      --   -- if not dismiss_K2_message then dismiss_K2_message = true end
      -- end
    elseif n==3 and z==1 then
      if nav_active_control == 1 and waveform_loaded then
        playing = playing == 1 and 0 or 1
        softcut.play(1, playing)
      end
      if waveform_loaded and nav_active_control > 1 then

        local new_cutter_start_x, new_cutter_finish_x
        if cutters[active_cutter]:get_finish_x() < 60 then
          new_cutter_start_x = cutters[active_cutter]:get_finish_x() + 5
          new_cutter_finish_x = new_cutter_start_x + 10
        else
          new_cutter_start_x = cutters[active_cutter]:get_start_x() - 20
          new_cutter_finish_x = new_cutter_start_x + 10
        end

        -- local new_cutter_finish_x = new_cutter_start_x + (cutters[active_cutter]:get_finish_x() - cutters[active_cutter]:get_start_x())
    
        table.insert(cutters, active_cutter+1, Cutter:new(active_cutter+1, new_cutter_start_x, new_cutter_finish_x))
        table.insert(cutter_rates, active_cutter+1,cutter_rates[active_cutter])
        sample_player.cutters_start_finish_update()
      end
      for i=1,#cutters,1
      do
        cutters[i]:set_cutter_id(i)
        cutters[i]:set_display_mode(0)
      end
      local display_mode = nav_active_control == 3 and 1 or 2
      cutters[active_cutter]:set_display_mode(display_mode)

      -- saved = "ss7-"..string.format("%04.0f",10000*math.random())..".wav"
      -- softcut.buffer_write_mono(_path.dust.."/audio/"..saved,1,length,1)
      sample_player.update()
    end
  end
end

function sample_player.enc(n,d)
  if show_instructions == false and file_selected == true then
    
    if n==1 then
      d = util.clamp(d,-1,1) * 0.01
      if nav_active_control == 3 then
        if alt_key_active == true then
          local active_cutter_edge = cutters[active_cutter]:get_active_edge()
          local cutter = cutters[active_cutter]
          if active_cutter_edge == 1 then -- adjust start cuttter
            cutter:set_start_x(util.clamp(cutters[active_cutter]:get_start_x()+(d*1),0,cutters[active_cutter]:get_finish_x()))
          else
            cutter:set_finish_x(util.clamp(cutters[active_cutter]:get_finish_x()+(d*1),cutters[active_cutter]:get_start_x(), 128))
          end
          sample_player.cutters_start_finish_update()
          if play_mode > 1 and cutter_to_play == active_cutter then sample_player.reset() end 
        else
          -- active_cutter_edge = util.clamp(active_cutter_edge + d,1, #cutters*2)
          cutters[active_cutter]:rotate_cutter_edge(d)
        end
      elseif nav_active_control == 4 then
        if alt_key_active == true then
          for i=#cutters,1,-1
          do  
            if (d<0 and cutters[i]:get_start_x() == 0) or (d>0 and cutters[i]:get_finish_x() == 128) then
              break
            elseif i == selected_cutter_group then
              cutters[i]:set_start_x(util.clamp(cutters[i]:get_start_x()+(d*1),0,cutters[i]:get_finish_x()))
              cutters[i]:set_finish_x(util.clamp(cutters[i]:get_finish_x()+(d*1),cutters[i]:get_start_x(), 128))
              sample_player.cutters_start_finish_update()
              if play_mode > 1 and cutter_to_play == active_cutter then 
                sample_player.reset() 
              end 
            end
          end
        end
      elseif nav_active_control == 5 then
        if alt_key_active == true then
          local rate = cutter_rates[active_cutter]
          rate = rate + d
          rate = rate ~= 0 and rate or rate + d
          rate = util.clamp(rate,-20,20)
          -- if play_mode < 2 then cutter_rates[1] = rate else cutter_rates[active_cutter] = rate end
          cutter_rates[active_cutter] = rate 
          sample_player.reset() 
        end
      end
    elseif n==2 then 
      d = util.clamp(d,-1,1)
      if alt_key_active == true then
        -- select prev/next cutter
        local new_active_cutter = util.clamp(active_cutter+d,1,#cutters)
        if new_active_cutter ~= active_cutter then
          for i=1,#cutters,1
          do
            cutters[i]:set_display_mode(0)
          end 
          local display_mode = nav_active_control == 3 and 1 or 2  
          cutters[new_active_cutter]:set_display_mode(display_mode)
          active_cutter = new_active_cutter
          -- if play_mode == 3 then cutter_to_play = active_cutter end
          -- if play_mode > 1 then 
            cutter_to_play = active_cutter 
            selected_cutter_group = active_cutter
            sample_player.reset() 
          -- end

          -- if play_mode < 2 then
          --   -- active_cutter = nil
          -- end
        end
      else
        nav_active_control = util.clamp(nav_active_control+d,1,#sample_player_nav_labels)
        if waveform_loaded then 
          if nav_active_control == 3 then 
            for i=1,#cutters,1
            do
              cutters[i]:set_display_mode(0)
            end 
            cutters[active_cutter]:set_display_mode(1)
          elseif nav_active_control == 4 then 
            for i=1,#cutters,1
            do
              cutters[i]:set_display_mode(0)
            end 
            cutters[active_cutter]:set_display_mode(2)
          end
        end
      end 
    elseif n==3 then
      d = util.clamp(d,-1,1)
      if nav_active_control == 1 then
        local adj_amt = d>0 and 0.05 or 0.001
        sample_position = util.clamp(sample_position + (d*adj_amt),0, 1)
        softcut.position(1,sample_position*length)
        softcut.position(2,sample_position*length)
      elseif nav_active_control == 2 then
        local new_play_mode = util.clamp(play_mode+d,0,#play_mode_text-1)
        sample_player.set_play_mode(new_play_mode)
      elseif nav_active_control == 3 then
        if alt_key_active == true then
          local active_cutter_edge = cutters[active_cutter]:get_active_edge()
          local cutter = cutters[active_cutter]
          if active_cutter_edge == 1 then -- adjust start cuttter
            cutter:set_start_x(util.clamp(cutters[active_cutter]:get_start_x()+(d*1),0,cutters[active_cutter]:get_finish_x()))
          else
            cutter:set_finish_x(util.clamp(cutters[active_cutter]:get_finish_x()+(d*1),cutters[active_cutter]:get_start_x(), 128))
          end
          sample_player.cutters_start_finish_update()
          if play_mode > 1 and cutter_to_play == active_cutter then sample_player.reset() end 
        else
          -- active_cutter_edge = util.clamp(active_cutter_edge + d,1, #cutters*2)
          cutters[active_cutter]:rotate_cutter_edge(d)
        end
      elseif nav_active_control == 4 then
        if alt_key_active == true then
          for i=#cutters,1,-1
          do  
            if (d<0 and cutters[i]:get_start_x() == 0) or (d>0 and cutters[i]:get_finish_x() == 128) then
              break
            elseif i == selected_cutter_group then
              cutters[i]:set_start_x(util.clamp(cutters[i]:get_start_x()+(d*1),0,cutters[i]:get_finish_x()))
              cutters[i]:set_finish_x(util.clamp(cutters[i]:get_finish_x()+(d*1),cutters[i]:get_start_x(), 128))
              sample_player.cutters_start_finish_update()
              if play_mode > 1 and cutter_to_play == active_cutter then 
                sample_player.reset() 
              end 
            end
          end
        end
      elseif nav_active_control == 5 then
        if alt_key_active == true then
        else
          local rate = cutter_rates[active_cutter]
          rate = rate + d
          rate = rate ~= 0 and rate or rate + d
          rate = util.clamp(rate,-20,20)
          -- if play_mode < 2 then cutter_rates[1] = rate else cutter_rates[active_cutter] = rate end
          cutter_rates[active_cutter] = rate 
          sample_player.reset() 
      end
      elseif nav_active_control == 6 then
        level = util.clamp(level+(d)/100,0,1)
        softcut.level(1,level)
      elseif nav_active_control == 7 then
        autogen = util.clamp(autogen+d,1,20)
        -- sample_player.set_record_mode(new_record_mode)
      end
    end
  end
  sample_player.update()
end

function sample_player.draw_sub_nav ()
  screen.level(10)
  screen.rect(2,10, screen_size.x-2, 3)
  screen.fill()
  screen.level(0)
  local num_field_menu_areas = #sample_player_nav_labels
  local area_menu_width = (screen_size.x-5)/num_field_menu_areas
  screen.rect(2+(area_menu_width*(nav_active_control-1)),10, area_menu_width, 3)
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

function sample_player.draw_top_nav ()
  subnav_title = sample_player_nav_labels[nav_active_control] 
  if nav_active_control == 2 then
    subnav_title = subnav_title .. ": " .. play_mode_text[play_mode+1]
  elseif nav_active_control == 3 then
    local cut_loc
    local active_cutter_edge = cutters[active_cutter]:get_active_edge()
    if active_cutter_edge == 1 then -- adjust start cuttter
      cut_loc = cutters[active_cutter]:get_start_x()
      cut_loc = math.floor(cut_loc * 10^3 + 0.5) / 10^3 -- round to nearest 1000th
      subnav_title = subnav_title .. ": " .. cut_loc
    else
      cut_loc = cutters[active_cutter]:get_finish_x()
      cut_loc = math.floor(cut_loc * 10^3 + 0.5) / 10^3 -- round to nearest 1000th
      subnav_title = subnav_title .. ": " .. cut_loc
    end
  elseif nav_active_control == 4 then
    local start = cutters[active_cutter]:get_start_x()
    start = start and start or 0
    local finish = cutters[active_cutter]:get_finish_x()
    finish = finish and finish or 1
    local clip_loc = start + (finish-start)/2
    clip_loc = math.floor(clip_loc * 10^3 + 0.5) / 10^3 -- round to nearest 1000th
    subnav_title = subnav_title .. ": " .. clip_loc
  elseif nav_active_control == 5 then
    -- local rate = play_mode > 2 and cutter_rates[active_cutter] or cutter_rates[1]
    -- local cutter_to_show = play_mode > 2 and active_cutter or 1
    local rate = cutter_rates[active_cutter]
    local cutter_to_show = active_cutter
    subnav_title = subnav_title .. "[" .. cutter_to_show .. "]: " .. rate
  elseif nav_active_control == 6 then
    subnav_title = subnav_title .. ": " .. level
  elseif nav_active_control == 7 then
    -- subnav_title = subnav_title .. ": " .. record_mode_text[record_mode]  
    -- if record_mode == 4 then subnav_title = subnav_title .. ": " .. autogen end
    subnav_title = subnav_title .. ": " .. autogen
    -- if record_mode == 4 then subnav_title = subnav_title .. ": " .. autogen end
  end

  screen.level(15)
  screen.stroke()
  screen.rect(0,0,screen_size.x,10)
  screen.fill()
  screen.level(0)
  screen.move(4,7)
  screen.text(subnav_title)
  if file_selected then
    sample_player.draw_sub_nav()
  end
  
  -- navigation marks
  screen.level(0)
  screen.rect(0,(pages.index-1)/NUM_PAGES*10,2,math.floor(10/NUM_PAGES))
  screen.fill()
end

function sample_player.update()
  screen.clear()
  if menu_status == false then
    -- screen.clear()
    if show_instructions == true then 
      screen.clear()
      instructions.display() 
    elseif not waveform_loaded then
        -- screen.level(15)
        -- screen.move(62,50)
        -- screen.text_center("hold K1 to load sample")
    else
      -- screen.level(15)
      -- screen.move(62,10)
      -- if not dismiss_K2_message then
      --   screen.text_center("K2: random copy/paste")
      -- else
      --   screen.text_center("K3: save new clip")
      -- end
      -- render waveforms
      screen.level(4)
      local x_pos = 0
      for i,s in ipairs(waveform_samples) do
        local height = util.round(math.abs(s) * (scale*level))
        screen.move(util.linlin(0,128,10,120,x_pos), 35 - height)
        screen.line_rel(0, 2 * height)
        screen.stroke()
        x_pos = x_pos + 1
      end
      screen.level(15)
      if playhead_position and playhead_position >= 10 and playhead_position <=120 then
        screen.move(playhead_position,18)
        screen.line_rel(0, 35)
        screen.stroke()
      end 
      for i=1,#cutters,1
      do
        cutters[i]:update()
      end
    end
    sample_player.draw_top_nav()
    screen.update()
  end
end

return sample_player