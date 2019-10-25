-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.51
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
-- Resource Configuration
-- PLEASE RESTART SERVER AFTER MAKING CHANGES TO THIS CONFIGURATION
--
local Config = {} -- Do not edit this line
-- Whether or not to disable all on-screen messages, exect call details
Config.DisableAllMessages = false
-- Whether or not to enable chat suggestions
Config.ChatSuggestions = true
-- Whether or not to enable a reminder for whitelisted people to enable their pagers shortly
-- after they join the server, if they have not done so already
Config.Reminder = true
-- Whether or not to enable command whitelist.
-- "ace" to use Ace permissions, "json" to use whitelist.json file, or false to disable.
Config.WhitelistEnabled = false
-- Separator character, goes between tones and details in /page command
Config.PageSep = "-"
-- Default fire department name, used in /page command
Config.DeptName = "Los Santos Fire Dept"
-- Default text shown when page details are not provided
Config.DefaultDetails = "Rapporter til stationen"
-- Time in ms between the beginning of each tone played.
-- 7.5 seconds by default, do not edit unless you need to
Config.WaitTime = 7500
-- List of tones that can be paged, read the wiki page below to learn how to add more
-- https://github.com/inferno-collection/Fire-EMS-Pager/wiki/Adding-custom-tones
Config.Tones = {"medical", "rescue", "fire", "other"}
-- List of stations fire sirens can be played at, read the wiki page below to learn how to add more
-- https://github.com/inferno-collection/Fire-EMS-Pager/wiki/Adding-custom-stations
Config.Stations = {} -- Do not edit this line
table.insert(Config.Stations, {Name = "pb", Loc = vector3(-379.53, 6118.32, 31.85), Radius = 800}) -- Paleto Bay
table.insert(Config.Stations, {Name = "fz", Loc = vector3(-2095.92, 2830.22, 32.96), Radius = 600}) -- Fort Zancudo
table.insert(Config.Stations, {Name = "ss", Loc = vector3(1691.24, 3585.83, 35.62), Radius = 500}) -- Sandy Shores
table.insert(Config.Stations, {Name = "rh", Loc = vector3(-635.09, -124.29, 39.01), Radius = 400}) -- Rockford Hills
table.insert(Config.Stations, {Name = "els", Loc = vector3(1193.42, -1473.72, 34.86), Radius = 400}) -- East Los Santos
table.insert(Config.Stations, {Name = "sls", Loc = vector3(199.83, -1643.38, 29.8), Radius = 400}) -- South Los Santos
table.insert(Config.Stations, {Name = "dpb", Loc = vector3(-1183.13, -1773.91, 4.05), Radius = 400}) -- Del Perro Beach
table.insert(Config.Stations, {Name = "lsia", Loc = vector3(-1068.74, -2379.96, 14.05), Radius = 500}) -- LSIA

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

-- Local Pager Variables
local Pager = {}
-- Is the client's local pager enabled
Pager.Enabled = false
-- Are all clients currently being paged
Pager.Paging = false
-- What the client's local pager is tuned to
Pager.TunedTo = {}
-- How long to wait between tones being played
Pager.WaitTime = Config.WaitTime
-- List of tones that can be paged
Pager.Tones = Config.Tones

-- Local Fire Siren Variables
local FireSiren = {}
-- Is a fire siren currently being paged
FireSiren.Enabled = false
-- Stations that currently have a fire siren being played
FireSiren.EnabledStations = {}
-- Fire Station Variables
FireSiren.Stations = Config.Stations

-- Local whitelist variable
local Whitelist = {}
-- Boolean for whether the whitelist is enabled
Whitelist.Enabled = Config.WhitelistEnabled
-- Whitelist variable for commands
Whitelist.Command = {}
-- Boolean for whether player is whitelisted for pager command
Whitelist.Command.pager = false
-- Boolean for whether player is whitelisted for page command
Whitelist.Command.page = true
-- Boolean for whether player is whitelisted for firesiren command
Whitelist.Command.firesiren = true
-- Boolean for whether player is whitelisted for cancelpage command
Whitelist.Command.cancelpage = false
-- Boolean for whether player is whitelisted for pagerwhitelist command
Whitelist.Command.pagerwhitelist = true

