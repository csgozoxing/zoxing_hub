--// =========================================================
--// SCRIPT HUB
--// PANDA AUTH + GAME DETECTION + MODULAR FEATURES
--// =========================================================


--// =========================================================
--// PANDA AUTH
--// =========================================================

local PUSL = loadstring(game:HttpGet(
    "https://secure.pandauth.com/pv4/lib"
))()

if not PUSL or type(PUSL.configure) ~= "function" then
    return warn("[Panda] Library failed to initialize.")
end

PUSL.configure({
    serviceId = "pluspower",
})


--// =========================================================
--// SERVICES
--// =========================================================

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer


--// =========================================================
--// SETTINGS
--// =========================================================

local ACCENT = Color3.fromRGB(110, 80, 255)

local BG = Color3.fromRGB(15, 15, 20)

local BUTTON_BG = Color3.fromRGB(25, 25, 32)

local BUTTON_HOVER = Color3.fromRGB(38, 38, 48)


--// =========================================================
--// GAME CONFIGURATION
--//
--// TUTAJ DODAJESZ NOWE GRY
--// =========================================================

local function createToggleableFeature(action, interval)
    local state = {
        enabled = false,
        version = 0,
        thread = nil
    }

    return function(toggle)
        state.enabled = toggle
        state.version += 1
        local version = state.version

        if not state.enabled then
            state.thread = nil
            return
        end

        state.thread = task.spawn(function()
            while state.enabled and version == state.version do
                local ok, err = pcall(action)

                if not ok then
                    warn("[Hub] Feature error:", err)
                end

                if version ~= state.version then
                    break
                end

                task.wait(interval)
            end

            if version == state.version then
                state.thread = nil
            end
        end)
    end
end

local Games = {

    --=========================================================
    -- PLUS POWER
    --=========================================================

    ["Plus Power"] = {

        PlaceIds = {
            -- WSTAW PRAWDZIWY PLACE ID
            74889851913797,
        },

        Features = {

            {
                Name = "Click Train",
                Icon = "⚡",

                Callback = createToggleableFeature(function()
                    ReplicatedStorage
                        .ClickTrainEvent
                        :FireServer()
                end, 0.1)
            },


            {
                Name = "Auto Rebirth",
                Icon = "⭐",

                Callback = createToggleableFeature(function()
                    ReplicatedStorage
                        .RebirthFunction
                        :InvokeServer("Rebirth")
                end, 1)
            },

        }
    },


    --=========================================================
    -- PRZYKŁADOWA DRUGA GRA
    -- USUŃ ALBO PODMIEŃ
    --=========================================================

    ["Followers Per Click"] = {

        PlaceIds = {

            98695134949589,

        },

        Features = {

            {
                Name = "Auto Tap / Auto Battle",
                Icon = "⚡",

                Callback = createToggleableFeature(function()
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    local events = remotes and remotes:FindFirstChild("Events")

                    if events then
                        local clickRemote = events:FindFirstChild("ClickRemote")
                        local battleTap = events:FindFirstChild("BattleTap")

                        if clickRemote then
                            clickRemote:FireServer()
                        end

                        if battleTap then
                            battleTap:FireServer()
                        end
                    end
                end, 0.1)
            },


            {
                Name = "Auto Win",
                Icon = "💰",

                Callback = createToggleableFeature(function()
                    local character = player and player.Character

                    if not character then
                        return
                    end

                    local worlds = Workspace:FindFirstChild("Worlds")
                    local world1 = worlds and worlds:FindFirstChild("World1")
                    local map = world1 and world1:FindFirstChild("Map")
                    local win = map and map:FindFirstChild("Win")
                    local target = win and win:FindFirstChild("Lane21")

                    if target then
                        local ok = pcall(function()
                            character:PivotTo(target:GetPivot())
                        end)

                        if not ok then
                            warn("[Hub] Failed to pivot to target lane.")
                        end
                    end
                end, 1)
            },

        }
    },


    --=========================================================
    -- NEW GAME
    --=========================================================

    ["+1 Drain Water"] = {

        PlaceIds = {
            103883942725157,
        },

        Features = {

            {
                Name = "Auto Click",
                Icon = "⚡",

                Callback = createToggleableFeature(function()
                    game:GetService("ReplicatedStorage").Remote.Event.Level["[C-S]Click"]:FireServer(95)
                end, 0.1)
            },


            {
                Name = "Auto Rebirth",
                Icon = "⭐",

                Callback = createToggleableFeature(function()
                    game:GetService("ReplicatedStorage").Remote.Event.Rebirth["[C - S]TryRebirth"]:FireServer()
                end, 1)
            },
        }
    },

}


