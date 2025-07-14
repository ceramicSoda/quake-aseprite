require "q_helpers"

function parseHeader(data)
    local header = {}
    local offset = 5
    header.magic = data:sub(1,4)
    header.version, offset = string.unpack("<I4", data, offset)
    header.type, offset = string.unpack("<I4", data, offset)
    header.radius, offset = string.unpack("<f", data, offset)
    header.maxwidth, offset = string.unpack("<I4", data, offset)
    header.maxheight, offset = string.unpack("<I4", data, offset)
    header.nframes, offset = string.unpack("<I4", data, offset)
    header.beamlength, offset = string.unpack("<f", data, offset)
    header.synchtype, offset = string.unpack("<I4", data, offset)
    return header, offset
end

function parseFrame(data, spr, offset)
    local frame = {}
    -- local img = spr.cels[1].image
    frame.group, offset = string.unpack("<I4", data, offset)
    if frame.group == 0 then -- usual case
        frame.ofsx, offset = string.unpack("<i4", data, offset)
        frame.ofsy, offset = string.unpack("<i4", data, offset)
        frame.height, offset = string.unpack("<I4", data, offset)
        frame.width, offset = string.unpack("<I4", data, offset)
        frame.pic = {}
        for i = 0, (frame.width - 1) do
            frame.pic[i] = {}
            for j = 0, (frame.height - 1) do
                frame.pic[i][j] = data:byte(offset) + 1
                offset = offset + 1;
            end
        end
    end

    return frame, offset
end

function importSpr(filename)
    local f = assert(io.open(filename, "rb"))
    if not f then
        app.alert("Cannot open " .. filename)
        return
    end
    local data = f:read("*all")
    f:close()
    if #data < 32 then
        app.alert("File " .. filename .. " is broken")
        return
    end

    local header, offset = parseHeader(data)
    local spr = Sprite(header.maxwidth, header.maxheight, ColorMode.INDEXED)
    local pal = getDefaultPalette();
    local frames = {}
    spr.filename = filename
    spr:setPalette(pal)
    

    if header.nframes < 1 then
        app.alert("No frames in sprite")
        return
    end

    for i = 1, header.nframes do
        -- local frame = spr.frames[1]
        -- if i > 1 then
        --     spr:newFrame(spr.frames[i])
        -- end
        -- offset = parseFrame(data, frame.sprite, offset)
        frames[i], offset = parseFrame(data, nil, offset)
    end

    for i = 1, header.nframes do
        local frame = spr.frames[1]
        if i > 1 then
            frame = spr:newFrame(frame)
        end
        local img = frame.sprite.cels[1].image
        local curFrame = header.nframes + 1 - i
        for j = 0, (frames[curFrame].height - 1) do
            for k = 0, (frames[curFrame].width - 1) do
                img:putPixel(j, k, frames[curFrame].pic[k][j])
            end
        end
    end

    -- app.alert("Magic: " .. header.magic .. " radius: " .. header.radius .. " w:" .. header.maxwidth .. " h: " .. header.maxheight .. ' offset: ' .. offset)
end