-- When the resource is started
AddEventHandler("onClientResourceStart", function (ResourceName)
	-- If the started resource is this resource
	if(GetCurrentResourceName() == ResourceName) then
		-- If the whitelisted is enabled
		if Whitelist.Enabled then
			-- Pass whitelist object to server for updating
			TriggerServerEvent("Fire-EMS-Pager:WhitelistCheck", Whitelist)
		-- If whitelist is not enabled
		else
			-- Loop through all commands
			for i in pairs(Whitelist.Command) do
				-- Grant players all permissions
				Whitelist.Command[i] = true
			end
			-- Override whitelist permission
			Whitelist.Command.pagerwhitelist = false
		end
	end
end)

-- On client join server
AddEventHandler("onClientMapStart", function()
	-- If chat suggestions are enabled
	if Config.ChatSuggestions then
		-- Create a temporary variables to add more text to
		local ValidTones = "Valid tones:"
		local ValidStations = "Valid stations:"

		-- Loop though all the tones
		for _, Tone in ipairs(Pager.Tones) do
			-- Add a tone to temporary string
			ValidTones = ValidTones .. " " .. Tone
		end

		-- Loop though all the stations
		for _, Station in ipairs(FireSiren.Stations) do
			-- Add a station to temporary string
			ValidStations = ValidStations .. " " .. Station.Name
		end

		-- Add /pager suggestion and include all valid tones
		TriggerEvent("chat:addSuggestion", "/pager", "Fra at allerede er indstillet, deaktiverer du personsøger. Fra personsøgeren er slået, skal du indtaste toner, der skal indstilles til, eller hvis de allerede er indstillet, toner, der skal indstilles på igen. Sæt et mellemrum mellem hver tone", {
			{ name = "tone", help = ValidTones }
		})
        --[[
		-- Add /page suggestion, include all valid tones, and call details help
		TriggerEvent("chat:addSuggestion", "/page", "Hvis der ikke i øjeblikket er nogen andre toner, der indtastes toner. Sæt et mellemrum mellem hver tone.", {
			{ name = "tones", help = ValidTones },
			{ name = "- call details", help = "For at tilføje valgfrie detaljer skal du tilføje et mellemrum efter den sidste tone, derefter et '-', derefter et andet mellemrum og derefter dine detaljer. For eksempel: /page brandmedicinsk - Dine detaljer går her" }
		})
        ]]
		-- Add /cancelpage suggestion, include all valid tones, and disregard details help
		TriggerEvent("chat:addSuggestion", "/cancelpage", "Spiller annulleringstone for valgte toner og viser ignorering af anmeldelse.", {
			{ name = "tones", help = ValidTones },
			{ name = "- disregard details", help = "Hvis du vil tilføje valgfri ignorering af detaljer, skal du tilføje et mellemrum efter den sidste tone, derefter et '-', derefter et andet mellemrum og derefter dine detaljer. For eksempel: /cancelpage brand medicinsk - Din ignorering detaljer Gå her" }
		})
		--[[
		-- Add /firesiren suggestion and include all valid stations
		TriggerEvent("chat:addSuggestion", "/firesiren", "Hvis der i øjeblikket ikke lyder andre sirener, vil der ske ildsiren på indtastede stationer. Sæt et mellemrum mellem hver station.", {
			{ name = "stations", help = ValidStations }
		})
		]]
		-- Add /pagerwhitelist suggestion and include help
		TriggerEvent("chat:addSuggestion", "/pagerwhitelist", "Føj til og / eller genindlæs hvidlisten til kommandoer.", {
			{ name = "{reload} or {player hex/server id}", help = "Skriv 'reload' for at indlæse den aktuelle hvidliste, eller hvis du tilføjer til hvidlisten, skal du indtaste spillerens steam hex, eller læg spillerens server-ID fra spillerlisten" },
			{ name = "commands", help = "Liste over alle de kommandoer, du vil have denne person til at få adgang til."}
		})
	end

	-- If the whitelisted is enabled
	if Whitelist.Enabled then
		-- Pass whitelist object to server for updating
		TriggerServerEvent("Fire-EMS-Pager:WhitelistCheck", Whitelist)
	-- If whitelist is not enabled
	else
		-- Loop through all commands
		for i in pairs(Whitelist.Command) do
			-- Grant players all permissions
			Whitelist.Command[i] = true
		end
		-- Override whitelist permission
		Whitelist.Command.pagerwhitelist = false
	end

	-- Adds page command chat template, including pager icon
	TriggerEvent("chat:addTemplate", "page", "<img src='data:image/gif;base64,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' height='16'> <b>{0}</b>: {1}")
end)

