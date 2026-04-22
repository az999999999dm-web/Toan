local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local speed = 2.0 -- Tốc độ bay ngang
local climbSpeed = 1.5 -- Tốc độ bay lên/xuống
local upHeld = false
local downHeld = false

-- 1. GIAO DIỆN (Menu Dark Mode)
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 120, 0, 40)
mainBtn.Position = UDim2.new(0.5, -60, 0.02, 0)
mainBtn.Text = "FLY: OFF"
mainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainBtn.TextColor3 = Color3.new(1, 1, 1)
mainBtn.Font = Enum.Font.GothamBold
mainBtn.Draggable = true
Instance.new("UICorner", mainBtn)

-- Nút điều khiển độ cao (Tay phải)
local function createNavBtn(txt, pos)
    local b = Instance.new("TextButton", screenGui)
    b.Size = UDim2.new(0, 60, 0, 60)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.AutoButtonColor = true
    Instance.new("UICorner", b)
    return b
end

local upBtn = createNavBtn("UP", UDim2.new(0.8, 0, 0.5, -70))
local downBtn = createNavBtn("DOWN", UDim2.new(0.8, 0, 0.5, 10))

upBtn.MouseButton1Down:Connect(function() upHeld = true end)
upBtn.MouseButton1Up:Connect(function() upHeld = false end)
downBtn.MouseButton1Down:Connect(function() downHeld = true end)
downBtn.MouseButton1Up:Connect(function() downHeld = false end)

-- 2. CORE FLY & NOCLIP
RunService.Stepped:Connect(function()
    if not flying then return end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if root and hum then
        -- Khóa vật lý để không rơi
        root.Velocity = Vector3.new(0, 0, 0)
        
        -- Noclip cứng: Xuyên tường
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end

        -- HƯỚNG DI CHUYỂN PHẲNG (Fix lỗi đi ngược/cắm đầu)
        local camCF = camera.CFrame
        local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
        
        -- Tính toán hướng từ Joystick
        local moveVector = (flatLook * -hum.MoveDirection.Z) + (flatRight * hum.MoveDirection.X)
        
        -- Tạo vị trí mới
        local nextPos = root.Position
        
        -- Nếu đẩy Joystick thì di chuyển ngang
        if hum.MoveDirection.Magnitude > 0 then
            nextPos = nextPos + (moveVector * speed)
        end
        
        -- Nếu giữ nút thì di chuyển dọc
        if upHeld then nextPos = nextPos + Vector3.new(0, climbSpeed, 0) end
        if downHeld then nextPos = nextPos - Vector3.new(0, climbSpeed, 0) end
        
        -- Cập nhật CFrame (Xoay nhân vật theo Camera nhưng đứng thẳng)
        root.CFrame = CFrame.new(nextPos, nextPos + flatLook)
    end
end)

-- 3. BẬT/TẮT
mainBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        mainBtn.Text = "FLY: ON"
        mainBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
    else
        mainBtn.Text = "FLY: OFF"
        mainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)
