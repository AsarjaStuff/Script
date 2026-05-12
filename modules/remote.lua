local ReplicatedStorage = game:GetService("ReplicatedStorage")
local API = ReplicatedStorage:WaitForChild("API")

local Remotes = {}

Remotes.HoldBaby = API:WaitForChild("AdoptAPI/HoldBaby")
Remotes.EjectBaby = API:WaitForChild("AdoptAPI/EjectBaby")
Remotes.ActivateFurniture = API:WaitForChild("HousingAPI/ActivateFurniture")
Remotes.ReplicatePerformanceModifiers = API:WaitForChild("PetAPI/ReplicatePerformanceModifiers")

return Remotes