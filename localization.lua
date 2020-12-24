local LocalizationData = {}
local HTTP_request = "http://127.0.0.1/localization/th.json"
local SaveFileName = "thai_loc.txt"
local translateOption = {}

function IsJsonValid(toValidJsonData)
	if type(toValidJsonData) ~= "string" then
		toValidJsonData = json.encode(toValidJsonData)
	end
	if type(toValidJsonData) == "string" then
		local stringJsonData = toValidJsonData:gsub("%s+", "")
		stringJsonData = string.gsub(toValidJsonData, "%s+", "")
		if (string.sub(stringJsonData, 1, 1) == "{" and string.sub(stringJsonData, -1) == "}") then
			return true
		else
			return false
		end
	end
	return false
end

function ReadJsonFile(file_path, open_mode)
	local file = io.open(file_path, open_mode)
	if file then
		local JsonSaveData = json.decode(file:read("*all"))
		file:close()
		if (IsJsonValid(JsonSaveData)) then
			return JsonSaveData
		else
			return {}
		end
	else
		return {}
	end
end

function get_json_localized_string(jsonData)
	local returnJsonData = {}
	if (jsonData) then
		for key, value in pairs(jsonData) do
			if (type(value) ~= "table") then
				if not (string.is_nil_or_empty(tostring(value))) and key then
					returnJsonData[key] = value
				end
			end
		end
		if table.getn(translateOption) > 0 then
			for key, value in pairs(translateOption) do
				if jsonData[tostring(value)] then
					for k, v in pairs(jsonData[tostring(value)]) do
						if not returnJsonData[k] then
							if not (string.is_nil_or_empty(tostring(v))) and k then
								returnJsonData[k] = v
							end
						end
					end
				end
			end
		end
	end
	return returnJsonData
end

LocalizationData = ReadJsonFile(SavePath .. SaveFileName, "r")
Hooks:Add(
	"LocalizationManagerPostInit",
	"LocalizationManagerPostInit_Loc",
	function(self)
		LocalizationManager:add_localized_strings(get_json_localized_string(LocalizationData))

		dohttpreq(
			HTTP_request,
			function(data)
				if (IsJsonValid(data)) then
					local file = io.open(SavePath .. SaveFileName, "w")
					if file then
						file:write(json.encode(json.decode(data)))
						file:close()
					end
					LocalizationData = ReadJsonFile(SavePath .. SaveFileName, "r")
					LocalizationManager:add_localized_strings(get_json_localized_string(LocalizationData))
				end
			end
		)
	end
)

function LocalizationManager.text(self, str, macros)
	if self._custom_localizations[str] then
		local return_str = self._custom_localizations[str]
		self._macro_context = macros
		return_str = self:_localizer_post_process(return_str)
		self._macro_context = nil
		if macros and type(macros) == "table" then
			for k, v in pairs(macros) do
				return_str = return_str:gsub("$" .. k, v)
			end
		end
		return return_str
	end
	return self.orig.text(self, str, macros)
end
