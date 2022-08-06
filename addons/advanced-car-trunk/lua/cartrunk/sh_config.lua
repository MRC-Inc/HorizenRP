CarTrunk.Config.Language = "ru"
CarTrunk.Config.KeyOne = KEY_LALT
CarTrunk.Config.KeyTwo = KEY_M

--[[
	1 = All people who has the keys
	2 = The main owner of the vehicle
	3 = Everyone while the car is opened
]]
CarTrunk.Config.AllowedToUseTrunk = 3

--[[
CarTrunk.Config.SpecificVehicles[ "class" ] = {
	hasTrunk = true,
	weight = 500,
	trunkPosition = Vector(),
	trunkAngle = Angle(),
}
]]

CarTrunk.Config.SpecificVehicles[ "Seat_Airboat" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "Chair_Office2" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "phx_seat" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "phx_seat2" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "phx_seat3" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "Chair_Plastic" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "Seat_Jeep" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "Chair_Office1" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "Chair_Wood" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "bmxgtav" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "tribikegtav" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "nemesisgtav" ] = {
	hasTrunk = false,
}
CarTrunk.Config.SpecificVehicles[ "busgtav" ] = {
	hasTrunk = true,
	weight = 500,
	trunkPosition = Vector( 80, 370, -27 ),
	trunkAngle = Angle( 0, 90, 0 ),
}

--[[
CarTrunk.Config.SpecificEntities[ "class" ] = {
	isBlacklisted = true,
	weight = 500,
	category = "Weapon",
}

About categories : 
If it's a weapon/food/ammo, use the following words for categories :
Weapon
Ammo
Food

By this way, it'll be automatically translated.
]]

CarTrunk.Config.SpecificEntities[ "spawned_money" ] = {
	isBlacklisted = true,
}
CarTrunk.Config.SpecificEntities[ "prop_physics" ] = {
	isBlacklisted = true,
}
CarTrunk.Config.SpecificEntities[ "prop_door_rotating" ] = {
	isBlacklisted = true,
}
CarTrunk.Config.SpecificEntities[ "func_door" ] = {
	isBlacklisted = true,
}
CarTrunk.Config.SpecificEntities[ "func_door_rotating" ] = {
	isBlacklisted = true,
}

CarTrunk.Config.SpecificEntities[ "spawned_weapon" ] = {
	category = "Weapon",
}
CarTrunk.Config.SpecificEntities[ "spawned_ammo" ] = {
	category = "Ammo",
}
CarTrunk.Config.SpecificEntities[ "spawned_food" ] = {
	category = "Food",
}

