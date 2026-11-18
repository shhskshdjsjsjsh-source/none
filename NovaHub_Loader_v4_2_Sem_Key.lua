--[[
    NOVA HUB | UNIVERSAL LOADER
    Version: 4.2.0
    Author: nexustester
    Discord: https://discord.gg/c2q9Sn2mDP

    Supported experiences:
      Legends of Speed  - 3101667897 (Main), 3232996272 (Space), 3276265788 (Desert)
      Muscle Legends   - 3623096087
      The Classic Soccer (TCS) - 13664698400

    This loader is original code. The game-specific scripts are fetched
    from the author's GitHub repository, not embedded in this file.

    Unknown Place IDs automatically use None Universal (None GOAT).
    No activation screens, license validation or premium gates.
    Automatically starts the script for the detected game.
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PLACE_ID = game.PlaceId

local BRAND = {
    Name = "NOVA HUB",
    Subtitle = "UNIVERSAL LOADER",
    Version = "4.2.0",
    Author = "nexustester",
    Discord = "https://discord.gg/c2q9Sn2mDP",
}

-- Update the following GitHub paths if the repository changes.
local REPOSITORY = "https://raw.githubusercontent.com/shhskshdjsjsjsh-source/none/refs/heads/main/"

local GAMES = {
    {
        Name = "Legends of Speed",
        Short = "LEGENDS OF SPEED",
        Ids = {3101667897, 3232996272, 3276265788},
        File = "Speed%20Of%20Legends",
        Details = "Main world, Outer Space and Speed Desert",
        Icon = "S",
    },
    {
        Name = "Muscle Legends",
        Short = "MUSCLE LEGENDS",
        Ids = {3623096087},
        File = "muscle%20legends",
        Details = "Muscle Legends main world",
        Icon = "M",
    },
    {
        Name = "The Classic Soccer",
        Short = "THE CLASSIC SOCCER",
        Ids = {13664698400},
        File = "tcs",
        Details = "TCS football experience",
        Icon = "T",
    },
}

local ROUTES = {}
for _, entry in ipairs(GAMES) do
    entry.URL = REPOSITORY .. entry.File
    for _, id in ipairs(entry.Ids) do
        assert(ROUTES[id] == nil, "Duplicate Nova Hub PlaceId: " .. tostring(id))
        ROUTES[id] = entry
    end
end

-- Any experience not explicitly mapped above uses the universal script.
-- Keep the fallback out of ROUTES so known games always take priority.
local isUniversalFallback = ROUTES[PLACE_ID] == nil
local matchedGame = ROUTES[PLACE_ID] or {
    Name = "None Universal",
    Short = "NONE UNIVERSAL",
    Ids = {},
    File = "None%20GOAT",
    URL = REPOSITORY .. "None%20GOAT",
    Details = "Fallback for unlisted Roblox experiences",
    Icon = "N",
    IsFallback = true,
}

local COLOR = {
    Background = Color3.fromRGB(11, 10, 19),
    Panel = Color3.fromRGB(21, 19, 33),
    Surface = Color3.fromRGB(32, 29, 48),
    SurfaceHover = Color3.fromRGB(43, 37, 65),
    Accent = Color3.fromRGB(157, 102, 255),
    AccentLight = Color3.fromRGB(208, 171, 255),
    Teal = Color3.fromRGB(101, 224, 212),
    Text = Color3.fromRGB(246, 243, 255),
    Muted = Color3.fromRGB(160, 154, 181),
    Stroke = Color3.fromRGB(64, 56, 91),
    Success = Color3.fromRGB(99, 225, 170),
    Error = Color3.fromRGB(255, 117, 139),
}

local function notify(title, content, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = content,
            Duration = duration or 5,
        })
    end)
end

local function new(className, parent, properties)
    local instance = Instance.new(className)
    for key, value in pairs(properties or {}) do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local function round(parent, radius)
    return new("UICorner", parent, {
        CornerRadius = UDim.new(0, radius or 12),
    })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", parent, {
        Color = color or COLOR.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    })
end

local function gradient(parent, first, second, rotation)
    return new("UIGradient", parent, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, first),
            ColorSequenceKeypoint.new(1, second),
        }),
        Rotation = rotation or 0,
    })
end

