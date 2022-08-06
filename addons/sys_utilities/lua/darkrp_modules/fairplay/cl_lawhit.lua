AddCSLuaFile()
surface.CreateFont("NameDrawHUDFL", {
    font = "Arial",
    size = 150,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true
})


function DrawPosInfoFD(icon,pos, s)
	local d = math.floor(LocalPlayer():GetPos():Distance(pos)/100)
	local pos = pos:ToScreen()

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(Material(icon))
	surface.DrawTexturedRect(pos.x, pos.y, 16, 16)

	surface.SetFont( "ChatFont" )
	surface.SetTextColor(235, 203, 87, 255)
	surface.SetTextPos(pos.x + 20, pos.y)
	surface.DrawText(s)

	local x, y = surface.GetTextSize(s)

	surface.SetFont("Default" )
	surface.SetTextColor(0, 0, 0, 255)
	surface.SetTextPos(pos.x + 1 + 20, pos.y + y + 1)
	surface.DrawText("Дистанция: "..d.."m")

	surface.SetFont("Default" )
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(pos.x + 20, pos.y + y)
	surface.DrawText("Дистанция: "..d.."m")
end

hook.Add("HUDPaint", "PAINTUDFORFLAME", function()
	if LocalPlayer():isHitman() and LocalPlayer():hasHit() and IsValid(LocalPlayer():getHitTarget()) then
		DrawPosInfoFD("icon16/user_red.png",LocalPlayer():getHitTarget():EyePos(),LocalPlayer():getHitTarget():Nick())
	end
end) 


function DrawOutlineFD(w, h, t, col)
    draw.RoundedBox(0, 0, h - t, w, t, col)
    draw.RoundedBox(0, 0, h - h, w, t, col)
    draw.RoundedBox(0, w - t, 0, t, h, col)
    draw.RoundedBox(0, w - w, 0, t, h, col)
end

local blurmat = Material("pp/blurscreen")
function DrawBlurFD(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blurmat)

    for i = 1, 3 do
        blurmat:SetFloat("$blur", (i / 3) * (amount or 6))
        blurmat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

surface.CreateFont("MyFavoriteFont =3", {
    font = "Arial",
    size = (ScrW() + ScrH()) * .008,
    weight = 1000,
	shadow = true,
	outline = false,
})
surface.CreateFont("MyFavoriteFont =2", {
    font = "Arial",
    size = (ScrW() + ScrH()) * .006,
    weight = 1000,
	shadow = true,
	outline = false,
})

function ShowInfoFD(text,header)
	local pidor = vgui.Create("DFrame")
	pidor:SetSize(ScrW()*.3,ScrH()*.4)
	pidor:SetPos(ScrW()*.35,ScrH()*.45)
	pidor:SetTitle("")
	--pidor:MakePopup()

	pidor.Paint = function(self,w,h)
        DrawBlurFD(self, 5)
        DrawOutlineF(w, h, 1, Color(0, 0, 0, 255))
		draw.RoundedBox(0,0,0,w,h,Color(30,30,30,150))
		draw.SimpleText(header,"MyFavoriteFont =3",w/2,0,Color(255,255,255,200),1,0)
	end

	local ebanuytext = vgui.Create("RichText", pidor)
	ebanuytext:SetPos(pidor:GetWide()*.04, pidor:GetTall()*.08)
	ebanuytext:SetSize(pidor:GetWide()*.92, pidor:GetTall()*.9)

	--ebanuytext:SizeToContents()
	ebanuytext:InsertColorChange( 255,255,255,200 )
	ebanuytext:AppendText( text )
	ebanuytext.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(130,130,130,150))
	end
end