-- Return from whitelist check
RegisterNetEvent("Fire-EMS-Pager:return:WhitelistCheck")
AddEventHandler("Fire-EMS-Pager:return:WhitelistCheck", function(NewWhitelist)
	-- Update local whitelist values with server ones
	Whitelist = NewWhitelist

	-- If reminder is enabled and the client is whitelisted to use the /pager command
	if Config.Reminder and Whitelist.Command.pager then
		-- Wait two minutes after they join the server
		Citizen.Wait(120000)
		-- If their pager is still not enabled
		if not Pager.Enabled then
			-- Send reminder
			NewNoti("Glem ikke at indstille din personsøger!", true)
		end
	end
end)

-- Forces a whitelist reload on the client
RegisterNetEvent("Fire-EMS-Pager:WhitelistRecheck")
AddEventHandler("Fire-EMS-Pager:WhitelistRecheck", function()
	-- Ask the server for client's lastest whitelist status
	TriggerServerEvent("Fire-EMS-Pager:WhitelistCheck", Whitelist)
end)

-- /pager command
-- Used to enable and disable pager, and set tones to be tuned to
RegisterCommand("pager", function(Source, Args)
	-- Check if the player is whitelisted to use this command
	if Whitelist.Command.pager then
		-- pager function, called only from this command
		function EnablePager()
			-- Loop though all the tones provided by the client
			for _, ProvidedTone in ipairs(Args) do
				-- Loop through all the valid tones
				for _, ValidTone in ipairs(Pager.Tones) do
					-- If a provided tone matches a valid tone
					if ProvidedTone:lower() == ValidTone then
						-- Add it to the list of tones to be tuned to
						table.insert(Pager.TunedTo, ValidTone)
					end
				end
			end

			-- If the number of originally provided tones matches the
			-- number of tones, and there where tones acutally provided
			-- in the first place
			if not #Args ~= #Pager.TunedTo and #Args ~= 0 then
				-- Create a temporary variable to add more text to
				local NotificationText = "Pager indstillet til:"
				-- Loop though all the tones that the client will be tuned to
				for _, Tone in ipairs(Pager.TunedTo) do
					-- Add them to the temporary variable
					NotificationText = NotificationText .. " " .. Tone:upper()
				end
				-- Draw new notification on client's screen
				NewNoti(NotificationText, false)
				-- Locally anable the client's pager
				Pager.Enabled = true
			-- If there is a mismatch, i.e. invalid/no tone/s provided
			else
				-- Draw new notification on client's screen
				NewNoti("Ugyldige toner, skal du kontrollere dine kommando argumenter.", true)
				-- Ensure the client's pager is locally disabled
				Pager.Enabled = false
				-- Clear list of tones to be tuned to
				Pager.TunedTo = {}
			end
		end

		-- If pager is currently off
		if not Pager.Enabled then
			-- Attempt to enable pager
			EnablePager()
		-- If pager is disabled
		else
			-- If there are tones provided
			if #Args ~= 0 then
				-- Clear list of currently tuned tones to avoid duplicates
				Pager.TunedTo = {}
				-- Attempt to enable pager
				EnablePager()
			-- If no tones where provided, and they just want it turned off
			else
				-- Draw new notification on client's screen
				NewNoti("Pager blev slukket.", false)
				-- Ensure the client's pager is locally disabled
				Pager.Enabled = false
				-- Clear list of tones to be tuned to
				Pager.TunedTo = {}
			end
		end
	-- If player is not whitelisted
	else
		-- Draw error message on player screen
		NewNoti("Du er ikke whitelisted til denne kommando.", true)
	end
end)

-- /page command
-- Used to page out a tone/s
RegisterCommand("page", function(Source, Args)
	PagePagers(Args)
end)

