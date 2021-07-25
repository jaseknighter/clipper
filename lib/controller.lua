-- softcut study 8: copy
--
-- K1 load backing track
-- K2 random copy/paste
-- K3 save clip
-- E1 level

-- saved = "..."
-- level = 1.0
-- rec = 1.0
-- pre = 1.0
-- length = 1
-- position = 1
-- selecting = false
-- waveform_loaded = false
-- subnav_title = ""
-- playing = 0
-- cutters = {}
-- active_cutter_edge = 1
-- -- active_cutter_edge_index = 1
-- -- active_cutter_edge_table = {{1,1},{1,2},{2,1},{1,}}
-- selected_cutter_group = 1

-- zoom = 1

-- dismiss_K2_message = false

controller = {}


function controller.init()
  -- sample_player.init()
end

function controller.update()
  if initializing == false then
    if pages.index == 1 then
      -- sample_player.update()
    elseif pages.index == 2 then
      --  swing.update()
    elseif pages.index == 3 then
      --  swing.update()
    elseif pages.index == 4 then
      --  swing.update()
    elseif pages.index == 5 then
      --  swing.update()
    end
  end
  -- screen.update()
end

return controller