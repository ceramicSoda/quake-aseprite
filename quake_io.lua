function importLmpPal(filename)
    local f = assert(io.open(filename, "r"))
    if not f then
        app.alert("Cannot open " + filename)
        return
    end
    local data = f:read("*all")
    f:close()

    if #data < 768 then
        app.alert("File is too small to be a palette :( ")
        return
    end

    local pal = Palette(256)
    local spr = Sprite(16, 16, ColorMode.INDEXED)
    local img = spr.cels[1].image

    for i = 0, 255 do
      local r = data:byte(i*3 + 1)
      local g = data:byte(i*3 + 2)
      local b = data:byte(i*3 + 3)

      local color = Color{ r=r, g=g, b=b }
      pal:setColor(i, color)

      local x = i % 16
      local y = math.floor(i / 16)
      img:putPixel(x, y, i)
    end

    spr:setPalette(pal)
    app.refresh()
end