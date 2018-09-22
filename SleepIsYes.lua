-------------------------------------------------------
-- Sleep Is Yes. Polling addon by Scientist-Shadowsong
-------------------------------------------------------

siyDB = siyDB or { scale = 1, hidden = false, lock = false, }
local locale = GetLocale()
local frame = nil
local window = nil
local results = nil
local votes = nil

local function siy_SavePosition()
    local point, _, relativePoint, xOfs, yOfs = window:GetPoint()
    if not siyDB.Position then
        siyDB.Position = {}
    end
    siyDB.Position.point = point
    siyDB.Position.relativePoint = relativePoint
    siyDB.Position.xOfs = xOfs
    siyDB.Position.yOfs = yOfs
end

local function siy_LoadPosition()
    if siyDB.Position then
        window:SetPoint(siyDB.Position.point,UIParent,siyDB.Position.relativePoint,siyDB.Position.xOfs,siyDB.Position.yOfs)
    else
        window:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end

local function siy_add_option(opt)
    local options = window.answers
    options.count = options.count + 1

    if opt == nil then
        opt = "Option "..tostring(options.count)
    end

    if window.answers[options.count] == nil then
        window.answers[options.count] = CreateFrame("EditBox", opt, window.polltitle, "InputBoxTemplate")
    end

    window.answers[options.count]:SetFrameStrata("MEDIUM")
    window.answers[options.count]:SetSize(240,30)
    window.answers[options.count]:SetPoint("BOTTOMLEFT", window.answers[options.count-1], 0,-30)
    window.answers[options.count]:SetWidth(240)
    window.answers[options.count]:SetText(opt)
    window.answers[options.count]:SetAutoFocus(false)
    window.answers[options.count]:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    local h = window:GetHeight()
    window:SetHeight(h+30)

    window.answers[options.count]:Show()
    window.answers.count = options.count

    siy_LoadPosition()
end

local function siy_reset()
    local x
    for x in ipairs(results.messages) do
        results.messages[x].vote:Hide();
        results.messages[x].vote:SetText(nil)
        results.messages[x].count:Hide();
        results.messages[x].count:SetText(nil)
        results.messages[x]:Hide();
    end

    for x in ipairs(window.answers) do
        if x > 2 then
            if window.answers[x] then
                window.answers[x]:SetText("")
                window.answers[x]:Hide()
            end
        end
    end
    window.answers.count = 2
    window:SetHeight(150)
    results:SetHeight(150)
end

local function siy_close_window()
    siy_reset()
    window:Hide()
    results:Hide()
end

local function siy_CreateResults()

    if results == nil then
        results = CreateFrame("Frame", nil, UIParent)
    end

    results:SetMovable(false)
    results:SetWidth(300)
    results:SetHeight(150)
    results:SetClampedToScreen(true)

    results:SetPoint("TOPLEFT", window, "TOPRIGHT")
    --results:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
    --results:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() siy_SavePosition() end end)

    if not results.texture then
        results.texture = results:CreateTexture(nil, "LOW")
    end
    results.texture:SetAllPoints(results)
    results.texture:SetTexture(nil)
    results.texture:SetColorTexture(0,0,0,0.8)

    if results.messages == nil then
        results.messages = {}
    end
    if not results.title then
        results.title = CreateFrame("Frame", nil, results)
    end
    results.title:SetWidth(300)
    results.title:SetHeight(30)
    results.title:SetPoint("TOPLEFT", results, "TOPLEFT")

    if not results.titlestring then
        results.titlestring = results.title:CreateFontString()
    end
    results.titlestring:SetWidth(300)
    results.titlestring:SetPoint("TOP", results.title, "TOP", 0,-15)
    results.titlestring:SetFontObject("ChatFontNormal")
    results.titlestring:SetText('')

    results.messages[0] = results.titlestring
    -- results.titlestring:SetTextColor(1,0,0,1)
end

local function siy_sendvote(index)
    C_ChatInfo.SendAddonMessage("SIYR", tostring(index), "GUILD");
end


local function siy_SendPoll()
    local bytecount = window.polltitle:GetNumLetters()
    for i, opt in ipairs(window.answers) do
        bytecount = bytecount + opt:GetNumLetters()
    end

    if bytecount > 250 then
        ChatFrame1:AddMessage("SIY Too many characters. Max 250 (question + answers)")
    else
        --ChatFrame1:AddMessage("sending poll with "..tostring(bytecount).." bytes")
        local msg = window.polltitle:GetText();

        for i, opt in ipairs(window.answers) do
            if opt:GetText() == nil or opt:GetText() == "" then break end
            msg = msg .. "\n" .. opt:GetText()
        end
        C_ChatInfo.SendAddonMessage("SIYP", msg, "GUILD");
    end
