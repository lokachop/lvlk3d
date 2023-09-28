-- most based off LvLK3D
LvLK3D = LvLK3D or {}
LvLK3D.Textures = LvLK3D.Textures or {}

local function readByte(fileObject)
    return string.byte(fileObject:read(1))
end

local function closeFile(fileObject)
    fileObject:close()
end

local function readAndGetFileObject(path)
    local f = love.filesystem.newFile(path)
    f:open("r")
    return f
end

local function readString(fileObject)
    -- read the 0A (10)
    local readCont = readByte(fileObject)
    if readCont ~= 10 then
        return "nostring :("
    end

    local buff = {}
    for i = 1, 4096 do -- read long strings
        readCont = readByte(fileObject)
        if readCont == 10 then
            break
        end

        buff[#buff + 1] = string.char(readCont)
    end

    return table.concat(buff, "")
end

local function readUntil(fileObject, stopNum)
    local readCont
    local buff = {}
    for i = 1, 2048 do -- read big nums
        readCont = readByte(fileObject)
        if readCont == stopNum then
            break
        end

        buff[#buff + 1] = string.char(readCont)
    end
    return table.concat(buff, "")
end

-- ppm files are header + raw data which is EZ
function LvLK3D.NewTexturePPM(name, path)
    print("---LvLK3D-PPMLoad---")
    print("Loading texture at \"" .. path .. "\"")


    local fObj = readAndGetFileObject(path)
    local readCont = readByte(fObj)
    if readCont ~= 80 then
        closeFile(fObj)
        error("PPM Decode error! (header no match!) [" .. readCont .. "]")
        return
    end

    readCont = readByte(fObj)
    if readCont ~= 54 then
        closeFile(fObj)
        error("PPM Decode error! (header no match!) [" .. readCont .. "]")
        return
    end
    readCont = readByte(fObj)
    -- string, read until next 10
    if readCont == 10 then
        local fComm = readUntil(fObj, 10)
        print("Comment; \"" .. fComm .. "\"")
    end

    -- read the width and height
    local w = tonumber(readUntil(fObj, 32))
    local h = tonumber(readUntil(fObj, 10))

    local cDepth = tonumber(readUntil(fObj, 10))
    print("Texture is " .. w .. "x" .. h .. " with a coldepth of " .. cDepth)


    local canvasData = love.graphics.newCanvas(w, h)
    local _oldCanvas = love.graphics.getCanvas()
    local _oldShader = love.graphics.getShader()
    -- slow pixel loading
    love.graphics.setCanvas(canvasData)
    local pixToRead = w * h
    for i = 0, (pixToRead - 1) do
        local r = readByte(fObj) / cDepth
        local g = readByte(fObj) / cDepth
        local b = readByte(fObj) / cDepth


        love.graphics.setColor(r, g, b)
        local xc = (i % w)
        local yc = math.floor(i / w)


        love.graphics.rectangle("fill", xc, yc, 1, 1)
    end
    closeFile(fObj)

    love.graphics.setCanvas(_oldCanvas)
    love.graphics.setShader(_oldShader)

    LvLK3D.Textures[name] = canvasData
end


LvLK3D.NewTexturePPM("loka",       "textures/loka.ppm")
LvLK3D.NewTexturePPM("jelly",      "textures/jelly.ppm")
LvLK3D.NewTexturePPM("jet",        "textures/jet.ppm")
LvLK3D.NewTexturePPM("mandrill",   "textures/mandrill.ppm")
LvLK3D.NewTexturePPM("none",       "textures/loka.ppm")

LvLK3D.NewTexturePPM("loka_sheet",         "textures/loka_sheet.ppm")
LvLK3D.NewTexturePPM("train_sheet",        "textures/train_sheet.ppm")
LvLK3D.NewTexturePPM("traintrack_sheet",   "textures/traintrack_sheet.ppm")
LvLK3D.NewTexturePPM("cubemap",            "textures/cubemap_lq.ppm")

function LvLK3D.GetTexture(name)
    local tex = LvLK3D.Textures[name]
    if not tex then
        return LvLK3D.Textures["none"]
    end

    return tex
end

function LvLK3D.NewTextureEmpty(name, w, h, col)
    local canvasData = love.graphics.newCanvas(w, h)
    local _oldCanvas = love.graphics.getCanvas()
    local _oldShader = love.graphics.getShader()

    love.graphics.setCanvas(canvasData)
        love.graphics.clear(col[1] / 255, col[2] / 255, col[3] / 255)
    love.graphics.setCanvas(_oldCanvas)
    love.graphics.setShader(_oldShader)


    LvLK3D.Textures[name] = canvasData
end

function LvLK3D.NewTextureFunc(name, w, h, func)
    local canvasData = love.graphics.newCanvas(w, h)
    local _oldCanvas = love.graphics.getCanvas()
    local _oldShader = love.graphics.getShader()

    love.graphics.setCanvas(canvasData)
        for i = 0, ((w * h) - 1) do
            local xc = i % w
            local yc = math.floor(i / w)
            local fine, dataFunc = pcall(func, xc, yc)
            if not fine then
                print("TextureInit error!;" .. dataFunc)
                dataFunc = {255, 255, 0}
            end

            love.graphics.setColor(dataFunc[1] / 255, dataFunc[2] / 255, dataFunc[3] / 255)
            love.graphics.rectangle("fill", xc, yc, 1, 1)
        end
    love.graphics.setCanvas(_oldCanvas)
    love.graphics.setShader(_oldShader)
    LvLK3D.Textures[name] = canvasData
end

function LvLK3D.RenderTexture(name, func)
    local canvasData = love.graphics.newCanvas(w, h)
    local _oldCanvas = love.graphics.getCanvas()
    local _oldShader = love.graphics.getShader()

    love.graphics.setCanvas(canvasData)
        func()
    love.graphics.setCanvas(_oldCanvas)
    love.graphics.setShader(_oldShader)
end

function LvLK3D.SetTextureFilter(name, near, far)
    LvLK3D.Textures[name]:setFilter(near, far or near)
end

function LvLK3D.SetTextureWrap(name, mode)
    LvLK3D.Textures[name]:setWrap(mode)
end

LvLK3D.NewTextureEmpty("white", 16, 16, {255, 255, 255})