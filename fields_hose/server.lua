RegisterNetEvent("beginHose")
AddEventHandler("beginHose", function( cords )
	--x,y,z = (unpack (x) )
	local coordinates = cords
	TriggerClientEvent("hoseEffect", -1, coordinates )
end)

RegisterNetEvent("nameSend")
AddEventHandler("nameSend", function(name) 
	resourcename = name
end)
AddEventHandler("playerConnecting", function() 
	ExecuteCommand( "restart fields_hose" ) 
end)
