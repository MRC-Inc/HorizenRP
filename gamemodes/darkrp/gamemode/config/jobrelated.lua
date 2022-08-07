local GAMEMODE = GAMEMODE or GM

-- Список персонала
local stafflist = {
        "superadmin",
        "admin",
        "curator",
        "admin3",
        "admin2",
        "admin1",
        "moder3",
        "moder2",
        "moder1",
        "moder0"
}

-- Список донат групп
local donatelist = {
        "deluxe",
        "premium",
        "vip"
}

-- Граждане
TEAM_CITIZEN = DarkRP.createJob("Гражданин", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/player/group01/male_01.mdl",
        "models/player/Group01/Male_02.mdl",
        "models/player/Group01/male_03.mdl",
        "models/player/Group01/Male_04.mdl",
        "models/player/Group01/Male_05.mdl",
        "models/player/Group01/Male_06.mdl",
        "models/player/Group01/Male_07.mdl",
        "models/player/Group01/Male_08.mdl",
        "models/player/Group01/Male_09.mdl",
        "models/player/Group01/Female_01.mdl",
        "models/player/Group01/Female_02.mdl",
        "models/player/Group01/Female_03.mdl",
        "models/player/Group01/Female_04.mdl",
        "models/player/Group01/Female_06.mdl",
    },
    description = [[Гражданин - базовый общественный слой, которым Вы можете беспрепятственно стать. 
    У Вас нет предопределенной роли в жизни города.
    Вы можете придумать себе свою собственную профессию и заниматься своим делом.]],
    weapons = {},
    command = "citizen",
    modelScale = 1,
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Граждане",
})

TEAM_GUN = DarkRP.createJob("Продавец оружия", {
    color = Color(20, 150, 20, 255),
    model = "models/player/monk.mdl",
    description = [[Вы торгуете оружием, но прежде чем начать торговлю, Вам нужна лицензия.]],
    weapons = {},
    command = "gundealer",
    modelScale = 1,
    max = 3,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Граждане",
})

TEAM_MEDIC = DarkRP.createJob("Доктор", {
    color = Color(20, 150, 20, 255),
    model = "models/player/kleiner.mdl",
    description = [[Ваша задача состоит в том, чтобы лечить людей, организуйте небольшую больницу и предлагайте свои услуги жителям города.]],
    weapons = {"med_kit"},
    command = "medic",
    modelScale = 1,
    max = 4,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    medic = true,
    category = "Граждане",
})

TEAM_MINER = DarkRP.createJob("Шахтер", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/player/Group03/male_01.mdl",
        "models/player/Group03/Male_02.mdl",
        "models/player/Group03/male_03.mdl",
        "models/player/Group03/Male_04.mdl",
        "models/player/Group03/Male_05.mdl",
        "models/player/Group03/Male_06.mdl",
        "models/player/Group03/Male_07.mdl",
        "models/player/Group03/Male_08.mdl",
        "models/player/Group03/Male_09.mdl",
        "models/player/Group03/female_01.mdl",
        "models/player/Group03/Female_02.mdl",
        "models/player/Group03/Female_03.mdl",
        "models/player/Group03/Female_04.mdl",
        "models/player/Group03/Female_06.mdl",
    },
    description = [[Вы работаете на местной шахте.
    Добывайте руду и отправляйте ее на переработку.]],
    weapons = {"mgs_pickaxe"},
    command = "miner",
    modelScale = 1,
    max = 5,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Граждане"
})

TEAM_WOODMAN = DarkRP.createJob("Дровосек", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/player/Group03/male_01.mdl",
        "models/player/Group03/Male_02.mdl",
        "models/player/Group03/male_03.mdl",
        "models/player/Group03/Male_04.mdl",
        "models/player/Group03/Male_05.mdl",
        "models/player/Group03/Male_06.mdl",
        "models/player/Group03/Male_07.mdl",
        "models/player/Group03/Male_08.mdl",
        "models/player/Group03/Male_09.mdl",
        "models/player/Group03/female_01.mdl",
        "models/player/Group03/Female_02.mdl",
        "models/player/Group03/Female_03.mdl",
        "models/player/Group03/Female_04.mdl",
        "models/player/Group03/Female_06.mdl",
    },
    description = [[Вы зарабатываете на добыче и переработке дерева.
    Рубите деревья и отправляйте бревна на переработку.]],
    weapons = {"swm_chopping_axe"},
    command = "woodman",
    modelScale = 1,
    max = 5,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Граждане"
})

