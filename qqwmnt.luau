Local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UIS = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua'))()
local Window = WindUI:CreateWindow({
    Title = 'qqwmnt hub',
    Icon = 'ghost',
    Author = 'by qqwmntSS',
    Folder = 'solvexis hub',
    Size = UDim2.fromOffset(500, 350),
    Transparent = false,
    Theme = 'Dark',
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200,
    OpenButton = {
        Enabled = true,
        Title = 'solvexis',
        Draggable = true,
        CornerRadius = UDim.new(0, 8),
        StrokeThickness = 1,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
    },
})

-- Вкладки
local PrankTab = Window:Tab({
    Title = 'Prank Bomb',
    Icon = 'mouse-pointer-click',
})
local GoldTab = Window:Tab({
    Title = 'Gold Jump',
    Icon = 'mouse-pointer-click',
})
local ESPTab = Window:Tab({
    Title = 'ESP',
    Icon = 'eye',
})

local gui = Instance.new('ScreenGui')
gui.Name = 'BombJumpUI'
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer.PlayerGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

----------------------------------------------------
-- СИСТЕМА СОХРАНЕНИЯ ПОЗИЦИЙ
----------------------------------------------------
local function SaveButtonPosition(pos, name)
    pcall(function()
        if writefile then
            local folder = 'NexiumHub'
            if not isfolder(folder) then
                makefolder(folder)
            end
            writefile(folder .. '/' .. name .. 'Pos.json', HttpService:JSONEncode({
                X = { Scale = pos.X.Scale, Offset = pos.X.Offset },
                Y = { Scale = pos.Y.Scale, Offset = pos.Y.Offset },
            }))
        end
    end)
end

local function LoadButtonPosition(name)
    local success, result = pcall(function()
        if readfile and isfile and isfile('NexiumHub/' .. name .. 'Pos.json') then
            return HttpService:JSONDecode(readfile('NexiumHub/' .. name .. 'Pos.json'))
        end
    end)
    if success and result then
        return UDim2.new(result.X.Scale, result.X.Offset, result.Y.Scale, result.Y.Offset)
    end
    return nil
end

