--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

2D ray beam to check for intersections with objects in the world.

]]--
--[[ ================================================ ]]--

---requirements
local RayBeam2D = ISBaseObject:derive("RayBeam2D")


function RayBeam2D:_checkForIntersectedObject()

end


function RayBeam2D:castRay()

end





function RayBeam2D:new(startPoint, vectorBeam, _ignoredObjects)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- parameters
    o.startPoint = startPoint
    o.vectorBeam = vectorBeam
    o.ignoredObjects = _ignoredObjects or {}

    -- initialize vectors and values used in casting the ray
    o.beamLength = vectorBeam:getLength()
    local x1, y1, z = startPoint.x, startPoint.y, startPoint.z
    o.x1, o.y1, o.z = x1, y1, z
    o.farPoint = {x = x1 + vectorBeam:getX(), y = y1 + vectorBeam:getY()}
    local deltaLength = 0.01
    o.deltaVector = vectorBeam:clone():setLength(deltaLength)

    return o
end



