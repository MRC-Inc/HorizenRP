local text = Color(255, 255, 255)
local red = Color(78, 80, 101)

if (CLIENT) then
    local msgs = {
        "Группа ВКонтакте: https://vk.com/hzdarkrp",
        "Наш Discord: https://discord.com/invite/Mdx89zG9yt",
        "Наш сайт: https://horizen-rp.01g.info/",
        "Что-бы отправить жалобу на игрока используйте !report",
        "Нашему проекту требуются модераторы и администраторы. Возможно именно Вы нужны нам! Не стесняйтесь писать, рассматриваем все заявки. Оставляйте Вашу заявку на форуме."
    }

    local curmsg = 1

    timer.Create("fpadvertstimer", 200, 0, function()
        chat.AddText(red,'HorizenRP | ', text, msgs[curmsg])
        curmsg = curmsg + 1 > #msgs and 1 or curmsg + 1
    end)
end

if (SERVER) then
    timer.Simple(25, function()
        local function hasCSS()
            return IsMounted"cstrike" or file.IsDir("cstrike", "BASE_PATH") or file.Exists("models/props/cs_office/Exit_ceiling.mdl", "GAME")
        end

        if not hasCSS() then
            chat.AddText( red, "HorizenRP", text, " |", text, " У Вас не установлен контент Counter-Strike Source.")
            chat.AddText( red, "HorizenRP", text, " |", text, " Его установка исправит отображение некоторого контента!")
            chat.AddText( red, "HorizenRP", text, " |", text, " Ссылка на загрузку контента https://yadi.sk/d/Ju470WmOWX9vmQ")
        end
    end)
end