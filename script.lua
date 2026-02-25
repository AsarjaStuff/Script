-- Pet Controller UI (Fixed Remotes)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetControllerUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🐾 Pet Controller"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Parent = mainFrame
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16

-- Refresh Pets Button
local refreshButton = Instance.new("TextButton")
refreshButton.Name = "RefreshButton"
refreshButton.Parent = mainFrame
refreshButton.Size = UDim2.new(1, -20, 0, 30)
refreshButton.Position = UDim2.new(0, 10, 0, 45)
refreshButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8)
refreshButton.BorderSizePixel = 0
refreshButton.Text = "🔄 Refresh Pet List"
refreshButton.TextColor3 = Color3.new(1, 1, 1)
refreshButton.Font = Enum.Font.SourceSansBold
refreshButton.TextSize = 14

-- Pet Dropdown
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Name = "DropdownFrame"
dropdownFrame.Parent = mainFrame
dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.ClipsDescendants = true

local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Parent = dropdownFrame
dropdownButton.Size = UDim2.new(1, 0, 0, 35)
dropdownButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
dropdownButton.BorderSizePixel = 0
dropdownButton.Text = "Select a Pet ▼"
dropdownButton.TextColor3 = Color3.new(1, 1, 1)
dropdownButton.Font = Enum.Font.SourceSans
dropdownButton.TextSize = 14

-- Scrollable Pet List
local petListFrame = Instance.new("ScrollingFrame")
petListFrame.Name = "PetListFrame"
petListFrame.Parent = dropdownFrame
petListFrame.Size = UDim2.new(1, 0, 0, 150)
petListFrame.Position = UDim2.new(0, 0, 0, 35)
petListFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
petListFrame.BorderSizePixel = 0
petListFrame.ScrollBarThickness = 6
petListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
petListFrame.Visible = false

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Parent = mainFrame
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Click Refresh to load pets"
statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Control Buttons Frame
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "ControlsFrame"
controlsFrame.Parent = mainFrame
controlsFrame.Size = UDim2.new(1, -20, 0, 100)
controlsFrame.Position = UDim2.new(0, 10, 0, 165)
controlsFrame.BackgroundTransparency = 1

-- Drop Button
local dropButton = Instance.new("TextButton")
dropButton.Name = "DropButton"
dropButton.Parent = controlsFrame
dropButton.Size = UDim2.new(1, 0, 0, 45)
dropButton.Position = UDim2.new(0, 0, 0, 0)
dropButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0.2)
dropButton.BorderSizePixel = 0
dropButton.Text = "Drop Pet"
dropButton.TextColor3 = Color3.new(0.5, 0.5, 0.5)
dropButton.Font = Enum.Font.SourceSansBold
dropButton.TextSize = 16
dropButton.AutoButtonColor = false

-- Pick Up Button
local pickUpButton = Instance.new("TextButton")
pickUpButton.Name = "PickUpButton"
pickUpButton.Parent = controlsFrame
pickUpButton.Size = UDim2.new(1, 0, 0, 45)
pickUpButton.Position = UDim2.new(0, 0, 0, 55)
pickUpButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.2)
pickUpButton.BorderSizePixel = 0
pickUpButton.Text = "Pick Up Pet"
pickUpButton.TextColor3 = Color3.new(0.5, 0.5, 0.5)
pickUpButton.Font = Enum.Font.SourceSansBold
pickUpButton.TextSize = 16
pickUpButton.AutoButtonColor = false

-- Variables
local selectedPet = nil
local dropRemote = nil
local pickUpRemote = nil
local dropdownOpen = false

-- Function to find API remotes
local function findApiRemotes()
    local apiFolder = game:GetService("ReplicatedStorage"):WaitForChild("API")
    
    -- EXACT remote names you provided
    dropRemote = apiFolder:WaitForChild("nQcejsHBu/fbasBbdA")
    pickUpRemote = apiFolder:WaitForChild("nQcejsHBuCkibAac/")
    
    if dropRemote and pickUpRemote then
        print("Found drop remote:", dropRemote.Name)
        print("Found pick up remote:", pickUpRemote.Name)
        return true
    end
    
    return false
end

