local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyControl"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local flyFrame = Instance.new("Frame")
flyFrame.Name = "FlyFrame"
flyFrame.Size = UDim2.new(0, 200, 0, 100)
flyFrame.Position = UDim2.new(1, -210, 0, 10)
flyFrame.BorderSizePixel = 0
flyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
flyFrame.BackgroundTransparency = 0.25
flyFrame.Parent = screenGui

-- Add UI corners for a nice rounded look
local uiCorner = Instance.new("UICorner")
uiCorner.Parent = flyFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Fly Controls"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = flyFrame

local toggleFlyButton = Instance.new("TextButton")
toggleFlyButton.Name = "ToggleFlyButton"
toggleFlyButton.Size = UDim2.new(1, -20, 0, 30)
toggleFlyButton.Position = UDim2.new(0, 10, 0, 30)
toggleFlyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleFlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleFlyButton.Text = "Toggle Fly (F)"
toggleFlyButton.TextScaled = true
toggleFlyButton.Font = Enum.Font.SourceSansSemibold
toggleFlyButton.Parent = flyFrame

-- Add UI corners to the button
local buttonCorner = Instance.new("UICorner")
buttonCorner.Parent = toggleFlyButton

local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(1, -60, 0, 30)
speedInput.Position = UDim2.new(0, 10, 0, 65)
speedInput.PlaceholderText = "Fly Speed (1-500)"
speedInput.Text = "50"
speedInput.ClearTextOnFocus = false
speedInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.SourceSansSemibold
speedInput.TextScaled = true
speedInput.Parent = flyFrame

-- Add UI corners to the text box
local inputCorner = Instance.new("UICorner")
inputCorner.Parent = speedInput

-- Variables for flying logic
local isFlying = false
local currentSpeed = 50
local lastFlyCFrame = nil
local gravityWas = workspace.Gravity

-- Fly Toggling and Speed Control
local function toggleFly()
    isFlying = not isFlying
    if isFlying then
        -- Start flying
        toggleFlyButton.Text = "Disable Fly (F)"
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.AutoRotate = false
        humanoid.PlatformStand = true
        workspace.Gravity = 0
        lastFlyCFrame = humanoidRootPart.CFrame
    else
        -- Stop flying
        toggleFlyButton.Text = "Toggle Fly (F)"
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
        workspace.Gravity = gravityWas
        humanoidRootPart.CFrame = lastFlyCFrame
    end
end

-- Keybind for toggling fly
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- Update the fly speed from the TextBox
speedInput.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed and newSpeed > 0 and newSpeed <= 500 then
        currentSpeed = newSpeed
        print("Fly speed set to: " .. currentSpeed)
    else
        -- Invalid input, revert to previous value and inform user
        speedInput.Text = tostring(currentSpeed)
        print("Invalid speed. Please enter a number between 1 and 500.")
    end
end)

-- Main flying loop
RunService.Heartbeat:Connect(function(step)
    if not isFlying then return end

    local moveVector = Vector3.new(0, 0, 0)
    local moveSpeed = currentSpeed

    -- Get user input for movement
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector += Vector3.new(0, 0, -1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector += Vector3.new(0, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector += Vector3.new(-1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector += Vector3.new(1, 0, 0)
    end

    -- Up/down movement
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveVector += Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveVector += Vector3.new(0, -1, 0)
    end

    -- Normalize vector and apply speed
    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit * moveSpeed * step
        humanoidRootPart.CFrame += humanoidRootPart.CFrame.Rotation * moveVector
    end
end)

-- Listen for character death to reset fly state
humanoid.Died:Connect(function()
    isFlying = false
    -- The script will automatically respawn with the player, so we just need to reset the state.
end)

-- Add a hint to the screen for controls
local hintLabel = Instance.new("TextLabel")
hintLabel.Name = "HintLabel"
hintLabel.Size = UDim2.new(1, -20, 0, 20)
hintLabel.Position = UDim2.new(0.5, -90, 1, -25)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "W,A,S,D to move, Space to go up, Shift to go down"
hintLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
hintLabel.TextScaled = true
hintLabel.Font = Enum.Font.SourceSans
