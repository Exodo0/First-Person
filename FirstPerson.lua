repeat wait() until game:GetService("Players").LocalPlayer.Character ~= nil
local runService = game:GetService("RunService")
local input = game:GetService("UserInputService")
local players = game:GetService("Players")

-- Configuración ajustable
local CanToggleMouse = {allowed = true, activationkey = Enum.KeyCode.F}
local CanViewBody = true
local Sensitivity = 0.6
local Smoothness = 0.05
local FieldOfView = 80
local HeadOffset = CFrame.new(0, 1.3 ,0)

local cam = game.Workspace.CurrentCamera
local player = players.LocalPlayer
local m = player:GetMouse()
m.Icon = "http://www.roblox.com/asset/?id=569021388"

local character = player.Character or player.CharacterAdded:wait()
local humanoid = character.Humanoid
local humanoidpart = character.HumanoidRootPart
local head = character:WaitForChild("Head")

local CamPos, TargetCamPos = cam.CoordinateFrame.p, cam.CoordinateFrame.p 
local AngleX, TargetAngleX = 0, 0
local AngleY, TargetAngleY = 0, 0

local running = true
local freemouse = false
local defFOV = FieldOfView

local w, a, s, d, lshift = false, false, false, false, false

local easingtime = 0.1
local walkspeeds = {
	enabled = true,
	walkingspeed = 16,
	backwardsspeed = 10,
	sidewaysspeed = 15,
	diagonalspeed = 16,
	runningspeed = 25,
	runningFOV = 85
}

function updatechar()
	for _, v in pairs(character:GetChildren()) do
		if CanViewBody then
			if v.Name == 'Head' then
				v.LocalTransparencyModifier = 1
				v.CanCollide = false
			end
		else
			if v:IsA('MeshPart') then
				v.LocalTransparencyModifier = 1
				v.CanCollide = false
			elseif v:IsA('Part') or v:IsA('UnionOperation') or v:IsA('MeshPart') then
				v.LocalTransparencyModifier = 1
				v.CanCollide = false
			end
		end
		if v:IsA('Accessory') then
			v:FindFirstChild('Handle').LocalTransparencyModifier = 1
			v:FindFirstChild('Handle').CanCollide = false
		end
		if v:IsA('Hat') then
			v:FindFirstChild('Handle').LocalTransparencyModifier = 1
			v:FindFirstChild('Handle').CanCollide = false
		end
	end
end

function lerp(a, b, t)
	return a * (1-t) + (b*t)
end

input.InputChanged:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = Vector2.new(inputObject.Delta.x / Sensitivity, inputObject.Delta.y / Sensitivity) * Smoothness
		local X = TargetAngleX - delta.y 
		TargetAngleX = (X >= 80 and 80) or (X <= -80 and -80) or X 
		TargetAngleY = (TargetAngleY - delta.x) % 360 
	end	
end)

input.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		if inputObject.KeyCode == CanToggleMouse.activationkey then
			if CanToggleMouse.allowed and freemouse == false then
				freemouse = true
			else
				freemouse = false
			end
		end

		if inputObject.KeyCode == Enum.KeyCode.W then w = true end
		if inputObject.KeyCode == Enum.KeyCode.A then a = true end
		if inputObject.KeyCode == Enum.KeyCode.S then s = true end
		if inputObject.KeyCode == Enum.KeyCode.D then d = true end
		if inputObject.KeyCode == Enum.KeyCode.LeftShift then lshift = true end
	end
end)

input.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		if inputObject.KeyCode == Enum.KeyCode.W then w = false end
		if inputObject.KeyCode == Enum.KeyCode.A then a = false end
		if inputObject.KeyCode == Enum.KeyCode.S then s = false end
		if inputObject.KeyCode == Enum.KeyCode.D then d = false end
		if inputObject.KeyCode == Enum.KeyCode.LeftShift then lshift = false end
	end
end)

runService.RenderStepped:Connect(function()
	if running then
		updatechar()

		CamPos = CamPos + (TargetCamPos - CamPos) * 0.28 
		AngleX = AngleX + (TargetAngleX - AngleX) * 0.35 
		local dist = TargetAngleY - AngleY 
		dist = math.abs(dist) > 180 and dist - (dist / math.abs(dist)) * 360 or dist 
		AngleY = (AngleY + dist * 0.35) % 360
		cam.CameraType = Enum.CameraType.Scriptable

		cam.CFrame = CFrame.new(head.Position) 
			* CFrame.Angles(0, math.rad(AngleY), 0) 
			* CFrame.Angles(math.rad(AngleX), 0, 0)
			* HeadOffset

		humanoidpart.CFrame = CFrame.new(humanoidpart.Position) * CFrame.Angles(0, math.rad(AngleY), 0)
	else
		game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
	end

	if (cam.Focus.p - cam.CFrame.p).Magnitude < 1 then
		running = false
	else
		running = true
		if freemouse then
			game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
		else
			game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	end

	if not CanToggleMouse.allowed then
		freemouse = false
	end

	cam.FieldOfView = FieldOfView

	if walkspeeds.enabled then
		if w and s then return end

		if w and not lshift then
			FieldOfView = lerp(FieldOfView, defFOV, easingtime)
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.walkingspeed, easingtime)
		elseif w and a then
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.diagonalspeed, easingtime)
		elseif w and d then
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.diagonalspeed, easingtime)
		elseif s then
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.backwardsspeed, easingtime)
		elseif s and a then
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.backwardsspeed - (walkspeeds.diagonalspeed - walkspeeds.backwardsspeed), easingtime)
		elseif s and d then
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.backwardsspeed - (walkspeeds.diagonalspeed - walkspeeds.backwardsspeed), easingtime)
		elseif d then
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.sidewaysspeed, easingtime)
		elseif a then
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.sidewaysspeed, easingtime)
		end

		if lshift and w then
			FieldOfView = lerp(FieldOfView, walkspeeds.runningFOV, easingtime)
			humanoid.WalkSpeed = lerp(humanoid.WalkSpeed, walkspeeds.runningspeed, easingtime)
		end
	end
end)
