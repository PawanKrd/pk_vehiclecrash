Citizen.CreateThread(function()
    while true do
        -- Iterate through all vehicles in the game
        local allVehiclesInGame = GetAllVehicles()
        for _, currentVehicle in ipairs(allVehiclesInGame) do
            Citizen.CreateThread(function()
                local currentStateOfVehicle = Entity(currentVehicle).state

                -- Check and update the engine damaged time
                if currentStateOfVehicle.engineDamagedTime ~= nil then
                    if currentStateOfVehicle.engineDamagedTime > 0 then
                        currentStateOfVehicle.engineDamagedTime = currentStateOfVehicle.engineDamagedTime - 1
                    end
                else
                    currentStateOfVehicle.engineDamagedTime = 0
                end
            end)
        end

        -- Delay the loop to reduce CPU usage
        Citizen.Wait(1000) -- Increased from 500 ms for better performance
    end
end)
