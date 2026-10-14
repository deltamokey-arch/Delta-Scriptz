-- Paxz Scriptz Cosmic Edition - UI Library (Rayfield-style)
-- Styling: Cosmic Dark #030208, Neon Purple #9D4EDD / #C77DFF, Mint Green Status #52B788

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PaxzLib = {}

-- Cosmetisch kleurenpalet gebaseerd op de Design Briefing
local THEME = {
    Background = Color3.fromRGB(3, 2, 8),          -- #030208 (Bijna zwart)
    ContainerBg = Color3.fromRGB(14, 11, 26),     -- Diep kosmisch glasoppervlak
    PrimaryPurple = Color3.fromRGB(114, 9, 183),   -- #7209B7 (Diep paars)
    AccentPurple = Color3.fromRGB(157, 78, 221),   -- #9D4EDD (Neon paars)
    GlowPurple = Color3.fromRGB(199, 125, 255),    -- #C77DFF (Licht violet)
    MintStatus = Color3.fromRGB(82, 183, 136),     -- Mintgroene systeemstatus
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(170, 160, 190)
}

function PaxzLib:CreateWindow(Settings)
    Settings = Settings or {}
    local WindowName = Settings.Name or "Paxz Scriptz | Cosmic Edition"
    
    -- Verwijder bestaande UI indien aanwezig
    if CoreGui:FindFirstChild("PaxzCosmicUI") then
        CoreGui.PaxzCosmicUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PaxzCosmicUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Hoofdvenster (Glassmorphism & afgeronde hoeken)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
    MainFrame.BackgroundColor3 = THEME.Background
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.AccentPurple
    MainStroke.Transparency = 0.4
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- Topbalk (Navigatie & Branding)
    local TopBar = Instance.new("Frame")
    MainFrame.ClipsDescendants = true
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.BackgroundColor3 = THEME.ContainerBg
    TopBar.BackgroundTransparency = 0.3
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 14)
    TopCorner.Parent = TopBar

    -- Titel / Logo met paars accent
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 300, 1, 0)
    TitleLabel.Position = UDim2.new(0, 18, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = WindowName
    TitleLabel.TextColor3 = THEME.TextWhite
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Pulserende mintgroene statusindicator
    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
    StatusIndicator.Position = UDim2.new(0, 245, 0.5, -4)
    StatusIndicator.BackgroundColor3 = THEME.MintStatus
    StatusIndicator.Parent = TopBar

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusIndicator

    -- Tab-knoppen container (Linkerkolom)
    local TabButtonsContainer = Instance.new("ScrollingFrame")
    TabButtonsContainer.Name = "TabButtonsContainer"
    TabButtonsContainer.Size = UDim2.new(0, 175, 1, -66)
    TabButtonsContainer.Position = UDim2.new(0, 12, 0, 60)
    TabButtonsContainer.BackgroundTransparency = 1
    TabButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtonsContainer.ScrollBarThickness = 2
    TabButtonsContainer.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = TabButtonsContainer

    -- Pagina container (Rechterkolom)
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Size = UDim2.new(1, -200, 1, -66)
    PagesContainer.Position = UDim2.new(0, 195, 0, 60)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainFrame

    -- Sleepfunctionaliteit voor het venster
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Window = {}
    local FirstTab = true

    function Window:CreateTab(TabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.BackgroundColor3 = THEME.ContainerBg
        TabButton.BackgroundTransparency = 0.5
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = "   " .. TabName
        TabButton.TextColor3 = THEME.TextMuted
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabButtonsContainer

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = TabButton

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = TabName .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 3
        TabPage.Parent = PagesContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = TabPage

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        if FirstTab then
            FirstTab = false
            TabPage.Visible = true
            TabButton.TextColor3 = THEME.TextWhite
            TabButton.BackgroundTransparency = 0.1
            TabButton.BackgroundColor3 = THEME.PrimaryPurple
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(PagesContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            for _, btn in pairs(TabButtonsContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.25), {TextColor3 = THEME.TextMuted, BackgroundTransparency = 0.5, BackgroundColor3 = THEME.ContainerBg}):Play()
                end
            end
            TabPage.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.25), {TextColor3 = THEME.TextWhite, BackgroundTransparency = 0.1, BackgroundColor3 = THEME.PrimaryPurple}):Play()
        end)

        local TabObject = {}

        -- ** Component: Button **
        function TabObject:CreateButton(ButtonSettings)
            ButtonSettings = ButtonSettings or {}
            local Name = ButtonSettings.Name or "Button"
            local Callback = ButtonSettings.Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -12, 0, 40)
            Btn.BackgroundColor3 = THEME.ContainerBg
            Btn.BackgroundTransparency = 0.4
            Btn.Font = Enum.Font.GothamMedium
            Btn.Text = "   " .. Name
            Btn.TextColor3 = THEME.TextWhite
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = TabPage

            local BC = Instance.new("UICorner")
            BC.CornerRadius = UDim.new(0, 8)
            BC.Parent = Btn

            local BS = Instance.new("UIStroke")
            BS.Color = THEME.AccentPurple
            BS.Transparency = 0.5
            BS.Parent = Btn

            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, BackgroundColor3 = THEME.PrimaryPurple}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.4, BackgroundColor3 = THEME.ContainerBg}):Play()
            end)

            Btn.MouseButton1Click:Connect(function()
                pcall(Callback)
            end)
        end

        -- ** Component: Toggle **
        function TabObject:CreateToggle(ToggleSettings)
            ToggleSettings = ToggleSettings or {}
            local Name = ToggleSettings.Name or "Toggle"
            local Default = ToggleSettings.CurrentValue or false
            local Callback = ToggleSettings.Callback or function() end

            local Toggled = Default

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, -12, 0, 40)
            ToggleFrame.BackgroundColor3 = THEME.ContainerBg
            ToggleFrame.BackgroundTransparency = 0.4
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = TabPage

            local TC = Instance.new("UICorner")
            TC.CornerRadius = UDim.new(0, 8)
            TC.Parent = ToggleFrame

            local TS = Instance.new("UIStroke")
            TS.Color = THEME.AccentPurple
            TS.Transparency = 0.5
            TS.Parent = ToggleFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -60, 1, 0)
            Title.Position = UDim2.new(0, 14, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamMedium
            Title.Text = Name
            Title.TextColor3 = THEME.TextWhite
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = ToggleFrame

            local ToggleSwitch = Instance.new("Frame")
            ToggleSwitch.Size = UDim2.new(0, 38, 0, 20)
            ToggleSwitch.Position = UDim2.new(1, -48, 0.5, -10)
            ToggleSwitch.BackgroundColor3 = Toggled and THEME.MintStatus or THEME.ContainerBg
            ToggleSwitch.Parent = ToggleFrame

            local TSC = Instance.new("UICorner")
            TSC.CornerRadius = UDim.new(1, 0)
            TSC.Parent = ToggleSwitch

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = THEME.TextWhite
            Knob.Parent = ToggleSwitch

            local KC = Instance.new("UICorner")
            KC.CornerRadius = UDim.new(1, 0)
            KC.Parent = Knob

            local function UpdateToggle()
                TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Toggled and THEME.MintStatus or THEME.ContainerBg}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                pcall(Callback, Toggled)
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                UpdateToggle()
            end)
        end

        return TabObject
    end

    return Window
end

return PaxzLib