-- /firesiren command
-- Used to play a fire siren at a specific station/s
RegisterCommand("firesiren", function(Source, Args)
	-- Check if the player is whitelisted to use this command
	if Whitelist.Command.firesiren then
		-- If fire sirens are not already being sounded
		if not FireSiren.Enabled then
			-- Local array to store stations to be sounded
			local ToBeSirened = {}
			-- Loop though all the stations provided in the command
			for _, ProvidedStation in ipairs(Args) do
				-- Loop through all the valid stations
				for _, ValidStation in ipairs(FireSiren.Stations) do
					-- If a provided station matches a valid station
					if ProvidedStation:lower() == ValidStation.Name then
						ValidStation.x, ValidStation.y, ValidStation.z = table.unpack(ValidStation.Loc)
						table.insert(ToBeSirened, ValidStation)
					end
				end
			end

			-- If the number of originally provided stations matches
			-- the number of stations, and there where stations acutally
			-- provided in the first place
			if not #Args ~= #ToBeSirened and #Args ~= 0 then
				-- Create a temporary variable to add more text to
				local NotificationText = "Sounding:"
				-- Loop though all stations
				for _, Station in ipairs(ToBeSirened) do
					-- Add station to temporary variable
					NotificationText = NotificationText .. " " .. Station.Name:upper()
				end
				-- Draw new notification on client's screen
				NewNoti(NotificationText, false)
				-- Bounces stations off of server
				TriggerServerEvent("Fire-EMS-Pager:SoundSirens", ToBeSirened)
			-- If there is a mismatch, i.e. invalid/no stations/s provided
			else
				-- Draw new notification on client's screen
				NewNoti("Ugyldige stationer til at lyde. Kontroller venligst dine kommando argumenter.", true)
			end
		-- If sirens are already being sounded
		else
			-- Draw new notification on client's screen
			NewNoti("Sirener lyder allerede!", true)
		end
	-- If player is not whitelisted
	else
		-- Draw error message on player screen
		NewNoti("Du er ikke hvidlistet til denne kommando.", true)
	end
end)

-- /cancelpage command
-- Used to play a sound to signal a canceled call
RegisterCommand("cancelpage", function(Source, Args)
	-- Temporary Variable to count provided tones
	local ToneCount = 0
	-- Whether the arguments has details or not
	local HasDetails = false
	-- Local array to store tones to be paged
	local ToBeCanceled = {}

	-- Check if the player is whitelisted to use this command
	if Whitelist.Command.cancelpage then
		-- If tones are not already being paged
		if not Pager.Paging then
			-- Loop though all the tones provided in the command
			for _, ProvidedTone in ipairs(Args) do
				-- Loop through all the valid tones
				for _, ValidTone in ipairs(Pager.Tones) do
					-- If a provided tone matches a valid tone
					if ProvidedTone:lower() == ValidTone then
						-- Add it to the list of tones to be paged
						table.insert(ToBeCanceled, ValidTone)
						-- No need to keep searching for this tone
						break
					-- Checks for the separator character
					elseif ProvidedTone:lower() == Config.PageSep then
						-- Set true, used for checking and loop breaking
						HasDetails = true
						-- Counts up to the number of valid tones provided
						-- plus 1, to include the separator
						for _ = ToneCount + 1, 1, -1 do
							-- Remove tones from arguments to leave details
							table.remove(Args, 1)
						end
						-- Break from loop
						break
					end
				end
				-- If a break is needed
				if HasDetails then
					-- Break from loop
					break
				end
				-- Increase count
				ToneCount = ToneCount + 1
			end

			-- If the number of originally provided tones matches the
			-- number of tones, and there where tones acutally provided
			-- in the first place
			if not ToneCount ~= #ToBeCanceled and ToneCount ~= 0 then
				-- Create a temporary variable to add more text to
				local NotificationText = "Canceling:"
				-- Loop though all the tones
				for _, Tone in ipairs(ToBeCanceled) do
					-- Add a tone to temporary string
					NotificationText = NotificationText .. " " .. Tone:upper()
				end
				-- Draw new notification on client's screen
					NewNoti(NotificationText, false)
				-- Bounces tones off of server
				TriggerServerEvent("Fire-EMS-Pager:CancelPage", ToBeCanceled, HasDetails, Args)
			-- If there is a mismatch, i.e. invalid/no tone/s provided
			else
				-- Draw new notification on client's screen
				NewNoti("Ugyldige toner, kontroller venligst dine kommando argumenter.", true)
			end
		-- If tones are already being paged
		else
			-- Draw new notification on client's screen
			NewNoti("Der undersøges toner, vent venligst!", true)
		end
	-- If player is not whitelisted
	else
		-- Draw error message on player screen
		NewNoti("Du er ikke whitelisted til denne kommando", true)
	end
end)