----------------------------------------------------
-- СИСТЕМА КНОПОК BOMB JUMP (BACKGROUND TRANSPARENCY = 0.45)
----------------------------------------------------
local function CreateJumpSystem(config)
    local size = config.Size or 70
    local visible = false
    local cooldown = false
    local cooldownTime = config.Cooldown
    local editMode = false
    local buttonDefaultText = 'Bomb jump'
    local saveName = config.BombName
    local currentKeybind = config.Keybind or nil
    local defaultPos = config.Position or UDim2.new(0.5, -(size / 2), 0.5, -(size / 2))
    local buttonPos = LoadButtonPosition(saveName) or defaultPos

    local activeThemeColor = config.DefaultColor or Color3.fromRGB(140, 80, 255)

    local button = Instance.new('TextButton')
    button.Name = saveName .. 'Button'
    button.Parent = gui
    button.Size = UDim2.new(0, size, 0, size)
    button.Position = buttonPos
    button.Text = ""
    button.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
    button.BackgroundTransparency = 0.45 -- Установлено значение 0.45
    button.Active = true
    button.AutoButtonColor = false
    button.Visible = visible
    button.ZIndex = 100

    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local mainGradient = Instance.new('UIGradient')
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 20, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 20)),
    })
    mainGradient.Transparency = NumberSequence.new(0.2)
    mainGradient.Rotation = 45
    mainGradient.Parent = button

    local label = Instance.new('TextLabel')
    label.Name = "ButtonLabel"
    label.Parent = button
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = buttonDefaultText
    label.TextScaled = false
    label.TextSize = 13
    label.TextWrapped = true
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.7
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.ZIndex = 102

    local stroke = Instance.new('UIStroke')
    stroke.Thickness = 1.5
    stroke.Color = activeThemeColor
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = button

    local function UpdateButtonColor(newColor)
        activeThemeColor = newColor
        stroke.Color = newColor
    end

    local function UpdateSize(newSize)
        size = newSize
        button.Size = UDim2.new(0, size, 0, size)
    end

    local function PlayClickAnimation()
        local currentSize = button.Size.X.Offset

        local tweenDown = TweenService:Create(button, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, currentSize * 0.92, 0, currentSize * 0.92),
        })
        local tweenUp = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, currentSize, 0, currentSize),
        })

        tweenDown:Play()
        tweenDown.Completed:Connect(function()
            tweenUp:Play()
        end)
    end

    local function EnsureBombInBackpack()
        local character = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild('Backpack')
        if not character or not backpack then return nil end

        local bomb = character:FindFirstChild(config.BombName) or backpack:FindFirstChild(config.BombName)
        if not bomb then
            pcall(function()
                ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer(config.BombName)
            end)
            task.wait(0.15)
            bomb = character:FindFirstChild(config.BombName) or backpack:FindFirstChild(config.BombName)
        end
        return bomb
    end

    task.spawn(function()
        while true do
            task.wait(0.8)
            if visible then
                EnsureBombInBackpack()
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        cooldown = false
        task.wait()
        if not cooldown and not editMode then
            label.Text = buttonDefaultText
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        if visible then
            task.wait(0.5)
            EnsureBombInBackpack()
        end
    end)

    local dragging = false
    local dragStart
    local startPos

    button.InputBegan:Connect(function(input)
        if not editMode then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and editMode then
                SaveButtonPosition(button.Position, saveName)
            end
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not editMode then return end
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    local function GetBomb()
        local character = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild('Backpack')
        if not character then return nil end

        local bomb = character:FindFirstChild(config.BombName)
        if bomb then return bomb end

        if backpack then
            bomb = backpack:FindFirstChild(config.BombName)
            if bomb then
                bomb.Parent = character
                return bomb
            end
        end

        bomb = EnsureBombInBackpack()
        if bomb and backpack and bomb.Parent == backpack then
            bomb.Parent = character
        end
        return bomb
    end

    local function DoJump()
        if cooldown then return end
        local character = LocalPlayer.Character
        if not character then return end

        local hrp = character:FindFirstChild('HumanoidRootPart')
        local humanoid = character:FindFirstChild('Humanoid')
        if not hrp or not humanoid then return end

        local bomb = GetBomb()
        if not bomb then return end

        local remote = bomb:FindFirstChild('Remote')
        if not remote then return end

        local camera = workspace.CurrentCamera
        local lookVector = camera.CFrame.LookVector
        local position = hrp.Position + (lookVector * 5) + Vector3.new(0, 2, 0)

        pcall(function()
            remote:FireServer(CFrame.new(position), 50)
        end)

        task.delay(0.05, function()
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, math.max(hrp.AssemblyLinearVelocity.Y, 50), hrp.AssemblyLinearVelocity.Z)
            end
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)

        cooldown = true

        task.spawn(function()
            for i = cooldownTime, 1, -1 do
                if not cooldown then break end
                label.Text = tostring(i)
                task.wait(1)
            end

            if not editMode then
                label.Text = buttonDefaultText
            end
            cooldown = false
        end)

        task.delay(0.4, function()
            if bomb and bomb.Parent == character then
                bomb.Parent = LocalPlayer.Backpack
            end
        end)
    end

    button.MouseButton1Click:Connect(function()
        if editMode then return end
        PlayClickAnimation()
        DoJump()
    end)

    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or editMode or not currentKeybind then return end
        if input.KeyCode == currentKeybind then
            PlayClickAnimation()
            DoJump()
        end
    end)

    config.Tab:Toggle({
        Title = 'Show Button',
        Default = false,
        Callback = function(state)
            visible = state
            button.Visible = visible
            if visible then
                EnsureBombInBackpack()
            end
        end,
    })

    config.Tab:Toggle({
        Title = 'Edit Mode',
        Default = false,
        Callback = function(state)
            editMode = state
            if editMode then
                label.Text = 'MOVE'
            else
                if not cooldown then
                    label.Text = buttonDefaultText
                end
            end
        end,
    })

    config.Tab:Colorpicker({
        Title = 'Button Color',
        Default = activeThemeColor,
        Callback = function(color)
            UpdateButtonColor(color)
        end,
    })

    config.Tab:Slider({
        Title = 'Button Size',
        Value = { Min = 30, Max = 200, Default = size },
        Callback = function(v)
            UpdateSize(v)
        end,
    })

    config.Tab:Keybind({
        Title = 'Jump Keybind',
        Default = currentKeybind,
        Callback = function(key)
            currentKeybind = key
        end,
    })
end

CreateJumpSystem({
    Tab = PrankTab,
    BombName = 'FakeBomb',
    Cooldown = 22,
    Size = 75,
    Keybind = Enum.KeyCode.Q,
    DefaultColor = Color3.fromRGB(140, 80, 255),
})

CreateJumpSystem({
    Tab = GoldTab,
    BombName = 'GoldBomb',
    Cooldown = 4,
    Size = 75,
    Keybind = Enum.KeyCode.G,
    DefaultColor = Color3.fromRGB(240, 180, 50),
})

----------------------------------------------------
-- МОДУЛЬ ESP ИЗ VISION HUB (ИГРОКИ, РОЛИ, GUN DROP)
----------------------------------------------------
local ESP_Config = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Tracers = false,
    Roles = false,
    GunDrop = false,
    InnocentColor = Color3.fromRGB(0, 255, 0),
    SheriffColor = Color3.fromRGB(0, 0, 255),
    MurdererColor = Color3.fromRGB(255, 0, 0),
    HeroColor = Color3.fromRGB(255, 255, 0),
    GunDropColor = Color3.fromRGB(0, 255, 255)
}

local espGui = Instance.new("Folder")
espGui.Name = "VisionESP"
espGui.Parent = game:GetService("CoreGui")

local function GetPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character

    local hasKnife = (backpack and backpack:FindFirstChild("Knife")) or character:FindFirstChild("Knife")
    local hasGun = (backpack and backpack:FindFirstChild("Gun")) or character:FindFirstChild("Gun")

    if hasKnife then
        return "Murderer"
    elseif hasGun then
        return "Sheriff"
    end
    return "Innocent"
