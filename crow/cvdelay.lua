--- control voltage delay
-- input1: CV to delay
-- input2: 0v = capture, 5v = loop (continuous)
-- output1-4: delay equaly spaced delay taps

-- note: length units are increments of 
MAX_LENGTH = 1000 -- max loop time. MUST BE CONSTANT
public{tap1 = 1}:range(1,MAX_LENGTH):type'slider'
public{tap2 = 1}:range(1,MAX_LENGTH):type'slider'
public{tap3 = 1}:range(1,MAX_LENGTH):type'slider'
public{tap4 = 1}:range(1,MAX_LENGTH):type'slider'
public{loop = 0.01}:range(0,1):type'slider'
public{recorder_state = 'on'}:options{'off','on'}
public{loop_length = 1000}:range(1,MAX_LENGTH)
public{reset = 0}
-- public{p_bucket = {}}


bucket = {}
write = 1
cv_mode = 0
inited = false

--public{bucket_size=#bucket}


function init()
    print("init crow streaming")
    -- stream rate is set to 60kHz so the crow memory buffer doesn't fill up
    -- input[1].mode('stream', 0.001) -- 1kHz
    local STREAM_RATE = 0.01 -- 10kHz
    input[1].mode('stream', STREAM_RATE) 

    -- for n=1,4 do output[n].slew = 0.002 end -- smoothing at nyquist
    for n=1,4 do output[n].slew = 0.002 end -- smoothing at nyquist
    -- bucket = {}
    for n=1,MAX_LENGTH  do 
        bucket[n] = 0 
    end -- clear the buffer
    inited = true
end

function reset()
    for n=1,MAX_LENGTH do bucket[n] = 0 end -- clear the buffer
    write = 1
end

function peek(tap)
    local ix = (math.floor(write - tap - 1) % MAX_LENGTH) + 1
    -- print(ix)
    return bucket[ix]
end

function poke(v, ix)
    -- local c = (input[2].volts / 4.5) + public.loop
    -- c = (c < 0) and 0 or c
    -- c = (c > 1) and 1 or c
    -- print("poke")
    local c = public.loop
    bucket[ix] = v + c*(bucket[ix] - v)
end

input[1].stream = function(v)
    if (inited == true) then
        if public.reset == 1 then 
            -- print("reset")
            public.reset = 0
            reset()
        else
            output[1].volts = peek(public.tap1)
            output[2].volts = peek(public.tap2)
            output[3].volts = peek(public.tap3)
            output[4].volts = peek(public.tap4)
            local record_cv = input[2].volts
            if public.recorder_state == "on" or record_cv >= 5 then
                poke(v, write)
            end

            if (write % public.loop_length) == 0 then
                -- print("MAX_LENGTH reached",public.loop_length)
            end
            write = (write % public.loop_length) + 1
        end
    end
end