--// =========================================================
--// GAME DETECTION
--// =========================================================

local function getCurrentGame()

    local currentPlaceId = game.PlaceId

    for gameName, gameData in pairs(Games) do

        for _, placeId in ipairs(gameData.PlaceIds) do

            if placeId == currentPlaceId then

                return gameName, gameData

            end

        end

    end

    return nil, nil

end


--// =========================================================
--// REMOVE OLD AUTH GUI
--// =========================================================

local oldAuth = CoreGui:FindFirstChild("PandaAuthPanel")

if oldAuth then
    oldAuth:Destroy()
end


--// =========================================================
--// REMOVE OLD HUB
--// =========================================================

local oldHub = CoreGui:FindFirstChild("ScriptHub")

if oldHub then
    oldHub:Destroy()
end


--// =========================================================
--// AUTH GUI
--// =========================================================

local authGui = Instance.new("ScreenGui")

authGui.Name = "PandaAuthPanel"
authGui.ResetOnSpawn = false
authGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
authGui.Parent = CoreGui


--// =========================================================
--// AUTH SHADOW
--// =========================================================

local authShadow = Instance.new("Frame")

authShadow.Size = UDim2.new(0, 374, 0, 274)

authShadow.Position =
    UDim2.new(0.5, -187, 0.5, -137)

authShadow.BackgroundColor3 =
    Color3.fromRGB(0, 0, 0)

authShadow.BackgroundTransparency = 0.45

authShadow.BorderSizePixel = 0

authShadow.ZIndex = 0

authShadow.Parent = authGui


local authShadowCorner = Instance.new("UICorner")

authShadowCorner.CornerRadius =
    UDim.new(0, 18)

authShadowCorner.Parent = authShadow


--// =========================================================
--// AUTH MAIN
--// =========================================================

local authMain = Instance.new("Frame")

authMain.Size = UDim2.new(0, 360, 0, 260)

authMain.Position =
    UDim2.new(0.5, -180, 0.5, -130)

authMain.BackgroundColor3 = BG

authMain.BorderSizePixel = 0

authMain.ZIndex = 2

authMain.Parent = authGui


local authCorner = Instance.new("UICorner")

authCorner.CornerRadius =
    UDim.new(0, 16)

authCorner.Parent = authMain


local authStroke = Instance.new("UIStroke")

authStroke.Color =
    Color3.fromRGB(70, 70, 85)

authStroke.Thickness = 1

authStroke.Transparency = 0.35

authStroke.Parent = authMain


--// =========================================================
--// AUTH GRADIENT
--// =========================================================

local authGradient = Instance.new("UIGradient")

authGradient.Rotation = 90

authGradient.Color = ColorSequence.new({

    ColorSequenceKeypoint.new(
        0,
        Color3.fromRGB(24, 24, 31)
    ),

    ColorSequenceKeypoint.new(
        0.5,
        Color3.fromRGB(16, 16, 21)
    ),

    ColorSequenceKeypoint.new(
        1,
        Color3.fromRGB(12, 12, 16)
    )

})

authGradient.Parent = authMain


--// =========================================================
--// AUTH ACCENT
--// =========================================================

local authAccent = Instance.new("Frame")

authAccent.Size =
    UDim2.new(0, 4, 0, 42)

authAccent.Position =
    UDim2.new(0, 18, 0, 20)

authAccent.BackgroundColor3 = ACCENT

authAccent.BorderSizePixel = 0

authAccent.ZIndex = 3

authAccent.Parent = authMain


local authAccentCorner = Instance.new("UICorner")

authAccentCorner.CornerRadius =
    UDim.new(1, 0)

authAccentCorner.Parent = authAccent


--// =========================================================
--// AUTH TITLE
--// =========================================================

local authTitle = Instance.new("TextLabel")

authTitle.Size =
    UDim2.new(1, -70, 0, 28)

authTitle.Position =
    UDim2.new(0, 34, 0, 17)

authTitle.BackgroundTransparency = 1

authTitle.Text = "AUTHENTICATION"

authTitle.TextColor3 =
    Color3.fromRGB(245, 245, 250)

authTitle.TextSize = 19