-- /pagerwhitelist
-- Reload, and/or add someone to the whitelist
RegisterCommand("pagerwhitelist", function(Source, Args)
	-- Check if the player is whitelisted to use this command
	if Whitelist.Command.pagerwhitelist then
		-- If the first argument is defined and is equal to "reload"
		if Args[1] and Args[1]:lower() == "reload" then
			-- Tell server to reload the whitelist on all clients
			TriggerServerEvent("Fire-EMS-Pager:WhitelistReload")
			-- Draw message on player screen
			NewNoti("Whitelist genindlæs færdig.", true)
		-- Else if only the first argument is set
		elseif Args[1] then
			-- Temporary variable for steam hex
			local ID
			-- Temporary whitelist entry variables
			local Entry = {}
			-- Declaring pager as a valid command
			Entry.pager = "pending"
			-- Declaring page as a valid command
			Entry.page = "pending"
			-- Declaring firesiren as a valid command
			Entry.firesiren = "pending"
			-- Declaring cancelpage as a valid command
			Entry.cancelpage = "pending"
			-- Declaring pagerwhitelist as a valid command
			Entry.pagerwhitelist = "pending"

			-- If the first argument is a number
			if tonumber(Args[1]) then
				-- Set the steam hex to the number, assuming a server ID has been provided
				ID = Args[1]
			-- Else if the first part of the string contains "steam:"
			elseif string.sub(Args[1]:lower(), 1, string.len("steam:")) == "steam:" then
				-- Set the steam hex to the string
				ID = Args[1]
			-- In all other cases
			else
				-- Set the steam hex to the string, adding "steam:" to the front
				ID = "steam:" .. Args[1]
			end

			-- Loop though all command arguments
			for i in pairs(Args) do
				-- If the argument is a valid command
				if Entry[Args[i]:lower()] then
					-- Allow the player access to the command
					Entry[Args[i]] = true
				end
			end

			-- Loop though all commands
			for i in pairs(Entry) do
				-- If the command is still pending
				if Entry[i] == "pending" then
					-- Disallow the player access to the command
					Entry[i] = false
				end
			end

			-- Tell the server to add the new entry to the whitelist and reload
			TriggerServerEvent("Fire-EMS-Pager:WhitelistAdd", ID, Entry)
			-- Positive feedback
			NewNoti("~g~" .. ID .. " Føjet til whitelist med succes", true)
		-- If first argument not set
		else
			NewNoti("ikke nok argumenter.", true)
		end
	-- If player is not whitelisted
	else
		-- Draw error message on player screen
		NewNoti("Du er ikke whitelisted til denne kommando", true)
	end
end)