end

local function siy_CreateWindow()
    window = CreateFrame("Frame", nil, UIParent)
    window:SetMovable(true)
    window:SetWidth(300)
    window:SetHeight(120)
    window:SetClampedToScreen(true)
    window:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
    window:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() siy_SavePosition() end end)

    local texture = window:CreateTexture(nil, "LOW")
    texture:SetAllPoints(window)
    texture:SetTexture(nil)
    texture:SetColorTexture(0,0,0,0.8)
    window.texture = texture

    window.polltitle = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    window.polltitle:SetText("What do you want to do?")
    window.polltitle:SetAutoFocus(false)
    window.polltitle:SetFontObject("ChatFontNormal")
    window.polltitle:SetPoint("TOPLEFT", window, 15,-5)
    window.polltitle:SetWidth(240)
    window.polltitle:SetFrameStrata("MEDIUM")
    window.polltitle:SetSize(240,35)
    window.polltitle:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)


    window.answers = {}
    window.answers.count = 1
    window.answers[1] = CreateFrame("EditBox", nil, window.polltitle, "InputBoxTemplate")
    window.answers[1]:SetFrameStrata("MEDIUM")
    window.answers[1]:SetSize(240,30)
    window.answers[1]:SetPoint("BOTTOMLEFT", window.polltitle, 0,-30)
    window.answers[1]:SetWidth(240)
    window.answers[1]:SetText("Go to sleep")
    window.answers[1]:SetAutoFocus(false)
    window.answers[1]:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)


    --
    --
    --
    window.addoption = CreateFrame("Button", "plussbutton", window)
    window.addoption:SetText("+")
    window.addoption:SetSize(30, 30)
    window.addoption:SetNormalFontObject("ChatFontNormal")
    window.addoption:SetPoint("RIGHT", window.answers[1], 35, 0)
    window.addoption:SetFrameStrata("MEDIUM")

    window.addoption:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
    window.addoption:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
    window.addoption:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")

    window.addoption:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.addoption:GetNormalTexture():SetAllPoints()
    window.addoption:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.addoption:GetHighlightTexture():SetAllPoints()
    window.addoption:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.addoption:GetPushedTexture():SetAllPoints()

    window.addoption:SetScript("OnClick", function(self) siy_add_option(nil) end)

    --
    --
    --
    window.submit = CreateFrame("Button", "submitbutton", window)
    window.submit:SetText("Submit Poll!")
    window.submit:SetSize(100, 30)
    window.submit:SetNormalFontObject("ChatFontNormal")
    window.submit:SetPoint("BOTTOM", window, 0, 10)
    window.submit:SetFrameStrata("MEDIUM")

    window.submit:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
    window.submit:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
    window.submit:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")

    window.submit:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.submit:GetNormalTexture():SetAllPoints()
    window.submit:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.submit:GetHighlightTexture():SetAllPoints()
    window.submit:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.submit:GetPushedTexture():SetAllPoints()

    window.submit:SetScript("OnClick", siy_SendPoll)

    ---
    --
    --
    window.addoption = CreateFrame("Button", "closebutton", window)
    window.addoption:SetText("X")
    window.addoption:SetSize(30, 30)
    window.addoption:SetNormalFontObject("ChatFontNormal")
    window.addoption:SetPoint("BOTTOMLEFT", window, 5, 10)
    window.addoption:SetFrameStrata("MEDIUM")

    window.addoption:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
    window.addoption:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
    window.addoption:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")

    window.addoption:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.addoption:GetNormalTexture():SetAllPoints()
    window.addoption:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.addoption:GetHighlightTexture():SetAllPoints()
    window.addoption:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    window.addoption:GetPushedTexture():SetAllPoints()

    window.addoption:SetScript("OnClick", function(self) siy_close_window() end)

    --window.polltitle:Show()

    --window:SetPoint("CENTER", 0,0)
    siy_add_option("Continue raiding")
    window:Show()

    siy_LoadPosition()
end


    -- results.messages = {}
    -- results.title = CreateFrame("Frame", nil, results)
    -- results.title:SetWidth(300)

    -- results.title:SetHeight(30)
    -- results.title:SetPoint("TOPLEFT", results, "TOPLEFT")

    -- results.titlestring = results.title:CreateFontString()
    -- results.titlestring:SetPoint("TOP", results.title, "TOP", 0,-15)
    -- results.titlestring:SetFontObject("ChatFontNormal")
    -- results.titlestring:SetText('temp question')

