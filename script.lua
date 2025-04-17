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

	DisableRayfieldPrompts = false,
	DisableBuildWarnings = true,

	ConfigurationSaving = {
		Enabled = true,
		FolderName = "ProjectFire",
		FileName = "BGSI"
	},

	Discord = {
		Enabled = false, 
		Invite = "noinvitelink", 
		RememberJoins = true 
	},

	KeySystem = false,
	KeySettings = {
		Title = "Untitled",
		Subtitle = "Key System",
		Note = "No key",
		FileName = "Key", 
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"Hello"}
	}
})

local Main = Window:CreateTab("Main", 4483362458)
local Eggs = Window:CreateTab("Eggs", 4483362458)
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
	print(EggName)
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
		print(SelectedEgg)
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

local UnlockButton = Misc:CreateButton({
	Name = "Unlock All Worlds",
	Callback = function()
		local Worlds = require(game:GetService("ReplicatedStorage").Shared.Data.Worlds)
		local CurrentWorld = Worlds[Plr:GetAttribute("World")]
		local LastWorld = CurrentWorld.Islands[#CurrentWorld.Islands].Name

		TweenService:Create(HumRoot, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = workspace.Worlds:FindFirstChild(Plr:GetAttribute("World")).Islands:FindFirstChild(LastWorld).Island.UnlockHitbox.CFrame}):Play()
	end,
})

Rayfield:LoadConfiguration()
