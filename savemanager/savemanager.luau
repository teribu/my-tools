local HttpService = game:GetService("HttpService")
local SaveManager = {
    Folder = "Teddy",
    Library = nil,
    Data = {}
}

function SaveManager:Save()
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end

    local path = self.Folder .. "/config.json"
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, self.Data)

    if not ok then
        warn("[ Save Manager ] Failed to encode config")
        return
    end

    return writefile(path, encoded)
end

function SaveManager:Load()
    if not SaveManager.Library then
        return
    end

    if not isfolder(self.Folder) then
        return
    end

    local path = self.Folder .. "/config.json"
    if not isfile(path) then
        return
    end

    local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(path))

    if not ok then
    warn("[ SaveManager ] Invalid config")
        return
    end

    for flag, value in data do
        local option = self.Library.Options[flag]

        if option then
            option:SetValue(value)
        end
    end

    return data
end

function SaveManager:init(Library)
    if SaveManager.Library then
        warn("[ SaveManager ] SaveManager is already initialized")
        return
    end
    SaveManager.Library = Library

    local initializing = true

    for flag, element in Library.Options do
        SaveManager.Data[flag] = element.Value

        element:OnChanged(function(Value)
            SaveManager.Data[flag] = Value

            if not initializing then
                SaveManager:Save()
            end
        end)
    end

    initializing = false
    return true
end

return SaveManager
