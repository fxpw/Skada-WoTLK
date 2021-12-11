local Skada = Skada
Skada:AddLoadableModule("Healthstones", function(L)
	if Skada:IsDisabled("Healthstones") then return end

	local mod = Skada:NewModule(L["Healthstones"])
	local stonename = GetSpellInfo(47874)
	local stonespells = {
		[27235] = true,
		[27236] = true,
		[27237] = true,
		[47872] = true,
		[47873] = true,
		[47874] = true,
		[47875] = true,
		[47876] = true,
		[47877] = true
	}

	local function log_healthstone(set, playerid, playername, playerflags)
		local player = Skada:GetPlayer(set, playerid, playername, playerflags)
		if player then
			player.healthstone = (player.healthstone or 0) + 1
			set.healthstone = (set.healthstone or 0) + 1
		end
	end

	local used = {}
	local function StoneUsed(_, eventtype, srcGUID, srcName, srcFlags, _, _, _, spellid, spellname)
		if (spellid and stonespells[spellid]) or spellname and spellname == stonename then
			log_healthstone(Skada.current, srcGUID, srcName, srcFlags)
		end
	end

	function mod:Update(win, set)
		win.title = self.moduleName

		local total = set.healthstone or 0
		if total > 0 then
			if win.metadata then
				win.metadata.maxvalue = 0
			end

			local nr = 1
			for _, player in ipairs(set.players) do
				if player.healthstone then
					local d = win.dataset[nr] or {}
					win.dataset[nr] = d

					d.id = player.id or player.name
					d.label = player.name
					d.class = player.class
					d.role = player.role
					d.spec = player.spec

					d.value = player.healthstone
					d.valuetext = Skada:FormatValueText(
						d.value,
						self.metadata.columns.Count,
						Skada:FormatPercent(d.value, total),
						self.metadata.columns.Percent
					)

					if win.metadata and d.value > win.metadata.maxvalue then
						win.metadata.maxvalue = d.value
					end
					nr = nr + 1
				end
			end
		end
	end

	function mod:OnEnable()
		stonename = stonename or GetSpellInfo(47874)
		self.metadata = {
			showspots = true,
			ordersort = true,
			columns = {Count = true, Percent = true},
			icon = [[Interface\Icons\inv_stone_04]]
		}
		Skada:RegisterForCL(StoneUsed, "SPELL_CAST_SUCCESS", {src_is_interesting = true})
		Skada:AddMode(self)
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end

	function mod:GetSetSummary(set)
		return set.healthstone or 0
	end
end)