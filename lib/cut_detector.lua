local cut_detector = {}

cut_detector.height_checked = true
cut_detector.height_tab = {}

local height_diff_tab = {}
local height_diff_sorted_tab = {}

-- function cut_detector.get_height_tab()
--   return height_diff_tab
-- end

function cut_detector.set_height_start()
  clock.sleep(0.5)
  cut_detector.height_checked = false
  cut_detector.height_tab = {}
end

function cut_detector.set_height(height)
  if cut_detector.height_checked == false then
    table.insert(cut_detector.height_tab, height)
  end
end

function cut_detector.set_height_completed()
  if cut_detector.height_checked == false then
    cut_detector.height_checked = true
    cut_detector.find_cuts()
  end
end


function cut_detector.get_sorted_cut_indices()
  local sorted_cut_indices = {}
  for i=#height_diff_tab,1,-1
  do
    table.insert(sorted_cut_indices,height_diff_sorted_tab[i][2][1])
  end
  
  return sorted_cut_indices
end


function cut_detector.find_cuts()
  height_diff_tab = {}
  for i=2,#cut_detector.height_tab,1
  do
    local h_diff = cut_detector.height_tab[i] - cut_detector.height_tab[i-1]
    h_diff = h_diff < 0 and h_diff * -1 or h_diff
    -- print("i,h_diff",i,h_diff)
    table.insert(height_diff_tab,{i,h_diff})
  end

  height_diff_sorted_tab = {}
  for k, v in pairs(height_diff_tab) do
      table.insert(height_diff_sorted_tab,{k,v})
  end

  table.sort(height_diff_sorted_tab, function(a,b) 
      return a[2][2] < b[2][2]
    end
  )
end

return cut_detector