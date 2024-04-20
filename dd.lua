local ESP = {}

-- Your ESP settings
ESP.settings = {
    box = {
        enabled = true,
        color = Color3.new(1, 1, 1),
        thickness = 1,
        transparency = 1,
        filled = false
    },
    text = {
        nameEnabled = true,
        color = Color3.new(1, 1, 1),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    },
    distanceText = {
        enabled = true,
        color = Color3.new(0, 1, 0),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    },
    healthText = {
        enabled = true,
        color = Color3.new(1, 1, 0),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    },
    healthBar = {
        enabled = true,
        color = Color3.new(1, 1, 0),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    },
    weaponText = {
        enabled = true,
        maxLength = 12, -- Maximum length of displayed tool name
        color = Color3.new(1, 1, 1),
        size = 13,
        center = true,
        outline = true,
        outlineColor = Color3.new(0, 0, 0)
    }
}

local espObjects = {}

local function CreateESP(part)
    local boxSettings = ESP.settings.box
    local textSettings = ESP.settings.text
    local distanceTextSettings = ESP.settings.distanceText
    local healthTextSettings = ESP.settings.healthText
    local healthBarSettings = ESP.settings.healthBar
    local weaponTextSettings = ESP.settings.weaponText

    local box = Drawing.new("Quad")
    box.Visible = boxSettings.enabled
    box.Color = boxSettings.color
    box.Thickness = boxSettings.thickness
    box.Transparency = boxSettings.transparency
    box.Filled = boxSettings.filled

    local text = Drawing.new("Text")
    text.Visible = textSettings.nameEnabled
    text.Color = textSettings.color
    text.Size = textSettings.size
    text.Center = textSettings.center
    text.Outline = textSettings.outline
    text.OutlineColor = textSettings.outlineColor

    local distancetext = Drawing.new("Text")
    distancetext.Visible = distanceTextSettings.enabled
    distancetext.Color = distanceTextSettings.color
    distancetext.Size = distanceTextSettings.size
    distancetext.Center = distanceTextSettings.center
    distancetext.Outline = distanceTextSettings.outline
    distancetext.OutlineColor = distanceTextSettings.outlineColor

    local healthText = Drawing.new("Text")
    healthText.Visible = healthTextSettings.enabled
    healthText.Color = healthTextSettings.color
    healthText.Size = healthTextSettings.size
    healthText.Center = healthTextSettings.center
    healthText.Outline = healthTextSettings.outline
    healthText.OutlineColor = healthTextSettings.outlineColor

    local healthBarBackground = Drawing.new("Line")
    healthBarBackground.Visible = healthBarSettings.enabled
    healthBarBackground.Thickness = 4 -- Background thickness
    healthBarBackground.Transparency = 0.5 -- Background transparency
    healthBarBackground.From = Vector2.new(0, 0)
    healthBarBackground.To = Vector2.new(0, 0) -- Initial position (will be updated dynamically)

    local healthBar = Drawing.new("Line")
    healthBar.Visible = healthBarSettings.enabled
    healthBar.Thickness = 2 -- Health bar thickness
    healthBar.Transparency = 1 -- No transparency for health bar
    healthBar.From = Vector2.new(0, 0)
    healthBar.To = Vector2.new(0, 0) -- Initial position (will be updated dynamically)

    local weaponText = Drawing.new("Text")
    weaponText.Visible = weaponTextSettings.enabled
    weaponText.Color = weaponTextSettings.color
    weaponText.Size = weaponTextSettings.size
    weaponText.Center = weaponTextSettings.center
    weaponText.Outline = weaponTextSettings.outline
    weaponText.OutlineColor = weaponTextSettings.outlineColor

    local gradientColors = {
        Color3.new(255, 0, 0), -- Red
        Color3.new(255, 255, 0), -- Yellow
        Color3.new(0, 255, 0) -- Green
    }

    return {
        update = function()
            if part and part.Parent then
                local character = part.Parent
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and character.Humanoid.Health > 0 then -- Only update if health > 0%
                    local head = character:FindFirstChild("Head")
                    if head then
                        local camera = workspace.CurrentCamera
                        local headPosition, headVisible = camera:WorldToViewportPoint(head.Position - Vector3.new(0, 2, 0))
                        if headVisible then
                            local scaleFactor = 1 / (headPosition.Z * math.tan(math.rad(camera.FieldOfView / 2)) * 2) * 100
                            local width = math.floor(35 * scaleFactor)
                            local height = math.floor(50 * scaleFactor)
                            local headScreenPosition = Vector2.new(headPosition.X, headPosition.Y)
                            box.PointA = headScreenPosition - Vector2.new(width / 2, height / 2)
                            box.PointB = headScreenPosition - Vector2.new(-width / 2, height / 2)
                            box.PointC = headScreenPosition - Vector2.new(-width / 2, -height / 2)
                            box.PointD = headScreenPosition - Vector2.new(width / 2, -height / 2)
                            -- Update box visibility
                            box.Visible = ESP.settings.box.enabled

                            -- Update name text visibility and position
                            local nameEnabled = textSettings.nameEnabled
                            text.Visible = nameEnabled
                            if nameEnabled then
                                local nameText = tostring(character.Name)
                                text.Text = nameText
                                text.Position = headScreenPosition + Vector2.new(0, -(height / 2) - 15)
                            end

                            -- Determine vertical positioning based on text visibility
                            local verticalOffset = 0
                            local weaponTextEnabled = weaponTextSettings.enabled
                            local distanceTextEnabled = distanceTextSettings.enabled

                            -- Update weapon text visibility and position
                            if weaponTextEnabled then
                                local toolEquipped = character:FindFirstChildOfClass("Tool") or character:FindFirstChildOfClass("BackpackItem")
                                if toolEquipped then
                                    local toolName = toolEquipped.Name
                                    if #toolName > weaponTextSettings.maxLength then
                                        toolName = toolName:sub(1, weaponTextSettings.maxLength) .. "..."
                                    end
                                    weaponText.Text = toolName
                                    weaponText.Position = headScreenPosition + Vector2.new(0, (height / 2) + 2 + verticalOffset)
                                    verticalOffset = verticalOffset + weaponText.TextBounds.Y + 4
                                else
                                    weaponText.Text = "[None]"
                                    weaponText.Position = headScreenPosition + Vector2.new(0, (height / 2) + 2 + verticalOffset)
                                    verticalOffset = verticalOffset + weaponText.TextBounds.Y + 4
                                end
                            end

                            -- Update distance text visibility and position
                            if distanceTextEnabled then
                                local localPlayer = game.Players.LocalPlayer
                                local localHumanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if localHumanoidRootPart then
                                    local distance = (part.Position - localHumanoidRootPart.Position).Magnitude
                                    local meterDistance = math.floor(distance / 3.5714285714 + 0.5)
                                    distancetext.Text = meterDistance .. "m"
                                    distancetext.Position = headScreenPosition + Vector2.new(0, (height / 2) + 2 + verticalOffset)
                                    verticalOffset = verticalOffset + distancetext.TextBounds.Y + 4
                                end
                            end

                            -- Update health text visibility and position
                            local healthTextEnabled = healthTextSettings.enabled
                            healthText.Visible = healthTextEnabled
                            if healthTextEnabled then
                                local health = humanoid.Health
                                local maxHealth = humanoid.MaxHealth
                                if maxHealth > 0 then
                                    local healthPercentage = health / maxHealth
                                    healthText.Text = string.format("%d%%", healthPercentage * 100)
                                    healthText.Position = headScreenPosition + Vector2.new(-(width / 2 + 18), -(height / 2) - 2)
                                end
                            end

                            -- Update health bar visibility, position, and color
                            local healthBarEnabled = healthBarSettings.enabled
                            healthBar.Visible = healthBarEnabled
                            if healthBarEnabled then
                                local health = humanoid.Health
                                local maxHealth = humanoid.MaxHealth
                                if maxHealth > 0 then
                                    local healthPercentage = health / maxHealth
                                    local barLength = height * healthPercentage
                                    local barX = headScreenPosition.X - width / 2 - 4
                                    local barY = headScreenPosition.Y - height / 2

                                    -- Update health bar position
                                    healthBar.From = Vector2.new(barX, barY)
                                    healthBar.To = Vector2.new(barX, barY + barLength)

                                    -- Calculate color based on gradient
                                    local colorIndex = math.floor(healthPercentage * (#gradientColors - 1)) + 1
                                    local gradientColor = gradientColors[colorIndex]

                                    healthBar.Color = gradientColor
                                end
                            end

                            -- Always show/hide the health bar background based on health bar visibility
                            healthBarBackground.Visible = healthBarEnabled

                        else
                            -- If not headVisible, hide all components
                            box.Visible = false
                            text.Visible = false
                            healthText.Visible = false
                            distancetext.Visible = false
                            healthBar.Visible = false
                            weaponText.Visible = false
                            healthBarBackground.Visible = false
                        end
                    end
                else
                    -- If health is 0 or below, hide all components
                    box.Visible = false
                    text.Visible = false
                    healthText.Visible = false
                    distancetext.Visible = false
                    healthBar.Visible = false
                    weaponText.Visible = false
                    healthBarBackground.Visible = false
                end
            end
        end,
        remove = function()
            box:Remove()
            text:Remove()
            distancetext:Remove()
            healthText:Remove()
            healthBar:Remove()
            weaponText:Remove()
            healthBarBackground:Remove()
        end
    }
end

local function updateESP()
    local localPlayer = game.Players.LocalPlayer
    local localHumanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                if not espObjects[character] then
                    espObjects[character] = CreateESP(humanoidRootPart)
                end
                espObjects[character].update()
            end
        end
    end
end

local function handleCharacterAdded(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    espObjects[character] = CreateESP(humanoidRootPart)
end

local function handleCharacterRemoving(character)
    local espObject = espObjects[character]
    if espObject then
        espObject.remove()
        espObjects[character] = nil
    end
end

local function handlePlayerAdded(player)
    local function onCharacterAdded(character)
        handleCharacterAdded(character)
    end

    local function onCharacterRemoving(character)
        handleCharacterRemoving(character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)

    if player.Character then
        handleCharacterAdded(player.Character)
    end
end

game.Players.PlayerAdded:Connect(handlePlayerAdded)
for _, player in ipairs(game.Players:GetPlayers()) do
    handlePlayerAdded(player)
end

game:GetService("RunService").Heartbeat:Connect(updateESP)
return ESP
