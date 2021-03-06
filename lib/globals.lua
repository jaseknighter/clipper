-- global functions and variables 

-------------------------------------------
-- global functions
-------------------------------------------

page_scroll = function (delta)
  pages:set_index_delta(util.clamp(delta, -1, 1), false)
end

-------------------------------------------
-- global variables
-------------------------------------------
NUM_PAGES = 2
show_instructions = false
updating_controls = false
OUTPUT_DEFAULT = 4
SCREEN_FRAMERATE = 1/30
menu_status = false
pages = 0

alt_key_active = false
screen_level_graphics = 15
screen_size = vector:new(127,64)
center = vector:new(screen_size.x/2, screen_size.y/2)
num_pages = 1

menu_status = norns.menu.status()
clear_subnav = true
-- screen_dirty = true
show_instructions = false

initializing = true
saving = false
saving_elipses = ""
pre_save_play_mode = false


