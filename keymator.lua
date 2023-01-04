local AnimatorModule = {}

local function Contains(Table, Check)
	for Index, Value in next, Table do 
		if rawequal(Check, Index) or rawequal(Check, Value) then 
			return true
		end
	end
	return false
end

local AnimDefaults = {
	["Neck"] = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
	["RootJoint"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
	["Right Shoulder"] = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
	["Left Shoulder"] = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	["Right Hip"] = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
	["Left Hip"] = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	["Head"] = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
	["Torso"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
	["Right Arm"] = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
	["Left Arm"] = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	["Right Leg"] = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
	["Left Leg"] = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	["Sheath"] = getgenv().script.rig.Sheath.C0,
	["BackSword"] = getgenv().script.rig.BackSword.C0,
	["Sword"] = getgenv().script.rig.Sword.C0
}

local function Edit(Joint, Change, Duration, Style, Direction)
	Style = Enum.EasingStyle[string.split(tostring(Style), ".")[3]]
	Direction = Enum.EasingDirection[string.split(tostring(Direction), ".")[3]]
	local Anim = game:GetService("TweenService"):Create(Joint, TweenInfo.new(Duration, Style, Direction), {C0 = Change})
	Anim:Play()
	return Anim
end

function AnimatorModule:ResetJoints(Rig)
	local RigHumanoid = Rig:FindFirstChildOfClass("Humanoid")
	assert(RigHumanoid:IsA("Humanoid"), "Rig Humanoid Missing!")
	if not RigHumanoid.RigType == Enum.HumanoidRigType.R6 then
		return error("Rig Humanoid is not R6!")
	end
	local Joints = {
		["Torso"] = Rig.HumanoidRootPart:FindFirstChild("RootJoint") or Rig.HumanoidRootPart:FindFirstChild("Root Joint"),
		["Left Arm"] = Rig.Torso["Left Shoulder"],
		["Right Arm"] = Rig.Torso["Right Shoulder"],
		["Left Leg"] = Rig.Torso["Left Hip"],
		["Right Leg"] = Rig.Torso["Right Hip"],
		["Head"] = Rig.Torso["Neck"],
	}
	for Limb, Joint in next, Joints do
		Edit(Joint, AnimDefaults[Limb], 0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	end
end

function AnimatorModule:LoadAnimation(Rig, KeyframeSequence)
	local Sequence = KeyframeSequence
	assert(Sequence:IsA("KeyframeSequence"), "KeyframeSequence Missing!")
	local RigHumanoid = Rig:FindFirstChildOfClass("Humanoid")
	assert(RigHumanoid:IsA("Humanoid"), "Rig Humanoid Missing!")
	if not RigHumanoid.RigType == Enum.HumanoidRigType.R6 then
		return error("Rig Humanoid is not R6!")
	end
	local Joints = {
		["Torso"] = Rig.HumanoidRootPart:FindFirstChild("RootJoint") or Rig.HumanoidRootPart:FindFirstChild("Root Joint"),
		["Left Arm"] = Rig.Torso["Left Shoulder"],
		["Right Arm"] = Rig.Torso["Right Shoulder"],
		["Left Leg"] = Rig.Torso["Left Hip"],
		["Right Leg"] = Rig.Torso["Right Hip"],
		["Head"] = Rig.Torso["Neck"],
		["Sword"] = Rig:WaitForChild("Sword",1),
		["BackSword"] = Rig:WaitForChild("BackSword",1),
		["Sheath"] = Rig:WaitForChild("Sheath",1)
	}
	local Class = {}
	Class.Speed = 1
	Class.KeepLast = 0
	local Keyframes = Sequence:GetKeyframes()
	table.sort(Keyframes, function(a, b) return a.Time < b.Time end) -- Thanks 10k_i, roblox not sorting by default.
	Class.Length = Keyframes[#(Keyframes)].Time
	local Yield = function(Seconds)
		local Time = Seconds * (60 + Class.Length)
		for i = 1, Time, Class.Speed do 
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
	if Sequence:FindFirstChild("xSIXxNull", true) or Sequence:FindFirstChild("xSIXxCustomDir", true) or Sequence:FindFirstChild("xSIXxCustomStyle", true) then -- Moon Suite Fix
		local Children = Sequence:GetChildren()
		for i = 1, #(Children) do
			if Children[i]:FindFirstChild("Torso") then
				local Limbs = Children[i].Torso:GetChildren()
				for l = 1, #(Limbs) do
					Limbs[l].Parent = Children[i].HumanoidRootPart.Torso
				end
				Children[i].Torso:Destroy()
			end
		end
	end
	local Descendants = Sequence:GetDescendants()
	for i = 1, #(Descendants) do
		if Descendants[i]:IsA("IntValue") or Descendants[i]:IsA("StringValue") or Descendants[i]:IsA("Folder") then
			Descendants[i]:Destroy()
		end
		if Descendants[i].Parent ~= Sequence and Descendants[i]:IsA("Pose") and not Rig:FindFirstChild(Descendants[i].Name, true) then
			Descendants[i]:Destroy()
		end
	end
	Class.Stopped = true
	Class.IsPlaying = false
	Class.TimePosition = 0
	Class.Looped = Sequence.Loop
	local Completion = Instance.new("BindableEvent")
	local Reached = Instance.new("BindableEvent")
	Class.Completed = Completion.Event
	Class.KeyframeReached = Reached.Event
	Class["Play"] = function(self, FadeIn, Speed)
		if Speed and Speed < 0 then
			Speed += (Speed*2)
		end
		Class.Speed = Speed or Class.Speed
		Class.Stopped = false
		Class.IsPlaying = true
		task.spawn(function()
			wait(1/60)
			if FadeIn ~= nil then
				Class.TimePosition -= FadeIn
			end
			Class.Completed:Connect(function()
				if Class.Looped ~= false then
					Class.TimePosition = 0
				end
			end)
			repeat game:GetService("RunService").Heartbeat:Wait()
				Class.TimePosition += (1 * Class.Speed) / (60 * Class.Speed) 
			until Class.IsPlaying == false or Class.Stopped ~= false or RigHumanoid.Health == 0
		end)
		task.spawn(function()
			if FadeIn ~= nil then
				task.wait(1/55)
				task.spawn(function()
					local Frames = Keyframes[1]:GetDescendants()
					for i = 1, #(Frames) do 
						local Pose = Frames[i]
						if Contains(Joints, Pose.Name) then 
							task.spawn(function()
								for i = 1, 2 do
									Edit(Joints[Pose.Name], AnimDefaults[Pose.Name] * Pose.CFrame, FadeIn, Pose.EasingStyle, Pose.EasingDirection)
									task.wait()
								end
							end)
						end
					end
				end)
				Yield(FadeIn)
			end
			repeat
				for K = 1, #(Keyframes) do 
					local K0, K1, K2 = Keyframes[K-1], Keyframes[K], Keyframes[K+1]
					if Class.Stopped ~= true and RigHumanoid.Health ~= 0 then
						if K0 ~= nil then 
							Yield(K1.Time - K0.Time)
						end
						task.spawn(function()
							for i = 1, #(K1:GetDescendants()) do 
								local Pose = K1:GetDescendants()[i]
								if Contains(Joints, Pose.Name) then 
									local Duration = K2 ~= nil and (K2.Time - K1.Time) / Class.Speed or 0.5
									Edit(Joints[Pose.Name], AnimDefaults[Pose.Name] * Pose.CFrame, Duration, Pose.EasingStyle, Pose.EasingDirection)
								end
							end
						end)
						if K == #(Keyframes) and Class.KeepLast > 0 then
							Yield(Class.KeepLast)
						end
						Reached:Fire(K1.Name)
					else
						break
					end
				end
				Completion:Fire()
			until Class.Looped ~= true or Class.Stopped ~= false or RigHumanoid.Health == 0
			Class.IsPlaying = false
		end)
	end
	Class["Stop"] = function()
		Class.Stopped = true
	end
	Class["AdjustSpeed"] = function(self, Speed)
		if Speed < 0 then
			Speed += (Speed*2)
		end
		Class.Speed = Speed or Class.Speed
	end
	return Class
end

return AnimatorModule