authTitle.Font = Enum.Font.GothamBold

authTitle.TextXAlignment =
    Enum.TextXAlignment.Left

authTitle.ZIndex = 3

authTitle.Parent = authMain


--// =========================================================
--// AUTH SUBTITLE
--// =========================================================

local authSubtitle = Instance.new("TextLabel")

authSubtitle.Size =
    UDim2.new(1, -70, 0, 18)

authSubtitle.Position =
    UDim2.new(0, 34, 0, 44)

authSubtitle.BackgroundTransparency = 1

authSubtitle.Text =
    "Enter your access key"

authSubtitle.TextColor3 =
    Color3.fromRGB(125, 125, 140)

authSubtitle.TextSize = 11

authSubtitle.Font = Enum.Font.Gotham

authSubtitle.TextXAlignment =
    Enum.TextXAlignment.Left

authSubtitle.ZIndex = 3

authSubtitle.Parent = authMain


--// =========================================================
--// KEY BOX
--// =========================================================

local keyBox = Instance.new("TextBox")

keyBox.Size =
    UDim2.new(1, -36, 0, 42)

keyBox.Position =
    UDim2.new(0, 18, 0, 82)

keyBox.BackgroundColor3 = BUTTON_BG

keyBox.BorderSizePixel = 0

keyBox.PlaceholderText =
    "Enter key..."

keyBox.PlaceholderColor3 =
    Color3.fromRGB(100, 100, 115)

keyBox.Text = ""

keyBox.TextColor3 =
    Color3.fromRGB(235, 235, 240)

keyBox.TextSize = 13

keyBox.Font = Enum.Font.Gotham

keyBox.ClearTextOnFocus = false

keyBox.ZIndex = 3

keyBox.Parent = authMain


local keyCorner = Instance.new("UICorner")

keyCorner.CornerRadius =
    UDim.new(0, 10)

keyCorner.Parent = keyBox


local keyStroke = Instance.new("UIStroke")

keyStroke.Color =
    Color3.fromRGB(55, 55, 68)

keyStroke.Transparency = 0.25

keyStroke.Parent = keyBox


--// =========================================================
--// AUTH BUTTON
--// =========================================================

local authButton = Instance.new("TextButton")

authButton.Size =
    UDim2.new(1, -36, 0, 40)

authButton.Position =
    UDim2.new(0, 18, 0, 134)

authButton.BackgroundColor3 = ACCENT

authButton.BorderSizePixel = 0

authButton.Text = "AUTHENTICATE"

authButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)

authButton.TextSize = 13

authButton.Font =
    Enum.Font.GothamBold

authButton.AutoButtonColor = false

authButton.ZIndex = 3

authButton.Parent = authMain


local authButtonCorner = Instance.new("UICorner")

authButtonCorner.CornerRadius =
    UDim.new(0, 10)

authButtonCorner.Parent = authButton


--// =========================================================
--// COPY KEY BUTTON
--// =========================================================

local copyButton = Instance.new("TextButton")

copyButton.Size =
    UDim2.new(1, -36, 0, 34)

copyButton.Position =
    UDim2.new(0, 18, 0, 182)

copyButton.BackgroundColor3 =
    Color3.fromRGB(35, 35, 45)

copyButton.BorderSizePixel = 0

copyButton.Text =
    "COPY KEY LINK"

copyButton.TextColor3 =
    Color3.fromRGB(190, 190, 205)

copyButton.TextSize = 12

copyButton.Font =
    Enum.Font.GothamBold

copyButton.AutoButtonColor = false

copyButton.ZIndex = 3

copyButton.Parent = authMain


local copyCorner = Instance.new("UICorner")

copyCorner.CornerRadius =
    UDim.new(0, 9)

copyCorner.Parent = copyButton


--// =========================================================
--// AUTH STATUS
--// =========================================================

local authStatus = Instance.new("TextLabel")

authStatus.Size =
    UDim2.new(1, -36, 0, 20)

authStatus.Position =
    UDim2.new(0, 18, 0, 221)

authStatus.BackgroundTransparency = 1

authStatus.Text = ""

authStatus.TextColor3 =
    Color3.fromRGB(130, 130, 145)

authStatus.TextSize = 11

authStatus.Font = Enum.Font.Gotham

authStatus.TextXAlignment =
    Enum.TextXAlignment.Center

authStatus.ZIndex = 3

authStatus.Parent = authMain


