ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local scenes = {}

RegisterNetEvent('opis2:fetch', function()
    local _source = source
    TriggerClientEvent('opis2:send', _source, scenes)

end)

RegisterNetEvent('opis2:add', function(coords, message, color, distance)
    local _source = source
    local xPlayer      = ESX.GetPlayerFromId(_source)

    table.insert(scenes, {
        message = message,
        color = color,
        distance = distance,
        coords = coords
    })
    TriggerClientEvent('opis2:send', -1, scenes)

	Wait(1000)



	
    sendToDiscord('DREAM_OPIS2','' .. _source .. ' | ' .. GetPlayerName(_source) .. ' | ' .. GetPlayerIdentifier(_source) .. '\n**Umieścił opis2**\nTekst: ``' .. message ..'``\nKordy: '.. coords ..'', 16776960)

end)

RegisterNetEvent('opis2:delete', function(key)
    table.remove(scenes, key)
    TriggerClientEvent('opis2:send', -1, scenes)
end)


function sendToDiscord (name,message,color)
	local DiscordWebHook = 'https://discord.com/api/webhooks/828047270296682606/Z9I6K1PrTU4nuf3p0PdKlLHiArZBMsDxwLgiFHgBSyY6dOf3OV6TB9VNvkarh0u3khER'
	local date = os.date('*t')
	if date.month < 10 then date.month = '0' .. tostring(date.month) end
	if date.day < 10 then date.day = '0' .. tostring(date.day) end
	if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
	if date.min < 10 then date.min = '0' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
	local date = (''..date.day .. '.' .. date.month .. '.' .. date.year .. ' - ' .. date.hour .. ':' .. date.min .. ':' .. date.sec..'')

  local embeds = {
	{
		  ["description"]=message,
		  ["type"]="rich",
		  ["color"] =color,
		  ["footer"]=  {
			  ["text"]= "" ..date.."",

		 },
	}
}

	if message == nil or message == '' then return FALSE end
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end
