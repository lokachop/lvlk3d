LvLK3D = LvLK3D or {}
-- TODO render meshes
local function renderObject(obj)
    local shad = LvLK3D.CurrShader
    love.graphics.setShader(shad)
    shad:send("mdlMatrix", obj.mat_mdl)
    shad:send("viewMatrix", LvLK3D.CamMatrix_Rot * LvLK3D.CamMatrix_Trans)
    shad:send("projectionMatrix", LvLK3D.CamMatrix_Proj)

    local oCol = obj.col
    love.graphics.setColor(oCol[1], oCol[2], oCol[3])
    love.graphics.draw(obj.mesh)

    love.graphics.setShader()
end



function LvLK3D.RenderActiveUniverse()
    love.graphics.setCanvas({LvLK3D.CurrRT, depth = true})
        for k, v in pairs(LvLK3D.CurrUniv["objects"]) do
            renderObject(v)
        end
    love.graphics.setCanvas()
end

