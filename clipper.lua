---clipper
-- 1.1 @jaseknighter
-- lines: llllllll.co/t/47147
--
-- k1+e3: show instructions

-------------------------
-- code based on softcut studies: https://monome.org/docs/norns/softcut/

-- TODOs
-- in sample_player.lua:
--    figure out hot to get "play all cuts" mode working when clip rates are both < and > 0
--    fix code to set levels so the clippers don't invert themselves while getting to 0
--    figure out why scrubber doesn't scrub with playhead stopped
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

  pages = UI.Pages.new(0, 2)
    
  -- set_redraw_timer()
  -- controller.init()
  sample_player.init()
  page_scroll(1)
  set_redraw_timer()
  set_params()
  initializing = false
end


--------------------------
-- params
--------------------------
function set_params()
  params:add_trigger("set_", "save samples")
  params:set_action("set_", function(x)
    if Namesizer ~= nil then
      textentry.enter(pre_save,Namesizer.phonic_nonsense().."_"..Namesizer.phonic_nonsense())
    else
      textentry.enter(sample_recorder.save_samples)
    end
  end)
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
    if menu_status == false and initializing == false then
      if pages.index == 1 then
        sample_player.update()
      else
        cv_player.update()
      end
      -- screen_dirty = false
      clear_subnav = true
    elseif menu_status == true and clear_subnav == true then
      -- screen_dirty = true
      clear_subnav = false
    end
  end, SCREEN_FRAMERATE, -1)
  redrawtimer:start()  

end


function cleanup ()
  -- add cleanup code
end