TEAM_BANKIR = DarkRP.createJob("Банкир", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/player/hostage/hostage_01.mdl",
		"models/player/hostage/hostage_02.mdl",
		"models/player/hostage/hostage_03.mdl",
		"models/player/hostage/hostage_04.mdl"
    },
    description = [[Банкир зарабатывает на выдаче кредитов и хранении принтеров.
    Учтите, что Вам придётся постоянно улучшать защиту своего бизнеса, иначе Вас могут ограбить и Ваш банк потеряет доверие жителей города.]],
    weapons = {},
    command = "bankir",
    modelScale = 1,
    max = 2,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Граждане"
})

TEAM_OXRANA = DarkRP.createJob("Охранник", {
    color = Color(243,188,13),
    model = {
        "models/player/odessa.mdl"
    },
    description = [[Нанимайтесь в охрану магазина, банка, предприятия или же частным телохранителем.
    Вы должны защищать заведение от хулиганов и мелких воров. 
    При сложной ситуации вызывайте полицию.]],
    weapons = {"weaponchecker"},
    command = "oxrana",
    modelScale = 1.2,
    max = 5,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Граждане",
    customCheck = function(ply) return ply:GetUserGroup() == "vip" or ply:GetUserGroup() == "moderator" or ply:IsAdmin() end, 
    CustomCheckFailMsg = "Прикупите привилегию VIP или выше!"
})

TEAM_RABOTNIKJEK = DarkRP.createJob("Работник ЖКХ", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/player/Group03/male_01.mdl",
        "models/player/Group03/Male_02.mdl",
        "models/player/Group03/male_03.mdl",
        "models/player/Group03/Male_04.mdl",
        "models/player/Group03/Male_05.mdl",
        "models/player/Group03/Male_06.mdl",
        "models/player/Group03/Male_07.mdl",
        "models/player/Group03/Male_08.mdl",
        "models/player/Group03/Male_09.mdl",
        "models/player/Group03/female_01.mdl",
        "models/player/Group03/Female_02.mdl",
        "models/player/Group03/Female_03.mdl",
        "models/player/Group03/Female_04.mdl",
        "models/player/Group03/Female_06.mdl",
    },
    description = [[Вы зарабатываете на ремонте инфраструктуры города.]],
    weapons = {"cityworker_pliers", "cityworker_shovel", "cityworker_wrench"},
    command = "rabotnikjek",
    modelScale = 1,
    max = 4,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Граждане"
})

-- Полиция
TEAM_POLICE = DarkRP.createJob("Патрульный", {
    color = Color(30, 30, 255),
    model = {"models/player/police.mdl", "models/player/police_fem.mdl"},
    description = [[Полицейский является защитником каждого гражданина, который живет в городе. 
    Вы можете выписывать штрафы, арестовать преступников и защитить невинный людей.]],
    weapons = {"arrest_stick", "stunstick", "door_ram", "weaponchecker", "bb_glock", "pocket"},
    command = "police",
    modelScale = 1,
    max = 5,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Полиция",
    PlayerSpawn = function(ply)
        ply:SetBodygroup(1, 0)
    end,
    PlayerLoadout = function(ply) ply:SetArmor(100) end,
    canDemote = true
})

TEAM_CHIEF = DarkRP.createJob("Начальник полиции", {
    color = Color(30, 30, 255),
    model = {"models/player/magnusson.mdl"},
    description = [[Начальник полиции руководит работой всего участка.
    Вы подчиняетесь только Мэру.]],
    weapons = {"arrest_stick", "unarrest_stick", "stunstick", "door_ram", "weaponchecker", "bb_deagle", "pocket"},
    command = "chief",
    modelScale = 1,
    max = 1,
    salary = 3000,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Полиция",
    PlayerSpawn = function(ply)
        ply:SetBodygroup(1, 2)
    end,
    canDemote = true
})

