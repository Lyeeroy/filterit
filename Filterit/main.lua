local filterIT, addonTable = ...
local match
local clearButton = false
-- Create the main frame
local frame = CreateFrame("Frame", filterIT .. "Frame", UIParent)
frame:SetPoint("CENTER")
frame:SetSize(666, 420)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

-- Set frame properties for resizing
frame:SetResizable(true)
frame:SetMinResize(666, 400)
frame:SetMaxResize(1400, 1000)

-- Create the resize button
local resizeButton = CreateFrame("Button", filterIT .. "ResizeButton", frame)
resizeButton:SetPoint("BOTTOMRIGHT", -5, 5)
resizeButton:SetSize(16, 16)
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeButton:SetScript("OnMouseDown", function(self, button)
    frame:StartSizing("BOTTOMRIGHT")   
end)
resizeButton:SetScript("OnMouseUp", function(self, button)
    frame:StopMovingOrSizing()
end)




-- Create a background texture for the frame
frame.background = frame:CreateTexture(nil, "BACKGROUND")
frame.background:SetAllPoints(frame)
frame.background:SetTexture(0, 0, 0, 0.5)

-- Create a close button for the frame
frame.closeButton = CreateFrame("Button", filterIT .. "CloseButton", frame, "UIPanelCloseButton")
frame.closeButton:SetPoint("TOPRIGHT", -6, -6)

-- Create the chat frame
local chatFrame = CreateFrame("ScrollingMessageFrame", filterIT .. "ChatFrame", frame)
chatFrame:SetPoint("BOTTOMLEFT", 10, 10) -- Change anchor point to the bottom left of the frame
chatFrame:SetPoint("BOTTOMRIGHT", -10, 10) -- Change anchor point to the bottom right of the frame
chatFrame:SetFontObject(ChatFontNormal)
chatFrame:SetJustifyH("LEFT")
chatFrame:SetFading(false)
chatFrame:EnableMouse(false)
chatFrame:SetMaxLines(5000)
chatFrame:SetInsertMode("BOTTOM") -- Set insert mode to "BOTTOM" to make messages slide from bottom to top
-- Define borders of the frame
--chatFrame:SetBackdrop({
--    bgFile = "Interface\\Buttons\\WHITE8x8",
--    edgeFile = "Interface\\Buttons\\WHITE8x8",
--    tile = false, tileSize = 0, edgeSize = 1,
--    insets = { left = 0, right = 0, top = 0, bottom = 0 }
--})
chatFrame:SetBackdropColor(0, 0, 0, 0.4) -- Set the background color
chatFrame:SetBackdropBorderColor(0.4, 0.4, 0.4) -- Set the border color
chatFrame:SetResizable(false)

-- Create the input box
local inputBox = CreateFrame("EditBox", filterIT .. "InputBox", frame, "InputBoxTemplate")
inputBox:SetWidth(390)
inputBox:SetHeight(20)
inputBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 52, -13)
inputBox:SetAutoFocus(false)
inputBox:SetFontObject(ChatFontNormal)
inputBox:SetScript(
    "OnEnterPressed",
    function(self)
        self:ClearFocus()
    end
)



-- Create the label "Filter:"
local filterLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
filterLabel:SetPoint("BOTTOMLEFT", inputBox, "BOTTOMLEFT", -47, 4)
filterLabel:SetText("Filter:")

-- Create a table to store message frames
local messageFrames = {}

