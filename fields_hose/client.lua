---------------------made by Wick under TEST---------------------------------------
-------------------------------------------------------------------------------------
local dict = "core"
local particle = "water_cannon_jet"
--local particle = "water_cannon_spray"
local ped = PlayerPedId()
local x,y,z = table.unpack(GetEntityCoords(playerPed))
local xx,yy,zz = table.unpack(GetEntityForwardVector(playerPed))
xx = xx * 5
yy = yy * 5

local animDict = "weapons@misc@fire_ext"
local animName = "fire_high"
hose = false
watercanon = true
function setHose(flag)
  hose = flag
  watercannon = false
end
RegisterNetEvent("Hose")
AddEventHandler("Hose", function()
	if ( watercanon ) then
		setHose(true)
        watercanon = false
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"Hose Equipped"}
          })
    
	else
		setHose(false)
        watercanon = true
        TriggerEvent('chat:addMessage', {
            color = { 3, 202, 252 },
            multiline = true,
            args = {"Hose Removed"}
          })
       
	end
end)
RegisterNetEvent("nameSend")
AddEventHandler('onClientResourceStart', function (resourceName)
        TriggerServerEvent("nameSend", resourceName)
end)

RegisterCommand("hose", function(source, args, raw) --change command here
    TriggerEvent("Hose")
end, false) --False, allow everyone to run it(thnx @Havoc)



    local pressed = false
Citizen.CreateThread(function()
    --if hose == true then
        RequestNamedPtfxAsset(dict)
        while not HasNamedPtfxAssetLoaded(dict) do
            Citizen.Wait(0)
        end
        print('\n[PARTICLES] Finished loading particle dictionary (' .. dict .. ').')
        
        local particleEffect = 0
        UseParticleFxAssetNextCall(dict)
        --particleEffect = StartParticleFxLoopedOnEntity(particle, ped, 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, false, false, false)
        while true do
            Citizen.Wait(0)
            --if GetSelectedPedWeapon(ped) ~= GetHashKey('WEAPON_FIREEXTINGUISHER') then
            --    setHose(false)
            --    TriggerEvent( 'chat:addMessage', {
            --        color = { 3, 202, 252 },
            --        multiline = true,
            --        args = {"Hose Removed"}
            --    })
            --    Citizen.Wait(1000000)  
            --end     
                if hose == true then
                    if GetSelectedPedWeapon(ped) == GetHashKey('WEAPON_FIREEXTINGUISHER') and (IsControlJustPressed(0, 24) or IsDisabledControlPressed(0, 24)) and not pressed then
                        pressed = true
                        UseParticleFxAssetNextCall(dict)
                        particleEffect = StartParticleFxLoopedOnEntity(particle, ped, 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, false, false, false)
                    end
                    if GetSelectedPedWeapon(ped) == GetHashKey('WEAPON_FIREEXTINGUISHER') then
                        DisablePlayerFiring(PlayerId(), true)
                        DisableControlAction(0, 24, true)
                        if pressed then
                            SetParticleFxLoopedOffsets(particleEffect, 0.0, 0.0, 0.0, GetGameplayCamRelativePitch(), 0.0, 0.0)--GetEntityHeading(PlayerPedId()))
                        end
                    end
                    if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) and pressed then
                        StopParticleFxLooped(particleEffect, 0)
                        pressed = false
                    end 
                else
                end
        
        end
    --end
end)

function PlayEffect(pdict, pname, posx, posy, posz)
    Citizen.CreateThread(function()
        UseParticleFxAssetNextCall(pdict)
        local pfx = StartParticleFxLoopedAtCoord(pname, posx, posy, posz, 0.0, 0.0, GetEntityHeading(PlayerPedId()), 1.0, false, false, false, false)
        Citizen.Wait(100)
        StopParticleFxLooped(pfx, 0)
    end)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if hose == true then
            if pressed then
                print('hose')
                Citizen.Wait(100)
                SetParticleFxShootoutBoat(true)
                local off = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 12.0 + GetGameplayCamRelativePitch()* 0.4, 0.0)
                local x = off.x
                local y = off.y
                

                -- DrawLine(x, y, 0.0, x, y, 800.0, 255, 0, 0, 255)
                local _,z = GetGroundZFor_3dCoord(x, y, off.z)
                -- DrawLine(x, y, z - 0.2, x, y, z + 0.2, 255, 0, 0, 255)
                Citizen.Wait(GetGameplayCamRelativePitch())
                local cordis = { x, y, z }
                PlayEffect("core", "water_cannon_spray", x, y, z)
                RegisterNetEvent("beginHose")
                TriggerServerEvent("beginHose", cordis)
            else
                Citizen.Wait(0)
            end
        else

        end
    end
end)

RegisterNetEvent("hoseEffect")


AddEventHandler("hoseEffect", function( cords )
    local sx,sy,sz = ( unpack (cords) )
	Citizen.Wait(100)
	Citizen.Wait(GetGameplayCamRelativePitch())
	SetParticleFxShootoutBoat(true)
	PlayEffect("core", "water_cannon_spray", sx, sy, sz)
end)

-----------------------DEBUG-----------------------------------
local weapons = {
    "WEAPON_FIREEXTINGUISHER",
}
----------------------------------------------------------------------------------
function CheckWeapon(ped)
	local ped = GetPlayerPed(-1)
    for i = 1, #weapons do
        if GetHashKey(weapons[i]) == GetSelectedPedWeapon(ped) then
            return true
        end
    end
    return false
end

SetPedInfiniteAmmo(GetPlayerPed(-1), true, "WEAPON_FIREEXTINGUISHER")