-- SWAT
TEAM_SWATSOLIDER = DarkRP.createJob("Штурмовик", {
    color = Color(45, 45, 45),
    model = "models/player/urban.mdl",
    description = [[Штурмовой отряд спецназ, выполняет зачистку и штурм особо опасной местности.]],
    weapons = {"arrest_stick", "stunstick", "door_ram", "weaponchecker", "bb_usp", "bb_m4a1", "bb_css_smoke", "pocket"},
    command = "swatsolider",
    modelScale = 1,
    max = 3,
    salary = 1200,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "SWAT",
    canDemote = true,
	PlayerSpawn = function(ply)
		ply:SetHealth(100)
		ply:SetMaxHealth(100)
		ply:SetArmor(100)
		ply:SetMaxArmor(100)
	end,
})

TEAM_SWATMEDIC = DarkRP.createJob("Врач", {
    color = Color(45, 45, 45),
    model = "models/player/gasmask.mdl",
    description = [[Выполняет поддержку штурмового отряда во время зачистки или штурма особо опасной местности.]],
    weapons = {"arrest_stick", "stunstick", "door_ram", "weaponchecker", "medkit", "bb_usp", "bb_mp5", "pocket"},
    command = "swatmedic",
    modelScale = 1,
    max = 1,
    salary = 1500,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "SWAT",
    canDemote = true,
    PlayerSpawn = function(ply)
        ply:SetHealth(100)
        ply:SetMaxHealth(100)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
    end,
})

TEAM_SWATSNIPER = DarkRP.createJob("Снайпер", {
    color = Color(45, 45, 45),
    model = "models/player/riot.mdl",
    description = [[Прикрывает своих товарищей во время штурма или зачистки особо опасной местности.]],
    weapons = {"arrest_stick", "stunstick", "door_ram", "weaponchecker", "bb_usp", "bb_scout", "pocket"},
    command = "swatsniper",
    modelScale = 1,
    max = 1,
    salary = 1700,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "SWAT",
    canDemote = true,
	PlayerSpawn = function(ply)
		ply:SetHealth(100)
		ply:SetMaxHealth(100)
		ply:SetArmor(100)
		ply:SetMaxArmor(100)
	end,
})

TEAM_SWATCOMANDER = DarkRP.createJob("Командир отделения", {
    color = Color(45, 45, 45),
    model = "models/player/swat.mdl",
    description = [[Командир отряда спецназ, корденирует работу подразделения и раздает указания как действовать в какой либо ситуции.
    Вы подчиняетесь только Мэру.]],
    weapons = {"arrest_stick", "stunstick", "door_ram", "weaponchecker", "bb_usp", "bb_m4a1", "bb_css_smoke", "pocket"},
    command = "swatcomander",
    modelScale = 1,
    max = 1,
    salary = 3200,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "SWAT",
    canDemote = true,
	PlayerSpawn = function(ply)
		ply:SetHealth(100)
		ply:SetMaxHealth(100)
		ply:SetArmor(100)
		ply:SetMaxArmor(100)
	end,
})

TEAM_SWATBERSERK = DarkRP.createJob("Берсерк (VIP)", {
    color = Color(243,188,13),
    model = "models/player/combine_soldier_prisonguard.mdl",
    description = [[Особый отряд спецназ, облаают большой стойкостью и живучестью.
    В боевых навыках Вам нет равных.]],
    weapons = {"arrest_stick", "stunstick", "door_ram", "weaponchecker", "bb_deagle", "bb_m249", "bb_cssfrag", "bb_css_smoke", "pocket"},
    command = "swatberserk",
    modelScale = 1.3,
    max = 2,
    salary = 2000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "SWAT",
    canDemote = true,
	customCheck = function(ply) return ply:GetUserGroup() == "vip" or ply:GetUserGroup() == "moderator" or ply:IsAdmin() end, 
    CustomCheckFailMsg = "Прикупите привилегию VIP или выше!",
	PlayerSpawn = function(ply)
		ply:SetHealth(250)
		ply:SetMaxHealth(250)
		ply:SetArmor(250)
		ply:SetMaxArmor(250)
	end,
})

