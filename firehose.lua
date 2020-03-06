---------------------made by Wick under TEST---------------------------------------
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