--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Noise map tools of TLOU Spores. Used to calculate a linear interpolation function.

]]--
--[[ ================================================ ]]--

--- CACHING
-- module
local DoggyAPI = require "DoggyAPI_module"
local NOISEMAP = DoggyAPI.NOISEMAP

-- random
local NOISEMAP_RANDOM = newrandom()


-- Random gradient generator (deterministic using math.randomseed)
---@param x integer
---@param y integer
---@param MINIMUM_NOISE_VECTOR_VALUE number
---@param MAXIMUM_NOISE_VECTOR_VALUE number
---@param X_SEED integer
---@param Y_SEED integer
---@param OFFSET_SEED integer
---@return table
NOISEMAP.randomGradient = function(x, y, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE, X_SEED, Y_SEED, OFFSET_SEED)
    local seed = x * X_SEED + y * Y_SEED + OFFSET_SEED
    NOISEMAP_RANDOM:seed(seed)
    return table.newarray( -- Random vector
        NOISEMAP_RANDOM:random(MINIMUM_NOISE_VECTOR_VALUE,MAXIMUM_NOISE_VECTOR_VALUE) * 2 - 1,
        NOISEMAP_RANDOM:random(MINIMUM_NOISE_VECTOR_VALUE,MAXIMUM_NOISE_VECTOR_VALUE) * 2 - 1
    )
end

---Perlin-style 2D noise at specific coordinates.
---
---You can have x and y be anything, as long as it's consistent you can generate a noise map. These can be square tile coordinates, chunk coordinates, or even cells coordinates.
---@param x integer
---@param y integer
---@param NOISE_MAP_SCALE integer
---@param MINIMUM_NOISE_VECTOR_VALUE number
---@param MAXIMUM_NOISE_VECTOR_VALUE number
---@param X_SEED integer
---@param Y_SEED integer
---@param OFFSET_SEED integer
---@return number
NOISEMAP.getNoiseValue = function(
    x,y,
    NOISE_MAP_SCALE,
    MINIMUM_NOISE_VECTOR_VALUE,MAXIMUM_NOISE_VECTOR_VALUE,
    X_SEED, Y_SEED, OFFSET_SEED
)
    -- Scale coordinates
    local scaledX = x / NOISE_MAP_SCALE
    local scaledY = y / NOISE_MAP_SCALE

    -- Grid cell coordinates
    local x0 = scaledX - scaledX%1
    local x1 = x0 + 1
    local y0 = scaledY - scaledY%1
    local y1 = y0 + 1

    -- Compute noise values at each corner
    local gradient = NOISEMAP.randomGradient(x0, y0, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE, X_SEED, Y_SEED, OFFSET_SEED)
    local n00 = (scaledX - x0) * gradient[1] + (scaledY - y0) * gradient[2]

    local gradient = NOISEMAP.randomGradient(x1, y0, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE, X_SEED, Y_SEED, OFFSET_SEED)
    local n10 = (scaledX - x1) * gradient[1] + (scaledY - y0) * gradient[2]

    local gradient = NOISEMAP.randomGradient(x0, y1, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE, X_SEED, Y_SEED, OFFSET_SEED)
    local n01 = (scaledX - x0) * gradient[1] + (scaledY - y1) * gradient[2]

    local gradient = NOISEMAP.randomGradient(x1, y1, MINIMUM_NOISE_VECTOR_VALUE, MAXIMUM_NOISE_VECTOR_VALUE, X_SEED, Y_SEED, OFFSET_SEED)
    local n11 = (scaledX - x1) * gradient[1] + (scaledY - y1) * gradient[2]

    -- Interpolate noise values
    local sx = scaledX - x0
    local sy = scaledY - y0
    local nx0 = n00 + (n10 - n00) * sx
    local nx1 = n01 + (n11 - n01) * sx
    local value = nx0 + (nx1 - nx0) * sy

    -- Normalize to [0, 1] (optional)
    return (value + 1) / 2
end