-- Plays tones on the client
RegisterNetEvent("Fire-EMS-Pager:PlayTones")
AddEventHandler("Fire-EMS-Pager:PlayTones", function(Tones, HasDetails, Details)
	-- Temporary boolean variable
	local NeedToPlay = false
	-- Temporary variable
	local Tuned
	-- Stop tones being paged over the top of others
	Pager.Paging = true

	-- If the pager is enabled, if not, ignore
	if Pager.Enabled then
		-- Loop though all tones that need to be paged
		for _, Tone in ipairs(Tones) do
			-- Loop through all the tones the player is tuned to
			for _, TunedTone in ipairs(Pager.TunedTo) do
				-- If player is tuned to this tone
				if Tone == TunedTone then
					-- Set temporary variable
					NeedToPlay = true
				end
			end
		end

		-- If the player is tuned to one or more of the tones being paged
		if NeedToPlay then
			-- Draw new notification on client's screen
			NewNoti("~h~~y~Din personsøger aktiveres", true)
			-- Short pause before tones are played
			Citizen.Wait(1500)
			-- Loop though all tones that need to be paged
			for _, Tone in ipairs(Tones) do
				-- Reset to false
				Tuned = false
				-- Loop through all the tones the player is tuned to
				for _, TunedTone in ipairs(Pager.TunedTo) do
					-- If player is tuned to this specific tone
					if Tone == TunedTone then
						-- Set temporary variable
						Tuned = true
					end
				end

				-- If player is tuned to this tone
				if Tuned then
					-- New NUI message
					SendNUIMessage({
						-- Tell the NUI a tone needs to be played
						TransactionType	= "PlayTone",
						-- Provide vibration tone
						TransactionFile	= "vibrate"
					})
					-- Draw new notification on client's screen
					NewNoti("~h~~y~Rapporter til stationen!", true)
				-- If player is not tuned to it
				else
					-- New NUI message
					SendNUIMessage({
						-- Tell the NUI a tone needs to be played
						TransactionType	= "PlayTone",
						-- Provide the tone
						TransactionFile	= Tone
					})
				end
				-- Wait time between tones
				Citizen.Wait(Pager.WaitTime)
			end

			-- New NUI message
			SendNUIMessage({
				-- Tell the NUI a tone needs to be played
				TransactionType     = "PlayTone",
				-- Provide ending beeps
				TransactionFile     = "end"
			})

			-- Temporary variable for hours
			local Hours = GetClockHours()
			-- Temporary variable for minutes
			local Minutes = GetClockMinutes()

			-- If hours are less than or equal to 9
			if Hours <= 9 then
				-- Add a 0 infront
				Hours = "0" .. tostring(Hours)
			end
			-- If minutes are less than or equal to 9
			if Minutes <= 9 then
				-- Add a 0 infront
				Minutes = "0" .. tostring(Minutes)
			end

			-- If a details was included
			if HasDetails then
				-- Create a temporary variable for details
				local NewDetails = ""
				-- Create a temporary variable for tones
				local NewTones = "Call "

				-- Loop though details (each word is an element)
				for _, l in ipairs(Details) do
					-- Add word to temporary variable
					NewDetails = NewDetails .. " " .. l
				end
				-- Capitalise first letter
				NewDetails = NewDetails:gsub("^%l", string.upper)

				-- Loop though all tones
				for _, Tone in ipairs(Tones) do
					-- Add tone to string and capitalise
					NewTones = NewTones .. Tone:gsub("^%l", string.upper) .. " "
				end

				-- Send message to chat, only people tuned to specified tones can see the message
				TriggerEvent("chat:addMessage", {
					-- Use page template
					templateId = "page",
					-- "Alarmcentralen" in red
					color = { 255, 0, 0},
					-- Allow multiline
					multiline = true,
					-- Message
					args = {"Alarmcentralen", "\nOpmærksomhed " .. Config.DeptName .. " - " .. NewDetails .. " - " .. NewTones .. "\n\nTimeout " .. Hours .. Minutes.. "."}
				})
			-- If no details provided
			else
				-- Send message to chat, only people tuned to specified tones can see the message
				TriggerEvent("chat:addMessage", {
					-- Use page template
					templateId = "page",
					-- "Alarmcentralen" in red
					color = { 255, 0, 0},
					-- Allow multiline
					multiline = true,
					-- Message
					args = {"Alarmcentralen", "\nOpmærksomhed " .. Config.DeptName .. " - " .. Config.DefaultDetails .. ".\n\nTimeout " .. Hours .. Minutes.. "."}
				})
			end
		else
			-- Wait same amount of time
			for _, Tone in ipairs(Tones) do
				Citizen.Wait(Pager.WaitTime)
			end
			Citizen.Wait(1500)
		end
		-- Wait for sound to finish
		Citizen.Wait(3000)
	else
		-- Wait same amount of time
		for _, _ in ipairs(Tones) do
			Citizen.Wait(Pager.WaitTime)
		end
		Citizen.Wait(3000)
	end
	-- Allow more tones to be paged
	Pager.Paging = false
end)

