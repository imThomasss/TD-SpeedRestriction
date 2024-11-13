Citizen.CreateThread(function()
    local lastVehicle = nil
    local speedLimitApplied = false
    local maxSpeedMph = 129  -- Set a default speed limit
    local maxSpeedMps = maxSpeedMph / 2.236936  -- Convert to meters per second

    while true do
        Citizen.Wait(500)  -- Check every 500 milliseconds

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            -- Reset speed limit flag when changing vehicles
            if vehicle ~= lastVehicle then
                lastVehicle = vehicle
                speedLimitApplied = false
            end

            -- Check if the vehicle is a plane or helicopter
            local vehicleClass = GetVehicleClass(vehicle)

            -- Check and apply speed limit only if not in a plane or helicopter
            if vehicleClass ~= 15 and vehicleClass ~= 16 then  -- 15 = Plane, 16 = Helicopter
                local speed = GetEntitySpeed(vehicle) * 2.236936  -- Speed in mph

                if speed > maxSpeedMph then
                    if not speedLimitApplied then
                        SetEntityMaxSpeed(vehicle, maxSpeedMps)
                        speedLimitApplied = true

                        -- Notify player
                        lib.notify({
                            id = 'speednoti1',
                            title = "Thomas Developments",
                            description = 'The server speed limit is: ' .. maxSpeedMph .. ' MPH. We have reduced your speed to ensure you are compliant with our server rules.',
                            Duration = 10000,
                            showDuration = true,
                            position = 'top-right',
                            style = {
                                backgroundColor = '#141517',
                                color = '#C1C2C5',
                                ['.description'] = {
                                    color = '#909296'
                                }
                            },
                            icon = 'circle-info',
                            iconAnimation = "beat",
                            iconColor = '#ADD8E6'
                        })
                    end
                else
                    if speedLimitApplied then
                        SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel'))
                        speedLimitApplied = false
                    end
                end
            else
                -- If in a plane or helicopter, reset speed limit
                if speedLimitApplied then
                    SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel'))
                    speedLimitApplied = false
                end
            end
        else
            -- Player is not in a vehicle, reset vehicle reference
            lastVehicle = nil
            speedLimitApplied = false  -- Reset speed limit flag when exiting vehicle
        end
    end
end)