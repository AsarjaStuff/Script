local BASE = "https://raw.githubusercontent.com/YOURNAME/YOURREPO/main/modules/"

local Remotes = loadstring(game:HttpGet(BASE.."remotes.lua"))()
local Pets = loadstring(game:HttpGet(BASE.."pets.lua"))()
local Sleep = loadstring(game:HttpGet(BASE.."sleep.lua"))()
local UI = loadstring(game:HttpGet(BASE.."ui.lua"))()

UI.Init(Pets, Sleep, Remotes)