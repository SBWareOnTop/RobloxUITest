--[[ ======================= Lucide Icon Kit (drop-in) =======================
Ajoute des icônes Lucide (spritesheet) à tes TextButton/TextLabel, à gauche du texte,
avec pulsation au hover. Fonctionne avec n’importe quelle UI custom.

USAGE (après ce bloc) :
---------------------------------------------------------------------------
local IconKit = require_or_paste_above -- si collé au-dessus, IconKit est déjà défini
-- Button simple :
local btn = Instance.new("TextButton") -- ... configure/parent ...
IconKit.AddIconToControl(btn, "airplane") -- icône blanche à gauche, hover animé

-- Toggle (label + bouton de bascule séparé) :
--   labelControl = ton TextLabel portant le texte
--   hoverTarget  = le bouton cliquable (TextButton) pour prendre le hover
IconKit.AddIconToLabel(labelControl, hoverTarget, "shield")
--------------------------------------------------------------------------- ]]

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local IconsOk, Icons = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/SBWareOnTop/RobloxUITest/refs/heads/main/icons.Lua"))()
end)
Icons = IconsOk and Icons or {}
local IconSet = (Icons and Icons["48px"]) or {}

local function _ensurePaddingLeft(textObj)
    local pad = textObj:FindFirstChildOfClass("UIPadding")
    if not pad then
        pad = Instance.new("UIPadding")
        pad.Parent = textObj
    end
    return pad
end

local function _autoFitIcon(iconImg, host)
    local function fit()
        local h = math.max(14, math.floor(host.AbsoluteSize.Y - 4))
        iconImg.Size = UDim2.new(0, h, 0, h)
    end
    fit()
    host:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
end

local function _attachIconCore(textObj, hoverObj, iconName)
    if not iconName or iconName == "" then return nil end
    local data = IconSet[iconName]
    if not data then
        -- fallback silencieux : pas d’icône si nom inconnu
        return nil
    end

    local imgId, rectSize, rectOffset = data[1], data[2], data[3]

    -- ImageLabel icône
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://" .. tostring(imgId)
    Icon.ImageRectSize  = Vector2.new(rectSize[1], rectSize[2])
    Icon.ImageRectOffset= Vector2.new(rectOffset[1], rectOffset[2])
    Icon.ImageColor3    = Color3.fromRGB(255, 255, 255) -- blanc demandé
    Icon.AnchorPoint    = Vector2.new(0, 0.5)
    Icon.Position       = UDim2.new(0, 4, 0.5, 0)
    Icon.ZIndex         = (textObj.ZIndex or 2) + 1
    Icon.ImageTransparency = 0.05
    Icon.Parent = textObj

    -- Ajuste le texte pour laisser la place à l’icône
    textObj.TextXAlignment = Enum.TextXAlignment.Left
    local pad = _ensurePaddingLeft(textObj)
    local function padLeft()
        local h = math.max(14, math.floor(textObj.AbsoluteSize.Y - 4))
        pad.PaddingLeft = UDim.new(0, h + 8)
    end
    padLeft()
    textObj:GetPropertyChangedSignal("AbsoluteSize"):Connect(padLeft)

    -- Icon autosize
    _autoFitIcon(Icon, textObj)

    -- Hover animation (pulsation/fade) si on a un hoverObj qui supporte MouseEnter/Leave
    if hoverObj and hoverObj.MouseEnter and hoverObj.MouseLeave then
        hoverObj.MouseEnter:Connect(function()
            local h = Icon.AbsoluteSize.Y
            TweenService:Create(
                Icon,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ImageTransparency = 0, Size = UDim2.new(0, h + 2, 0, h + 2) }
            ):Play()
        end)
        hoverObj.MouseLeave:Connect(function()
            local h = math.max(14, math.floor(textObj.AbsoluteSize.Y - 4))
            TweenService:Create(
                Icon,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ImageTransparency = 0.05, Size = UDim2.new(0, h, 0, h) }
            ):Play()
        end)
    end

    return Icon
end

-- API publique
local IconKit = {}

-- Pour les boutons (TextButton qui contient le texte et est cliquable)
function IconKit.AddIconToControl(buttonTextButton, iconName)
    if not buttonTextButton or buttonTextButton.ClassName ~= "TextButton" then return nil end
    return _attachIconCore(buttonTextButton, buttonTextButton, iconName)
end

-- Pour les toggles (label = TextLabel avec le texte, hoverTarget = TextButton cliquable)
function IconKit.AddIconToLabel(labelTextLabel, hoverTargetButton, iconName)
    if not labelTextLabel or labelTextLabel.ClassName ~= "TextLabel" then return nil end
    return _attachIconCore(labelTextLabel, hoverTargetButton, iconName)
end

-- expose au reste du script si besoin
_G.__IconKit = IconKit
-- Si tu veux en module, renvoie :
-- return IconKit
-- Sinon, si tu colles ce bloc en haut de ton script, utilise _G.__IconKit.* plus bas.

-- =================== / Lucide Icon Kit =================== --