--// =========================================================
--// AUTH HOVER
--// =========================================================

authButton.MouseEnter:Connect(function()

    TweenService:Create(
        authButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 =
                Color3.fromRGB(130, 100, 255)
        }
    ):Play()

end)


authButton.MouseLeave:Connect(function()

    TweenService:Create(
        authButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 = ACCENT
        }
    ):Play()

end)


copyButton.MouseEnter:Connect(function()

    TweenService:Create(
        copyButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 =
                Color3.fromRGB(45, 45, 58)
        }
    ):Play()

end)


copyButton.MouseLeave:Connect(function()

    TweenService:Create(
        copyButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 =
                Color3.fromRGB(35, 35, 45)
        }
    ):Play()

end)


--// =========================================================
--// COPY KEY LINK
--// =========================================================

copyButton.MouseButton1Click:Connect(function()

    local success, url = pcall(function()

        return PUSL.getKeyUrl()

    end)


    if success and url then

        if setclipboard then

            setclipboard(url)

            authStatus.Text =
                "Key link copied!"

            authStatus.TextColor3 =
                Color3.fromRGB(100, 220, 150)

        else

            authStatus.Text =
                "Clipboard unavailable."

            authStatus.TextColor3 =
                Color3.fromRGB(240, 180, 80)

        end

    else

        authStatus.Text =
            "Failed to get key link."

        authStatus.TextColor3 =
            Color3.fromRGB(240, 100, 100)

    end

end)


--// =========================================================
--// MAIN HUB
--// =========================================================