end

local function GetRoleColor(role)
    if role == "Murderer" then return ESP_Config.MurdererColor
    elseif role == "Sheriff" then return ESP_Config.SheriffColor
    elseif role == "Hero" then return ESP_Config.HeroColor
    else return ESP_Config.InnocentColor end
end

local espObjects = {}

local function ClearESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        espObjects[player] = nil
    end
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    ClearESP(player)

    local folder = Instance.new("Folder")
    folder.Name = player.Name
    folder.Parent = espGui

    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.Adornee = nil
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = folder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameGui"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = folder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = billboard

    espObjects[player] = {
        Folder = folder,
        Highlight = highlight,
        Billboard = billboard,
        Label = nameLabel
    }
end

local gunDropHighlight = nil
local gunDropBillboard = nil

local function UpdateGunDropESP()
    local gunDrop = workspace:FindFirstChild("GunDrop", true)
    if ESP_Config.GunDrop and gunDrop then
        if not gunDropHighlight then
            gunDropHighlight = Instance.new("Highlight")
            gunDropHighlight.Name = "GunDropHighlight"
            gunDropHighlight.FillColor = ESP_Config.GunDropColor
            gunDropHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            gunDropHighlight.FillTransparency = 0.3
            gunDropHighlight.Parent = espGui

            gunDropBillboard = Instance.new("BillboardGui")
            gunDropBillboard.AlwaysOnTop = true
            gunDropBillboard.Size = UDim2.new(0, 150, 0, 40)
            gunDropBillboard.StudsOffset = Vector3.new(0, 2, 0)
            gunDropBillboard.Parent = espGui

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextColor3 = ESP_Config.GunDropColor
            lbl.Text = "Gun Drop"
            lbl.TextStrokeTransparency = 0.5
            lbl.Parent = gunDropBillboard
        end
        gunDropHighlight.Adornee = gunDrop
        gunDropBillboard.Adornee = gunDrop
        gunDropHighlight.Enabled = true
        gunDropBillboard.Enabled = true
    else
        if gunDropHighlight then gunDropHighlight.Enabled = false end
        if gunDropBillboard then gunDropBillboard.Enabled = false end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateGunDropESP()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = espObjects[player]
            if not data then
                CreateESPForPlayer(player)
                data = espObjects[player]
            end

            if data and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                local hrp = char.HumanoidRootPart
                local role = GetPlayerRole(player)
                local color = GetRoleColor(role)

                if ESP_Config.Enabled then
                    if ESP_Config.Boxes or ESP_Config.Roles then
                        data.Highlight.Adornee = char
                        data.Highlight.FillColor = color
                        data.Highlight.OutlineColor = color
                        data.Highlight.Enabled = true
                    else
                        data.Highlight.Enabled = false
                    end

                    if ESP_Config.Names or ESP_Config.Roles then
                        data.Billboard.Adornee = hrp
                        local text = ""
                        if ESP_Config.Names then text = text .. player.DisplayName end
                        if ESP_Config.Roles then text = text .. " [" .. role .. "]" end
                        data.Label.Text = text
                        data.Label.TextColor3 = color
                        data.Billboard.Enabled = true
                    else
                        data.Billboard.Enabled = false
                    end
                else
                    data.Highlight.Enabled = false
                    data.Billboard.Enabled = false
                end
            elseif data then
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(ClearESP)

----------------------------------------------------
-- ИНТЕРФЕЙС ВКЛАДКИ ESP (WindUI)
----------------------------------------------------
ESPTab:Toggle({
    Title = 'Enable ESP',
    Default = false,
    Callback = function(state)
        ESP_Config.Enabled = state
    end,
})

ESPTab:Toggle({
    Title = 'Show Roles (Murderer/Sheriff)',
    Default = false,
    Callback = function(state)
        ESP_Config.Roles = state
    end,
})

ESPTab:Toggle({
    Title = 'Show Boxes / Highlights',
    Default = false,
    Callback = function(state)
        ESP_Config.Boxes = state
    end,
})

ESPTab:Toggle({
    Title = 'Show Names',
    Default = false,
    Callback = function(state)
        ESP_Config.Names = state
    end,
})

ESPTab:Toggle({
    Title = 'Show Gun Drop',
    Default = false,
    Callback = function(state)
        ESP_Config.GunDrop = state
    end,
})

ESPTab:Colorpicker({
    Title = 'Murderer Color',
    Default = ESP_Config.MurdererColor,
    Callback = function(color)
        ESP_Config.MurdererColor = color
    end,
})

ESPTab:Colorpicker({
    Title = 'Sheriff Color',
    Default = ESP_Config.SheriffColor,
    Callback = function(color)
        ESP_Config.SheriffColor = color
    end,
})

ESPTab:Colorpicker({
    Title = 'Innocent Color',
    Default = ESP_Config.InnocentColor,
    Callback = function(color)
        ESP_Config.InnocentColor = color
    end,
})

ESPTab:Colorpicker({
    Title = 'Gun Drop Color',
    Default = ESP_Config.GunDropColor,
    Callback = function(color)
        ESP_Config.GunDropColor = color
    end,
})
