if (CLIENT) then
    local text = Color(255, 255, 255)
    local lime = Color(186, 41, 41)
    local orange = Color(186, 41, 41)
    local red = Color(186, 41, 41)
    local gold = Color(186, 41, 41)
    local yellow = Color(186, 41, 41)

    local msgs = {
        "Группа ВКонтакте: https://vk.com/fairplay_gm",
        "Наш Discord: https://discord.com/invite/pXpPVPTGqD",
        "Наш сайт: https://fp-gaming.ru/",
        "Что-бы отправить жалобу на игрока используйте !report",
        "В разделе настроек можно найти много полезных функций (FPS Boost, Интерфейс и т.п)",
        "Нашему проекту требуются модераторы и администраторы. Возможно именно Вы нужны нам! Не стесняйтесь писать, рассматриваем все заявки. Оставляйте Вашу заявку - https://fp-gaming.ru/appadmin"
    }

    local curmsg = 1

    timer.Create("fpadvertstimer", 200, 0, function()
        chat.AddText(red,'FairPlay | ', Color(255,255,255), msgs[curmsg])
        curmsg = curmsg + 1 > #msgs and 1 or curmsg + 1
    end)
end

if (SERVER) then
    timer.Simple(25, function()
        local function hasCSS()
            return IsMounted"cstrike" or file.IsDir("cstrike", "BASE_PATH") or file.Exists("models/props/cs_office/Exit_ceiling.mdl", "GAME")
        end

        if not hasCSS() then
            chat.AddText( Color(186, 41, 41), "FairPlay", Color(255, 255, 255), " |", Color(255, 255, 255), " У Вас не установлен контент Counter-Strike Source.")
            chat.AddText( Color(186, 41, 41), "FairPlay", Color(255, 255, 255), " |", Color(255, 255, 255), " Его установка исправит отображение некоторого контента!")
            chat.AddText( Color(186, 41, 41), "FairPlay", Color(255, 255, 255), " |", Color(255, 255, 255), " Ссылка на загрузку контента https://yadi.sk/d/Ju470WmOWX9vmQ")
        end
    end)
end