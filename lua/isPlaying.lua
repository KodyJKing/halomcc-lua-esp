local function isPlaying()
    local paused = readBytes("halo1.dll+2AECAC8") == 1
    local focused = getOpenedProcessID() == getForegroundProcess()
    return not paused and focused
end
return isPlaying