local function label(parent, text, size, color, bold)
    return new("TextLabel", parent, {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or COLOR.Text,
        TextSize = size or 13,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function animate(instance, target, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), target)
    tween:Play()
    return tween
end

local function resolveGuiParent()
    if type(gethui) == "function" then
        local ok, root = pcall(gethui)
        if ok and typeof(root) == "Instance" then
            return root
        end
    end

    local ok = pcall(function()
        return CoreGui:GetChildren()
    end)
    if ok then
        return CoreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = resolveGuiParent()
local env = type(getgenv) == "function" and getgenv() or _G

-- Closing an earlier copy of the loader does not stop a game script that
-- was already executed; it only removes the former loader interface.
if type(env.NovaHubLoaderCleanup) == "function" then
    pcall(env.NovaHubLoaderCleanup)
end

local previousGui = guiParent:FindFirstChild("NovaHubUniversalLoader")
if previousGui then
    previousGui:Destroy()
end

local screen = new("ScreenGui", guiParent, {
    Name = "NovaHubUniversalLoader",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 800,
})

local overlay = new("Frame", screen, {
    BackgroundColor3 = COLOR.Background,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    BorderSizePixel = 0,
})
gradient(overlay, COLOR.Background, Color3.fromRGB(22, 13, 38), 30)
animate(overlay, {BackgroundTransparency = 0.22}, 0.4)

local shadow = new("Frame", screen, {
    Name = "Shadow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(508, 482),
    BackgroundColor3 = COLOR.Accent,
    BackgroundTransparency = 0.88,
    BorderSizePixel = 0,
})
round(shadow, 24)

local main = new("CanvasGroup", screen, {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(488, 462),
    BackgroundColor3 = COLOR.Panel,
    BorderSizePixel = 0,
    GroupTransparency = 1,
    ClipsDescendants = true,
})
round(main, 20)
stroke(main, COLOR.Stroke, 1.5)
animate(main, {GroupTransparency = 0}, 0.45)

local accentLine = new("Frame", main, {
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 4),
    BorderSizePixel = 0,
    BackgroundColor3 = COLOR.Accent,
})
gradient(accentLine, COLOR.Accent, COLOR.Teal)

local header = new("Frame", main, {
    Size = UDim2.new(1, 0, 0, 100),
    BackgroundColor3 = Color3.fromRGB(26, 21, 42),
    BorderSizePixel = 0,
})
gradient(header, Color3.fromRGB(37, 24, 62), COLOR.Panel, 0)

local logo = new("Frame", header, {
    Position = UDim2.fromOffset(20, 23),
    Size = UDim2.fromOffset(52, 52),
    BackgroundColor3 = COLOR.Accent,
    BorderSizePixel = 0,
})
round(logo, 15)
gradient(logo, COLOR.Accent, Color3.fromRGB(90, 68, 218), 120)

local logoLetter = label(logo, "N", 29, Color3.fromRGB(255, 255, 255), true)
logoLetter.Size = UDim2.fromScale(1, 1)
logoLetter.TextXAlignment = Enum.TextXAlignment.Center

local hubTitle = label(header, BRAND.Name, 21, COLOR.Text, true)
hubTitle.Position = UDim2.fromOffset(86, 27)
hubTitle.Size = UDim2.new(1, -170, 0, 29)

local hubSub = label(header, BRAND.Subtitle .. "  /  V" .. BRAND.Version, 10, COLOR.AccentLight, true)
hubSub.Position = UDim2.fromOffset(87, 57)
hubSub.Size = UDim2.new(1, -170, 0, 17)

local closeX = new("TextButton", header, {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -16, 0, 25),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = COLOR.Surface,
    BorderSizePixel = 0,
    Text = "X",
    TextColor3 = COLOR.Muted,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
})
round(closeX, 10)

local content = new("Frame", main, {
    Position = UDim2.fromOffset(20, 112),
    Size = UDim2.new(1, -40, 0, 265),
    BackgroundTransparency = 1,
})

local sectionTitle = label(content, "DETECTED EXPERIENCE", 10, COLOR.Muted, true)
sectionTitle.Position = UDim2.fromOffset(2, 0)
sectionTitle.Size = UDim2.new(1, -4, 0, 16)

local detectedBox = new("Frame", content, {
    Position = UDim2.fromOffset(0, 24),
    Size = UDim2.new(1, 0, 0, 69),
    BackgroundColor3 = COLOR.Surface,
    BorderSizePixel = 0,
})
round(detectedBox, 12)
stroke(detectedBox, COLOR.Stroke)

local detectedName = label(detectedBox, isUniversalFallback and "None Universal (Fallback)" or matchedGame.Name, 16, COLOR.Text, true)
detectedName.Position = UDim2.fromOffset(14, 11)
detectedName.Size = UDim2.new(1, -120, 0, 22)

local detectedId = label(detectedBox, "PLACE ID  " .. tostring(PLACE_ID), 11, COLOR.Muted)
detectedId.Position = UDim2.fromOffset(14, 36)
detectedId.Size = UDim2.new(1, -26, 0, 18)

