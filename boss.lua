local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local updateCharData = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateCharData")

local BossAim = {
	Enabled = true,
	PredictedCFrame = nil,
}

local function findNearestBoss()
	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	if not localRoot then return nil end

	local npcSpawns = workspace:FindFirstChild("NPCSpawns")
	if not npcSpawns then return nil end

	local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
	local bestRoot = nil
	local bestScreenDistance = math.huge

	for _, descendant in ipairs(npcSpawns:GetDescendants()) do
		if not descendant:IsA("Model") then continue end
		local humanoid = descendant:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then continue end
		local root = descendant:FindFirstChild("HumanoidRootPart")
		if not root then continue end
		local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(root.Position)
		if not onScreen then continue end
		local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - screenCenter).Magnitude
		if screenDistance < bestScreenDistance then
			bestRoot = root
			bestScreenDistance = screenDistance
		end
	end

	return bestRoot
end

RunService.Heartbeat:Connect(function()
	if not BossAim.Enabled then
		BossAim.PredictedCFrame = nil
		return
	end

	local targetRoot = findNearestBoss()
	if not targetRoot then
		BossAim.PredictedCFrame = nil
		return
	end

	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	local targetPosition = targetRoot.Position

	if localRoot then
		BossAim.PredictedCFrame = CFrame.lookAt(
			Vector3.new(localRoot.Position.X, targetPosition.Y, localRoot.Position.Z),
			targetPosition
		)
	else
		BossAim.PredictedCFrame = CFrame.new(targetPosition)
	end
end)

if getgenv().BossAimOriginalHook then
	pcall(hookmetamethod, game, "__namecall", getgenv().BossAimOriginalHook)
	getgenv().BossAimOriginalHook = nil
end

getgenv().BossAimOriginalHook = hookmetamethod(game, "__namecall", function(...)
	local arguments = table.pack(...)
	local method = getnamecallmethod()

	if arguments[1] ~= updateCharData or method ~= "FireServer" then
		return getgenv().BossAimOriginalHook(table.unpack(arguments, 1, arguments.n))
	end

	if not BossAim.Enabled or not BossAim.PredictedCFrame then
		return getgenv().BossAimOriginalHook(table.unpack(arguments, 1, arguments.n))
	end

	local modified = table.pack(table.unpack(arguments, 1, arguments.n))
	modified[2] = BossAim.PredictedCFrame
	return getgenv().BossAimOriginalHook(table.unpack(modified, 1, modified.n))
end)

getgenv().BossAim = BossAim

StarterGui:SetCore("SendNotification", {
	Title = "Boss Silent Aim",
	Text = "Loaded",
	Duration = 3,
})
