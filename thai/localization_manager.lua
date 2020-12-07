local text_original = LocalizationManager.text
Localization_Data = {}

HTTP_request = "http://127.0.0.1/menu.json"

Hooks:Add(
	"LocalizationManagerPostInit",
	"LocalizationManagerPostInit_THLoc",
	function(self)
		dohttpreq(
			HTTP_request,
			function(data)
				Localization_Data = json.decode(data)
			end
		)
	end
)

function LocalizationManager:text(string_id, macros, ...)
	if (Localization_Data) then
		if (string_id) then
			if (Localization_Data[string_id]) then
				local str = text_original(self, string_id, ...)
				if not str:match("ERROR") then
					str = Localization_Data[string_id]

					if macros and type(macros) == "table" then
						for k, v in pairs(macros) do
							str = str:gsub("$" .. k, v)
						end
					end
					return str, string_id, macros, ...
				end
			end
		end
	end
	return text_original(self, string_id, macros, ...)
end