-- Нацгвардия
TEAM_NACGUARIANMED = DarkRP.createJob("Медик", {
    color = Color(15, 100, 15),
    model = "models/player/dod_american.mdl",
    description = [[Вы служите в нацгвардии, оказываете медецинкую помощь своим сослуживцам]],
    weapons = {"stunstick", "weaponchecker", "medkit", "bb_fiveseven", "bb_galil"},
    command = "nacguardianmed",
    modelScale = 1,
    max = 2,
    salary = 1300,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Нацгвардия",
    PlayerSpawn = function(ply)
        ply:SetBodygroup(0, 5)
        ply:SetBodygroup(1, 0)
    end,
    PlayerLoadout = function(ply) ply:SetArmor(100) end,
    canDemote = true
})

TEAM_NACGUARIANSOLIDER = DarkRP.createJob("Солдат", {
    color = Color(15, 100, 15),
    model = "models/player/dod_american.mdl",
    description = [[Вы служите в нацгвардии. Выполняйте приказы командира.]],
    weapons = {"stunstick", "weaponchecker", "bb_fiveseven", "bb_galil", "bb_cssfrag", "bb_css_smoke"},
    command = "nacguardiansolider",
    modelScale = 1,
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Нацгвардия",
    PlayerSpawn = function(ply)
        ply:SetBodygroup(0, 1)
        ply:SetBodygroup(1, 0)
    end,
    PlayerLoadout = function(ply) ply:SetArmor(100) end,
    canDemote = true
})

TEAM_NACGUARIANCOMANDER = DarkRP.createJob("Командир нацгвардии", {
    color = Color(15, 100, 15),
    model = "models/player/dod_american.mdl",
    description = [[Вы руководите силами нацгвардии этого города.
    Задача нацгвардии обеспечивать безопастность города при особом положении города.
    Вы подчиняетесь только Мэру.]],
    weapons = {"stunstick", "weaponchecker", "bb_deagle", "bb_ak47", "bb_cssfrag", "bb_css_smoke"},
    command = "nacguardiancomander",
    modelScale = 1,
    max = 1,
    salary = 2900,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Нацгвардия",
    PlayerSpawn = function(ply)
        ply:SetBodygroup(0, 4)
        ply:SetBodygroup(1, 1)
    end,
    PlayerLoadout = function(ply) ply:SetArmor(100) end,
    canDemote = true
})

-- Криминал
TEAM_GANG = DarkRP.createJob("Бандит", {
    color = Color(100, 0, 0),
    model = {
        "models/player/group03/male_01.mdl",
        "models/player/Group03/Male_02.mdl",
        "models/player/Group03/male_03.mdl",
        "models/player/Group03/Male_04.mdl",
        "models/player/Group03/Male_05.mdl",
        "models/player/Group03/Male_06.mdl",
        "models/player/Group03/Male_07.mdl",
        "models/player/Group03/Male_08.mdl",
        "models/player/Group03/Male_09.mdl",
        "models/player/Group03/Female_01.mdl",
        "models/player/Group03/Female_02.mdl",
        "models/player/Group03/Female_03.mdl",
        "models/player/Group03/Female_04.mdl",
        "models/player/Group03/Female_06.mdl",},
    description = [[Низшая каста в криминальном мире. 
    Бандит обычно работает на авторитета, который заправляет всеми делами. 
    Воруйте, убивайте и выполняйте заданиям от авторитета.]],
    weapons = {"bb_glock"},
    command = "gangster",
    modelScale = 1,
    max = 10,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Криминал",
})

