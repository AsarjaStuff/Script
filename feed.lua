--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Find API folder
local API = ReplicatedStorage:WaitForChild("API")

--// Auto find the RemoteFunction inside API
local function findFeedRemote()
	for _, v in pairs(API:GetChildren()) do
		if v:IsA("RemoteFunction") then
			return v
		end
	end
end

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0.5, -125, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(0, 220, 0, 35)
TextBox.Position = UDim2.new(0.5, -110, 0, 15)
TextBox.PlaceholderText = "Enter Egg Name..."
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
TextBox.TextColor3 = Color3.new(1,1,1)

local FeedButton = Instance.new("TextButton", Frame)
FeedButton.Size = UDim2.new(0, 220, 0, 35)
FeedButton.Position = UDim2.new(0.5, -110, 0, 65)
FeedButton.Text = "Feed Pet"
FeedButton.BackgroundColor3 = Color3.fromRGB(70,130,255)
FeedButton.TextColor3 = Color3.new(1,1,1)

--// Feed logic
FeedButton.MouseButton1Click:Connect(function()

	local eggName = TextBox.Text
	if eggName == "" then return end

	local remote = findFeedRemote()
	if not remote then
		warn("Feed remote not found")
		return
	end

	local egg = workspace:WaitForChild("Pets"):FindFirstChild(eggName)
	if not egg then
		warn("Egg not found")
		return
	end

	local args = {
		"f-57",
		"UseBlock",
		{
			cframe = CFrame.new(8946.6591796875, 6954.2998046875, 11964.7998046875)
		},
		egg
	}

	remote:InvokeServer(unpack(args))
end)
