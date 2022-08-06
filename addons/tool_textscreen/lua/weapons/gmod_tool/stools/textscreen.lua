TOOL.Category = "HorizenRP - Инструменты"
TOOL.Name = "#tool.textscreen.name"
TOOL.Command = nil
TOOL.ConfigName = ""
local textBox = {}
local lineLabels = {}
local labels = {}
local sliders = {}
local rainbowCheckboxes = {}
local textscreenFonts = textscreenFonts
local rainbow_enabled = cvars.Number("ss_enable_rainbow", 1)

for i = 1, 5 do
	TOOL.ClientConVar["text" .. i] = ""
	TOOL.ClientConVar["size" .. i] = 20
	TOOL.ClientConVar["r" .. i] = 255
	TOOL.ClientConVar["g" .. i] = 255
	TOOL.ClientConVar["b" .. i] = 255
	TOOL.ClientConVar["a" .. i] = 255
	TOOL.ClientConVar["font" .. i] = 1
	TOOL.ClientConVar["rainbow" .. i] = 0
end

cleanup.Register("textscreens")

if (CLIENT) then
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" },
	}
	-- Add default english language strings here, in case no localisation exists
	language.Add("tool.textscreen.name", "3D2D Текст")
	language.Add("tool.textscreen.desc", "Создайте текст с несколькими строками, цветами и размерами шрифта.")
	language.Add("tool.textscreen.left", "Создать текст.") -- Does not work with capital T in tool. Same with right and reload.
	language.Add("tool.textscreen.right", "Обновить настройки текста.")
	language.Add("tool.textscreen.reload", "Копировать текст.")
	language.Add("Undone.textscreens", "Отменить текст")
	language.Add("Undone_textscreens", "Отменить текст")
	language.Add("Cleanup.textscreens", "Текст очищен")
	language.Add("Cleanup_textscreens", "Текст очищен")
	language.Add("Cleaned.textscreens", "Очистить весь текст")
	language.Add("Cleaned_textscreens", "Очистить весь текст")
	language.Add("SBoxLimit.textscreens", "Вы достигли предела текста!")
	language.Add("SBoxLimit_textscreens", "Вы достигли предела текста!")
end

function TOOL:LeftClick(tr)
	if (tr.Entity:GetClass() == "player") then return false end
	if (CLIENT) then return true end
	local ply = self:GetOwner()

	if hook.Run("PlayerSpawnTextscreen", ply, tr) == false then return false end

	if not (self:GetWeapon():CheckLimit("textscreens")) then return false end
	-- ensure at least 1 line of the textscreen has text before creating entity
	local hasText = false
	for i = 1, 5 do
		local text = self:GetClientInfo("text" .. i) or ""
		if text ~= "" then
			hasText = true
		end
	end
	if not hasText then return false end
	local textScreen = ents.Create("sammyservers_textscreen")
	textScreen:SetPos(tr.HitPos)
	local angle = tr.HitNormal:Angle()
	angle:RotateAroundAxis(tr.HitNormal:Angle():Right(), -90)
	angle:RotateAroundAxis(tr.HitNormal:Angle():Forward(), 90)
	textScreen:SetAngles(angle)
	textScreen:Spawn()
	textScreen:Activate()

	undo.Create("textscreens")
	undo.AddEntity(textScreen)
	undo.SetPlayer(ply)
	undo.Finish()
	ply:AddCount("textscreens", textScreen)
	ply:AddCleanup("textscreens", textScreen)

	for i = 1, 5 do
		textScreen:SetLine(
			i, -- Line
			self:GetClientInfo("text" .. i) or "", -- text
			Color( -- Color
				tonumber(self:GetClientInfo("r" .. i)) or 255,
				tonumber(self:GetClientInfo("g" .. i)) or 255,
				tonumber(self:GetClientInfo("b" .. i)) or 255,
				tonumber(self:GetClientInfo("a" .. i)) or 255
			),
			tonumber(self:GetClientInfo("size" .. i)) or 20,
			-- font
			tonumber(self:GetClientInfo("font" .. i)) or 1,

			rainbow_enabled == 1 and tonumber(self:GetClientInfo("rainbow" .. i)) or 0
		)
	end

	return true
end

function TOOL:RightClick(tr)
	if (tr.Entity:GetClass() == "player") then return false end
	if (CLIENT) then return true end
	local traceEnt = tr.Entity

	if (IsValid(TraceEnt) and traceEnt:GetClass() == "sammyservers_textscreen") then
		for i = 1, 5 do
			traceEnt:SetLine(
				i, -- Line
				tostring(self:GetClientInfo("text" .. i)), -- text
				Color( -- Color
					tonumber(self:GetClientInfo("r" .. i)) or 255,
					tonumber(self:GetClientInfo("g" .. i)) or 255,
					tonumber(self:GetClientInfo("b" .. i)) or 255,
					tonumber(self:GetClientInfo("a" .. i)) or 255
				),
				tonumber(self:GetClientInfo("size" .. i)) or 20,
				-- font
				tonumber(self:GetClientInfo("font" .. i)) or 1,

				rainbow_enabled and tonumber(self:GetClientInfo("rainbow" .. i)) or 0
			)
		end

		traceEnt:Broadcast()

		return true
	end