-- Set up an OnEvent handler to update the chat in real-time
local function OnEvent(self, event, ...)
    if event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" then
        -- Initialize numMatches variable
        if not numMatches then
            numMatches = 0
        end

        -- Search string, lets go for this madness; Edit: I was coding this for like 4 hours
        local message, playerName, _, channelName = ...
        local searchString = inputBox:GetText()
        
        -- Reset numMatches and hide label if search string has changed or is empty
        if searchString ~= prevSearchString or searchString == "" then
            numMatches = 0
            if inputBox.label then
                inputBox.label:Hide()
            end
        end
        
        -- Split the search string into individual "&" groups and process each group
        local searchGroups = {}
        for group in string.gmatch(searchString, "[^&]+") do
            local searchWords = {}
            for word in string.gmatch(group, "%S+") do
                table.insert(searchWords, string.lower(word))
            end
            table.insert(searchGroups, searchWords)
        end
        
        -- Check if any of the search groups match the message
        local match = false
        for _, searchWords in ipairs(searchGroups) do
            local groupMatch = true
            for _, word in ipairs(searchWords) do
                if not string.find(string.lower(message), word, 1, true) then
                    groupMatch = false
                    break
                end
            end
            if groupMatch then
                match = true
                break
            end
        end
        
        if searchString ~= "" and not match then
            return
        end
        

        -- Update label with number of matches
        if searchString ~= "" then
            if match == true then
                numMatches = numMatches + 1
            end
        end

        if numMatches > 0 then
            if not inputBox.label then
                inputBox.label = inputBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                inputBox.label:SetPoint("LEFT", filterLabel, "RIGHT", 420, 0)
            end
            inputBox.label:SetText(numMatches .. " match(es) found")
            inputBox.label:Show()
        else
            if inputBox.label then
                inputBox.label:Hide()
            end
        end

        if clearButton == false then
            clearButton = true
                -- Create a clear button for the chat frame
                local clearButton = CreateFrame("Button", filterIT .. "ClearButton", frame, "UIPanelButtonTemplate")
                clearButton:SetText("Clear Chat")
                clearButton:SetPoint("TOPRIGHT", -40, -12)
                clearButton:SetSize(80, 20)
                clearButton:SetScript("OnClick", function()
                    for i = 1, #messageFrames do
                        messageFrames[1]:Hide()
                        table.remove(messageFrames, 1)
                    end
                end)
        end

        -- Save current search string for comparison in next event
        prevSearchString = searchString

        -- Create a new message frame and add the message to it
        local messageFrame = CreateFrame("Frame", nil, chatFrame)
        messageFrame:SetSize(frame:GetWidth() - 40, 40)
        messageFrame:SetPoint("TOPLEFT", chatFrame, "TOPLEFT", 20, -chatFrame:GetHeight())
        messageFrame.text = messageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        messageFrame.text:SetPoint("LEFT", messageFrame, "LEFT", 0, 0)
        messageFrame.text:SetWidth(messageFrame:GetWidth())
        messageFrame.text:SetHeight(messageFrame:GetHeight())
        messageFrame.text:SetJustifyH("LEFT")
        messageFrame.text:SetWordWrap(true)
        if channelName == "" then
            channelName = 'Y/S'
        end
        messageFrame.text:SetText(
            "|cff00cc44" .. "<" .. playerName .. ">|r " .. "|cff00ccff<" .. channelName .. "> " .. "|r" .. message
        )
        messageFrame:SetHeight(messageFrame.text:GetStringHeight())

        -- Create the whisper button and position it to the left of the message frame
        local whisperButton = CreateFrame("Button", nil, messageFrame)
        whisperButton:SetSize(16, 16)
        whisperButton:SetPoint("RIGHT", messageFrame.text, "LEFT", -5, 0)
        whisperButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
        whisperButton:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")
        whisperButton:SetScript(
            "OnClick",
            function()
                ChatFrame_SendTell(playerName)
            end
        )

        -- Add the new message frame to the table
        table.insert(messageFrames, messageFrame)

        -- Hide the oldest message frames if the chat frame is about to hit its maximum height
        local maxHeight = frame:GetHeight()
        for i = 1, #messageFrames do
            if messageFrames[i] then
              maxHeight = maxHeight - messageFrames[i]:GetHeight() - 3.5 -- Let some space at the TOP jeez ur too dmn fat
              if maxHeight < messageFrame:GetHeight() then
                messageFrames[1]:Hide()
                table.remove(messageFrames, 1)
              end
            end
          end
          

        -- Adjust the chat frame height to fit the new message frame and whisper button
        chatFrame:SetHeight(chatFrame:GetHeight() + messageFrame:GetHeight())

        -- Scroll to the bottom of the chat frame
        chatFrame:ScrollToBottom()
    end
end

frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:SetScript("OnEvent", OnEvent)


-- Handle the /fit command
SLASH_FIT1 = "/fit"
SlashCmdList["FIT"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end