local function siy_CHAT_MSG_ADDON(prefix, message, dist, sender)
    ChatFrame1:AddMessage("PREFIX "..prefix.." _msg_ "..message.." _dist_"..dist.." _sender_ "..sender )
    if prefix == "SIYP" then
        ChatFrame1:AddMessage("PREFIX "..prefix.." _msg_ "..message.." _dist_"..dist.." _sender_ "..sender )


        local mtable = {}
        local i = 0

        while true do
            i = string.find(message, "\n", i+1)
            if i == nil then break end
            table.insert(mtable, i)
        end
        table.insert(mtable, -1)

        results.titlestring:SetText(string.sub(message, 1, mtable[1]-1))

        local x
        for x in ipairs(mtable) do
            local offset = 1
            --ChatFrame1:AddMessage(mtable[x])

            if mtable[x] == -1 then break end
            if mtable[x+1] == -1 then offset = 0 end
            local search = string.sub(message, mtable[x]+1, mtable[x+1] - offset)

            --ChatFrame1:AddMessage(search)
            if results.messages[x] == nil then
                results.messages[x] = results.title:CreateFontString()
                results.messages[x]:SetPoint("TOP", results.messages[x-1], "TOP", 0, -30)
                results.messages[x]:SetFontObject("ChatFontNormal")
                results.messages[x]:SetWidth(300)
                --results.messages[x]:SetJustifyH("LEFT")
                if x > 2 then
                    local h = results:GetHeight()
                    results:SetHeight(h+30)
                end

                results.messages[x].vote = CreateFrame("Button", "votebutton"..tostring(x), window)
                results.messages[x].vote:SetSize(100, 30)
                results.messages[x].vote:SetNormalFontObject("ChatFontNormal")
                results.messages[x].vote:SetPoint("TOP", results.messages[x], "TOP", 0, 0)
                results.messages[x].vote:SetFrameStrata("MEDIUM")

                results.messages[x].count = results.title:CreateFontString()
                results.messages[x].count:SetPoint("RIGHT", results.messages[x].vote, "RIGHT", 80, 0)
                results.messages[x].count:SetFontObject("ChatFontNormal")
                results.messages[x].count:SetWidth(300)
                results.messages[x].count:SetJustifyH("RIGHT")

                results.messages[x].vote:SetScript("OnClick", function(self) siy_sendvote(x) end)

            end
            results.messages[x].count:SetText("0")
            results.messages[x].vote:SetText(search)

            results.messages[x].vote:Show();
            results.messages[x].count:Show();
            results.messages[x]:Show();
            --results.messages[x]:SetText(search)

        end

    elseif prefix == "SIYR" then

        --ChatFrame1:AddMessage("PREFIX "..prefix.." _msg_ "..message.." _dist_"..dist.." _sender_ "..sender )
        --ChatFrame1:AddMessage(tostring(tonumber(message)))

        local count
        local index = tonumber(message)

        if index then
            count = tonumber(results.messages[index].count:GetText())
        end
        if count then
            results.messages[index].count:SetText(tostring(count+1))
        end
    end
end


local function siy_PLAYER_ENTERING_WORLD(self)

end

local function SleepIsYes_Command()
    if window:IsVisible() then
        siy_reset();
        window:Hide()
        results:Hide()
    else
        siy_reset();
        window:Show();
        results:Show();
    end
end

local function siy_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHAT_MSG_ADDON")

    local ok = C_ChatInfo.RegisterAddonMessagePrefix("SIYP")
    if ok then
        ChatFrame1:AddMessage("Registered SIYP")
        ok = C_ChatInfo.RegisterAddonMessagePrefix("SIYR")
        if ok then
            ChatFrame1:AddMessage("Registered SIYR")
        end
    end

    siy_CreateWindow()
    siy_CreateResults()

    SlashCmdList["SleepIsYes"] = SleepIsYes_Command
    SLASH_SleepIsYes1 = "/siy"

    local regpre = C_ChatInfo.GetRegisteredAddonMessagePrefixes()
    ChatFrame1:AddMessage(regpre)
    ChatFrame1:AddMessage("siy by Scientist",0,1,0)
end

local eventhandler = {
    ["VARIABLES_LOADED"] = function(self) siy_OnLoad(self) end,
    ["PLAYER_ENTERING_WORLD"] = function(self) siy_PLAYER_ENTERING_WORLD(self) end,
    ["CHAT_MSG_ADDON"] = function(self,...) siy_CHAT_MSG_ADDON(...) end,
}

local function siy_OnEvent(self,event,...)
    eventhandler[event](self,...)
end

frame = CreateFrame("Frame",nil,UIParent)
frame:SetScript("OnEvent", siy_OnEvent)
frame:RegisterEvent("VARIABLES_LOADED")
