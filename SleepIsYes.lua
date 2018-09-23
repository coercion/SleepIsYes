-------------------------------------------------------
-- Sleep Is Yes. Polling addon by Scientist-Shadowsong
-------------------------------------------------------

siyDB = siyDB or { scale = 1, hidden = false, lock = false, }
local locale = GetLocale()
local topframe = nil
local frame = nil
local window = nil
local results = nil
local votes = nil

local function siy_SavePosition()
    local point, _, relativePoint, xOfs, yOfs = topframe:GetPoint()
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
        topframe:SetPoint(siyDB.Position.point,UIParent,siyDB.Position.relativePoint,siyDB.Position.xOfs,siyDB.Position.yOfs)
    else
        topframe:SetPoint("TOPLEFT", UIParent, "CENTER")
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
    h = topframe:GetHeight()
    topframe:SetHeight(h+30)

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
    topframe:SetHeight(200)
end

local function siy_close_window()
    siy_reset()
    topframe:Hide();
    --window:Hide()
    --results:Hide()
end

local function siy_CreateResults()

    if results == nil then
        results = CreateFrame("Frame", nil, topframe)
    end

    results:SetMovable(false)
    results:SetWidth(300)
    results:SetHeight(150)
    results:SetClampedToScreen(true)

    results:SetPoint("TOPLEFT", topframe, "TOPLEFT", 0, -50)
    --results:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
    --results:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() siy_SavePosition() end end)

    if not results.texture then
        results.texture = results:CreateTexture(nil, "LOW")
    end
    results.texture:SetAllPoints(results)
    results.texture:SetTexture(nil)
    --results.texture:SetColorTexture(0,0,0,0.8)

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
    results:Hide()
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

local function siy_CreateTopFrame()
    topframe = CreateFrame("Frame", nil, UIParent)
    topframe:SetMovable(true)
    topframe:SetWidth(300)
    topframe:SetHeight(170)
    topframe:SetFrameStrata("LOW")
    topframe:SetClampedToScreen(true)

    --topframe:SetPoint("TOPLEFT", UIParent, "CENTER")
    topframe:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
    topframe:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() siy_SavePosition() end end)

    topframe.texture = topframe:CreateTexture(nil, "LOW")
    topframe.texture:SetAllPoints(topframe)
    topframe.texture:SetTexture(nil)
    topframe.texture:SetColorTexture(0,0,0,0.8)



    topframe.tab1 = CreateFrame("Button", "tab1", topframe)
    topframe.tab1:SetText("Create Poll")
    topframe.tab1:SetSize(115, 25)
    topframe.tab1:SetNormalFontObject("ChatFontNormal")
    topframe.tab1:SetPoint("TOPLEFT", topframe, 10, -10)
    topframe.tab1:SetFrameStrata("MEDIUM")
    topframe.tab1:SetScript("OnClick", function(self) window:Show(); results:Hide(); end)

    local texture = topframe.tab1:CreateTexture(nil, "LOW")
    texture:SetTexture(nil)
    texture:SetColorTexture(0.5,0.5,0.5,0.3)
    texture:SetAllPoints()
    texture:SetAllPoints(topframe.tab1)

    topframe.tab2 = CreateFrame("Button", "tab2", topframe)
    topframe.tab2:SetText("Results")
    topframe.tab2:SetSize(115, 25)
    topframe.tab2:SetNormalFontObject("ChatFontNormal")
    topframe.tab2:SetPoint("LEFT", topframe.tab1, "RIGHT", 10, 0)
    topframe.tab2:SetFrameStrata("MEDIUM")
    topframe.tab2:SetScript("OnClick", function(self) results:Show(); window:Hide(); end)

    local texture2 = topframe.tab2:CreateTexture(nil, "LOW")
    texture2:SetTexture(nil)
    texture2:SetColorTexture(0.5,0.5,0.5,0.3)
    texture2:SetAllPoints()
    texture2:SetAllPoints(topframe.tab2)


    topframe.close = CreateFrame("Button", "closebutton", topframe)
    topframe.close:SetText("X")
    topframe.close:SetSize(30, 25)
    topframe.close:SetNormalFontObject("ChatFontNormal")
    topframe.close:SetPoint("LEFT", topframe.tab2, "RIGHT", 10, 0)
    topframe.close:SetFrameStrata("MEDIUM")

    local texture3 = topframe.close:CreateTexture(nil, "LOW")
    texture3:SetTexture(nil)
    texture3:SetColorTexture(0.5,0.5,0.5,0.3)
    texture3:SetAllPoints()
    texture3:SetAllPoints(topframe.close)

    topframe.close:SetScript("OnClick", function(self) siy_close_window() end)



    siy_LoadPosition()
    topframe:Show()