TEAM_MOB = DarkRP.createJob("Авторитет", {
    color = Color(100, 0, 0),
    model = "models/player/gman_high.mdl",
    description = [[Авторитет является самым уважаемым преступником в городе. 
    Он дает задания своим подчинённым бандитам и формирует эффективные преступные группировки.
    Он обладает способностью взламывать квартиры и выпускать из тюрем людей. 
    Организовывайте теракты, налеты, рейды совместно с бандитами.]],
    weapons = {"lockpick", "unarrest_stick", "bb_glock"},
    command = "mobboss",
    modelScale = 1,
    max = 1,
    salary = 100,
    admin = 0,
    vote = true,
    hasLicense = false,
    category = "Криминал",
})

-- Мафия
TEAM_MAFIA = DarkRP.createJob("Член мафии", {
    color = Color(75, 75, 75),
    model = {
        "models/player/Group03/female_03.mdl",
        "models/player/Group03/female_04.mdl",
        "models/player/Group03/female_05.mdl",
        "models/player/Group03/female_06.mdl"
    },
    description = [[Планируйте похищения, "крышуйте" бизнесы под себя, собирая с них процент.
    Вы подчиняетесь Дону мафии.]],
    weapons = {"bb_glock"},
    command = "mafia",
    modelScale = 1,
    max = 6,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Мафия"
})

TEAM_DONMAFIA = DarkRP.createJob("Дон мафии", {
    color = Color(75, 75, 75),
    model = {
        "models/player/gman_high.mdl"
    },
    description = [[Вы - один из двух главных криминальных единиц города.
    Планируйте грабежи и крупные похищения, рейд на мэрию или войну между семьями или мафией и бандитами.
    Держите город в страхе, давайте указания членам своей семьи.
    Если вы хотите основать свою семью, придумайте ей название и пропишите её через /job.]],
    weapons = {"lockpick", "unarrest_stick", "bb_glock"},
    command = "donmafia",
    modelScale = 1,
    max = 2,
    salary = 100,
    admin = 0,
    vote = true,
    hasLicense = false,
    category = "Мафия",
    PlayerDeath = function(ply, weapon, killer)
        if( ply:Team() == TEAM_DONMAFIA ) then
            ply:changeTeam( GAMEMODE.DefaultTeam, true )
            for k,v in pairs( player.GetAll() ) do
                v:PrintMessage( HUD_PRINTCENTER, "Глава мафии умер!" )
            end
        end
    end
})

-- Криминал
TEAM_HITMAN = DarkRP.createJob("Наемный убийца", {
    color = Color(100, 0, 0),
    model = "models/player/phoenix.mdl",
    description = [[Вы убиваете людей за деньги.
    Не можете убивать за бесплатно или просто так.
    Если рядом есть свидетели, то подождите пока жертва уйдёт из людного места или используйте снайперскую винтовку.]],
    weapons = {"bb_css_knife"},
    command = "hitman",
    modelScale = 1,
    max = 2,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    hobo = true,
    category = "Криминал"
})

TEAM_HITMANVIP = DarkRP.createJob("Киллер (VIP)", {
    color = Color(243,188,13),
    model = "models/player/leet.mdl",
    description = [[Вы убиваете людей за деньги.
    Не можете убивать за бесплатно или просто так.
    Если рядом есть свидетели, то подождите пока жертва уйдёт из людного места или используйте снайперскую винтовку.]],
    weapons = {"bb_css_knife", "bb_awp"},
    command = "hitmanvip",
    modelScale = 1,
    max = 2,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    hobo = true,
    category = "Криминал",
	customCheck = function(ply) return ply:GetUserGroup() == "vip" or ply:GetUserGroup() == "moderator" or ply:IsAdmin() end, 
    CustomCheckFailMsg = "Прикупите привилегию VIP или выше!",
})

TEAM_VOR = DarkRP.createJob("Вор", {
    color = Color(100, 0, 0),
    model = {
        "models/player/guerilla.mdl"        
    },
    description = [[Вор является частью криминальных структур.
    Вскрывайте двери и взламывайте кодовые замки.]],
    weapons = {"lockpick", "keypad_cracker"},
    command = "vor",
    modelScale = 1,
    max = 3,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Криминал"
})

