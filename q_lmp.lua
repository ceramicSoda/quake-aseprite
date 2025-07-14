require "q_helpers"

function validateSizes(height, width, len)
    local valid = true
    if width < 1 or width > 2048 or height < 1 or height > 2048 then
        app.alert("Image has wrong dimensions")
        valid = false
    elseif len ~= (height * width + 8) then
        app.alert("Image data may be corrupted")
        valid = true
    end

    if valid then
        return height, width, 8
    else    -- guessing sizes for files like pop.lmp 
        height = math.floor(math.sqrt(len))
        return height, height, 0
    end
end

-- Palette file import
function importLmpPal(filename)
    local f = assert(io.open(filename, "rb"))
    if not f then
        app.alert("Cannot open " .. filename)
        return
    end
    local data = f:read("*all")
    f:close()
    local pal = Palette(257) -- since first color always transparent
    local spr = Sprite(16, 16, ColorMode.INDEXED)
    local img = spr.cels[1].image

    for i = 0, 255 do
        local pIndex = i + 1; 
        local r = data:byte(i*3 + 1)
        local g = data:byte(i*3 + 2)
        local b = data:byte(i*3 + 3)

        local clr = Color{ r=r, g=g, b=b }
        pal:setColor(pIndex, clr)

        local x = i % 16
        local y = math.floor(i / 16)
        img:putPixel(x, y, pIndex)
    end

    spr:setPalette(pal)
    app.refresh()
end

-- Regular image file import
function importLmp(filename)
    local f = assert(io.open(filename, "rb"))
    if not f then
        app.alert("Cannot open " + filename)
        return
    end
    local data = f:read("*all")
    f:close()

    local offset = 8;
    local width = string.unpack("<I4", data:sub(1,4))
    local height = string.unpack("<I4", data:sub(5,8))
    width, height, offset = validateSizes(width, height, data:len())

    local spr = Sprite(width, height, ColorMode.INDEXED)
    local img = spr.cels[1].image
    local pal = getDefaultPalette();
    spr.filename = filename
    spr:setPalette(pal)

    for i = 0, width do
        for j = 0, height do
            local pos = (offset) + i + j * width + 1
            local idx = 0
            if (data:byte(pos) ~= nil) then
                if (data:byte(pos) < 255) then
                    idx = data:byte(pos) + 1
                end
            end
            img:putPixel(i, j, idx)
        end
    end
end

-- Palette file export
function exportLmpPal(filename)
    local spr = app.sprite
    if spr.width ~= 16 or spr.height ~= 16 then
        app.alert("Sprite must be 16x16 pixels! Aborted")
        return
    end
    spr.filename = filename
    local img = Image(spr.spec)
    img:drawSprite(spr, app.frame)

    local f = assert(io.open(filename, "wb"))
    io.output(f)
    for i = 0, 255 do
        local x = i % 16
        local y = math.floor(i / 16)
        local c = img:getPixel(x, y)
        if spr.colorMode == ColorMode.INDEXED then
            local clr = spr.palettes[app.frame.frameNumber]:getColor(c)
            f:write(string.char(clr.red, clr.green, clr.blue))
        else
            local r = app.pixelColor.rgbaR(c)
            local g = app.pixelColor.rgbaG(c)
            local b = app.pixelColor.rgbaB(c)
            f:write(string.char(r, g, b))
        end
    end
    io.close(f)
    app.alert("Done!") 
end

-- Regular image file export
function exportLmp(filename)
    local spr = app.sprite
    local f = assert(io.open(filename, "wb"))
    if #spr.palettes[1] < 255 and spr.colorMode == ColorMode.INDEXED then
        app.alert("Warning! The sprite palette has less than 256 colors")
    end
    local img = Image(spr.spec)
    local height = spr.height;
    local width = spr.width;
    local qPal = getDefaultPalette()

    if spr.colorMode ~= ColorMode.INDEXED then
        if height * width > 100000 then
            app.alert("!!! The file is too big, Aseprite may freeze !!!")
        end
    end

    f:write(string.pack("<I4", width))
    f:write(string.pack("<I4", height))
    for i = 0, (height - 1) do
        for j = 0, (width - 1) do
            local c = img:getPixel(j, i)
            if spr.colorMode == ColorMode.INDEXED then
                c = math.min(255, math.max(0, c - 1))
                f:write(string.char(c))
            else
                local pIdx = approxColor(Color(c), qPal)
                f:write(string.char(pIdx))
            end
        end
    end
    io.close(f)
    app.alert("Done!") 
end