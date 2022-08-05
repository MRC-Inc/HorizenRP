local function Buy(ply, _, ent, cost)
    ent:CPPISetOwner(ply)
end

hook.Add('playerBoughtCustomEntity', 'EntOwnFix', Buy)
hook.Add('playerBoughtAmmo', 'AmmoOwnFix', Buy)
hook.Add('playerBoughtShipment', 'ShipOwnFix', Buy)
hook.Add('playerBoughtPistol', 'GunOwnFix', Buy)