end

local function siy_CreateWindow()
    window = CreateFrame("Frame", nil, topframe)
    --window:SetMovable(true)
    window:SetWidth(300)
    window:SetHeight(120)
    --window:SetClampedToScreen(true)
    --window:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
    --window:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() siy_SavePosition() end end)


    window:SetPoint("TOPLEFT", topframe, "TOPLEFT", 0, -50)

    local texture = window:CreateTexture(nil, "LOW")
    texture:SetAllPoints(window)
    texture:SetTexture(nil)
    --texture:SetColorTexture(0,0,0,0.8)
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

    window.addoption.texture = window.addoption:CreateTexture(nil, "LOW")
    window.addoption.texture:SetTexture(nil)
    window.addoption.texture:SetColorTexture(0.5,0.5,0.5,0.3)
    window.addoption.texture:SetAllPoints()

    -- window.addoption:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
    -- window.addoption:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
    -- window.addoption:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")

    -- window.addoption:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    -- window.addoption:GetNormalTexture():SetAllPoints()
    -- window.addoption:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    -- window.addoption:GetHighlightTexture():SetAllPoints()
    -- window.addoption:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    -- window.addoption:GetPushedTexture():SetAllPoints()

    window.addoption:SetScript("OnClick", function(self) siy_add_option(nil) end)

    --
    --
    --
    window.submit = CreateFrame("Button", "submitbutton", window)
    window.submit:SetText("Submit Poll!")
    window.submit:SetSize(280, 25)
    window.submit:SetNormalFontObject("ChatFontNormal")
    window.submit:SetPoint("BOTTOM", window, 0, 10)
    window.submit:SetFrameStrata("MEDIUM")

    local texture1 = window.submit:CreateTexture(nil, "LOW")
    texture1:SetTexture(nil)
    texture1:SetColorTexture(0.5,0.5,0.5,0.3)
    texture1:SetAllPoints()
    texture1:SetAllPoints(window.submit)


    window.submit:SetScript("OnClick", siy_SendPoll)

    ---
    --
    --
    

    --window.polltitle:Show()

    --window:SetPoint("CENTER", 0,0)
    siy_add_option("Continue raiding")
    window:Show()

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
    --ChatFrame1:AddMessage("PREFIX "..prefix.." _msg_ "..message.." _dist_"..dist.." _sender_ "..sender )
    if prefix == "SIYP" then
        --ChatFrame1:AddMessage("PREFIX "..prefix.." _msg_ "..message.." _dist_"..dist.." _sender_ "..sender )


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

                results.messages[x].vote = CreateFrame("Button", "votebutton"..tostring(x), results)
                results.messages[x].vote:SetSize(220, 25)
                results.messages[x].vote:SetNormalFontObject("ChatFontNormal")
                results.messages[x].vote:SetPoint("TOP", results.messages[x], "TOP", -15, 0)
                results.messages[x].vote:SetFrameStrata("MEDIUM")


                local texture = results.messages[x].vote:CreateTexture(nil, "LOW")
                texture:SetAllPoints(results.messages[x].vote)
                texture:SetTexture(nil)
                texture:SetColorTexture(0.5,0.5,0.5,0.5)
                texture:SetAllPoints()


                results.messages[x].count = results.title:CreateFontString()
                results.messages[x].count:SetPoint("RIGHT", results.messages[x].vote, "RIGHT", 25, 0)
                results.messages[x].count:SetFontObject("ChatFontNormal")
                results.messages[x].count:SetWidth(300)
                results.messages[x].count:SetJustifyH("RIGHT")

                results.messages[x].vote:SetScript("OnClick", function(self) siy_sendvote(x) end)

            end
            results.messages[x].count:SetText("0")
            results.messages[x].vote:SetText(search)

            results.messages[x].vote:Show();
            results.messages[x].count:Show();
            --results.messages[x]:Show();
            --results.messages[x]:SetText(search)
            topframe:Show()
            results:Show()
            window:Hide()

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
    if topframe:IsVisible() then
        siy_reset();
        topframe:Hide()
        --results:Hide()
    else
        siy_reset();
        topframe:Show();
        --results:Show();
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

    siy_CreateTopFrame()
    siy_CreateWindow()
    siy_CreateResults()

    SlashCmdList["SleepIsYes"] = SleepIsYes_Command
    SLASH_SleepIsYes1 = "/siy"

    -- local regpre = C_ChatInfo.GetRegisteredAddonMessagePrefixes()
    -- ChatFrame1:AddMessage(tostring(regpre))
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
