local LocaleData = {
    locales = {},
    size = 0,
}
local HTTP_request = "http://censor1337.github.io/PD2_Localizations/localization/th.json"
local SaveFileName = "thai_loc.txt"
local locFilePath = ("%s%s"):format(SavePath, SaveFileName)

local function tableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

local function readJsonFile(file_path)
    local file = io.open(file_path, "r")
    if (file) then
        local JsonSaveData = json.decode(file:read("*all"))
        file:close()
        return JsonSaveData or {}
    end
    return {}
end

LocaleData.locales = readJsonFile(locFilePath)
LocaleData.size = tableSize(LocaleData.locales)

local function initLocale()
    if (LocaleData.size <= 0) then return end
    local locData = {}
    for stringId, locale in pairs(LocaleData.locales) do
        locData[stringId] = locale
    end
    LocalizationManager:add_localized_strings(locData)
end

Hooks:Add("MenuManagerOnOpenMenu", "OnRequestLocalization", function(self, menu)
    if (menu ~= "menu_main" and menu ~= "lobby") then return end
    if not (managers.network and managers.network.account) then return end

    initLocale()
    dohttpreq(HTTP_request, function(resp)
        local file = io.open(locFilePath, "w")
        if (file) then
            file:write(resp)
            file:close()
        end
        local data = readJsonFile(locFilePath)
        LocaleData.locales = data
        LocaleData.size = tableSize(data)
        initLocale()
    end)

    if (LocaleData.size > 0) then return end
    local notification_data = {
        title = "อัปเดต",
        text = "กรุณาเริ่มเกมใหม่เพื่อประสิทธิภาพของส่วนเสริมภาษาไทย",
        button_list = { { text = "ตกลง", is_cancel_button = true } },
        id = tostring(math.random(0, 0xFFFFFFFF)),
    }
    managers.system_menu:show(notification_data)
end)
