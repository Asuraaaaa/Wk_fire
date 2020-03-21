print("Fire Script has loaded! Coded by Wick")


RegisterServerEvent("WK:firePos")
AddEventHandler("WK:firePos", function(mx, my, mz)
	print(string.format("Fire reported %.2f, %.2f, %.2f.",mx,my,mz))
	TriggerClientEvent("WK:FirePlacing", -1, mx, my, mz)
end)
 RegisterServerEvent("WK:firesyncs")
 AddEventHandler("WK:firesyncs", function( firec, lastamnt, deletedfires, original )
	--local test = ping
	TriggerClientEvent("WK:firesyncs2", -1, firec, lastamnt, deletedfires, original)
	--TriggerClientEvent("WK:firesync3", -1)
end)
  RegisterServerEvent("WK:fireremovesyncs2")
 AddEventHandler("WK:fireremovesyncs2", function( firec, lastamnt, deletedfires, original )
	--local test = ping
	TriggerClientEvent("WK:fireremovesync", -1, firec, lastamnt, deletedfires, original)
 end)
 
 RegisterServerEvent("WK:firesyncs60")
 AddEventHandler("WK:firesyncs60", function()
	--local test = ping
	--TriggerClientEvent("WK:firesyncs2", -1, firec, lastamnt, deletedfires, original)
	TriggerClientEvent("WK:firesync3", -1)
 end)
 
 RegisterServerEvent("fire:syncedAlarm")
AddEventHandler("fire:syncedAlarm", function()
  TriggerClientEvent("triggerSound", source)
end)
 
AddEventHandler("chatMessage", function(p, color, msg)
    if msg:sub(1, 1) == "/" then
        fullcmd = stringSplit(msg, " ")
        cmd = fullcmd[1]
		
        if cmd == "/firestop" then
			--TriggerClientEvent("chatMessage", p, "FIRE ", {255, 0, 0}, "You stopped all the fires!")
			TriggerClientEvent("chatMessage", p, "FIRE ", {255, 0, 0}, "Du stoppede alle brande!")
        	TriggerClientEvent("WK:firestop", p)
			TriggerClientEvent("WK:firesync", -1)
        	CancelEvent()
        end
       --[[ if cmd == "/coor098ds" then
        	TriggerClientEvent("WK:coords", p)
        	CancelEvent()
        end]]
		if cmd == "/firecount" then
        	TriggerClientEvent("WK:firecounter", p)
        	CancelEvent()
        end
        if cmd == "/cbomb" then
        	TriggerClientEvent("WK:carbomb", p)
        	CancelEvent()
        end
		if cmd == "/sync" then
        	TriggerClientEvent("WK:firesync3", p)
        end
    end
end)

function stringSplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

------------------------------------------------------------
----------------------- RANDOM FIRES -----------------------
------------------------------------------------------------
RegisterServerEvent("WK:amfireman")

local spawnRandomFires = true -- set to true and put x,y,z locations and amount of time before their is a chance of a fire spawning
local spawnRandomFireChance = 750 -- basically a thousand sided dice is rolled and if it gets above this number then a fire spawns at one of the locations specified
local spawnRandomFireAlways = true -- for debugging, overrides the chance.
local randomSpawnTime = 1200000 -- time to wait before trying ot spawn another random fire in milliseconds 1,200,000 is 20 minutes.
local randomResponseTime = 1000 -- time to wait for response from clients if they're a fireman.
local function randomFireAttempt()
	if not spawnRandomFires then
		SetTimeout(randomSpawnTime,randomFireAttempt)
		print("[FIRE] Random fires are extinguished.")
	elseif not spawnRandomFireAlways and not (math.random(1,1000) <= spawnRandomFireChance) then
		SetTimeout(randomSpawnTime,randomFireAttempt)
		print("[FIRE] Random fire got a bad throw.")
	else
		print("[FIRE] Random fire starts...")
		local event
		event = AddEventHandler("WK:amfireman",function()
			if event then
				RemoveEventHandler(event)
				event = nil
				TriggerClientEvent("WK:random",source)
				SetTimeout(randomSpawnTime,randomFireAttempt)
				print("[FIRE] "..(GetPlayerName(source) or "???").." will do it.")
			end
		end)
		SetTimeout(randomResponseTime,function()
			if event then
				RemoveEventHandler(event)
				event = nil
				SetTimeout(randomSpawnTime,randomFireAttempt)
				print("[FIRE] Nevermind, no firefighters on!")
			end
		end)
		TriggerClientEvent("WK:askfireman",-1)
	end
end
math.randomseed(os.time())
SetTimeout(randomSpawnTime,randomFireAttempt)