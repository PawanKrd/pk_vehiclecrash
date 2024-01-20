playerPed = 0
isDrivingVehicle = false
isEngineDamaged = false
vehiclePedIsIn = 0
vehicleHealth = 0
vehicleState = nil

Citizen.CreateThread(function()
	while not DoesEntityExist(playerPed) or playerPed == 0 do
		playerPed = PlayerPedId()
        -- print("Player Ped: " .. playerPed)
		Citizen.Wait(25)
	end
end)

Citizen.CreateThread(function()
	-- Update the playerPed variable if it does not exist or is invalid
	if not DoesEntityExist(playerPed) or playerPed == 0 then
	    playerPed = PlayerPedId()
        print("Player Ped: " .. playerPed)
	end

    while true do
        -- Check if the player is in any vehicle
        local isPlayerInVehicle = IsPedInAnyVehicle(playerPed, true)
        if isPlayerInVehicle then
            local currentVehicle = GetVehiclePedIsIn(playerPed, false)

            -- Check if the player is in the driver's seat
            if GetPedInVehicleSeat(currentVehicle, -1) == playerPed then
                if currentVehicle ~= vehiclePedIsIn then
                    -- Update vehicle-related variables when the player switches vehicles
                    vehicleHealth = GetVehicleEngineHealth(currentVehicle)
                    vehiclePedIsIn = currentVehicle
                    vehicleState = Entity(vehiclePedIsIn).state
                end
                isDrivingVehicle = true
            else
                isDrivingVehicle = false
            end
        else
            isDrivingVehicle = false
        end

        -- Wait for 500 ms before the next loop iteration
        Citizen.Wait(500)
    end
end)


Citizen.CreateThread(function()
    local refreshRate = 500 -- Default refresh rate when not driving

    while true do
        if isDrivingVehicle then
            if isEngineDamaged then
                refreshRate = 0 -- Faster refresh rate when engine is damaged
            else
                refreshRate = 250 -- Default refresh rate when driving
            end

            -- Handle engine damage and display timer
            if vehicleState.engineDamagedTime ~= nil then
                -- print("Engine Damaged Time: " .. vehicleState.engineDamagedTime)
                if vehicleState.engineDamagedTime > 0 then
                    -- Set engine damage to true and display timer
                    isEngineDamaged = true

                    -- Display timer if enabled in config
                    if Config.DisplayTimer then
                        local vehiclePosition = GetEntityCoords(vehiclePedIsIn)
                        local displayText = 'Engine Damaged\n~b~Wait ~r~' .. vehicleState.engineDamagedTime .. '~b~ Seconds'
                        Draw3DText(vehiclePosition.x, vehiclePosition.y, vehiclePosition.z, displayText, { red = 255, green = 199, blue = 43, alpha = 180 }, 4, 0.1)
                    end

                    -- Turn off the engine
                    ConfigureVehicleEngine(vehiclePedIsIn, false)
                else
                    if isEngineDamaged then
                        -- Set engine damage to false and reset timer
                        isEngineDamaged = false
                        vehicleState:set('engineDamagedTime', 0, true)

                        -- Turn on the engine
                        ConfigureVehicleEngine(vehiclePedIsIn, true)
                    end

                    -- Calculate and update engine damage
                    local updatedVehicleHealth = GetVehicleEngineHealth(vehiclePedIsIn)
   
                    if vehicleHealth > updatedVehicleHealth and not isEngineDamaged then
                        print("Vehicle Health: " .. vehicleHealth, "Updated Vehicle Health: " .. updatedVehicleHealth)
                        local damageAmount = vehicleHealth - updatedVehicleHealth
                        local damageDuration = CalculateCrushTime(damageAmount)
                        vehicleHealth = updatedVehicleHealth

                        if damageDuration > 0 then
                            vehicleState:set('engineDamagedTime', damageDuration, true)
                            isEngineDamaged = true
                            Citizen.Wait(100)
                        end
                    end
                end
            else
                vehicleState:set('engineDamagedTime', 0, true)
            end
        else
            refreshRate = 500 -- Reset refresh rate when not driving
        end

        Citizen.Wait(refreshRate)
    end
end)


