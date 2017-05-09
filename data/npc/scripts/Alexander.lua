local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()							npcHandler:onThink()                    	end

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

-- Runas
shopModule:addBuyableItem({'animate dead rune'}, 2316, 375, 'animate dead rune')
shopModule:addBuyableItem({'blank'}, 2260, 10, 'blank rune')
shopModule:addBuyableItem({'desintegrate rune'}, 2310, 26, 'desintegrate rune')
shopModule:addBuyableItem({'energy bomb rune'}, 2262, 162, 'energy bomb rune')
shopModule:addBuyableItem({'fireball rune'}, 2302, 30, 'fireball rune')
shopModule:addBuyableItem({'holy missile rune'}, 2295, 16, 'holy missile rune')
shopModule:addBuyableItem({'icicle rune'}, 2271, 30, 'icicle rune')
shopModule:addBuyableItem({'magic wall rune'}, 2293, 116, 'magic wall rune')
shopModule:addBuyableItem({'paralyze rune'}, 2278, 700, 'paralyze rune')
shopModule:addBuyableItem({'poison bomb rune'}, 2286, 85, 'poison bomb rune')
shopModule:addBuyableItem({'soulfire rune'}, 2308, 46, 'soulfire rune')
shopModule:addBuyableItem({'stone shower rune'}, 2288, 37, 'stone shower rune')
shopModule:addBuyableItem({'thunderstorm rune'}, 2315, 37, 'thunderstorm rune')
shopModule:addBuyableItem({'wild growth rune'}, 2269, 160, 'wild growth rune')

-- Wands
shopModule:addBuyableItem({'wand of vortex'}, 2190, 500, 'wand of vortex')
shopModule:addBuyableItem({'wand of dragonbreath'}, 2191, 1000, 'wand of dragonbreath')
shopModule:addBuyableItem({'wand of decay'}, 2188, 5000, 'wand of decay')
shopModule:addBuyableItem({'wand of cosmic energy'}, 2189, 10000, 'wand of cosmic energy')

-- Rods
shopModule:addBuyableItem({'hailstorm rod', 'hailstorm'}, 2183, 15000, 'hailstorm rod')
shopModule:addBuyableItem({'snakebite rod', 'snakebite'}, 2182, 500, 'snakebite rod')
shopModule:addBuyableItem({'moonlight rod', 'moonlight'}, 2186, 1000, 'moonlight rod')
shopModule:addBuyableItem({'necrotic rod', 'necrotic'}, 2185, 5000, 'necrotic rod')
shopModule:addBuyableItem({'northwind rod', 'northwind'}, 8911, 7500, 'northwind rod')
shopModule:addBuyableItem({'springsprout rod', 'springsprout'}, 8912, 18000, 'springsprout rod')
shopModule:addBuyableItem({'terra rod', 'terra'}, 2181, 10000, 'terra rod')

-- Outros
shopModule:addBuyableItem({'spellbook'}, 2175, 150, 'spellbook')
shopModule:addBuyableItem({'life ring'}, 2168, 900, 'life ring')
shopModule:addBuyableItem({'crystal ball', 'crystal ball'}, 2192, 530, 'crystal ball')
shopModule:addSellableItem({'spellbook of enlightenment', 'spellbook of enlightenment'}, 8900, 4000, 'spellbook of enlightenment')
shopModule:addSellableItem({'spellbook of warding', 'spellbook of warding'}, 8901, 8000, 'spellbook of warding')
shopModule:addSellableItem({'spellbook of mind control', 'spellbook of mind control'}, 8902, 13000, 'spellbook of mind control')
shopModule:addSellableItem({'spellbook of lost souls', 'spellbook of lost souls'}, 8903, 19000, 'spellbook of lost souls')
shopModule:addSellableItem({'crystal ball', 'crystal ball'}, 2192, 190, 'crystal ball')
shopModule:addSellableItem({'life crystal', 'life crystal'}, 2177, 85, 'life crystal')
shopModule:addSellableItem({'mind Stone', 'mind Stone'}, 2178, 170, 'mind stone')
shopModule:addSellableItem({'spellwand'}, 7735, 299, 'spellwand')

function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end
	end	

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())