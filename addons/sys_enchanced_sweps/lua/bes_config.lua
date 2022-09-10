BES.CONFIG.Language = "english"

BES.CONFIG.DoorRam = {}
BES.CONFIG.DoorRam.DoorHealth = 100
BES.CONFIG.DoorRam.DamagePerHit = 15
BES.CONFIG.DoorRam.DoorRegenTime = 60
BES.CONFIG.DoorRam.InstantOpen = false
BES.CONFIG.DoorRam.InstantAdmin = false

BES.CONFIG.Keys = {}
BES.CONFIG.Keys.ServerLogo = "https://i.imgur.com/kJ3AO1d.jpg" -- The logo used on the keys (false to disable), requires an direct image URL e.g. https://i.imgur.com/fx49qdF.jpg
BES.CONFIG.Keys.DefaultToDoorKey = false

BES.CONFIG.Lockpick = {}
BES.CONFIG.Lockpick.Time = 10
BES.CONFIG.Lockpick.ClickTime = 2.5 -- How long the player has to click when the lock gets stuck
BES.CONFIG.Lockpick.ClicksReq = 4 -- How many clicks are needed per lockpick
BES.CONFIG.Lockpick.ShowHint = false -- Whether a hint should popup when they player needs to click

BES.CONFIG.Medkit = {}
BES.CONFIG.Medkit.PlyHeal = 50
BES.CONFIG.Medkit.SelfHeal = 50
BES.CONFIG.Medkit.HealTime = 4
BES.CONFIG.Medkit.SelfHealTime = 4
BES.CONFIG.Medkit.SlowdownSelfHeal = true

BES.CONFIG.HandCuffs = {}
BES.CONFIG.HandCuffs.CuffTime = 2
BES.CONFIG.HandCuffs.ShowHint = true
BES.CONFIG.HandCuffs.Blacklist = { "dsr_keys", "m9k_scoped_taurus", "m9k_remington1858", "m9k_honeybadger", "m9k_vector", "m9k_l85", "m9k_val", "m9k_aw50", "m9k_barret_m82", "m9k_m98b", "m9k_dragunov", "m9k_dbarrel", "m9k_spas12", "m9k_usas", "m9k_striker12", "m9k_ares_shrike", "m9k_m249lmg", "m9k_rpg7", "m9k_ex41", "m9k_m79gl", "m9k_milkormgl", "dsr_medkit", "weapon_vape_american", "weapon_vape_butterfly", "weapon_vape_custom", "weapon_vape_dragon", "weapon_vape_golden", "weapon_vape_hallucinogenic", "weapon_vape_helium", "weapon_vape_juicy", "weapon_vape_medicinal", "weapon_vape_mega", "weapon_vape", "weapon_cuff_standard", "weapon_cuff_elastic", "weapon_cuff_plastic", "weapon_cuff_police", "weapon_cuff_rope", "weapon_cuff_shackles", "weapon_cuff_tactical" }
BES.CONFIG.HandCuffs.JobBlacklist = { "police", "chief", "fbi", "director", "scientist", "forces", "medic", "sniper", "heavy", "commander", "mayor", "secretary", "administrator", "master" } -- Jobs that cannot be handcuffed (add the job command to the list)

timer.Simple(1, function()
    for id, v in ipairs(weapons.GetList()) do
        local wepname = v.Base or ""

        if string.sub(wepname, 1, 4) == "csgo" then
            table.insert(BES.CONFIG.HandCuffs.Blacklist, v.ClassName)
        end
    end
end)

BES.CONFIG.Taser = {}
BES.CONFIG.Taser.JobBlacklist = { "police", "chief", "fbi", "director", "scientist", "forces", "medic", "sniper", "heavy", "commander", "mayor", "secretary", "administrator", "master" } -- Jobs that cannot be tasered (add the job command to the list)

BES.CONFIG.Themes = {}
BES.CONFIG.Themes.Primary = Color( 30, 33, 36 )
BES.CONFIG.Themes.Secondary = Color( 46, 49, 54 )
BES.CONFIG.Themes.Tertiary = Color( 54, 57, 62 )
BES.CONFIG.Themes.Red = Color( 240, 71, 71 )
BES.CONFIG.Themes.Hover = Color( 255, 255, 255, 2 )
BES.CONFIG.Themes.Text = Color( 220, 221, 222 )