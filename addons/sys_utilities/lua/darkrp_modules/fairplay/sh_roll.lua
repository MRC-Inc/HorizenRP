local roll_message = " бросает кости, выпало "

hook.Add("PostGamemodeLoaded","luctus_roll",function()
  if not DarkRP then return end
  DarkRP.declareChatCommand{
    command = "roll",
    description = "Бросить кости.",
    delay = 1.5
  }
  if SERVER then
    local function roll_cmd(ply, args)
      local DoSay = function()
        if GAMEMODE.Config.alltalk then
          for k,target in pairs(player.GetAll()) do
            DarkRP.talkToPerson(target, team.GetColor(ply:Team()), ply:Nick()..roll_message..math.random(1,12)..".")
	  end
	else
          DarkRP.talkToRange(ply,ply:Nick()..roll_message..math.random(1,12)..".","",GAMEMODE.Config.talkDistance)
        end
      end
      return args, DoSay
    end
    DarkRP.defineChatCommand("roll", roll_cmd, true, 1.5)
  else
    --CLIENT
    DarkRP.addChatReceiver("/roll", "roll a dice", function(ply) return true end)
  end
end)