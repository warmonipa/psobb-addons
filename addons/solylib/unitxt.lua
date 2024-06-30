local unitxtPointer = 0x00A9CD50
local specialBaseID = 0x005E4CBB
--unitxtItemName = 0x04
--unitxtMonsterName = 0x08
--unitxtItemDesc = 0x0C
--unitxtMonsterNameUlt = 0x10

local srankSpecial =
{
    "", "Jellen", "Zalure", "HP Regeneration", "TP Regeneration",
    "Burning", "Tempest", "Blizzard", "Arrest", "Chaos", "Hell",
    "Spirit", "Berserk", "Demon's", "Gush", "Geist", "King's",
}
local magColor =
{
    "Red", "Blue", "Yellow", "Green", "Purple", "Black", "White",
    "Cyan", "Brown", "Orange", "Slate Blue", "Olive", "Turquoise",
    "Fuchsia", "Grey", "Cream", "Pink", "Dark Green",
}

local magColor2 =
{
    "0xFFFF0000", "0XFF0000FF", "0xFFEAF718", "0XFF00FF00", "0XFF79085E", "0XFF252321", "0XFFFFFFFF",
    "0XFF008080", "0XFF3D1C16", "0XFFFF8800", "0XFF647580", "0XFFB5B35C", "0XFF508498",
    "0XFFFD3F92", "0XFFB9BBBE", "0XFFF8E7AF", "0XFFFF0084", "0XFF374333",
}

-- Internal function to read text from the unitxt.
-- Note that the unitxt is reloaded at the main menu, so this function
-- will return nil in that case.
local function _Read(group, index)
    local address = pso.read_u32(unitxtPointer)
    if address == 0 then
        return nil
    end

    address = address + (group * 4)
    address = pso.read_u32(address)
    if address == 0 then
        return nil
    end

    address = address + 4 * index
    address = pso.read_u32(address)
    if address == 0 then
        return nil
    end

    return pso.read_wstr(address, -1)
end

-- Public function to read a string from a
-- given string group in the unitxt
local function Read(group, index)
    return _Read(group, index)
end

-- Reads item names from the unitxt with the given id, from the PMT data
local function GetItemName(index)
    if index == -1 then
        return "???"
    end
    return _Read(1, index)
end

-- Reads a special name based on it's index
local function GetSpecialName(id)
    if id == 0 then
        return "None"
    end

    local baseID = pso.read_u32(specialBaseID)
    return GetItemName(baseID + id)
end

-- Reads a monster name based on it's ID.
-- If ultimate is true, ultimate names will be used
local function GetMonsterName(index, ultimate)
    ultimate = ultimate or false
    if ultimate then
        return _Read(4, index)
    else
        return _Read(2, index)
    end
end

-- Reads a technique names based on the technique ID
local function GetTechniqueName(id)
    return _Read(5, id)
end

-- Reads class names based on the class ID
local function GetClassName(id)
    return _Read(8, id)
end

-- Reads section ID names based on the section ID
local function GetSectionIDName(id)
    return _Read(72, id)
end

-- Reads photon blast names based on it's id
-- If shortName is true, only the first character
-- of the name will be read
local function GetPhotonBlastName(id, shortName)
    shortName = shortName or false

    if id < 0 then
        return " "
    end

    -- unitxt may be unloaded
    local result = _Read(9, id) or " "
    if shortName == true then
        result = string.sub(result, 1, 1)
    end

    return result
end

-- Reads the encoded srank name from the item data
local function GetSRankName(itemData)
    if itemData == nil then
        return "Null"
    end
    if table.getn(itemData) < 12 then
        return "Invalid length"
    end

    local result = ""
    local temp = 0
    for i=1,6,2 do
        local n = bit.lshift(itemData[7 + i - 1], 8) + itemData[8 + i - 1]
        n = n - 0x8000

        temp = math.floor(n / 0x400) + 0x40
        if temp > 0x40 and temp < 0x60 and i ~= 1 then
            result = result .. string.char(temp)
        end
        n = n % 0x400

        temp = math.floor(n / 0x20) + 0x40
        if temp > 0x40 and temp < 0x60 then
            result = result .. string.char(temp)
        end
        n = n % 0x20

        temp = n + 0x40
        if temp > 0x40 and temp < 0x60 then
            result = result .. string.char(temp)
        end
    end
    return result
end

-- Reads srank special name
local function GetSRankSpecialName(index)
    -- adjust index to lua 1 based crap
    index = index + 1
    if index > table.getn(srankSpecial) then
        return "Invalid special"
    end

    return srankSpecial[index]
end

-- Reads mag color name
local function GetMagColor(index)
    -- adjust index to lua 1 based crap
    index = index + 1
    if index > table.getn(magColor) then
        return "Not set"
    end

    return magColor[index]
end

-- Reads mag color RGB
local function GetMagColor2(index)
    -- adjust index to lua 1 based crap
    index = index + 1
    if index > table.getn(magColor2) then
        -- default mag color Brown
        return magColor2[magColor['Brown']]
    end

    return magColor2[index]
end

local function AddServerMagColors(server)
    if server == 1 then -- Vanilla

    elseif server == 2 then -- Ultima

    elseif server == 3 then -- Ephinea

        local ephineaNewMagColors = {
            "Chartreuse", "Azure", "Royal Purple",
            "Ruby", "Sapphire", "Emerald",
            "Gold", "Silver", "Bronze",
            "Plum", "Violet", "Goldenrod"
        }

        local ephineaNewMagColors2 = {
            "0XFFBFBF6C", "0XFF7FCEE2", "0XFF7851A9",
            "0XFFCE2D46", "0XFF385F8F", "0XFF046307",
            "0XFFA57C00", "0XFFC7D1DA", "0XFF88540B",
            "0XFF9C51B6", "0XFF8806CE", "0XFFFCD667"
        }

        for i=1,table.getn(ephineaNewMagColors) do
            -- 1 based indexes...
            magColor[table.getn(magColor) + 1] = ephineaNewMagColors[i]

            -- add ephinea new mag RGB colors
            magColor2[table.getn(magColor2) + 1] = ephineaNewMagColors2[i]
        end

    elseif server == 4 then -- Schthack

    end
end

return
{
    Read = Read,
    GetItemName = GetItemName,
    GetSpecialName = GetSpecialName,
    GetMonsterName = GetMonsterName,
    GetTechniqueName = GetTechniqueName,
    GetClassName = GetClassName,
    GetSectionIDName = GetSectionIDName,
    GetPhotonBlastName = GetPhotonBlastName,

    -- Not actually related to unitxt
    GetSRankName = GetSRankName,
    GetSRankSpecialName = GetSRankSpecialName,
    GetMagColor = GetMagColor,
    GetMagColor2 = GetMagColor2,
    AddServerMagColors = AddServerMagColors,
}