TEAM_PROFECIONALVOR = DarkRP.createJob("Профессиональный вор (VIP)", {
    color = Color(243,188,13),
    model = {
        "models/player/arctic.mdl"
    },
    description = [[Вы можете грабить людей и взламывать дома!]],
    weapons = {"lockpick", "weapon_sh_keypadcracker_deploy", "bb_glock"},
    command = "profivor",
    modelScale = 1,
    max = 3,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Криминал",
	customCheck = function(ply) return ply:GetUserGroup() == "vip" or ply:GetUserGroup() == "moderator" or ply:IsAdmin() end, 
    CustomCheckFailMsg = "Прикупите привилегию VIP или выше!"
})

TEAM_CRAKCOOK = DarkRP.createJob("Химик", {
    color = Color(100, 0, 0),
    model = {
        "models/player/kleiner.mdl"
    },
    description = [[Варите крэк для продажи, следите за процессом варки и охраняйте своё имущество.
    Вы можете сотрудничать с бандитами, так же мафия может начать крышевать ваш бизнес.]],
    weapons = {},
    command = "crakcook",
    modelScale = 1,
    max = 3,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Криминал"
})

-- Правительство
TEAM_MAYOR = DarkRP.createJob("Мэр", {
    color = Color(0, 100, 200),
    model = "models/player/breen.mdl",
    description = [[Мэр города создает законы, чтобы улучшить жизнь людей в городе.
    Вы можете создавать или принимать ордера на обыск игроков.
    Во время Комендантского часа все люди должны быть в своих домах, а полицейские должны патрулировать город.]],
    weapons = {"arrest_stick", "unarrest_stick"},
    command = "mayor",
    modelScale = 1,
    max = 1,
    salary = 4500,
    admin = 0,
    vote = true,
    hasLicense = false,
    mayor = true,
    category = "Правительство",
    PlayerDeath = function(ply, weapon, killer)
        if( ply:Team() == TEAM_MAYOR ) then
            ply:changeTeam( GAMEMODE.DefaultTeam, true )
            for k,v in pairs( player.GetAll() ) do
                v:PrintMessage( HUD_PRINTCENTER, "Мэр умер!" )
            end
        end
    end
})

-- Остальное
TEAM_HOBO = DarkRP.createJob("Бездомный", {
    color = Color(255, 255, 255),
    model = "models/player/corpse1.mdl",
    description = [[Бездомный находится в самом низу общественного стоя. Над ним все смеются. 
    У вас нет дома. Вы вынуждены просить еду и деньги. Постройте дом из дощечек и подручного 
    мусора, чтобы укрыться от холода. Вы можете поставить ведро и написать на нем просьбу, 
    что бы вам подали денег. Проявите фантазию, устройте цирковое представление, спойте песню. 
    Таким образом вы можете получить больше денег.]],
    weapons = {"weapon_bugbait"},
    command = "hobo",
    modelScale = 1,
    max = 5,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    hobo = true,
    category = "Граждане",
})

if not DarkRP.disabledDefaults["modules"]["hungermod"] then
    TEAM_COOK = DarkRP.createJob("Повар", {
        color = Color(255, 255, 255),
        model = "models/player/mossman.mdl",
        description = [[Голодное общество нуждается в Вас! Организуйте маленький ларек и продавайте еду.]],
        weapons = {},
        command = "cook",
        modelScale = 1,
        category = "Граждане",
        max = 2,
        salary = 100,
        admin = 0,
        vote = false,
        hasLicense = false,
        cook = true
    })
end

TEAM_MODER = DarkRP.createJob("NONRP", {
   color = Color(36, 36, 36, 255),
   model = {"models/maxofs2d/balloon_gman.mdl"},
   description = [[Следите за правилами сервера. Запрещенно учавствовать в РП процессе.]],
   weapons = {},
   command = "nonrp",
   modelScale = 1,
   max = 0,
   salary = 0,
   admin = 1,
   vote = false,
   hasLicense = true,
   vip = true,
   category = "Другое",
   candemote = false,
   PlayerSpawn = function(ply)
       ply:GodEnable()
   end,
   customCheck = function(ply) return table.HasValue(stafflist, ply:GetNWString("usergroup")) end,
   CustomCheckFailMsg = "Вы не сотрудник!"
})

