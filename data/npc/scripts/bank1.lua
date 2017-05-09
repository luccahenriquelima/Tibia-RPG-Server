local keywordHandler = KeywordHandler:new() 
local npcHandler = NpcHandler:new(keywordHandler) 
NpcSystem.parseParameters(npcHandler) 

local talkState = {} 
local count = {} 
local transferTo_name = {} 

local balance_storage = 8996 

function onCreatureAppear(cid)                          npcHandler:onCreatureAppear(cid) end 
function onCreatureDisappear(cid)                       npcHandler:onCreatureDisappear(cid) end 
function onCreatureSay(cid, type, msg)  npcHandler:onCreatureSay(cid, type, msg) end 
function onThink()                                              npcHandler:onThink() end 

local function getCount(string) 
    local ret = -1 
    local b, e = string.find(string, "%d+") 
    if b ~= nil and e ~= nil then 
       ret = tonumber(string.sub(string, b, e)) 
    end 
    return ret 
end 

local function playerExists(name) 
        dofile("./config.lua") 
        if sqlType == "mysql" then 
                env = assert(luasql.mysql()) 
                con = assert(env:connect(mysqlDatabase, mysqlUser, mysqlPass, mysqlHost, mysqlPort)) 
        else 
                env = assert(luasql.sqlite3()) 
                con = assert(env:connect(sqliteDatabase)) 
        end 
        local cur = assert(con:execute("SELECT `name`, `id` FROM `players` WHERE `name` = '" .. escapeString(name) .. "';")) 
        local row = cur:fetch({}, "a") 
        cur:close() 
        if row ~= nil then 
                con:close() 
                env:close() 
                return row.name 
        end 
        con:close() 
        env:close() 
        return 0 
end 

local function transferGold(player, amount) 
        dofile("./config.lua") 
        if sqlType == "mysql" then 
                env = assert(luasql.mysql()) 
                con = assert(env:connect(mysqlDatabase, mysqlUser, mysqlPass, mysqlHost, mysqlPort)) 
        else -- sqlite 
                env = assert(luasql.sqlite3()) 
                con = assert(env:connect(sqliteDatabase)) 
        end 
        assert(con:execute("UPDATE `player_storage` SET `value` = `value` + '"..amount.."' WHERE `player_id` = (SELECT `id` FROM `players` WHERE `name` = '" .. escapeString(player) .. "') AND `key` = '8996'")) 
        con:close() 
        env:close() 
return TRUE 
end 

function greetCallback(cid) 
        talkState[cid] = 0 
        count[cid] = 0 
        transferTo_name[cid] = 0 
        return true 
end 

