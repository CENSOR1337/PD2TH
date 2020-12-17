local LocalizationData = {}
local HTTP_request = "http://127.0.0.1/th.json"
local translateOption = {}

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
					LocalizationData = get_json_localized_string(jsonData)
				else
					-- offline mode do later (or maybe not cause lul)
					log("[PAYDAY 2 Localization Tool] : " .. "json failed")
				end
				LocalizationManager:add_localized_strings(LocalizationData)
			end
		)
	end
)