-- Совместимость отключенных работ
-- Гражданские
TEAM_CITIZEN             = TEAM_CITIZEN or -1
TEAM_GUN                 = TEAM_GUN or -1
TEAM_MEDIC               = TEAM_MEDIC or -1
TEAM_MINER               = TEAM_MINER or -1
TEAM_WOODMAN             = TEAM_WOODMAN or -1
TEAM_BANKIR              = TEAM_BANKIR or -1
TEAM_OXRANA              = TEAM_OXRANA or -1
TEAM_RABOTNIKJEK         = TEAM_RABOTNIKJEK or -1
-- Правительство
TEAM_MAYOR               = TEAM_MAYOR or -1
-- Полиция
TEAM_POLICE              = TEAM_POLICE or -1
TEAM_CHIEF               = TEAM_CHIEF or -1
-- SWAT
TEAM_SWATSOLIDER         = TEAM_SWATSOLIDER or -1
TEAM_SWATMEDIC           = TEAM_SWATMEDIC or -1
TEAM_SWATSNIPER          = TEAM_SWATSNIPER or -1
TEAM_SWATBERSERK         = TEAM_SWATBERSERK or -1
TEAM_SWATCOMANDER        = TEAM_SWATCOMANDER or -1
-- Нацгвардия
TEAM_NACGUARIANMED       = TEAM_NACGUARIANMED or -1
TEAM_NACGUARIANSOLIDER   = TEAM_NACGUARIANSOLIDER or -1
TEAM_NACGUARIANCOMANDER  = TEAM_NACGUARIANCOMANDER or -1
-- Мафия
TEAM_MAFIA               = TEAM_MAFIA or -1
TEAM_DONMAFIA            = TEAM_DONMAFIA or -1
-- Криминал
TEAM_GANG                = TEAM_GANG or -1
TEAM_MOB                 = TEAM_MOB or -1
TEAM_HITMAN              = TEAM_HITMAN or -1
TEAM_HITMANVIP           = TEAM_HITMANVIP or -1
TEAM_VOR                 = TEAM_VOR or -1
TEAM_PROFECIONALVOR      = TEAM_PROFECIONALVOR or -1
TEAM_CRAKCOOK            = TEAM_CRAKCOOK or -1
-- Другое
TEAM_HOBO                = TEAM_HOBO or -1
TEAM_COOK                = TEAM_COOK or -1

-- Группые дверей
AddDoorGroup("Правительство",       TEAM_MAYOR, TEAM_CHIEF, TEAM_SWATCOMANDER, TEAM_NACGUARIANCOMANDER)
AddDoorGroup("Мэрия",               TEAM_MAYOR, TEAM_CHIEF, TEAM_POLICE, TEAM_SWATCOMANDER, TEAM_SWATBERSERK, TEAM_SWATSNIPER, TEAM_SWATMEDIC, TEAM_SWATSOLIDER, TEAM_NACGUARIANCOMANDER, TEAM_NACGUARIANSOLIDER, TEAM_NACGUARIANMED)
AddDoorGroup("Полицейский участок", TEAM_MAYOR, TEAM_CHIEF, TEAM_POLICE, TEAM_SWATCOMANDER, TEAM_SWATBERSERK, TEAM_SWATSNIPER, TEAM_SWATMEDIC, TEAM_SWATSOLIDER)
AddDoorGroup("Камера",              TEAM_MAYOR, TEAM_CHIEF)
AddDoorGroup("Штаб",                TEAM_MAYOR, TEAM_NACGUARIANCOMANDER)
AddDoorGroup("Казармы",             TEAM_MAYOR, TEAM_NACGUARIANCOMANDER, TEAM_NACGUARIANSOLIDER, TEAM_NACGUARIANMED)
AddDoorGroup("КПП",                 TEAM_MAYOR, TEAM_NACGUARIANCOMANDER, TEAM_NACGUARIANSOLIDER, TEAM_NACGUARIANMED)
AddDoorGroup("ЖКХ",                 TEAM_RABOTNIKJEK)