surface.CreateFont( "FlameFont", {
	font = "Cambria",
	size = (ScrW() + ScrH()) *.007,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

local function buildmenu()
    local lawboard = vgui.Create("DFrame")
    lawboard:SetPos(ScrW() / 4, ScrH() / 4)
    lawboard:SetSize( ScrW() / 2, ScrH() / 2 )
    lawboard:SetAlpha(0)
    lawboard:AlphaTo(255,0.5)
    lawboard:MakePopup()
    lawboard:ShowCloseButton(false)
    lawboard:SetTitle(" ")

    lawboard.Paint = function(self, w, h)
		DrawBlurFD(self, 5)
		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        draw.RoundedBox(0, 0, 0, w, 25, Color(0,0,0,150))
        draw.DrawText("Законы города!", "FlameFont", 5, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
		--for k,v in pairs(DarkRP.getLaws()) do
		--	surface.SetTextColor( 255,255,255,255 )
		--	surface.SetFont( "FlameFont" )
		--	surface.SetTextPos( 5, 28*k )
		--	surface.DrawText( k.."."..v )
		--end
    end

    local close = vgui.Create("DButton", lawboard)
    close:SetPos(lawboard:GetWide() - lawboard:GetWide()*.1, 0)
    close:SetSize(lawboard:GetWide()*.1, 25)
    close:SetText("")

    close.DoClick = function(self)
        self:Remove()
        lawboard:SetDraggable(false)

        lawboard:AlphaTo(0,0.25,0,function()
            lawboard:Remove()
        end)

        surface.PlaySound("buttons/button14.wav")
    end

    close.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 51, 51, 255))
        draw.SimpleText("X", "FlameFont", w / 2, h / 2, Color(255, 255, 255, 255), 1,1)
    end

	local lawscrol = vgui.Create("DScrollPanel",lawboard)
    lawscrol:SetPos(0,27)
    if LocalPlayer():isMayor() then
	    lawscrol:SetSize(lawboard:GetWide() - 4, lawboard:GetTall() - 25 - lawboard:GetTall() * .1)
	else
		lawscrol:SetSize(lawboard:GetWide() - 4, lawboard:GetTall() - 27)
	end

	lawscrol.VBar:SetWide(3)
    lawscrol:DockMargin(0, 0, 0, 0)

    local bar = lawscrol.VBar
    bar.Paint = function(this, w, h)
    end
    bar.btnUp.Paint = function(this, w, h)
    end
    bar.btnDown.Paint = function(this, w, h)
    end

    lawscrol.Paint = function(self,w,h)
    	--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,150))
    end
    for k,v in ipairs(DarkRP.getLaws()) do
		local label = vgui.Create("DLabel",lawscrol)
		label:SetFont("FlameFont")
		label:SetText(k .."."..v)
		label:Dock( TOP )
		label:DockMargin( 0, 2, 0, 0 )
		label:SizeToContents()
		label.Paint = function(self,w,h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,150))
		end
	end

	if LocalPlayer():isMayor() then
		local mayorbs = vgui.Create("DPanel",lawboard)
		mayorbs:SetPos(2,lawboard:GetTall() - lawboard:GetTall() * .1 + 4)
		mayorbs:SetSize(lawboard:GetWide() - 4, lawboard:GetTall() * .1 - 6)
		mayorbs.Paint = function(self,w,h)
			--draw.RoundedBox(0, 0, 0, w, h, Color(0,0,255,75))
		end

		local b1 = vgui.Create("DButton",mayorbs)
		b1:SetWide(mayorbs:GetWide()*.25 - 2)
		b1:Dock( LEFT )
		b1:DockMargin( 2, 2, 0, 0 )
		b1:SetText("")
		b1.Paint = function(self,w,h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,255))
			draw.SimpleText("Добавить закон", "FlameFont", w / 2, h / 2, Color(255, 255, 255, 255), 1,1)
		end
		b1.DoClick = function(self)
			surface.PlaySound("buttons/button14.wav")

			Derma_StringRequest("Добавить закон","Какой закон вы ходите добавить?", '', function(s)
				RunConsoleCommand("darkrp", "addlaw", s)
				lawboard:SetDraggable(false)
		        lawboard:AlphaTo(0,0.25,0,function()
		            lawboard:Remove()
		            buildmenu()
		        end)
			end)
		end

		local b2 = vgui.Create("DButton",mayorbs)
		b2:SetWide(mayorbs:GetWide()*.25 - 2)
		b2:Dock( LEFT )
		b2:DockMargin( 2, 2, 0, 0 )
		b2:SetText("")
		b2.Paint = function(self,w,h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,255))
			draw.SimpleText("Удалить закон", "FlameFont", w / 2, h / 2, Color(255, 255, 255, 255), 1,1)
		end
		b2.DoClick = function(self)
			surface.PlaySound("buttons/button14.wav")
			Derma_StringRequest("Удалить закон","Напишите номер закона который нужно удалить!", '', function(s)
				RunConsoleCommand("darkrp", "removelaw", s)
				lawboard:SetDraggable(false)
		        lawboard:AlphaTo(0,0.25,0,function()
		            lawboard:Remove()
		            buildmenu()
		        end)
			end)
		end

		local b3 = vgui.Create("DButton",mayorbs)
		b3:SetWide(mayorbs:GetWide()*.25 - 2)
		b3:Dock( LEFT )
		b3:DockMargin( 2, 2, 0, 0 )
		b3:SetText("")
		b3.Paint = function(self,w,h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,255))
			draw.SimpleText("Обнулить законы", "FlameFont", w / 2, h / 2, Color(255, 255, 255, 255), 1,1)
		end

		b3.DoClick = function(self)
			surface.PlaySound("buttons/button14.wav")
			RunConsoleCommand("darkrp", "resetlaws")
			lawboard:SetDraggable(false)
	        lawboard:AlphaTo(0,0.25,0,function()
	            lawboard:Remove()
	            buildmenu()
	        end)
		end
	end
end

concommand.Add( "lawboard", function(ply, cmd) 
	buildmenu()
end)