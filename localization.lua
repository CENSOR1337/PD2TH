local LocalizationData = {}
local HTTP_request = "https://mw.ac.th/localization/th.json"

local translateOption = {"subtitle", "menu"}

Hooks:Add(
	"LocalizationManagerPostInit",
	"LocalizationManagerPostInit_Loc",
	function(self)
		dohttpreq(
			HTTP_request,
			function(data)
				local jsonEncodeData = json.encode(data)

				local stringJsonData = string.gsub(jsonEncodeData, "%s+", "")
				local firstStringJsonChar = string.sub(stringJsonData, 2, 2)
				local lengthStringJson = string.len(stringJsonData)
				local lastStringJsonChar = string.sub(stringJsonData, lengthStringJson - 1, lengthStringJson - 1)

				if (firstStringJsonChar == "{" and lastStringJsonChar == "}") then
					local jsonData = json.decode(data)
					if (jsonData) then
						for key, value in pairs(translateOption) do
							for k, v in pairs(jsonData[tostring(value)]) do
								if not (string.is_nil_or_empty(tostring(v))) and k then
									LocalizationData[k] = v
								end
							end
						end
						LocalizationManager:add_localized_strings(LocalizationData)
					end
				else
					-- offline mode do later
					log("json failed")
				end
			end
		)
	end
)