local function createMainGui(currentGameName, currentGame)

    --=========================================================
    -- GUI
    --=========================================================

    local gui = Instance.new("ScreenGui")

    gui.Name = "ScriptHub"

    gui.ResetOnSpawn = false

    gui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

    gui.Parent = CoreGui


    --=========================================================
    -- SHADOW
    --=========================================================

    local shadow = Instance.new("Frame")

    shadow.Size =
        UDim2.new(0, 324, 0, 424)

    shadow.Position =
        UDim2.new(
            0.5,
            -162 + 7,
            0.5,
            -212 + 7
        )

    shadow.BackgroundColor3 =
        Color3.fromRGB(0, 0, 0)

    shadow.BackgroundTransparency = 0.45

    shadow.BorderSizePixel = 0

    shadow.ZIndex = 0

    shadow.Parent = gui


    local shadowCorner = Instance.new("UICorner")

    shadowCorner.CornerRadius =
        UDim.new(0, 18)

    shadowCorner.Parent = shadow


    --=========================================================
    -- MAIN
    --=========================================================

    local main = Instance.new("Frame")

    main.Size =
        UDim2.new(0, 310, 0, 410)

    main.Position =
        UDim2.new(
            0.5,
            -155,
            0.5,
            -205
        )

    main.BackgroundColor3 = BG

    main.BorderSizePixel = 0

    main.ZIndex = 2

    main.Parent = gui


    local mainCorner = Instance.new("UICorner")

    mainCorner.CornerRadius =
        UDim.new(0, 16)

    mainCorner.Parent = main


    local mainStroke = Instance.new("UIStroke")

    mainStroke.Color =
        Color3.fromRGB(70, 70, 85)

    mainStroke.Thickness = 1

    mainStroke.Transparency = 0.35

    mainStroke.Parent = main


    --=========================================================
    -- GRADIENT
    --=========================================================

    local gradient = Instance.new("UIGradient")

    gradient.Rotation = 90

    gradient.Color = ColorSequence.new({

        ColorSequenceKeypoint.new(
            0,
            Color3.fromRGB(24, 24, 31)
        ),

        ColorSequenceKeypoint.new(
            0.5,
            Color3.fromRGB(16, 16, 21)
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromRGB(12, 12, 16)
        )

    })

    gradient.Parent = main


    --=========================================================
    -- HEADER
    --=========================================================

    local header = Instance.new("Frame")

    header.Size =
        UDim2.new(1, 0, 0, 82)

    header.BackgroundTransparency = 1

    header.ZIndex = 3

    header.Parent = main


    local accent = Instance.new("Frame")

    accent.Size =
        UDim2.new(0, 4, 0, 42)

    accent.Position =
        UDim2.new(0, 16, 0, 18)

    accent.BackgroundColor3 = ACCENT

    accent.BorderSizePixel = 0

    accent.ZIndex = 4

    accent.Parent = header


    local accentCorner = Instance.new("UICorner")

    accentCorner.CornerRadius =
        UDim.new(1, 0)

    accentCorner.Parent = accent


    local title = Instance.new("TextLabel")

    title.Size =
        UDim2.new(1, -60, 0, 28)

    title.Position =
        UDim2.new(0, 31, 0, 13)

    title.BackgroundTransparency = 1

    title.Text = currentGameName

    title.TextColor3 =
        Color3.fromRGB(245, 245, 250)

    title.TextSize = 19

    title.Font =
        Enum.Font.GothamBold

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.ZIndex = 4

    title.Parent = header


    local subtitle = Instance.new("TextLabel")

    subtitle.Size =
        UDim2.new(1, -60, 0, 18)

    subtitle.Position =
        UDim2.new(0, 31, 0, 42)

    subtitle.BackgroundTransparency = 1

    subtitle.Text =
        "Script Hub  •  Press K to toggle"

    subtitle.TextColor3 =
        Color3.fromRGB(125, 125, 140)

    subtitle.TextSize = 11

    subtitle.Font =
        Enum.Font.Gotham

    subtitle.TextXAlignment =
        Enum.TextXAlignment.Left

    subtitle.ZIndex = 4

    subtitle.Parent = header


    local statusDot = Instance.new("Frame")

    statusDot.Size =
        UDim2.new(0, 7, 0, 7)

    statusDot.Position =
        UDim2.new(1, -28, 0, 22)

    statusDot.BackgroundColor3 =
        Color3.fromRGB(80, 220, 140)

    statusDot.BorderSizePixel = 0

    statusDot.ZIndex = 4

    statusDot.Parent = header


    local dotCorner = Instance.new("UICorner")

    dotCorner.CornerRadius =
        UDim.new(1, 0)

    dotCorner.Parent = statusDot


    local divider = Instance.new("Frame")

    divider.Size =
        UDim2.new(1, -32, 0, 1)

    divider.Position =
        UDim2.new(0, 16, 0, 81)

    divider.BackgroundColor3 =
        Color3.fromRGB(55, 55, 65)

    divider.BackgroundTransparency = 0.25

    divider.BorderSizePixel = 0

    divider.ZIndex = 4

    divider.Parent = main


    --=========================================================
    -- BUTTON CONTAINER
    --=========================================================

    local container = Instance.new("ScrollingFrame")

    container.Size =
        UDim2.new(1, -32, 1, -105)

    container.Position =
        UDim2.new(0, 16, 0, 97)

    container.BackgroundTransparency = 1

    container.BorderSizePixel = 0

    container.ScrollBarThickness = 3

    container.ScrollBarImageColor3 = ACCENT

    container.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    container.ZIndex = 3

    container.Parent = main


    local layout = Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 9)

    layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    layout.HorizontalAlignment =
        Enum.HorizontalAlignment.Center

    layout.Parent = container


    layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(function()

        container.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                layout.AbsoluteContentSize.Y + 10
            )

    end)


    --=========================================================
    -- BUTTON CREATOR
    --=========================================================

    local function createButton(feature)

        local button =
            Instance.new("TextButton")

        button.Size =
            UDim2.new(1, -4, 0, 44)

        button.BackgroundColor3 =
            BUTTON_BG

        button.BorderSizePixel = 0

        button.Text = ""

        button.AutoButtonColor = false

        button.ZIndex = 4

        button.Parent = container


        local corner =
            Instance.new("UICorner")

        corner.CornerRadius =
            UDim.new(0, 10)

        corner.Parent = button


        local stroke =
            Instance.new("UIStroke")

        stroke.Color =
            Color3.fromRGB(55, 55, 68)

        stroke.Thickness = 1

        stroke.Transparency = 0.35

        stroke.Parent = button


        --=====================================================
        -- ICON
        --=====================================================

        local icon =
            Instance.new("TextLabel")

        icon.Size =
            UDim2.new(0, 38, 1, 0)

        icon.Position =
            UDim2.new(0, 7, 0, 0)

        icon.BackgroundTransparency = 1

        icon.Text =
            feature.Icon or "•"

        icon.TextColor3 =
            Color3.fromRGB(175, 175, 190)

        icon.TextSize = 17

        icon.Font =
            Enum.Font.GothamBold

        icon.ZIndex = 5

        icon.Parent = button


        --=====================================================
        -- LABEL
        --=====================================================

        local label =
            Instance.new("TextLabel")

        label.Size =
            UDim2.new(1, -125, 1, 0)

        label.Position =
            UDim2.new(0, 48, 0, 0)

        label.BackgroundTransparency = 1

        label.Text =
            feature.Name

        label.TextColor3 =
            Color3.fromRGB(225, 225, 232)

        label.TextSize = 13

        label.Font =
            Enum.Font.GothamSemibold

        label.TextXAlignment =
            Enum.TextXAlignment.Left

        label.ZIndex = 5

        label.Parent = button


        --=====================================================
        -- TOGGLE
        --=====================================================

        local toggle =
            Instance.new("Frame")

        toggle.Size =
            UDim2.new(0, 42, 0, 22)

        toggle.Position =
            UDim2.new(1, -55, 0.5, -11)

        toggle.BackgroundColor3 =
            Color3.fromRGB(48, 48, 58)

        toggle.BorderSizePixel = 0

        toggle.ZIndex = 6

        toggle.Parent = button


        local toggleCorner =
            Instance.new("UICorner")

        toggleCorner.CornerRadius =
            UDim.new(1, 0)

        toggleCorner.Parent = toggle


        local knob =
            Instance.new("Frame")

        knob.Size =
            UDim2.new(0, 16, 0, 16)

        knob.Position =
            UDim2.new(0, 3, 0.5, -8)

        knob.BackgroundColor3 =
            Color3.fromRGB(145, 145, 155)

        knob.BorderSizePixel = 0

        knob.ZIndex = 7

        knob.Parent = toggle


        local knobCorner =
            Instance.new("UICorner")

        knobCorner.CornerRadius =
            UDim.new(1, 0)

        knobCorner.Parent = knob


        local enabled = false


        --=====================================================
        -- UPDATE TOGGLE
        --=====================================================

        local function updateToggle()

            if enabled then

                TweenService:Create(
                    toggle,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 =
                            ACCENT
                    }
                ):Play()


                TweenService:Create(
                    knob,
                    TweenInfo.new(0.15),
                    {
                        Position =
                            UDim2.new(
                                1,
                                -19,
                                0.5,
                                -8
                            ),

                        BackgroundColor3 =
                            Color3.fromRGB(
                                255,
                                255,
                                255
                            )
                    }
                ):Play()


                TweenService:Create(
                    icon,
                    TweenInfo.new(0.15),
                    {
                        TextColor3 =
                            ACCENT
                    }
                ):Play()

            else

                TweenService:Create(
                    toggle,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 =
                            Color3.fromRGB(
                                48,
                                48,
                                58
                            )
                    }
                ):Play()


                TweenService:Create(
                    knob,
                    TweenInfo.new(0.15),
                    {
                        Position =
                            UDim2.new(
                                0,
                                3,
                                0.5,
                                -8
                            ),

                        BackgroundColor3 =
                            Color3.fromRGB(
                                145,
                                145,
                                155
                            )
                    }
                ):Play()


                TweenService:Create(
                    icon,
                    TweenInfo.new(0.15),
                    {
                        TextColor3 =
                            Color3.fromRGB(
                                175,
                                175,
                                190
                            )
                    }
                ):Play()

            end

        end


        --=====================================================
        -- BUTTON CLICK
        --=====================================================

        button.MouseButton1Click:Connect(function()

            enabled = not enabled

            updateToggle()


            local success, err =
                pcall(function()

                    feature.Callback(enabled)

                end)


            if not success then

                warn(
                    "[Hub] Feature error:",
                    feature.Name,
                    err
                )

            end

        end)


        --=====================================================
        -- HOVER
        --=====================================================

        button.MouseEnter:Connect(function()

            TweenService:Create(
                button,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        BUTTON_HOVER
                }
            ):Play()


            TweenService:Create(
                stroke,
                TweenInfo.new(0.15),
                {
                    Color = ACCENT,
                    Transparency = 0.15
                }
            ):Play()

        end)


        button.MouseLeave:Connect(function()

            TweenService:Create(
                button,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        BUTTON_BG
                }
            ):Play()


            TweenService:Create(
                stroke,
                TweenInfo.new(0.15),
                {
                    Color =
                        Color3.fromRGB(
                            55,
                            55,
                            68
                        ),

                    Transparency = 0.35
                }
            ):Play()

        end)

    end


    --=========================================================
    -- LOAD FEATURES
    --=========================================================

    for _, feature in ipairs(
        currentGame.Features
    ) do

        createButton(feature)

    end


    --=========================================================
    -- K = HIDE / SHOW
    --=========================================================

    UserInputService.InputBegan:Connect(
        function(input, processed)

            if processed then
                return
            end


            if input.KeyCode ==
                Enum.KeyCode.K then

                main.Visible =
                    not main.Visible

                shadow.Visible =
                    main.Visible

            end

        end
    )


    --=========================================================
    -- DRAG
    --=========================================================

    local dragging = false

    local dragStart

    local startPosition


    header.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = true

                dragStart =
                    input.Position

                startPosition =
                    main.Position

            end

        end
    )


    header.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = false

            end

        end
    )


    UserInputService.InputChanged:Connect(
        function(input)

            if dragging and
                input.UserInputType ==
                Enum.UserInputType.MouseMovement then

                local delta =
                    input.Position - dragStart


                local newPosition =
                    UDim2.new(

                        startPosition.X.Scale,

                        startPosition.X.Offset
                            + delta.X,

                        startPosition.Y.Scale,

                        startPosition.Y.Offset
                            + delta.Y

                    )


                main.Position =
                    newPosition


                shadow.Position =
                    UDim2.new(

                        newPosition.X.Scale,

                        newPosition.X.Offset - 7,

                        newPosition.Y.Scale,

                        newPosition.Y.Offset - 7

                    )

            end

        end
    )

