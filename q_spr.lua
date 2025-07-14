require "q_helpers"

-- Sprite file import
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
end

-- Sprite file export
function packHeader(spr, settings)
    local header = "IDSP"
    local maxSize = math.max(spr.height, spr.width)
    header = header .. string.pack("<I4", 1) -- version
    header = header .. string.pack("<I4", settings.type) -- type
    header = header .. string.pack("<f", (maxSize * 0.7)) -- radius
    header = header .. string.pack("<I4", spr.width) -- maxWidth
    header = header .. string.pack("<I4", spr.height) -- maxHeight
    header = header .. string.pack("<I4", #spr.frames) -- nframes   
    header = header .. string.pack("<f", 0) -- beam, not used
    header = header .. string.pack("<I4", settings.synchtype) -- 0 to sync animation between instances
    return header
end

function packFrame(spr, frame)
    local data = ""
    local img = Image(spr.spec)
    local qPal = getDefaultPalette()
    img:drawSprite(spr, frame)
    data = data .. string.pack("<I4", 0) -- group
    data = data .. string.pack("<i4", math.floor(-spr.width / 2)) -- offset x
    data = data .. string.pack("<i4", math.floor(spr.height / 2)) -- offset y
    data = data .. string.pack("<I4", spr.width) -- width
    data = data .. string.pack("<I4", spr.height) -- height
    for i = 0, (spr.height - 1) do
        for j = 0, (spr.width - 1) do
            local c = img:getPixel(j, i)
            if spr.colorMode == ColorMode.INDEXED then
                if c == 0 then
                    c = 256
                end
                c = math.min(255, math.max(0, c - 1))
                data = data .. string.char(c)
            else
                local pIdx = approxColor(Color(c), qPal)
                data = data .. string.char(pIdx)
            end
        end
    end
    return data 
end

function exportSpr(filename, settings)
    local spr = app.sprite
    local f = assert(io.open(filename, "wb"))
    spr.filename = filename
    local header = packHeader(spr, settings)
    for i = 1, #spr.frames do
        local frameData = packFrame(spr, spr.frames[i])
        header = header .. frameData
    end
    f:write(header)
    io.close(f)
    app.alert("Done!")
end