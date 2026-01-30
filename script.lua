local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

----------------------------------------------------
-- GUI CREATION
----------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.Parent = ScreenGui
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

----------------------------------------------------
-- TITLE BAR
----------------------------------------------------

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "✨ Modern Control Panel"
Title.TextSize = 20
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

----------------------------------------------------
-- TAB HOLDER
----------------------------------------------------

local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(0,120,1,-40)
TabHolder.Position = UDim2.new(0,0,0,40)
TabHolder.BackgroundColor3 = Color3.fromRGB(30,30,35)
TabHolder.Parent = Main

Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0,10)

----------------------------------------------------
-- CONTENT FRAME
----------------------------------------------------

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-120,1,-40)
Content.Position = UDim2.new(0,120,0,40)
Content.BackgroundTransparency = 1
Content.Parent = Main

----------------------------------------------------
-- TAB SYSTEM
----------------------------------------------------

local Tabs = {}
local function CreateTab(name)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,40)
    Button.Text = name
    Button.Font = Enum.Font.Gotham
    Button.TextColor3 = Color3.new(1,1,1)
    Button.BackgroundTransparency = 1
    Button.Parent = TabHolder

    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1,0,1,0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0,8)

    Tabs[Button] = Page

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(Content:GetChildren()) do
            if v:IsA("Frame") then
                v.Visible = false
            end
        end
        Page.Visible = true
    end)

    return Page
end

----------------------------------------------------
-- CREATE TABS
----------------------------------------------------

local MainTab = CreateTab("Main")
local SettingsTab = CreateTab("Settings")

MainTab.Visible = true

----------------------------------------------------
-- UI ELEMENT FUNCTIONS
----------------------------------------------------

local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-20,0,40)
    Button.BackgroundColor3 = Color3.fromRGB(50,50,60)
    Button.Text = text
    Button.Font = Enum.Font.Gotham
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = parent
    Instance.new("UICorner", Button)

    Button.MouseButton1Click:Connect(callback)
end

local function CreateToggle(parent, text)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1,-20,0,40)
    Toggle.BackgroundColor3 = Color3.fromRGB(50,50,60)
    Toggle.Text = text .. " : OFF"
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.Parent = parent
    Instance.new("UICorner", Toggle)

    local state = false

    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = text .. " : " .. (state and "ON" or "OFF")
    end)
end

local function CreateSlider(parent, text, min, max)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,-20,0,50)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,20)
    Label.Text = text .. " : " .. min
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1,0,0,10)
    Bar.Position = UDim2.new(0,0,0,30)
    Bar.BackgroundColor3 = Color3.fromRGB(70,70,80)
    Bar.Parent = Frame
    Instance.new("UICorner", Bar)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0,0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(150,100,255)
    Fill.Parent = Bar
    Instance.new("UICorner", Fill)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            local move
            move = game:GetService("UserInputService").InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then

                    local percent = math.clamp(
                        (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                        0,1
                    )

                    Fill.Size = UDim2.new(percent,0,1,0)

                    local value = math.floor(min + (max-min)*percent)
                    Label.Text = text .. " : " .. value
                end
            end)

            game:GetService("UserInputService").InputEnded:Wait()
            if move then move:Disconnect() end
        end
    end)
end

----------------------------------------------------
-- MAIN TAB CONTENT
----------------------------------------------------

CreateButton(MainTab,"🚀 Example Button",function()
    print("Button clicked!")
end)

CreateToggle(MainTab,"🔥 Power Mode")

CreateSlider(MainTab,"⚡ Speed",0,100)

----------------------------------------------------
-- SETTINGS TAB CONTENT
----------------------------------------------------

CreateToggle(SettingsTab,"🌙 Dark Mode")

CreateButton(SettingsTab,"❌ Close UI",function()
    ScreenGui:Destroy()
end)

----------------------------------------------------
-- OPEN ANIMATION
----------------------------------------------------

Main.Size = UDim2.new(0,0,0,0)

TweenService:Create(
    Main,
    TweenInfo.new(0.4,Enum.EasingStyle.Back),
    {Size = UDim2.new(0,500,0,320)}
):Play()