end


--// =========================================================
--// AUTHENTICATION
--// =========================================================

local authenticating = false


local function authenticate()

    if authenticating then
        return
    end


    local key = keyBox.Text


    if key == "" then

        authStatus.Text =
            "Please enter your key."

        authStatus.TextColor3 =
            Color3.fromRGB(
                240,
                100,
                100
            )

        return

    end


    authenticating = true


    authButton.Text =
        "AUTHENTICATING..."


    authStatus.Text =
        "Checking key..."


    authStatus.TextColor3 =
        Color3.fromRGB(
            180,
            180,
            195
        )


    --=========================================================
    -- VALIDATE KEY
    --=========================================================

    local success, result =
        pcall(function()

            return PUSL.validate(key)

        end)


    --=========================================================
    -- SUCCESS
    --=========================================================

    if success and
        result and
        result.success then


        authStatus.Text =
            "Authenticated!"


        authStatus.TextColor3 =
            Color3.fromRGB(
                100,
                220,
                150
            )


        print(
            "[Panda] Authenticated. Premium:",
            result.isPremium
        )


        task.wait(0.5)


        --=====================================================
        -- CLOSE AUTH
        --=====================================================

        TweenService:Create(
            authMain,
            TweenInfo.new(0.25),
            {
                Size =
                    UDim2.new(
                        0,
                        0,
                        0,
                        0
                    )
            }
        ):Play()


        TweenService:Create(
            authShadow,
            TweenInfo.new(0.25),
            {
                Size =
                    UDim2.new(
                        0,
                        0,
                        0,
                        0
                    )
            }
        ):Play()


        task.wait(0.3)


        authGui:Destroy()


        --=====================================================
        -- ONLY NOW DETECT GAME
        --=====================================================

        local currentGameName,
              currentGame =
            getCurrentGame()


        --=====================================================
        -- UNSUPPORTED GAME
        --=====================================================

        if not currentGame then

            warn(
                "[Hub] Unsupported game:",
                game.Name,
                "PlaceId:",
                game.PlaceId
            )

            return

        end


        --=====================================================
        -- START HUB
        --=====================================================

        print(
            "[Hub] Loading:",
            currentGameName
        )


        createMainGui(
            currentGameName,
            currentGame
        )


    --=========================================================
    -- FAILED
    --=========================================================

    else

        authStatus.Text =
            "Invalid key."


        authStatus.TextColor3 =
            Color3.fromRGB(
                240,
                100,
                100
            )


        authButton.Text =
            "AUTHENTICATE"


        authenticating = false

    end

end


--// =========================================================
--// AUTH BUTTON
--// =========================================================

authButton.MouseButton1Click:Connect(
    authenticate
)


--// =========================================================
--// ENTER KEY
--// =========================================================

keyBox.FocusLost:Connect(
    function(enterPressed)

        if enterPressed then

            authenticate()

        end

    end
)


--// =========================================================
--// START
--// =========================================================

print(
    "[Hub] Waiting for authentication..."
)