-- Повестки
--DarkRP.createAgenda("Gangster's agenda", TEAM_MOB, {TEAM_GANG})
--DarkRP.createAgenda("Police agenda", {TEAM_MAYOR, TEAM_CHIEF}, {TEAM_POLICE})

-- Групповые чаты
--DarkRP.createGroupChat(function(ply) return ply:isCP() end)
--DarkRP.createGroupChat(TEAM_MOB, TEAM_GANG)
--DarkRP.createGroupChat(function(listener, ply) return not ply or ply:Team() == listener:Team() end)

-- Дефолтная профа
GAMEMODE.DefaultTeam = TEAM_CITIZEN

-- Список гос работ
GAMEMODE.CivilProtection = {
    -- Правительство
    [TEAM_MAYOR] = true,
    -- Полиция
    [TEAM_POLICE] = true,
    [TEAM_CHIEF] = true,
    -- SWAT
    [TEAM_SWATSOLIDER] = true,
    [TEAM_SWATMEDIC] = true,
    [TEAM_SWATSNIPER] = true,
    [TEAM_SWATBERSERK] = true,
    [TEAM_SWATCOMANDER] = true,
    -- Нацгвардия
    [TEAM_NACGUARIANMED] = true,
    [TEAM_NACGUARIANSOLIDER] = true,
    [TEAM_NACGUARIANCOMANDER] = true,
}

-- Наемные убийцы
DarkRP.addHitmanTeam(TEAM_HITMAN,TEAM_HITMANVIP)

-- Группы демоута
DarkRP.createDemoteGroup("Гос. структуры",      {TEAM_MAYOR, TEAM_CHIEF, TEAM_POLICE, TEAM_SWATCOMANDER, TEAM_SWATBERSERK, TEAM_SWATSNIPER, TEAM_SWATMEDIC, TEAM_SWATSOLIDER, TEAM_NACGUARIANCOMANDER, TEAM_NACGUARIANSOLIDER, TEAM_NACGUARIANMED})
DarkRP.createDemoteGroup("Полиция",             {TEAM_CHIEF, TEAM_POLICE, TEAM_SWATCOMANDER, TEAM_SWATBERSERK, TEAM_SWATSNIPER, TEAM_SWATMEDIC, TEAM_SWATSOLIDER})
DarkRP.createDemoteGroup("SWAT",                {TEAM_SWATCOMANDER, TEAM_SWATBERSERK, TEAM_SWATSNIPER, TEAM_SWATMEDIC, TEAM_SWATSOLIDER})
DarkRP.createDemoteGroup("Нацгвардия",          {TEAM_NACGUARIANCOMANDER, TEAM_NACGUARIANSOLIDER, TEAM_NACGUARIANMED})
DarkRP.createDemoteGroup("Правительство",       {TEAM_MAYOR, TEAM_SECRETARMAYOR})

-- Категории
DarkRP.createCategory{
    name = "Граждане",
    categorises = "jobs",
    startExpanded = true,
    color = Color(20, 150, 20, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 100,
}

DarkRP.createCategory{
    name = "Правительство",
    categorises = "jobs",
    startExpanded = true,
    color = Color(0, 100, 200),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

DarkRP.createCategory{
    name = "SWAT",
    categorises = "jobs",
    startExpanded = true,
    color = Color(45, 45, 45),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

DarkRP.createCategory{
    name = "Нацгвардия",
    categorises = "jobs",
    startExpanded = true,
    color = Color(15, 100, 15),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

DarkRP.createCategory{
    name = "Полиция",
    categorises = "jobs",
    startExpanded = true,
    color = Color(30, 30, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

DarkRP.createCategory{
    name = "Криминал",
    categorises = "jobs",
    startExpanded = true,
    color = Color(100, 0, 0),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

DarkRP.createCategory{
    name = "Мафия",
    categorises = "jobs",
    startExpanded = true,
    color = Color(75, 75, 75),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

DarkRP.createCategory{
    name = "Другое",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 255, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 255,
}