function creatureSayCallback(cid, type, msg) 

        if(not npcHandler:isFocused(cid)) then 
                return false 
        end 

        if getPlayerStorageValue(cid, balance_storage) == -1 then 
                setPlayerStorageValue(cid, balance_storage, 0) 
        end 

        if msgcontains(msg, 'balance') then 
                npcHandler:say("Your account balance is " .. getPlayerStorageValue(cid, balance_storage) .. " gold.", cid) 
                talkState[cid] = 0 
        elseif msgcontains(msg, 'deposit all') then 
                if getPlayerMoney(cid) > 0 then 
                        count[cid] = getPlayerMoney(cid) 
                        npcHandler:say("Would you really like to deposit " .. count[cid] .. " gold?", cid) 
                        talkState[cid] = 2 
                else 
                        npcHandler:say("Please tell me how much gold it is you would like to deposit.", cid) 
                        talkState[cid] = 1 
                end 
        elseif msgcontains(msg, 'deposit') then 
                if getCount(msg) == 0 then 
                        npcHandler:say("You are joking, aren't you??", cid) 
                        talkState[cid] = 0 
                elseif getCount(msg) ~= -1 then 
                        if getPlayerMoney(cid) >= getCount(msg) then 
                                count[cid] = getCount(msg) 
                                npcHandler:say("Would you really like to deposit " .. count[cid] .. " gold?", cid) 
                                talkState[cid] = 2 
                        else 
                                npcHandler:say("You do not have enough gold.", cid) 
                                talkState[cid] = 0 
                        end 
                else 
                        npcHandler:say("Please tell me how much gold it is you would like to deposit.", cid) 
                        talkState[cid] = 1 
                end 
        elseif talkState[cid] == 1 then 
                if getCount(msg) == -1 then 
                        npcHandler:say("Please tell me how much gold it is you would like to deposit.", cid) 
                        talkState[cid] = 1 
                else 
                        if getPlayerMoney(cid) >= getCount(msg) then 
                                count[cid] = getCount(msg) 
                                npcHandler:say("Would you really like to deposit " .. count[cid] .. " gold?", cid) 
                                talkState[cid] = 2 
                        else 
                                npcHandler:say("You do not have enough gold.", cid) 
                                talkState[cid] = 0 
                        end 
                end 
        elseif msgcontains(msg, 'yes') and talkState[cid] == 2 then 
                if getPlayerMoney(cid) >= count[cid] then 
                        doPlayerRemoveMoney(cid, count[cid]) 
                        setPlayerStorageValue(cid, balance_storage, getPlayerStorageValue(cid, balance_storage) + count[cid]) 
                        npcHandler:say("Alright, we have added the amount of " .. count[cid] .. " gold to your balance. You can withdraw your money anytime you want to.", cid) 
                        count[cid] = 0 
                        talkState[cid] = 0 
                else 
                        npcHandler:say("I am inconsolable, but it seems you have lost your gold. I hope you get it back.", cid) 
                        count[cid] = 0 
                        talkState[cid] = 0 
                end 
        elseif msgcontains(msg, 'no') and talkState[cid] == 2 then 
                npcHandler:say("As you wish. Is there something else I can do for you?", cid) 
                talkState[cid] = 0 
        elseif msgcontains(msg, 'withdraw') then 
                if getCount(msg) == 0 then 
                        npcHandler:say("Sure, you want nothing you get nothing!", cid) 
                        talkState[cid] = 0 
                elseif getCount(msg) ~= -1 then 
                        if getPlayerStorageValue(cid, balance_storage) >= getCount(msg) then 
                                count[cid] = getCount(msg) 
                                npcHandler:say("Are you sure you wish to withdraw " .. count[cid] .. " gold from your bank account?", cid) 
                                talkState[cid] = 4 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                talkState[cid] = 0 
                        end 
                else 
                        npcHandler:say("Please tell me how much gold you would like to withdraw.", cid) 
                        talkState[cid] = 3 
                end 
        elseif talkState[cid] == 3 then 
                if getCount(msg) == -1 then 
                        npcHandler:say("Please tell me how much gold you would like to withdraw.", cid) 
                        talkState[cid] = 3 
                else 
                        if getPlayerStorageValue(cid, balance_storage) >= getCount(msg) then 
                                count[cid] = getCount(msg) 
                                npcHandler:say("Are you sure you wish to withdraw " .. count[cid] .. " gold from your bank account?", cid) 
                                talkState[cid] = 4 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                talkState[cid] = 0 
                        end 
                end 
        elseif msgcontains(msg, 'yes') and talkState[cid] == 4 then 
                if getPlayerStorageValue(cid, balance_storage) >= count[cid] then 
                        doPlayerAddMoney(cid, count[cid]) 
                        setPlayerStorageValue(cid, balance_storage, getPlayerStorageValue(cid, balance_storage) - count[cid]) 
                        npcHandler:say("Here you are, " .. count[cid] .. " gold. Please let me know if there is something else I can do for you.", cid) 
                        count[cid] = 0 
                        talkState[cid] = 0 
                else 
                        npcHandler:say("There is not enough gold on your account.", cid) 
                        count[cid] = 0 
                        talkState[cid] = 0 
                end 
        elseif msgcontains(msg, 'no') and talkState[cid] == 4 then 
                npcHandler:say("The customer is king! Come back anytime you want to if you wish to withdraw your money.", cid) 
                talkState[cid] = 0 
        elseif msgcontains(msg, 'transfer') then 
                if getCount(msg) == 0 then 
                        npcHandler:say("Please think about it. Okay?", cid) 
                        talkState[cid] = 0 
                elseif getCount(msg) ~= -1 then 
                        count[cid] = getCount(msg) 
                        if getPlayerStorageValue(cid, balance_storage) >= count[cid] then 
                                npcHandler:say("Who would you like to transfer " .. count[cid] .. " gold to?", cid) 
                                talkState[cid] = 6 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        end 
                else 
                        npcHandler:say("Please tell me the amount of gold you would like to transfer.", cid) 
                        talkState[cid] = 5 
                end 
        elseif talkState[cid] == 5 then 
                if getCount(msg) == -1 then 
                        npcHandler:say("Please tell me the amount of gold you would like to transfer.", cid) 
                        talkState[cid] = 5 
                else 
                        count[cid] = getCount(msg) 
                        if getPlayerStorageValue(cid, balance_storage) >= count[cid] then 
                                npcHandler:say("Who would you like to transfer " .. count[cid] .. " gold to?", cid) 
                                talkState[cid] = 6 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        end 
                end 
        elseif talkState[cid] == 6 then 
                if isPlayer(getPlayerByName(msg)) == TRUE then 
                        if getPlayerStorageValue(cid, balance_storage) >= count[cid] then 
                                transferTo_name[cid] = msg 
                                npcHandler:say("Would you really like to transfer " .. count[cid] .. " gold to " .. transferTo_name[cid] .. "?", cid) 
                                talkState[cid] = 7 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        end 
                elseif string.lower(playerExists(msg)) == string.lower(msg) then 
                        if getPlayerStorageValue(cid, balance_storage) >= count[cid] then 
                                transferTo_name[cid] = msg 
                                npcHandler:say("Would you really like to transfer " .. count[cid] .. " gold to " .. playerExists(msg) .. "?", cid) 
                                talkState[cid] = 7 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        end 
                else 
                        npcHandler:say("This player does not exist.", cid) 
                        count[cid] = 0 
                        talkState[cid] = 0 
                end 
        elseif talkState[cid] == 7 and msgcontains(msg, 'yes') then 
                if isPlayer(getPlayerByName(transferTo_name[cid])) == TRUE then 
                        if getPlayerStorageValue(cid, balance_storage) >= count[cid] then 
                                setPlayerStorageValue(cid, balance_storage, getPlayerStorageValue(cid, balance_storage) - count[cid]) 
                                setPlayerStorageValue(getPlayerByName(transferTo_name[cid]), balance_storage, getPlayerStorageValue(getPlayerByName(transferTo_name[cid]), balance_storage) + count[cid]) 
                                
                                npcHandler:say("Very well. You have transferred " .. count[cid] .. " gold to " .. transferTo_name[cid] .. ".", cid) 
                                transferTo_name[cid] = 0 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                transferTo_name[cid] = 0 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        end 
                elseif string.lower(playerExists(transferTo_name[cid])) == string.lower(transferTo_name[cid]) then 
                        if getPlayerStorageValue(cid, balance_storage) >= count[cid] then 
                                setPlayerStorageValue(cid, balance_storage, getPlayerStorageValue(cid, balance_storage) - count[cid]) 
                                transferGold(transferTo_name[cid], count[cid]) 
                                npcHandler:say("Very well. You have transferred " .. count[cid] .. " gold to " .. playerExists(transferTo_name[cid]) .. ".", cid) 
                                transferTo_name[cid] = 0 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        else 
                                npcHandler:say("There is not enough gold on your account.", cid) 
                                transferTo_name[cid] = 0 
                                count[cid] = 0 
                                talkState[cid] = 0 
                        end 
                else 
                        npcHandler:say("This player does not exist.", cid) 
                        transferTo_name[cid] = 0 
                        count[cid] = 0 
                        talkState[cid] = 0 
                end 
        elseif talkState[cid] == 7 and msgcontains(msg, 'no') then 
                npcHandler:say("Alright, is there something else I can do for you?", cid) 
                transferTo_name[cid] = 0 
                count[cid] = 0 
                talkState[cid] = 0 
        elseif msgcontains(msg, 'change gold') then 
                npcHandler:say("How many platinum coins would you like to get?", cid) 
                talkState[cid] = 8 
        elseif talkState[cid] == 8 then 
                if getCount(msg) == -1 or getCount(msg) == 0 then 
                        npcHandler:say("Hmm, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                else 
                        count[cid] = getCount(msg) 
                        npcHandler:say("So you would like me to change " .. count[cid] * 100 .. " of your gold coins into " .. count[cid] .. " platinum coins?", cid) 
                        talkState[cid] = 9 
                end 
        elseif talkState[cid] == 9 then 
                if msgcontains(msg, 'yes') then 
                        if doPlayerRemoveItem(cid, 2148, count[cid] * 100) == TRUE then 
                                npcHandler:say("Here you are.", cid) 
                                doPlayerAddItem(cid, 2152, count[cid]) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        else 
                                npcHandler:say("Sorry, you do not have enough gold coins.", cid) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        end 
                else 
                        npcHandler:say("Well, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                end 
        elseif msgcontains(msg, 'change platinum') then 
                npcHandler:say("Would you like to change your platinum coins into gold or crystal?", cid) 
                talkState[cid] = 10 
                count[cid] = 0 
        elseif talkState[cid] == 10 then 
                if msgcontains(msg, 'gold') then 
                        npcHandler:say("How many platinum coins would you like to change into gold?", cid) 
                        talkState[cid] = 11 
                        count[cid] = 0 
                elseif msgcontains(msg, 'crystal') then 
                        npcHandler:say("How many crystal coins would you like to get?", cid) 
                        talkState[cid] = 13 
                        count[cid] = 0 
                else 
                        npcHandler:say("Well, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                end 
        elseif talkState[cid] == 11 then 
                if getCount(msg) == -1 or getCount(msg) == 0 then 
                        npcHandler:say("Hmm, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                else 
                        count[cid] = getCount(msg) 
                        npcHandler:say("So you would like me to change " .. count[cid] .. " of your platinum coins into " .. count[cid] * 100 .. " gold coins for you?", cid) 
                        talkState[cid] = 12 
                end 
        elseif talkState[cid] == 12 then 
                if msgcontains(msg, 'yes') then 
                        if doPlayerRemoveItem(cid, 2152, count[cid]) == TRUE then 
                                npcHandler:say("Here you are.", cid) 
                                doPlayerAddItem(cid, 2148, count[cid] * 100) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        else 
                                npcHandler:say("Sorry, you do not have enough platinum coins.", cid) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        end 
                else 
                        npcHandler:say("Well, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                end 
        elseif talkState[cid] == 13 then 
                if getCount(msg) == -1 or getCount(msg) == 0 then 
                        npcHandler:say("Hmm, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                else 
                        count[cid] = getCount(msg) 
                        npcHandler:say("So you would like me to change " .. count[cid] * 100 .. " of your platinum coins into " .. count[cid] .. " crystal coins for you?", cid) 
                        talkState[cid] = 14 
                end 
        elseif talkState[cid] == 14 then 
                if msgcontains(msg, 'yes') then 
                        if doPlayerRemoveItem(cid, 2152, count[cid] * 100) == TRUE then 
                                npcHandler:say("Here you are.", cid) 
                                doPlayerAddItem(cid, 2160, count[cid]) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        else 
                                npcHandler:say("Sorry, you do not have enough platinum coins.", cid) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        end 
                else 
                        npcHandler:say("Well, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                end 
        elseif msgcontains(msg, 'change crystal') then 
                npcHandler:say("How many crystal coins would you like to change into platinum?", cid) 
                talkState[cid] = 15 
        elseif talkState[cid] == 15 then 
                if getCount(msg) == -1 or getCount(msg) == 0 then 
                        npcHandler:say("Hmm, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                else 
                        count[cid] = getCount(msg) 
                        npcHandler:say("So you would like me to change " .. count[cid] .. " of your crystal coins into " .. count[cid] * 100 .. " platinum coins for you?", cid) 
                        talkState[cid] = 16 
                end 
        elseif talkState[cid] == 16 then 
                if msgcontains(msg, 'yes') then 
                        if doPlayerRemoveItem(cid, 2160, count[cid]) == TRUE then 
                                npcHandler:say("Here you are.", cid) 
                                doPlayerAddItem(cid, 2152, count[cid] * 100) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        else 
                                npcHandler:say("Sorry, you do not have enough crystal coins.", cid) 
                                talkState[cid] = 0 
                                count[cid] = 0 
                        end 
                else 
                        npcHandler:say("Well, can I help you with something else?", cid) 
                        talkState[cid] = 0 
                        count[cid] = 0 
                end 
        elseif msgcontains(msg, 'change') then 
                npcHandler:say("There are three different coin types in Tibia: 100 gold coins equal 1 platinum coin, 100 platinum coins equal 1 crystal coin. So if you'd like to change 100 gold into 1 platinum, simply say '{change gold}' and then '1 platinum'.", cid) 
        elseif msgcontains(msg, 'bank') then 
                npcHandler:say("We can change money for you. You can also access your bank account.", cid) 
        end 
        return TRUE 
end 

npcHandler:setCallback(CALLBACK_GREET, greetCallback) 
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback) 
npcHandler:addModule(FocusModule:new())