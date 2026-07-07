local HttpService = game:GetService("HttpService")
local SaveManager = {
    Folder = "Library",
    Username = game:GetService("Players").LocalPlayer.Name,
    Library = nil,
    Data = {}
}

function SaveManager:EnsureFolder(onlyCheck)
    if onlyCheck then
        return isfolder(self.Folder) and isfolder(self.Folder .. "/Configs") and isfolder(self.Folder .. "/Configs/" .. self.Username)
    end

    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end

    local configsFolder = self.Folder .. "/Configs"
    if not isfolder(configsFolder) then
        makefolder(configsFolder)
    end

    local userFolder = configsFolder .. "/" .. self.Username
    if not isfolder(userFolder) then
        makefolder(userFolder)
    end

    return userFolder
end

function SaveManager:Save()
    local path = self:EnsureFolder() .. "/config.json"
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

    if not self:EnsureFolder(true) then
        return
    end

    local path = self.Folder .. "/Configs/" .. self.Username .. "/config.json"
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

    if Library.Name and type(Library.Name) == "string" then
        SaveManager.Folder = Library.Name
    end

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
    SaveManager:Load()
    return true
end

return SaveManager
