local UI = {}

function UI.Init(Pets, Sleep, Remotes)

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local selectedPet = nil

    -- UI creation (same as yours)
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "PetControllerUI"

    local holdBtn = Instance.new("TextButton", gui)
    local ejectBtn = Instance.new("TextButton", gui)
    local sleepBtn = Instance.new("TextButton", gui)

    -- HOLD
    holdBtn.MouseButton1Click:Connect(function()

        if not selectedPet then return end

        -- 🔥 CRITICAL FIX: send INSTANCE, NOT NAME
        Remotes.HoldBaby:FireServer(selectedPet)

    end)

    -- DROP
    ejectBtn.MouseButton1Click:Connect(function()

        if not selectedPet then return end

        Remotes.EjectBaby:FireServer(selectedPet)

    end)

    -- SLEEP
    sleepBtn.MouseButton1Click:Connect(function()

        if not selectedPet then return end

        local id,seat = Sleep.FindBed()

        if not id then return end

        Remotes.ActivateFurniture:InvokeServer(
            player,
            id,
            "Seat1",
            {cframe = seat.CFrame},
            selectedPet
        )

    end)
end

return UI