-- Function to update button states
local function updateButtons(enabled)
    if enabled then
        dropButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        dropButton.TextColor3 = Color3.new(1, 1, 1)
        dropButton.AutoButtonColor = true
        
        pickUpButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        pickUpButton.TextColor3 = Color3.new(1, 1, 1)
        pickUpButton.AutoButtonColor = true
    else
        dropButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0.2)
        dropButton.TextColor3 = Color3.new(0.5, 0.5, 0.5)
        dropButton.AutoButtonColor = false
        
        pickUpButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.2)
        pickUpButton.TextColor3 = Color3.new(0.5, 0.5, 0.5)
        pickUpButton.AutoButtonColor = false
    end
end

-- Function to refresh pet list
local function refreshPets()
    statusLabel.Text = "Loading pets..."
    statusLabel.TextColor3 = Color3.new(1, 1, 0.5)
    
    -- Clear existing list
    for _, child in ipairs(petListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Find pets folder
    local petsFolder = workspace:FindFirstChild("Pets")
    if not petsFolder then
        statusLabel.Text = "Pets folder not found!"
        statusLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
        return
    end
    
    local pets = {}
    for _, pet in ipairs(petsFolder:GetChildren()) do
        if pet:IsA("Model") or pet:IsA("Part") or pet:IsA("BasePart") then
            table.insert(pets, pet.Name)
        end
    end
    
    if #pets == 0 then
        statusLabel.Text = "No pets found!"
        statusLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
        return
    end
    
    -- Create buttons for each pet
    for i, petName in ipairs(pets) do
        local petButton = Instance.new("TextButton")
        petButton.Name = petName
        petButton.Parent = petListFrame
        petButton.Size = UDim2.new(1, -10, 0, 30)
        petButton.Position = UDim2.new(0, 5, 0, (i-1) * 35)
        petButton.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
        petButton.BorderSizePixel = 0
        petButton.Text = "  " .. petName
        petButton.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        petButton.Font = Enum.Font.SourceSans
        petButton.TextSize = 14
        petButton.TextXAlignment = Enum.TextXAlignment.Left
        
        petButton.MouseEnter:Connect(function()
            petButton.BackgroundColor3 = Color3.new(0.3, 0.5, 0.8)
        end)
        
        petButton.MouseLeave:Connect(function()
            petButton.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
        end)
        
        petButton.MouseButton1Click:Connect(function()
            selectedPet = petsFolder:FindFirstChild(petName)
            dropdownButton.Text = petName .. " ▼"
            dropdownOpen = false
            petListFrame.Visible = false
            dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
            
            if selectedPet then
                statusLabel.Text = "Selected: " .. petName
                statusLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
                updateButtons(true)
            end
        end)
    end
    
    petListFrame.CanvasSize = UDim2.new(0, 0, 0, #pets * 35)
    statusLabel.Text = "Found " .. #pets .. " pets! Select one."
    statusLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
    
    -- Try to find API
    if findApiRemotes() then
        statusLabel.Text = statusLabel.Text .. " (API Ready)"
    else
        statusLabel.Text = statusLabel.Text .. " (API not found)"
    end
end

-- Dropdown toggle
dropdownButton.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        petListFrame.Visible = true
        dropdownFrame.Size = UDim2.new(1, -20, 0, 190)
        dropdownButton.Text = dropdownButton.Text:gsub("▼", "▲")
    else
        petListFrame.Visible = false
        dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
        dropdownButton.Text = dropdownButton.Text:gsub("▲", "▼")
    end
end)

-- Refresh button
refreshButton.MouseButton1Click:Connect(function()
    refreshPets()
end)

-- Drop button - FIXED: Uses table with unpack like your example
dropButton.MouseButton1Click:Connect(function()
    if dropRemote and selectedPet then
        local args = {selectedPet}
        dropRemote:FireServer(unpack(args))
        statusLabel.Text = "Pet dropped!"
        statusLabel.TextColor3 = Color3.new(1, 0.8, 0.2)
    end
end)

-- Pick Up button - FIXED: Uses same format
pickUpButton.MouseButton1Click:Connect(function()
    if pickUpRemote and selectedPet then
        pickUpButton.Text = "Picking up..."
        
        local args = {selectedPet}
        pickUpRemote:FireServer(unpack(args))
        
        statusLabel.Text = "Pet picked up!"
        statusLabel.TextColor3 = Color3.new(0.2, 1, 1)
        
        wait(0.5)
        pickUpButton.Text = "Pick Up Pet"
    end
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Initialize buttons as disabled
updateButtons(false)

-- Auto-refresh on load
refreshPets()