-- Play fire sirens
RegisterNetEvent("Fire-EMS-Pager:PlaySirens")
AddEventHandler("Fire-EMS-Pager:PlaySirens", function(Stations)
	-- Stop sirens being paged over the top of others
	FireSiren.Enabled = true

	-- Loop though all stations
	for _, Station in ipairs(Stations) do
		Station.Loc = vector3(Station.x, Station.y, Station.z)
		-- Insert temporary array into enabled stations
		table.insert(FireSiren.EnabledStations, Station)
	end
	-- Short pause before sirens are played
	Citizen.Wait(1000)

	-- New NUI message
	SendNUIMessage({
		-- Tell the NUI to play the siren sound
		TransactionType = "PlaySiren"
	})
	-- Wait for sound to finish
	Citizen.Wait(51000)
	-- Then allow more sirens to be sounded
	FireSiren.Enabled = false
end)

-- Plays cancelpage sound on the client
RegisterNetEvent("Fire-EMS-Pager:CancelPage")
AddEventHandler("Fire-EMS-Pager:CancelPage", function(Tones, HasDetails, Details)
	-- Temporary boolean variable
	local NeedToPlay = false
	-- Stop tones being paged over the top of others
	Pager.Paging = true

	-- If the pager is enabled, if not, ignore
	if Pager.Enabled then
		-- Loop though all tones that need to be paged
		for _, Tone in ipairs(Tones) do
			-- Loop through all the tones the player is tuned to
			for _, TunedTone in ipairs(Pager.TunedTo) do
				-- If player is tuned to this tone
				if Tone == TunedTone then
					-- Set temporary variable
					NeedToPlay = true
				end
			end
		end

		-- If the player is tuned to one or more of the tones being paged
		if NeedToPlay then
			-- Draw new notification on client's screen
			NewNoti("Din personsøger aktiveres!", true)
			-- Short pause before tones are played
			Citizen.Wait(1500)

			SendNUIMessage({
				-- Tell the NUI a tone needs to be played
				TransactionType     = "PlayTone",
				-- Provide ending beeps
				TransactionFile     = "cancel"
			})

			-- If a details was included
			if HasDetails then
				-- Create a temporary variable for details
				local NewDetails = ""

				-- Loop though details (each word is an element)
				for _, l in ipairs(Details) do
					-- Add word to temporary variable
					NewDetails = NewDetails .. " " .. l
				end
				-- Capitalise first letter
				NewDetails = NewDetails:gsub("^%l", string.upper)

				-- Send message to chat, only people tuned to specified tones can see the message
				TriggerEvent("chat:addMessage", {
					-- Use page template
					templateId = "page",
					-- "Alarmcentralen" in red
					color = { 255, 0, 0},
					-- Allow multiline
					multiline = true,
					-- Message
					args = {"Alarmcentralen", "\nOpmærksomhed " .. Config.DeptName .. " - Opkald annulleret, Brand er slukket - " .. NewDetails}
				})
			-- If no details provided
			else
				-- Send message to chat, only people tuned to specified tones can see the message
				TriggerEvent("chat:addMessage", {
					-- Use page template
					templateId = "page",
					-- "Alarmcentralen" in red
					color = { 255, 0, 0},
					-- Allow multiline
					multiline = true,
					-- Message
					args = {"Alarmcentralen", "\nOpmærksomhed " .. Config.DeptName .. " - Opkald annulleret, Brand er slukket."}
				})
			end
		else
			-- Wait same amount of time
			Citizen.Wait(1500)
		end
	else
		-- Wait same amount of time
		Citizen.Wait(1500)
	end
	-- Wait for sound to finish
	Citizen.Wait(3500)
	-- Allow more tones to be paged
	Pager.Paging = false
end)

