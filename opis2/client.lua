ESX                           = nil
local PlayerData = {}

scenes = {}
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	Citizen.Wait(5000)
    PlayerData = ESX.GetPlayerData()
    
end)

local hidden = false
local coords = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)

    PlayerData.job = job
    
end)

RegisterNetEvent('opis2:send', function(sent)
    scenes = sent
end)

function Open_Main_Menu()
  ESX.UI.Menu.CloseAll()

  local elements = {
      {label = "Ustaw Opis", value = "setopis"},
      {label = "Usuń Opis", value = "deleteopis"},
      {label = "Ukryj Opisy", value = "hideopis"},
  }

  ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'opis_2',
      {
          title    = 'Opis',
          align    = 'center',
          elements = elements
      },
      function(data, menu)
        if data.current.value == "setopis" then
            ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'opis_2_text',
          {
            title = "Wpisz Tekst"
          },
          function(data2, menu2)

            local text = data2.value
            if text  == nil then
                TriggerEvent('esx:showNotification', 'Wiadomość nie może być pusta!')
            else
                menu2.close()
                menu.close()
                coords = {}
                local placement = SceneTarget()
                if placement == nil then return end
                coords = placement
                local message = data2.value
                local distance = 20
                if message == nil then 
                    TriggerEvent('esx:showNotification', 'Wiadomość nie może być pusta!')
                end

                distance = distance + 0.0
                if distance < 1.1 then distance = 1.1 end
                TriggerServerEvent('opis2:add', coords, message, color, distance)
            end


          end,
        function(data2, menu2)
            menu2.close()
        end)
        end
        if data.current.value == "deleteopis" then
            local scene = ClosestSceneLooking()
            if scene ~= nil then
                TriggerServerEvent('opis2:delete', scene)
            end
        end
        if data.current.value == "hideopis" then
            hidden = not hidden
            if hidden then
                TriggerEvent('esx:showNotification', 'Wyłączono wyświetlanie opis2')
            else
                TriggerEvent('esx:showNotification', 'Włączono wyświetlanie opis2')
            end
        end
      end,
      function(data, menu)
          menu.close()
      end
  )
end

RegisterCommand('opis2', function(source, args, rawCommand)

        Open_Main_Menu()


end)

CreateThread(function()
    while true do
        Wait(5)
        if #scenes > 0 then
            if not hidden then
                local plyCoords = GetEntityCoords(PlayerPedId())
                local closest = ClosestScene()
                if closest > 10.0 then
                    Wait(333)
                else
                    for k, v in pairs(scenes) do
                        distance = Vdist(plyCoords, v.coords)
                        if distance <= v.distance then
                            DrawScene(v.coords, v.message, v.color)
                        end
                    end
                end
            else
                Wait(333)
            end
        else
            Wait(333)
        end
    end
end)

TriggerServerEvent('opis2:fetch')


function SceneTarget()
    local camCoords = GetPedBoneCoords(PlayerPedId(), 37193, 0.0, 0.0, 0.0)
    local farCoords = GetCoordsFromCam()
    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(camCoords, farCoords, -1, PlayerPedId(), 4)
    local _, hit, endcoords, surfaceNormal, entityHit = GetShapeTestResult(RayHandle)
    if endcoords[1] == 0.0 then return end
    return endcoords
end

function GetCoordsFromCam()
    local rot = GetGameplayCamRot(2)
    local coord = GetGameplayCamCoord()
    
    local tZ = rot.z * 0.0174532924
    local tX = rot.x * 0.0174532924
    local num = math.abs(math.cos(tX))
    
    newCoordX = coord.x + (-math.sin(tZ)) * (num + 4.0)
    newCoordY = coord.y + (math.cos(tZ)) * (num + 4.0)
    newCoordZ = coord.z + (math.sin(tX) * 8.0)
    return vector3(newCoordX, newCoordY, newCoordZ)
end

function DrawScene(coords, text, color)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords[1], coords[2], coords[3])
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 155)
        SetTextEdge(1, 0, 0, 0, 250)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        
        DrawText(_x, _y)
        local factor = 1
    end
end

function ClosestScene()
    local closestscene = 1000.0
    for i = 1, #scenes do
        local distance = Vdist(scenes[i].coords, GetEntityCoords(PlayerPedId()))
        if (distance < closestscene) then
            closestscene = distance
        end
    end
    return closestscene
end

function ClosestSceneLooking()
    local closestscene = 1000.0
    local scanid = nil
    for i = 1, #scenes do
        local distance = Vdist(scenes[i].coords, SceneTarget())
        if (distance < closestscene and distance < scenes[i].distance) then
            scanid = i
            closestscene = distance
        end
    end
    return scanid
end
