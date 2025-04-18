local RS = game:GetService("ReplicatedStorage")
local HS = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Plr = game:GetService("Players").LocalPlayer
local HumRoot = Plr.Character.HumanoidRootPart

_G.Settings = {}

local function State(Setting)
	return _G.Settings[Setting]
end

local Network = require(RS.Shared.Framework.Network.Remote)
local DataModule = require(RS.Client.Framework.Services.LocalData)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Project: Fire",
	Icon = 0,
	LoadingTitle = "Project: Fire",
	LoadingSubtitle = "by Obama",
	Theme = "Default",

	DisableRayfieldPrompts = true,
	DisableBuildWarnings = true,

	ConfigurationSaving = {
		Enabled = true,
		FolderName = "ProjectFire",
		FileName = "BGSI"
	},

	Discord = {
		Enabled = true, 
		Invite = "8bAj9Wz8nj", 
		RememberJoins = true 
	},

	KeySystem = true,
	KeySettings = {
		Title = "Project: Fire | Key System",
		Subtitle = "By Obama",
		Note = "Follow the key system via our discord! ",
		FileName = "Key", 
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"Obamatron"}
	}
})

local Main = Window:CreateTab("Main", 4483362458)
local Eggs = Window:CreateTab("Eggs", 4483362458)
local Rifts = Window:CreateTab("Rifts", 4483362458)
local Rewards = Window:CreateTab("Rewards", 4483362458)
local Misc = Window:CreateTab("Misc", 4483362458)

local BubblesToggle = Main:CreateToggle({
	Name = "Auto Bubbles",
	CurrentValue = false,
	Flag = "AutoBubbles",
	Callback = function(Value)
		_G.Settings["AutoBubbles"] = Value
		while _G.Settings["AutoBubbles"] do 
			Network:FireServer("BlowBubble")
			wait()
		end
	end,
})

local SellToggle = Main:CreateToggle({
	Name = "Auto Sell",
	CurrentValue = false,
	Flag = "AutoSell",
	Callback = function(Value)
		_G.Settings["AutoSell"] = Value
		while _G.Settings["AutoSell"] do 
			Network:FireServer("SellBubble")
			wait()
		end
	end,
})

local SellToggle2 = Main:CreateToggle({
	Name = "Auto Sell When Full",
	CurrentValue = false,
	Flag = "AutoSellV2",
	Callback = function(Value)
		_G.Settings["AutoSellV2"] = Value
		local Info = HS:JSONDecode(Plr:GetAttribute("Bubble"))
		while _G.Settings["AutoSellV2"] do 
			if require(RS.Shared.Utils.Stats.StatsUtil):GetBubbleStorage(DataModule:Get()) == DataModule:Get().Bubble.Amount then
				Network:FireServer("SellBubble")
			end
			wait()
		end
	end,
})

local AutoCollect = Main:CreateToggle({
	Name = "Auto Collect",
	CurrentValue = false,
	Flag = "AutoCollect",
	Callback = function(Value)
		_G.Settings["AutoCollect"] = Value
		while _G.Settings["AutoCollect"] do 
			for i, Folder in workspace.Rendered:GetChildren() do
				if Folder.Name == "Chunker" then
					for i, v in Folder:GetChildren() do
						if not v:GetAttribute("Island") then
							RS.Remotes.Pickups.CollectPickup:FireServer(v.Name)
							v:Destroy()
						end
					end
				end
			end
			wait()
		end
	end,
})

local EggsModule = require(RS.Shared.Data.Eggs)
local AllEggs = {}
local SelectedEgg

for EggName, EggInfo in EggsModule do
	table.insert(AllEggs, EggName)
end

local EggsDropdown = Eggs:CreateDropdown({
	Name = "Select Egg",
	Options = AllEggs,
	CurrentOption = "Common Egg",
	MultipleOptions = false,
	Flag = "EggDropdown",
	Callback = function(Options)
		SelectedEgg = Options[1]
	end,
})

local HatchToggle = Eggs:CreateToggle({
	Name = "Auto Hatch",
	CurrentValue = false,
	Flag = "AutoHatch",
	Callback = function(Value)
		_G.Settings["AutoHatch"] = Value
		local EggCost = EggsModule[SelectedEgg].Cost
		while _G.Settings["AutoHatch"] do 
			if DataModule:Get()[EggCost.Currency] >= EggCost.Amount then
				Network:FireServer("HatchEgg", SelectedEgg, 10)
			end
			wait(0.25)
		end
	end,
})

