--[[
  COMPLETE EXAMPLE: Pet Controller with Cobalt House Data
  ========================================================
  
  This example shows how to use the house data setup with your Cobalt output.
  Paste your house_interior data and run this before any pet actions.
]]

-- Your Cobalt-generated house interior data
-- (This is the 3rd parameter from: firesignal(Event.OnClientEvent, \"PlayerName\", \"house_interior\", THIS_DATA, timestamp))
local houseInteriorData = {
    house_pos = Vector3.new(-6000, 4000, -9000),
    furniture = {
        [\"f-2\"] = {
            was_default = true,
            was_free = false,
            colors = {
                Color3.new(0.36862745881081, 0.29803922772408, 0.2549019753933),
                Color3.new(0.42745098471642, 0.3137255012989, 0.2392156869173),
                Color3.new(0.50196081399918, 0.73333334922791, 0.85882353782654),
                Color3.new(0.54509806632996, 0.52549022436142, 0.54117649793625),
                Color3.new(0.92941176891327, 0.91764706373215, 0.91764706373215)
            },
            id = \"towels\",
            scale = 1,
            cframe = CFrame.new(27.5, 5.9000239372253, -0.49987798929214, -1, 0, -0, 0, 0, -1, 0, -1, -0),
            no_value = true,
            hash = 2
        },
        [\"f-6\"] = {\n            was_default = true,\n            was_free = false,\n            colors = {\n                Color3.new(0.97254902124405, 0.97254902124405, 0.97254902124405),\n                Color3.new(0.35686275362968, 0.3647058904171, 0.41176471114159),\n                Color3.new(0.43137255311012, 0.60000002384186, 0.79215687513351)\n            },\n            id = \"pet_water_bowl\",\n            scale = 1,\n            cframe = CFrame.new(23, 0.11989700049162, -21, 0, 0, -1, 0, 1, 0, 1, 0, 0),\n            no_value = true,\n            hash = 23\n        },\n        [\"f-12\"] = {\n            hash = 35,\n            scale = 1,\n            was_free = false,\n            was_default = true,\n            colors = {\n                Color3.new(0.97254902124405, 0.97254902124405, 0.97254902124405)\n            },\n            occupied = {},\n            cframe = CFrame.new(39, 0, -12.5, 0, 0, 1, 0, 1, -0, -1, 0, 0),\n            id = \"toilet\",\n            no_value = true\n        },\n        [\"f-16\"] = {\n            was_default = true,\n            was_free = false,\n            colors = {\n                Color3.new(0.35686275362968, 0.3647058904171, 0.41176471114159),\n                Color3.new(0.79215687513351, 0.79607844352722, 0.81960785388947),\n                Color3.new(0.97254902124405, 0.97254902124405, 0.97254902124405)\n            },\n            id = \"modernshower\",\n            scale = 1,\n            cframe = CFrame.new(38.5, 0, -3.5, 0, 0, 1, 0, 1, -0, -1, 0, 0),\n            no_value = true,\n            hash = 6\n        },\n        [\"f-25\"] = {\n            was_default = true,\n            was_free = false,\n            colors = {\n                Color3.new(0.34509804844856, 0.4745098054409, 0.77647060155869),\n                Color3.new(0.91764706373215, 0.72156864404678, 0.57254904508591),\n                Color3.new(0.97254902124405, 0.97254902124405, 0.97254902124405),\n                Color3.new(1, 1, 1)\n            },\n            id = \"cheap_pet_bathtub_tutorial\",\n            scale = 1,\n            cframe = CFrame.new(39.5, 0, -8.5, -1, 0, 0, 0, 1, 0, 0, 0, -1),\n            no_value = true,\n            hash = 8\n        },\n        [\"f-8\"] = {\n            was_default = true,\n            was_free = false,\n            colors = {\n                Color3.new(0.38431373238564, 0.14509804546833, 0.81960785388947),\n                Color3.new(0.58431375026703, 0.53725492954254, 0.53333336114883),\n                Color3.new(0.6235294342041, 0.63137257099152, 0.6745098233223),\n                Color3.new(0.63921570777893, 0.63529413938522, 0.64705884456635),\n                Color3.new(0.84313726425171, 0.77254903316498, 0.60392159223557)\n            },\n            id = \"basicbed\",\n            scale = 1,\n            cframe = CFrame.new(12, 0, -30, 0, 0, -1, 0, 1, 0, 1, 0, 0),\n            no_value = true,\n            hash = 55\n        }\n        -- Add other furniture from your Cobalt output as needed\n    },\n    furniture_quantity = 30,\n    house_id = 12,\n    building_type = \"micro_2023\",\n    unique = \"house_{bdce744f-e2b0-4e17-94f3-364d49b93c93}\",\n    listed_for_trade = false,\n    player = game:GetService(\"Players\").LocalPlayer,\n    active_addons = {},\n    allows_coop_building = false,\n}\n\n-- Initialize house data BEFORE UI.Init\nlocal HouseDataSetup = require(...)\nHouseDataSetup.loadFromCobalt(houseInteriorData)\nprint(\"[Example] House data initialized\")\n\n-- Now run your normal loader\nlocal Remotes = require(...)\nlocal Pets = require(...)\nlocal Sleep = require(...)\nlocal Care = require(...)\nlocal Toys = require(...)\nlocal Requirements = require(...)\nlocal PetStatesModule = require(...)\nlocal UI = require(...)\n\nlocal PetState = nil\nif PetStatesModule and PetStatesModule.Init then\n    local ok, st = pcall(PetStatesModule.Init)\n    if ok then\n        PetState = st\n        print(\"[Example] PetStates OK\")\n    end\nend\n\n-- Pass houseData as 8th parameter\nif type(UI) == \"table\" and type(UI.Init) == \"function\" then\n    local ok, err = pcall(function()\n        UI.Init(Pets, Sleep, Care, Remotes, PetState, Toys, Requirements, houseInteriorData)\n    end)\n    if ok then\n        print(\"[Example] UI initialized with house data\")\n    else\n        warn(\"[Example] UI.Init error:\", err)\n    end\nend\n"