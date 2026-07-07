local ThemeManager = {
    Folder = "Library",
    OldThemes = {},
    Library = nil
}

function ThemeManager:EnsureFolder(onlyCheck)
    if onlyCheck then
        return isfolder(self.Folder) and isfolder(self.Folder .. "/Themes")
    end

    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end

    local themeFolder = self.Folder .. "/Themes"
    if not isfolder(themeFolder) then
        makefolder(themeFolder)
    end
    return themeFolder
end

function ThemeManager:GetThemes()
    local themesFolder = self:EnsureFolder()
    if not themesFolder then
        return {}
    end

    local themes = table.clone(self.OldThemes)
    for _, file in listfiles(themesFolder) do
        local name = file:match("([^/\\]+)%.json$")

        if name then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(file))

            if ok then
                themes[name] = data
            else
                warn(("[ ThemeManager ] Failed to load theme '%s'"):format(file))
            end
        end
    end

    return themes
end

function ThemeManager:RefreshList()
    self.Library.Themes = self:GetThemes()
end

function ThemeManager:init(Library)
    if ThemeManager.Library then
        warn("[ ThemeManager ] ThemeManager is already initialized")
        return
    end

    ThemeManager.Library = Library
    ThemeManager.OldThemes = Library.Themes

    if Library.Name and type(Library.Name) == "string" then
        ThemeManager.Folder = Library.Name
    end

    ThemeManager:RefreshList()
end

return ThemeManager