local CodesButton = Misc:CreateButton({
	Name = "Redeem All Codes",
	Callback = function()
		for i, v in require(RS.Shared.Data.Codes) do
			Network:InvokeServer("RedeemCode", i)
		end
	end,
})

local UnlockButton = Misc:CreateButton({
	Name = "Unlock All Worlds",
	Callback = function()
		local Worlds = require(game:GetService("ReplicatedStorage").Shared.Data.Worlds)
		local CurrentWorld = Worlds[Plr:GetAttribute("World")]
		local LastWorld = CurrentWorld.Islands[#CurrentWorld.Islands].Name

		TweenService:Create(HumRoot, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = workspace.Worlds:FindFirstChild(Plr:GetAttribute("World")).Islands:FindFirstChild(LastWorld).Island.UnlockHitbox.CFrame}):Play()
	end,
})

local MasteryToggle = Misc:CreateToggle({
	Name = "Auto Mastery",
	CurrentValue = false,
	Flag = "AutoMastery",
	Callback = function(Value)
		_G.Settings["AutoMastery"] = Value
		while _G.Settings["AutoMastery"] do 
			for i, UpgradeType in require(game:GetService("ReplicatedStorage").Shared.Data.Mastery).Upgrades do
				Network:FireServer("UpgradeMastery", i)
			end
			wait(15)
		end
	end,
})

local RiftsFolder = workspace.Rendered.Rifts
local AllRifts = {}
local SelectedRift

local function ResetRifts()
	AllRifts = {}
	for i, Rift in RiftsFolder:GetChildren() do
		table.insert(AllRifts, tostring(i) .. ". " .. Rift.Name)
	end
end
ResetRifts()

local RiftDropdown = Rifts:CreateDropdown({
	Name = "Teleport To Rift",
	Options = AllRifts,
	CurrentOption = "None",
	MultipleOptions = false,
	Flag = "RiftDropdown",
	Callback = function(Options)
		local RiftNumber = tonumber(string.split(Options[1], ".")[1])
		SelectedRift = RiftNumber
	end,
})

local TeleportButton = Rifts:CreateButton({
	Name = "Teleport",
	Callback = function()
		TweenService:Create(HumRoot, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = RiftsFolder:GetChildren()[SelectedRift].Display.CFrame}):Play()
	end,
})

RiftsFolder.ChildAdded:Connect(function()
	ResetRifts()
	RiftDropdown:Refresh(AllRifts)
end)

RiftsFolder.ChildRemoved:Connect(function()
	ResetRifts()	
	RiftDropdown:Refresh(AllRifts)
end)

local DailyToggle = Rewards:CreateToggle({
	Name = "Auto Claim Daily",
	CurrentValue = false,
	Flag = "AutoDaily",
	Callback = function(Value)
		_G.Settings["AutoDaily"] = Value
		while _G.Settings["AutoDaily"] do 
			Network:FireServer("DailyRewardClaimStars")
			task.wait(300)
		end
	end,
})

local WheelSpinToggle = Rewards:CreateToggle({
	Name = "Auto Wheel Spin",
	CurrentValue = false,
	Flag = "AutoWheel",
	Callback = function(Value)
		_G.Settings["AutoWheel"] = Value
		while _G.Settings["AutoWheel"] do 
			Network:FireServer("ClaimFreeWheelSpin")
			Network:InvokeServer("WheelSpin")
			task.wait(60)
		end
	end,
})

local Connection

local MysteryToggle = Rewards:CreateToggle({
	Name = "Auto Mystery Gift",
	CurrentValue = false,
	Flag = "AutoMystery",
	Callback = function(Value)
		_G.Settings["AutoMystery"] = Value
		Connection = workspace.Rendered.Gifts.ChildAdded:Connect(function(Gift)
			Network:FireServer("ClaimGift", Gift.Name)
		end)
		if not _G.Settings["AutoMystery"] then Connection:Disconnect() end
		while _G.Settings["AutoMystery"] do 
			Network:FireServer("UseGift", "Mystery Box", 10)
			task.wait()
		end
	end,
})

Rayfield:LoadConfiguration()
