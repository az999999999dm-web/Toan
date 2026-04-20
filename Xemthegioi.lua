-- SCRIPT FLY PHAP SU: BAY XEM THE GIOI (V2 - DRAG & AUTO LOAD) --
local p = game.Players.LocalPlayer
local char = p.Character or p.CharacterAdded:Wait()
local pGui = p:WaitForChild("PlayerGui")
local run = game:GetService("RunService")
local inputS = game:GetService("UserInputService")

local flying, speed, lastPos = false, 50, nil
local bV, bG

-- --- GIAO DIỆN (GUI) ---
local sg = Instance.new("ScreenGui", pGui)
sg.Name = "PhapSuFly_V2"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 180, 0, 110)
frame.Position = UDim2.new(0.5, -90, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
local corner = Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "FLY MENU (DRAG)"
title.TextColor3 = Color3.new(1, 1, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.9, 0, 0, 35)
btn.Position = UDim2.new(0.05, 0, 0.25, 0)
btn.Text = "FLY: OFF"
btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btn)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.9, 0, 0, 30)
box.Position = UDim2.new(0.05, 0, 0.65, 0)
box.Text = "50"
box.PlaceholderText = "Speed..."
box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
box.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", box)

-- --- LOGIC KÉO THẢ (SMOOTH DRAG) ---
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = frame.Position
    end
end)
inputS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
inputS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- --- LOGIC FLY ---
local function toggleFly()
    char = p.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    flying = not flying
    speed = tonumber(box.Text) or 50
    
    if flying then
        btn.Text = "FLY: ON" btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        if lastPos then char.HumanoidRootPart.CFrame = lastPos end
        
        bG = Instance.new("BodyGyro", char.HumanoidRootPart)
        bG.P = 9e4 bG.maxTorque = Vector3.new(9e9, 9e9, 9e9) bG.cframe = char.HumanoidRootPart.CFrame
        bV = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bV.velocity = Vector3.new(0, 0, 0) bV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        char.Humanoid.PlatformStand = true
    else
        btn.Text = "FLY: OFF" btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        lastPos = char.HumanoidRootPart.CFrame
        if bG then bG:Destroy() end if bV then bV:Destroy() end
        char.Humanoid.PlatformStand = false
    end
end

btn.MouseButton1Click:Connect(toggleFly)

run.RenderStepped:Connect(function()
    if flying and char and char:FindFirstChild("HumanoidRootPart") then
        bV.velocity = workspace.CurrentCamera.CFrame.LookVector * speed
        bG.cframe = workspace.CurrentCamera.CFrame
    end
end)