-- Used to page out a tone/s
function PagePagers(Args)
    -- Number of provided tones
    local ToneCount = 0
    -- Whether the arguments has details or not
    local HasDetails = false
    -- Local array to store tones to be paged
    local ToBePaged = {}

    -- Check if the player is whitelisted to use this command
    if Whitelist.Command.page then
        -- If tones are not already being paged
        if not Pager.Paging then
            -- Loop though all the tones provided in the command
            for _, ProvidedTone in ipairs(Args) do
                -- Loop through all the valid tones
                for _, ValidTone in ipairs(Pager.Tones) do
                    -- If a provided tone matches a valid tone
                    if ProvidedTone:lower() == ValidTone then
                        -- Add it to the list of tones to be paged
                        table.insert(ToBePaged, ValidTone)
                        -- No need to keep searching for this tone
                        break
                    -- Checks for the separator character
                    elseif ProvidedTone:lower() == Config.PageSep then
                        -- Set true, used for checking and loop breaking
                        HasDetails = true
                        -- Counts up to the number of valid tones provided
                        -- plus 1, to include the separator
                        for _ = ToneCount + 1, 1, -1 do
                            -- Remove tones from arguments to leave only details
                            table.remove(Args, 1)
                        end
                        -- Break from loop
                        break
                    end
                end
                -- If a break is needed
                if HasDetails then
                    -- Break from loop
                    break
                end
                -- Increase count
                ToneCount = ToneCount + 1
            end

            -- If the number of originally provided tones matches the
            -- number of tones, and there where tones acutally provided
            -- in the first place
            if not ToneCount ~= #ToBePaged and ToneCount ~= 0 then
                -- Create a temporary variable to add more text to
                local NotificationText = "~g~personsøgning:~y~"
                -- Loop though all the tones
                for _, Tone in ipairs(ToBePaged) do
                    -- Add a tone to temporary string
                    NotificationText = NotificationText .. " " .. Tone:upper()
                end
                -- Draw new notification on client's screen
                    NewNoti(NotificationText, false)
                -- Bounces tones off of server
                TriggerServerEvent("Fire-EMS-Pager:PageTones", ToBePaged, HasDetails, Args)
            -- If there is a mismatch, i.e. invalid/no tone/s provided
            else
                -- Draw new notification on client's screen
                NewNoti("~r~~h~Ugyldige toner, skal du kontrollere dine kommando argumenter", true)
            end
        -- If tones are already being paged
        else
            -- Draw new notification on client's screen
            NewNoti("~r~~h~Toner er allerede blevet søget.", true)
        end
    -- If player is not whitelisted
    else
        -- Draw error message on player screen
        NewNoti("~r~Du er ikke whitelisted til denne kommando.", true)
    end
end

-- Draws notification on client's screen
function NewNoti(Text, Flash)
	if not Config.DisableAllMessages then
		-- Tell GTA that a string will be passed
		SetNotificationTextEntry("STRING")
		-- Pass temporary variable to notification
		AddTextComponentString(Text)
		-- Draw new notification on client's screen
		DrawNotification(Flash, true)
	end
end

-- Resource master loop
Citizen.CreateThread(function()
	-- Forever
	while true do
		-- Allows safe looping
		Citizen.Wait(0)
		-- If fire siren is enabled
		if FireSiren.Enabled then
			-- Get player position
			local pP = GetEntityCoords(GetPlayerPed(-1), false)
			-- Temporary array
			local StationDistances = {}

			-- Loop though all valid stations
			for _, Station in ipairs(FireSiren.Stations) do
				-- Calculate distance between player and station
				local Distance = GetDistanceBetweenCoords(pP.x, pP.y, pP.z, Station.Loc.x, Station.Loc.y, Station.Loc.z, true)
				-- Insert distance into temporary array
				table.insert(StationDistances, {Name = Station.Name, Distance = Distance + 0.01}) -- Stops divide by 0 errors
			end
			-- Sort array so the closest station to the player is first
			table.sort(StationDistances, function(A, B) return A.Distance < B.Distance end)
			-- Loop though all enabled stations
			for _, Station in ipairs(FireSiren.EnabledStations) do
				-- If the closest station to the player is an enabled station
				if StationDistances[1].Name == Station.Name then
					-- If the distance to the closest station is within the fire siren radius
					if (StationDistances[1].Distance <= Station.Radius) then
						-- Volume is equal to 1 (max volume) mius the distance to the nearest station from the player
						-- divided the radius of the fire siren
						-- New NUI message
						SendNUIMessage({
							-- Tell the NUI to set the sire volume
							TransactionType	= "SetSirenVolume",
							-- The volume
							volume			= 1 - (StationDistances[1].Distance / Station.Radius)
						})
					-- If the cloest station is out of the radius of the fire siren
					else
						-- New NUI message
						SendNUIMessage({
							-- Tell the NUI to set the sire volume
							TransactionType	= "SetSirenVolume",
							-- The volume
							volume     		= 0
						})
					end
				end
			end
		end
	end
end)