local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local flying = false
local bodyVelocity
local bodyGyro
local flyConnection

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Tlačítko zavření GUI
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 100, 0, 40)
closeButton.Position = UDim2.new(0.95, -110, 0.95, -50) -- vpravo dole
closeButton.Text = "Stop"
closeButton.Parent = screenGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 30)
statusLabel.Position = UDim2.new(0.5, -100, 0.9, 0)
statusLabel.Text = "Fly on"
statusLabel.TextColor3 = Color3.new(0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = screenGui

local function startFlying()
    local character = player.Character
    if not character then
        print("Postava neexistuje, nelze létat")
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then
        print("Chybí HumanoidRootPart nebo Humanoid")
        return
    end

    humanoid.PlatformStand = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(0,0,0)
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000,400000,400000)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart

    local function flyUpdate()
        if not flying or not rootPart or not bodyVelocity or not bodyGyro then
            return
        end

        local moveDirection = Vector3.new()
        local camCF = workspace.CurrentCamera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0,1,0)
        end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * 50
            bodyVelocity.Velocity = moveDirection
            bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        else
            -- Vis ve vzduchu
            bodyVelocity.Velocity = Vector3.new(0, 5, 0)
            bodyVelocity.MaxForce = Vector3.new(0, 1e5, 0)
        end
    end

    flyConnection = RunService.RenderStepped:Connect(flyUpdate)
    print("Fly on")
end

local function stopFlying()
    flying = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    print("Fly off")
end

closeButton.MouseButton1Click:Connect(function()
    stopFlying()
    screenGui:Destroy()
end)

player.CharacterAdded:Connect(function()
    stopFlying()
end)

-- Zapni létání hned při spuštění skriptu
flying = true
startFlying()
