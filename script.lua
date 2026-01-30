-- Pet Controller UI
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
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Pet Controller"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16

-- Pet Name Input
local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Parent = mainFrame
inputFrame.Size = UDim2.new(1, -20, 0, 30)
inputFrame.Position = UDim2.new(0, 10, 0, 40)
inputFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
inputFrame.BorderSizePixel = 0

local petNameInput = Instance.new("TextBox")
petNameInput.Name = "PetNameInput"
petNameInput.Parent = inputFrame
petNameInput.Size = UDim2.new(1, -10, 1, 0)
petNameInput.Position = UDim2.new(0, 5, 0, 0)
petNameInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
petNameInput.BorderSizePixel = 0
petNameInput.Text = "Frost Dragon"
petNameInput.TextColor3 = Color3.new(1, 1, 1)
petNameInput.Font = Enum.Font.SourceSans
petNameInput.TextSize = 14

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Parent = mainFrame
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 80)
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Enter pet name and click Find API"
statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Find API Button
local findApiButton = Instance.new("TextButton")
findApiButton.Name = "FindApiButton"
findApiButton.Parent = mainFrame
findApiButton.Size = UDim2.new(1, -20, 0, 30)
findApiButton.Position = UDim2.new(0, 10, 0, 110)
findApiButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
findApiButton.BorderSizePixel = 0
findApiButton.Text = "Find API"
findApiButton.TextColor3 = Color3.new(1, 1, 1)
findApiButton.Font = Enum.Font.SourceSansBold
findApiButton.TextSize = 14

-- Drop Button (initially disabled)
local dropButton = Instance.new("TextButton")
dropButton.Name = "DropButton"
dropButton.Parent = mainFrame
dropButton.Size = UDim2.new(1, -20, 0, 40)
dropButton.Position = UDim2.new(0, 10, 0, 160)
dropButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
dropButton.BorderSizePixel = 0
dropButton.Text = "Drop Pet"
dropButton.TextColor3 = Color3.new(1, 1, 1)
dropButton.Font = Enum.Font.SourceSansBold
dropButton.TextSize = 14
dropButton.Active = false

-- Pick Up Button (initially disabled)
local pickUpButton = Instance.new("TextButton")
pickUpButton.Name = "PickUpButton"
pickUpButton.Parent = mainFrame
pickUpButton.Size = UDim2.new(1, -20, 0, 40)
pickUpButton.Position = UDim2.new(0, 10, 0, 210)
pickUpButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
pickUpButton.BorderSizePixel = 0
pickUpButton.Text = "Pick Up Pet"
pickUpButton.TextColor3 = Color3.new(1, 1, 1)
pickUpButton.Font = Enum.Font.SourceSansBold
pickUpButton.TextSize = 14
pickUpButton.Active = false

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Parent = mainFrame
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14

-- Variables to store found remotes
local dropRemote = nil
local pickUpRemote = nil
local foundPet = nil

-- Function to find API remotes
local function findApiRemotes(petName)
    statusLabel.Text = "Searching for API..."
    
    -- Find the pet
    foundPet = workspace:WaitForChild("Pets"):FindFirstChild(petName)
    if not foundPet then
        statusLabel.Text = "Pet not found!"
        statusLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
        return false
    end
    
    -- Find the API folder
    local apiFolder = game:GetService("ReplicatedStorage"):WaitForChild("API")
    if not apiFolder then
        statusLabel.Text = "API folder not found!"
        statusLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
        return false
    end
    
    -- Search for drop remote
    local dropPatterns = {"pSegluJDwBhdcuDdfC", "DropPet", "Drop", "pDrop"}
    for _, pattern in ipairs(dropPatterns) do
        dropRemote = apiFolder:FindFirstChild(pattern)
        if dropRemote then break end
    end
    
    -- Search for pick up remote
    local pickUpPatterns = {"pSegluJDwEmkdCceB", "PickUpPet", "PickUp", "pPickUp"}
    for _, pattern in ipairs(pickUpPatterns) do
        pickUpRemote = apiFolder:FindFirstChild(pattern)
        if pickUpRemote then break end
    end
    
    -- Check if remotes were found
    if dropRemote and pickUpRemote then
        statusLabel.Text = "API found! Ready to use."
        statusLabel.TextColor3 = Color3.new(0.2, 1, 0.2)
        dropButton.Active = true
        dropButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        pickUpButton.Active = true
        pickUpButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
        return true
    else
        statusLabel.Text = "API remotes not found!"
        statusLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
        return false
    end
end

-- Button connections
findApiButton.MouseButton1Click:Connect(function()
    local petName = petNameInput.Text
    if petName and petName ~= "" then
        findApiRemotes(petName)
    else
        statusLabel.Text = "Please enter a pet name!"
        statusLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
    end
end)

dropButton.MouseButton1Click:Connect(function()
    if dropRemote and foundPet then
        dropRemote:FireServer(foundPet)
        statusLabel.Text = "Pet dropped!"
        statusLabel.TextColor3 = Color3.new(1, 1, 0)
    end
end)

pickUpButton.MouseButton1Click:Connect(function()
    if pickUpRemote and foundPet then
        pickUpRemote:FireServer(foundPet)
        statusLabel.Text = "Pet picked up!"
        statusLabel.TextColor3 = Color3.new(0.2, 1, 1)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
