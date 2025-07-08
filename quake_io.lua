function importLmpPal(filename)
    local f = assert(io.open(filename, "r"))
    if not f then
        app.alert("Cannot open " + filename)
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

function exportSprLmpPal(filename)
    local spr = app.sprite
    if spr.width ~= 16 or spr.height ~= 16 then
        app.alert("Sprite must be 16x16 pixels! \n Aborted") 
        return
    end
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