local ReplicatedStorage = game:GetService("ReplicatedStorage")
local API = ReplicatedStorage:WaitForChild("API")

local Remotes = {}

Remotes.HoldBaby = API:WaitForChild("AdoptAPI/HoldBaby")
Remotes.EjectBaby = API:WaitForChild("AdoptAPI/EjectBaby")
Remotes.ActivateFurniture = API:WaitForChild("HousingAPI/ActivateFurniture")
Remotes.DataChanged = API:WaitForChild("DataAPI/DataChanged")

Remotes.ToolEquip = API:WaitForChild("ToolAPI/Equip")
Remotes.ToolUnequip = API:WaitForChild("ToolAPI/Unequip")
Remotes.ServerUseTool = API:WaitForChild("ToolAPI/ServerUseTool")
Remotes.CreatePetObject = API:WaitForChild("PetObjectAPI/CreatePetObject")

return Remotes
