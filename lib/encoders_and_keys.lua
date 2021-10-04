-- encoders and keys

local enc = function (n, d)

  d = util.clamp(d, -1, 1)
  if n == 1 and show_instructions == false and alt_key_active == false then
    -- scroll pages
    local page_increment = d
    local next_page = pages.index + page_increment
    if (next_page <= NUM_PAGES and next_page > 0) then
      page_scroll(page_increment)
    end
  elseif pages.index == 1 then
    if file_selected == true and saving == false and show_instructions == false then    
      if n==1 then
        d = util.clamp(d,-1,1) * 0.01
        if sample_player.nav_active_control == 3 then
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
            cutters[active_cutter]:rotate_cutter_edge(d)
          end
        elseif sample_player.nav_active_control == 4 then
          if alt_key_active == true then
            for i=1,#cutters,1
            do  
              if i == selected_cutter_group and (d<0 and cutters[i]:get_start_x() == 0) or (d>0 and cutters[i]:get_finish_x() == 128) then
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
        elseif sample_player.nav_active_control == 5 then
          if alt_key_active == true then
            local rate = cutter_rates[active_cutter]
            rate = rate + d
            rate = rate ~= 0 and rate or rate + d
            rate = util.clamp(rate,-20,20)
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
            local display_mode = sample_player.nav_active_control == 3 and 1 or 2  
            cutters[new_active_cutter]:set_display_mode(display_mode)
            active_cutter = new_active_cutter
            cutter_to_play = active_cutter 
            selected_cutter_group = active_cutter
            sample_player.reset() 
          end
        else
          sample_player.nav_active_control = util.clamp(sample_player.nav_active_control+d,1,#sample_player.nav_labels)
          if waveform_loaded then 
            if sample_player.nav_active_control == 3 then 
              for i=1,#cutters,1
              do
                cutters[i]:set_display_mode(0)
              end 
              cutters[active_cutter]:set_display_mode(1)
            elseif sample_player.nav_active_control == 4 then 
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
        if sample_player.nav_active_control == 1 then
          local r = cutter_rates[active_cutter]
          local adj_amt = (d>0) and (r>0 and 0.05 or 0.001) or (r>0 and 0.001 or 0.05)
          sample_position = util.clamp(sample_position + (d*adj_amt),0, 1)
          softcut.position(1,sample_position*length)
          softcut.position(2,sample_position*length)
        elseif sample_player.nav_active_control == 2 then
          local new_play_mode = util.clamp(play_mode+d,0,#sample_player.play_mode_text-1)
          sample_player.set_play_mode(new_play_mode)
        elseif sample_player.nav_active_control == 3 then
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
            cutters[active_cutter]:rotate_cutter_edge(d)
          end
        elseif sample_player.nav_active_control == 4 then
          if alt_key_active == true then
            for i=1,#cutters,1
            do  
              if i == selected_cutter_group  and (d<0 and cutters[i]:get_start_x() == 0) or (d>0 and cutters[i]:get_finish_x() == 128) then
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
        elseif sample_player.nav_active_control == 5 then
          local rate = cutter_rates[active_cutter]
          rate = rate + d
          rate = rate ~= 0 and rate or rate + d
          rate = util.clamp(rate,-20,20)
          -- if play_mode < 2 then cutter_rates[1] = rate else cutter_rates[active_cutter] = rate end
          if alt_key_active == false then
            cutter_rates[active_cutter] = rate 
          else
            for i=1,#cutter_rates,1
            do
              cutter_rates[i] = rate
            end
          end
          
          sample_player.reset() 
        elseif sample_player.nav_active_control == 6 then
          level = util.clamp(level+(d)/100,0,1)
          softcut.level(1,level)
        elseif sample_player.nav_active_control == 7 then
          autogen = util.clamp(autogen+d,1,20)
          sample_player.autogenerate_cutters(autogen)
        end
      end
    end
    sample_player.update()
  elseif pages.index == 2 then
    if n==2 then
      cv_player.nav_active_control = util.clamp(cv_player.nav_active_control+d,1,#cv_player.nav_labels)
    elseif n==3 then
      if cv_player.nav_active_control == 1 then
        local d = alt_key_active == true and d*100 or d*10
        local delay = params:get("cv_delay_tap_"..cv_player.screen1.selected_delay_tap) + d
        params:set("cv_delay_tap_"..cv_player.screen1.selected_delay_tap,delay)
      elseif cv_player.nav_active_control == 2 then
        local control_num = cv_player.screen2.selected_control_num 
        if control_num == 1 then
          local recorder_state = params:get("cv_recorder_state") + d
          local d = util.clamp(recorder_state,1,2)
          params:set("cv_recorder_state",d)
        elseif control_num == 2 then
          local d = alt_key_active == true and d*100 or d*10
          local loop_length = params:get("cv_loop_length") + d
          params:set("cv_loop_length",loop_length)
        end
      end
    end  
  end
end

local key = function (n,z)
  if n == 1 and z == 1 then
    alt_key_active = true
  elseif n == 1 and z == 0 then
    alt_key_active = false
  end

  if pages.index == 1 then
  
    if saving == false and n == 3 and show_instructions == true then
      show_instructions = false
      screen.clear() 
    elseif saving == false and n == 3 and z== 1 and alt_key_active then
      show_instructions = true
    end

    if saving == false and show_instructions == false and waveform_loaded then
      if n==1 and z==1 then
        -- do something 
      elseif n==2 and z==1 then
        if #cutters > 1 and sample_player.nav_active_control > 1 and sample_player.nav_active_control < 7 then
          table.remove(cutters, active_cutter)
          table.remove(cutter_rates, active_cutter)
          for i=1,#cutters,1
          do
            cutters[i]:set_cutter_id(i)
            cutters[i]:set_active_edge(1)
            cutters[i]:set_display_mode(0)
          end
          active_cutter = 1
          cutter_to_play = 1

          local display_mode = sample_player.nav_active_control == 3 and 1 or 2
          cutters[active_cutter]:set_display_mode(display_mode)
          sample_player.update()
        elseif sample_player.nav_active_control == 7 then

        end
      elseif n==3 and z==1 then
        if sample_player.nav_active_control == 1 then
          playing = playing == 1 and 0 or 1
          softcut.play(1, playing)
        end
        if sample_player.nav_active_control > 1 then

          local new_cutter_start_x, new_cutter_finish_x
          if cutters[active_cutter]:get_finish_x() < 60 then
            new_cutter_start_x = cutters[active_cutter]:get_finish_x() + 5
            new_cutter_finish_x = new_cutter_start_x + 10
          else
            new_cutter_start_x = cutters[active_cutter]:get_start_x() - 20
            new_cutter_finish_x = new_cutter_start_x + 10
          end
          table.insert(cutters, active_cutter+1, Cutter:new(active_cutter+1, new_cutter_start_x, new_cutter_finish_x))
          table.insert(cutter_rates, active_cutter+1,cutter_rates[active_cutter])
          sample_player.cutters_start_finish_update()
        end
        for i=1,#cutters,1
        do
          cutters[i]:set_cutter_id(i)
          cutters[i]:set_display_mode(0)
        end
        local display_mode = sample_player.nav_active_control == 3 and 1 or 2
        cutters[active_cutter]:set_display_mode(display_mode)
        sample_player.update()
      end
    end
    if (not waveform_loaded or sample_player.nav_active_control == 1) and n==2 and z==1 then
      screen.clear()
      selecting = true
      fileselect.enter(_path.dust,sample_player.load_file)
    end
  elseif pages.index == 2 and z==1 then
    local delta = 0
    if n==2 then
      delta = -1
    elseif n==3 then
      delta = 1
    end
    if n>1 and cv_player.nav_active_control == 1 then
      delta=util.clamp(cv_player.screen1.selected_delay_tap+delta,1,4)
      cv_player.screen1.selected_delay_tap = delta
    elseif n>1 and cv_player.nav_active_control == 2 then
      delta=util.clamp(cv_player.screen1.selected_delay_tap+delta,1,2)
      cv_player.screen2.selected_control_num = delta
    elseif n==2 and cv_player.nav_active_control == 3 then
      cv_player.reset_loop()
    end
  end
end

return{
  enc=enc,
  key=key
}
