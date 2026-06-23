--[[
  HOUSE DATA SETUP GUIDE
  =====================
  
  Before running UI.Init(), set your house furniture data using the Cobalt output.
  This ensures furniture locations are loaded before pet actions (feed, drink, toilet, shower, sleep).
  
  USAGE:
  ------
  
  1. Get Cobalt output (firesignal format) for your house:
     - Run in Cobalt: output the house_interior data
     - Or copy from a working script
  
  2. Load it in your script BEFORE UI.Init:
  
     local HouseDataSetup = require(...)
     
     local myHouseData = {
         -- Paste your Cobalt firesignal DATA here (the 3rd parameter)
         house_pos = Vector3.new(...),
         furniture = {...},
         ...other fields...
     }
     
     HouseDataSetup.loadFromCobalt(myHouseData)
  
  3. Then call UI.Init() normally - it will auto-fire house data before actions
  
  EXAMPLE WITH YOUR DATA:
  ----------------------
  
  local HouseDataSetup = require(script.Parent:FindFirstChild(\"HouseDataSetup\"))
  
  -- Your Cobalt house_interior data
  local houseData = {
      house_pos = Vector3.new(-6000, 4000, -9000),
      furniture = {
          [\"f-2\"] = { id = \"towels\", ... },
          [\"f-20\"] = { id = \"fancyfan\", ... },
          -- ... (all furniture entries)
      },
      furniture_quantity = 30,
      unique = \"house_{bdce744f-e2b0-4e17-94f3-364d49b93c93}\",
      -- ... (other fields from Cobalt output)
  }
  
  HouseDataSetup.loadFromCobalt(houseData)
  print(\"House data ready!\")
  
  -- Now when you run autofarm or manual actions, furniture will be available
  
  DYNAMIC UPDATE:
  ---------------
  
  If you get new furniture data (e.g., from an update):
  
      HouseDataSetup.loadFromCobalt(newHouseData)
  
  The cached data updates, and next furniture action will use the new layout.
  
  NOTES:
  ------
  - Data is cached per UI session
  - Fires every ~0.5s max (throttled to avoid spam)
  - Works for any player using the script
  - If no data is set, furniture actions will fall back to dynamic detection
]]

return nil  -- This file is documentation only
