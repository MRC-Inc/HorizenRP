function LockDown( ply, text, public )
    if (string.sub(text, 1, 4) == "/lkd") then
	if not ply:isMayor() then DarkRP.notify(ply, 1, 4, "У вас недостаточно привилегий!")	return "" end
	if GetGlobalBool("DarkRP_LockDown") then DarkRP.notify(ply, 1, 4,"Комендантский час уже идет!") return "" end
		if ply:GetNWBool("FilterLockDown") then  DarkRP.notify(ply, 1, 4, "Подождите несколько секунд!") return "" end
		if string.len(string.sub(text, 5, string.len(text))) < 30 and string.len(string.sub(text, 5, string.len(text))) > 3 then
				ply:SetNWBool("FilterLockDown",true) -- antispam
				timer.Create("T"..ply:SteamID64(),60,1,function() ply:SetNWBool("FilterLockDown",false) end)
				for _,self in pairs(player.GetAll()) do
				    self:ConCommand("play " .. GAMEMODE.Config.lockdownsound .. "\n")
				end
				DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))
				SetGlobalBool("DarkRP_LockDown", true)
				SetGlobalString("ReasonLockDown", string.sub(text, 6, string.len(text)))
			return ""
		else
			DarkRP.notify(ply, 1, 4, "Причина должна быть от 3 до 30 символов!")
			return ""
		end
    end
end
hook.Add( "PlayerSay", "LockDown", LockDown );

function TurnLockDownOff(p)
    if p:Team() == TEAM_MAYOR then
        SetGlobalBool("DarkRP_LockDown",false)
    end
end
 
hook.Add("PlayerDeath","On Death", TurnLockDownOff)
hook.Add("OnPlayerChangedTeam","On Change Team",TurnLockDownOff)
hook.Add("PlayerDisconnected","On disconnect",TurnLockDownOff)

function UnLockDown( ply, text, public )
    if (string.sub(text, 1, 6) == "/unlkd") then
	if not ply:isMayor() then DarkRP.notify(ply, 1, 4, "У вас недостаточно привилегий!") return "" end
	if !GetGlobalBool("DarkRP_LockDown") then DarkRP.notify(ply, 1, 4, "Комендантский час не начат!") return "" end
	DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_ended"))
				SetGlobalBool("DarkRP_LockDown",false)
			return ""
    end
end
hook.Add( "PlayerSay", "UnLockDown", UnLockDown );