local statusPill = new("Frame", detectedBox, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 13),
    Size = UDim2.fromOffset(98, 24),
    BackgroundColor3 = isUniversalFallback and Color3.fromRGB(62, 48, 96) or Color3.fromRGB(26, 78, 63),
    BorderSizePixel = 0,
})
round(statusPill, 8)
local statusPillLabel = label(statusPill, isUniversalFallback and "UNIVERSAL" or "SUPPORTED", 10, isUniversalFallback and COLOR.AccentLight or COLOR.Success, true)
statusPillLabel.Size = UDim2.fromScale(1, 1)
statusPillLabel.TextXAlignment = Enum.TextXAlignment.Center

local loadingTitle = label(content, "LOADER STATUS", 10, COLOR.Muted, true)
loadingTitle.Position = UDim2.fromOffset(2, 107)
loadingTitle.Size = UDim2.new(1, -4, 0, 16)

local progressBox = new("Frame", content, {
    Position = UDim2.fromOffset(0, 131),
    Size = UDim2.new(1, 0, 0, 8),
    BackgroundColor3 = COLOR.Surface,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
round(progressBox, 4)

local progressFill = new("Frame", progressBox, {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = COLOR.Accent,
    BorderSizePixel = 0,
})
round(progressFill, 4)
gradient(progressFill, COLOR.Accent, COLOR.Teal)

local progressStatus = label(content, isUniversalFallback and "Universal fallback is ready" or "Ready to load", 12, COLOR.Text)
progressStatus.Position = UDim2.fromOffset(1, 149)
progressStatus.Size = UDim2.new(1, -70, 0, 22)

local progressPct = label(content, "0%", 11, COLOR.AccentLight, true)
progressPct.AnchorPoint = Vector2.new(1, 0)
progressPct.Position = UDim2.new(1, 0, 0, 150)
progressPct.Size = UDim2.fromOffset(52, 20)
progressPct.TextXAlignment = Enum.TextXAlignment.Right

local listTitle = label(content, "SUPPORTED GAMES", 10, COLOR.Muted, true)
listTitle.Position = UDim2.fromOffset(2, 181)
listTitle.Size = UDim2.new(1, -4, 0, 16)

local listBox = new("Frame", content, {
    Position = UDim2.fromOffset(0, 204),
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = COLOR.Surface,
    BorderSizePixel = 0,
})
round(listBox, 10)

local gamesText = label(listBox, "Legends of Speed  |  Muscle Legends  |  TCS", 11, COLOR.Text, true)
gamesText.Position = UDim2.fromOffset(11, 6)
gamesText.Size = UDim2.new(1, -22, 0, 20)

local helpText = label(listBox, "Other games  /  None Universal fallback", 10, COLOR.Muted)
helpText.Position = UDim2.fromOffset(11, 29)
helpText.Size = UDim2.new(1, -22, 0, 19)

local footer = new("Frame", main, {
    Position = UDim2.new(0, 20, 1, -75),
    Size = UDim2.new(1, -40, 0, 60),
    BackgroundTransparency = 1,
})

local function makeButton(name, text, xScale, widthScale, background, foreground)
    local button = new("TextButton", footer, {
        Name = name,
        Position = UDim2.new(xScale, 0, 0, 0),
        Size = UDim2.new(widthScale, -7, 0, 40),
        BackgroundColor3 = background,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = foreground,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = true,
    })
    round(button, 11)
    return button
end

local loadButton = makeButton("Load", isUniversalFallback and "LOAD UNIVERSAL" or "LOAD NOW", 0, 0.43, COLOR.Accent, COLOR.Text)
local discordButton = makeButton("Discord", "DISCORD", 0.43, 0.31, COLOR.Surface, COLOR.AccentLight)
local exitButton = makeButton("Exit", "CLOSE", 0.74, 0.26, COLOR.Surface, COLOR.Muted)

local byline = label(footer, "NOVA HUB  |  by " .. BRAND.Author .. "  |  Auto-start enabled", 10, COLOR.Muted)
byline.Position = UDim2.fromOffset(3, 43)
byline.Size = UDim2.new(1, -6, 0, 16)
byline.TextXAlignment = Enum.TextXAlignment.Center

-- Responsive sizing, without shrinking the type too far on phones.
local screenScale = new("UIScale", main, {Scale = 1})
local shadowScale = new("UIScale", shadow, {Scale = 1})
local sizeConnection
local function updateSize()
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local scale = math.clamp(math.min(viewport.X / 510, viewport.Y / 500), 0.65, 1)
    screenScale.Scale = scale
    shadowScale.Scale = scale
end
updateSize()
if Workspace.CurrentCamera then
    sizeConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateSize)
end

local running = false
local loaded = false
local shuttingDown = false
local firstAttempt = true
local function closeLoader()
    if shuttingDown then
        return
    end
    shuttingDown = true
    if sizeConnection then
        sizeConnection:Disconnect()
        sizeConnection = nil
    end
    pcall(function()
        animate(main, {GroupTransparency = 1}, 0.18)
        animate(overlay, {BackgroundTransparency = 1}, 0.18)
    end)
    task.delay(0.2, function()
        if screen and screen.Parent then
            screen:Destroy()
        end
    end)
    if env.NovaHubLoaderCleanup == closeLoader then
        env.NovaHubLoaderCleanup = nil
    end
end

env.NovaHubLoaderCleanup = closeLoader

local function setProgress(value, message, color)
    local percent = math.clamp(value or 0, 0, 1)
    progressStatus.Text = message
    progressStatus.TextColor3 = color or COLOR.Text
    progressPct.Text = tostring(math.floor(percent * 100 + 0.5)) .. "%"
    animate(progressFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.27)
end

local function startLoad()
    if shuttingDown or running or loaded then
        return
    end
    if type(loadstring) ~= "function" then
        setProgress(0, "Executor does not support loadstring", COLOR.Error)
        loadButton.Text = "RETRY"
        notify("Nova Hub", "Your executor must support loadstring.", 6)
        return
    end

    running = true
    firstAttempt = false
    loadButton.Text = "LOADING..."
    loadButton.AutoButtonColor = false
    setProgress(0.15, "Connecting to GitHub...")

    task.spawn(function()
        local okDownload, sourceOrError = pcall(function()
            return game:HttpGet(matchedGame.URL)
        end)
        if shuttingDown then
            return
        end
        if not okDownload then
            running = false
            loadButton.AutoButtonColor = true
            loadButton.Text = "RETRY"
            setProgress(0.1, "Download failed. Tap Retry.", COLOR.Error)
            warn("[Nova Hub] HTTP error:", tostring(sourceOrError))
            notify("Nova Hub", "Failed to download the game script.", 5)
            return
        end
        if type(sourceOrError) ~= "string" or #sourceOrError < 10 then
            running = false
            loadButton.AutoButtonColor = true
            loadButton.Text = "RETRY"
            setProgress(0.25, "Remote script is empty or invalid", COLOR.Error)
            notify("Nova Hub", "The remote script is empty or invalid.", 6)
            return
        end

        -- A single comment (or only whitespace) compiles successfully as Lua,
        -- but does not load a hub. Report it instead of displaying LOADED.
        if not sourceOrError:gsub("%-%-[^\r\n]*", ""):match("%S") then
            running = false
            loadButton.AutoButtonColor = true
            loadButton.Text = "RETRY"
            setProgress(0.25, "No executable code in remote file", COLOR.Error)
            notify("Nova Hub", matchedGame.Name .. " has not published executable code yet.", 7)
            return
        end

        setProgress(0.55, "Compiling script...")
        local okCompile, compiledOrError, compileError = pcall(loadstring, sourceOrError)
        if shuttingDown then
            return
        end
        if not okCompile or type(compiledOrError) ~= "function" then
            running = false
            loadButton.AutoButtonColor = true
            loadButton.Text = "RETRY"
            setProgress(0.55, "Script compilation failed", COLOR.Error)
            warn("[Nova Hub] Compile error:", tostring(compileError or compiledOrError))
            notify("Nova Hub", "Script compilation failed. Check console.", 5)
            return
        end

        setProgress(0.85, "Starting " .. matchedGame.Name .. "...")
        local okExecute, runtimeError = pcall(compiledOrError)
        if shuttingDown then
            return
        end
        running = false
        if not okExecute then
            loadButton.AutoButtonColor = true
            loadButton.Text = "RETRY"
            setProgress(0.85, "Script reported a runtime error", COLOR.Error)
            warn("[Nova Hub] Runtime error:", tostring(runtimeError))
            notify("Nova Hub", "The script reported an error. Check console.", 5)
            return
        end

        loaded = true
        loadButton.Text = "LOADED"
        loadButton.AutoButtonColor = false
        setProgress(1, matchedGame.Name .. " started", COLOR.Success)
        notify("Nova Hub", matchedGame.Name .. " entrypoint executed.", 4)
        task.delay(2.4, closeLoader)
    end)
end

closeX.MouseButton1Click:Connect(closeLoader)
exitButton.MouseButton1Click:Connect(closeLoader)
loadButton.MouseButton1Click:Connect(startLoad)

discordButton.MouseButton1Click:Connect(function()
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, BRAND.Discord)
        if ok then
            notify("Nova Hub", "Discord invite copied!", 4)
            return
        end
    end
    notify("Nova Hub Discord", BRAND.Discord, 8)
end)

if isUniversalFallback then
    setProgress(0.05, "Unlisted game detected. Preparing None Universal...")
    notify("Nova Hub", "Game not listed (ID: " .. tostring(PLACE_ID) .. "). Loading None Universal...", 7)
else
    setProgress(0.05, "Detected " .. matchedGame.Name .. ". Preparing...")
end

task.delay(0.55, startLoad)