-- Function to display text on the screen
-- @param displayText: The text to be displayed
-- @param textSize: Scale for the text size
-- @param screenX: X-coordinate on the screen for text placement
-- @param screenY: Y-coordinate on the screen for text placement
function DisplayScreenText(displayText, textSize, screenX, screenY)
    SetTextFont(4) -- Set text font
    SetTextProportional(1) -- Enable proportional text
    SetTextScale(0.0, textSize) -- Set the scale of the text
    SetTextColour(255, 255, 255, 255) -- Set text color (white)
    SetTextDropshadow(0, 0, 0, 0, 255) -- Set text dropshadow properties
    SetTextEdge(1, 0, 0, 0, 255) -- Set edge properties for text
    SetTextDropShadow() -- Enable drop shadow
    SetTextOutline() -- Enable text outline
    SetTextEntry("STRING") -- Set the text entry type
    AddTextComponentString(displayText) -- Add the text to be displayed
    DrawText(screenX, screenY) -- Draw the text on screen at specified coordinates
end


-- Function to set the engine status of a vehicle
-- @param targetVehicle: The vehicle entity on which to set the engine status
-- @param engineActive: Boolean indicating whether to activate or deactivate the engine
function ConfigureVehicleEngine(targetVehicle, engineActive)
    -- Check if the vehicle entity exists
    if not DoesEntityExist(targetVehicle) then
        return
    end

    -- Activate or deactivate the engine based on the engineActive parameter
    if engineActive then
        -- Make the vehicle drivable and turn on the engine
        SetVehicleUndriveable(targetVehicle, false)
    else
        -- Turn off the engine and make the vehicle undriveable
        SetVehicleEngineOn(targetVehicle, false, false, true)
        SetVehicleUndriveable(targetVehicle, true)
    end
end


-- Function to get the crushing time based on vehicle damage
-- @param vehicleDamage: The amount of damage to the vehicle
-- @returns The calculated crush time based on the damage
function CalculateCrushTime(vehicleDamage)
    -- Default crush time if no matching range is found
    local crushTimeResult = 0

    -- Iterate over the damage time configurations
    for _, damageTimeConfig in ipairs(Config.VehicleDamageTimings) do
        local isDamageInRange = vehicleDamage >= damageTimeConfig.DamageRange.Min 
                                and vehicleDamage <= damageTimeConfig.DamageRange.Max

        -- Calculate crush time if damage is within the specified range
        if isDamageInRange then
            crushTimeResult = math.random(damageTimeConfig.TimeRange.Min, damageTimeConfig.TimeRange.Max)
            break -- Exit the loop as we found the applicable time range
        end
    end

    return crushTimeResult
end


-- Function to draw 3D text in the world with optimized performance
-- @param worldX, worldY, worldZ: World coordinates for the text
-- @param displayText: The text to display
-- @param textColor: Table containing RGBA values for text color (default if nil)
-- @param textFont: Text font (default if nil)
-- @param textSizeModifier: Additional scaling for the text (default if nil)
-- @param centerText: Boolean to center the text (true by default)
-- @param proportionalText: Boolean to make the text proportional (true by default)
function Draw3DText(worldX, worldY, worldZ, displayText, textColor, textFont, textSizeModifier, centerText, proportionalText)
    -- Convert world coordinates to screen coordinates
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(worldX, worldY, worldZ)

    -- Exit early if the text is not on screen
    if not onScreen then return end

    -- Set defaults for parameters
    textColor = textColor or { red = 210, green = 210, blue = 210, alpha = 180 }
    textFont = textFont or 4
    textSizeModifier = textSizeModifier or 0

    -- Configure text properties
    SetTextFont(textFont)
    SetTextScale(0.30 + textSizeModifier, 0.30 + textSizeModifier)
    SetTextProportional(proportionalText ~= false) -- True by default
    SetTextColour(textColor.red, textColor.green, textColor.blue, textColor.alpha)
    SetTextCentre(centerText ~= false) -- True by default
    SetTextDropshadow(50, 210, 210, 210, 255)
    SetTextOutline()

    -- Prepare and draw text
    SetTextEntry("STRING")
    AddTextComponentString(displayText)
    DrawText(screenX, screenY - 0.035) -- Offset Y to align properly
end