end

function TOOL:Reload(tr)
	local traceEnt = tr.Entity
	if (not isentity(traceEnt) or traceEnt:GetClass() ~= "sammyservers_textscreen") then return false end

	for i = 1, 5 do
		local linedata = traceEnt.lines[i]
		RunConsoleCommand("textscreen_r" .. i, linedata.color.r)
		RunConsoleCommand("textscreen_g" .. i, linedata.color.g)
		RunConsoleCommand("textscreen_b" .. i, linedata.color.b)
		RunConsoleCommand("textscreen_a" .. i, linedata.color.a)
		RunConsoleCommand("textscreen_size" .. i, linedata.size)
		RunConsoleCommand("textscreen_text" .. i, linedata.text)
		RunConsoleCommand("textscreen_font" .. i, linedata.font)
		RunConsoleCommand("textscreen_rainbow" .. i, linedata.rainbow)
	end

	return true
end

local conVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	
	local function TrimFontName(fontnum)
		return string.Left(textscreenFonts[fontnum], 8) == "Screens_" and string.TrimLeft(textscreenFonts[fontnum], "Screens_") or textscreenFonts[fontnum]
	end

	local changefont
	local fontnum = textscreenFonts[GetConVar("textscreen_font1"):GetInt()] ~= nil and GetConVar("textscreen_font1"):GetInt() or 1

	cvars.AddChangeCallback("textscreen_font1", function(convar_name, value_old, value_new)
		fontnum = textscreenFonts[tonumber(value_new)] ~= nil and tonumber(value_new) or 1
		local font = TrimFontName(fontnum)
		changefont:SetText("Изменить шрифт (" .. font .. ")")
	end)

	local function ResetFont(lines, text)
		if #lines >= 5 then
			fontnum = 1
			for i = 1, 5 do
				RunConsoleCommand("textscreen_font" .. i, 1)
			end
		end
		for k, i in pairs(lines) do
			if text then
				RunConsoleCommand("textscreen_text" .. i, "")
				labels[i]:SetText("")
			end
			labels[i]:SetFont(textscreenFonts[fontnum] .. "_MENU")
		end
	end

	resetall = vgui.Create("DButton", resetbuttons)
	resetall:SetSize(100, 25)
	resetall:SetText("Сбросить все")

	resetall.DoClick = function()
		local menu = DermaMenu()

		menu:AddOption("Сбросить цвет", function()
			for i = 1, 5 do
				RunConsoleCommand("textscreen_r" .. i, 255)
				RunConsoleCommand("textscreen_g" .. i, 255)
				RunConsoleCommand("textscreen_b" .. i, 255)
				RunConsoleCommand("textscreen_a" .. i, 255)
			end
		end)

		menu:AddOption("Сбросить размер", function()
			for i = 1, 5 do
				RunConsoleCommand("textscreen_size" .. i, 20)
				sliders[i]:SetValue(20)
				labels[i]:SetFont(textscreenFonts[fontnum] .. "_MENU")
			end
		end)

		menu:AddOption("Сбросить текстовые поля", function()
			for i = 1, 5 do
				RunConsoleCommand("textscreen_text" .. i, "")
				textBox[i]:SetValue("")
			end
		end)

		menu:AddOption("Сбросить шрифт", function()
			ResetFont({1, 2, 3, 4, 5}, false)
		end)

		if rainbow_enabled == 1 then
			menu:AddOption("Сбросить радужный текст", function()
				for i = 1, 5 do
					rainbowCheckboxes[i]:SetValue(0)
				end
			end)
		end

		menu:AddOption("Сбросить все", function()
			for i = 1, 5 do
				RunConsoleCommand("textscreen_r" .. i, 255)
				RunConsoleCommand("textscreen_g" .. i, 255)
				RunConsoleCommand("textscreen_b" .. i, 255)
				RunConsoleCommand("textscreen_a" .. i, 255)
				RunConsoleCommand("textscreen_size" .. i, 20)
				sliders[i]:SetValue(20)
				RunConsoleCommand("textscreen_text" .. i, "")
				RunConsoleCommand("textscreen_font" .. i, 1)
				textBox[i]:SetValue("")
				if rainbow_enabled == 1 then
					rainbowCheckboxes[i]:SetValue(0)
				end
			end
			ResetFont({1, 2, 3, 4, 5}, true)
		end)

		menu:Open()
	end

	CPanel:AddItem(resetall)
	resetline = vgui.Create("DButton")
	resetline:SetSize(100, 25)
	resetline:SetText("Сбросить линию")

	resetline.DoClick = function()
		local menu = DermaMenu()

		for i = 1, 5 do
			menu:AddOption("Сбросить линию " .. i, function()
				RunConsoleCommand("textscreen_r" .. i, 255)
				RunConsoleCommand("textscreen_g" .. i, 255)
				RunConsoleCommand("textscreen_b" .. i, 255)
				RunConsoleCommand("textscreen_a" .. i, 255)
				RunConsoleCommand("textscreen_size" .. i, 20)
				sliders[i]:SetValue(20)
				RunConsoleCommand("textscreen_text" .. i, "")
				textBox[i]:SetValue("")
				ResetFont({i}, true)
			end)
		end

		menu:AddOption("Сбросить все линии", function()
			for i = 1, 5 do
				RunConsoleCommand("textscreen_r" .. i, 255)
				RunConsoleCommand("textscreen_g" .. i, 255)
				RunConsoleCommand("textscreen_b" .. i, 255)
				RunConsoleCommand("textscreen_a" .. i, 255)
				RunConsoleCommand("textscreen_size" .. i, 20)
				sliders[i]:SetValue(20)
				RunConsoleCommand("textscreen_text" .. i, "")
				RunConsoleCommand("textscreen_font" .. i, 1)
				textBox[i]:SetValue("")
			end
			ResetFont({1, 2, 3, 4, 5}, true)
		end)

		menu:Open()
	end

	CPanel:AddItem(resetline)

	-- Change font
	changefont = vgui.Create("DButton")
	changefont:SetSize(100, 25)
	changefont:SetText("Изменить шрифт (" .. TrimFontName(fontnum) .. ")" )

	changefont.DoClick = function()
		local menu = DermaMenu()

		for i = 1, #textscreenFonts do
			local font = TrimFontName(i)
			menu:AddOption(font, function()
				fontnum = i
				for o = 1, 5 do
					RunConsoleCommand("textscreen_font" .. o, i)
					labels[o]:SetFont(textscreenFonts[fontnum] .. "_MENU")
				end
				changefont:SetText("Изменить шрифт (" .. font .. ")")
			end)
		end

		menu:Open()
	end

	CPanel:AddItem(changefont)

	CPanel:AddControl("ComboBox", {
		MenuButton = 1,
		Folder = "textscreen",
		Options = {
			["#preset.default"] = conVarsDefault
		},
		CVars = table.GetKeys(conVarsDefault)
	})

	for i = 1, 5 do
		lineLabels[i] = CPanel:AddControl("Label", {
			Text = "Линия " .. i,
			Description = "Линия " .. i
		})

		lineLabels[i]:SetFont("Default")

		CPanel:AddControl("Color", {
			Label = "Линия " .. i .. " Цвет шрифта",
			Red = "textscreen_r" .. i,
			Green = "textscreen_g" .. i,
			Blue = "textscreen_b" .. i,
			Alpha = "textscreen_a" .. i,
			ShowHSV = 1,
			ShowRGB = 1,
			Multiplier = 255
		})

		if rainbow_enabled == 1 then
			rainbowCheckboxes[i] = vgui.Create("DCheckBoxLabel")
			rainbowCheckboxes[i]:SetText("Радужный текст")
			rainbowCheckboxes[i]:SetTextColor(Color(0,0,0,255))
			rainbowCheckboxes[i]:SetConVar("textscreen_rainbow" .. i)
			rainbowCheckboxes[i]:SetTooltip("Включить радужный текст")
			rainbowCheckboxes[i]:SetValue(GetConVar("textscreen_rainbow" .. i):GetInt())
			CPanel:AddItem(rainbowCheckboxes[i])
		end

		sliders[i] = vgui.Create("DNumSlider")
		sliders[i]:SetText("Размер шрифта")
		sliders[i]:SetMinMax(20, 100)
		sliders[i]:SetDecimals(0)
		sliders[i]:SetValue(GetConVar("textscreen_size" .. i))
		sliders[i]:SetConVar("textscreen_size" .. i)

		CPanel:AddItem(sliders[i])
		textBox[i] = vgui.Create("DTextEntry")
		textBox[i]:SetUpdateOnType(true)
		textBox[i]:SetEnterAllowed(true)
		textBox[i]:SetConVar("textscreen_text" .. i)
		textBox[i]:SetValue(GetConVar("textscreen_text" .. i):GetString())

		textBox[i].OnTextChanged = function()
			labels[i]:SetText(textBox[i]:GetValue())
		end

		CPanel:AddItem(textBox[i])

		labels[i] = CPanel:AddControl("Label", {
			Text = #GetConVar("textscreen_text" .. i):GetString() >= 1 and GetConVar("textscreen_text" .. i):GetString() or "Линия " .. i,
			Description = "Линия " .. i
		})

		labels[i]:SetFont(textscreenFonts[fontnum] .. "_MENU")
		labels[i]:SetAutoStretchVertical(true)
		labels[i]:SetDisabled(true)
		labels[i]:SetHeight(50)

		labels[i].Think = function()
			labels[i]:SetColor(
				Color(
					GetConVar("textscreen_r" .. i):GetInt(),
					GetConVar("textscreen_g" .. i):GetInt(),
					GetConVar("textscreen_b" .. i):GetInt(),
					GetConVar("textscreen_a" .. i):GetInt()
				)
			)
		end
	end
end
