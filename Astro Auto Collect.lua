-- Settings & Variables
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gearFolder = ReplicatedFirst:WaitForChild("Gears")
local isToggled = false

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GearCollectorUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 150, 0, 50)
toggleBtn.Dragable = true
toggleBtn.Position = UDim2.new(0, 20, 0.5, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Auto-Collect: OFF"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.Parent = screenGui

-- Rounded corners for the button
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = toggleBtn

-- Function to find and teleport
local function teleportToGears()
    if not isToggled then return end
    
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Get list of valid gear names
    local validNames = {}
    for _, g in pairs(gearFolder:GetChildren()) do
        validNames[g.Name] = true
    end

    -- Deep find in Workspace
    for _, item in pairs(workspace:GetDescendants()) do
        if isToggled and validNames[item.Name] then
            -- Make sure it's an actual object in the world, not in your inventory
            if item:IsA("BasePart") or item:IsA("Model") then
                if not item:IsDescendantOf(character) then
                    
                    -- Teleport
                    if item:IsA("BasePart") then
                        root.CFrame = item.CFrame
                    else
                        root.CFrame = item:GetModelCFrame()
                    end
                    
                    task.wait(0.3) -- Small delay to prevent crashing/kick
                end
            end
        end
    end
end

-- Toggle Logic
toggleBtn.MouseButton1Click:Connect(function()
    isToggled = not isToggled
    
    if isToggled then
        toggleBtn.Text = "Auto-Collect: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        -- Run the loop in a separate thread
        task.spawn(function()
            while isToggled do
                teleportToGears()
                task.wait(1) -- Scans every 1 second
            end
        end)
    else
        toggleBtn.Text = "Auto-Collect: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)