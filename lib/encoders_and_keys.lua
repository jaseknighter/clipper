-- encoders and keys

local enc = function (n, delta)
  -- set variables needed by each page/example
  if n == 1  and alt_key_active == false then
    -- scroll pages
    local page_increment = util.clamp(delta, -1, 1)

    local next_page = pages.index + page_increment
    if (next_page <= num_pages and next_page > 0) then
      page_scroll(page_increment)
    end
  end

  if pages.index == 1 then
    sample_player.enc(n, delta)
  elseif pages.index == 2 then
    -- sample_recorder.enc(n, delta)

  elseif pages.index == 3 then

  elseif pages.index == 4 then

  elseif pages.index == 5 then

  end
end

local key = function (n,z)
  if n == 1 and z == 1 then
    alt_key_active = true
  elseif n == 1 and z == 0 then
    alt_key_active = false
  end

  if pages.index == 1 then
    sample_player.key(n, z)
  elseif pages.index == 2 then
    sample_recorder.key(n, z)
  elseif pages.index == 3 then

  elseif pages.index == 4 then

  elseif pages.index == 5 then

  end

end

return{
  enc=enc,
  key=key
}
