OMEDETOU_LOG_PREFIX = "|cff5fedf7[|r|cff1ae5f3Omedetou|r|cff5fedf7]|r"
SLASH_OMEDETOU_TOGGLE1 = "/garts"

local addonLoaded = CreateFrame("Frame")
addonLoaded:RegisterEvent("ADDON_LOADED")
addonLoaded:RegisterEvent("PLAYER_LOGOUT")

local OmedetouCooldown = 0
local OmedetouChatListener = CreateFrame("Frame")
local OmedetouMiniMapButton

local OmedetouMessageTemplates = {
  [1] = "garts",
  [2] = "grats!",
  [3] = "gratz",
  [4] = "Congratulations on your achievement!!!!"
}

local function startswith(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

local function GetChatMessage()
  local randIndex = math.random(1, #OmedetouMessageTemplates)
  return OmedetouMessageTemplates[randIndex]
end

local function GetMiniMapIcon()
  if OmedetouDB["OMEDETOU_ACTIVE"] then
    return "Interface\\Addons\\Omedetou\\minimap-icon-enabled"
  else
    return "Interface\\Addons\\Omedetou\\minimap-icon-disabled"
  end
end

local function ToggleOmedetou()
  OmedetouMiniMapButton.icon = GetMiniMapIcon()

  if OmedetouDB["OMEDETOU_ACTIVE"] then
    print(OMEDETOU_LOG_PREFIX .. " is now listening for achievements.")

    OmedetouChatListener:RegisterEvent("CHAT_MSG_GUILD")
    OmedetouChatListener:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")

    OmedetouChatListener:SetScript("OnEvent", function(self, event, ...)
      local currentPlayer = UnitName("player")
      local message = select(1, ...)
      local sender = select(2, ...)
      local playerName = sender:gsub("%-.+", "")
      local isSelf = playerName == currentPlayer

      -- DEBUG:
      -- isSelf = false

      local isAchievementText = startswith(tostring(message), "has earned the achievement |cff") or
          startswith(message, "[Attune] |cff")

      if isAchievementText then
        if not isSelf then
          if OmedetouCooldown == 0 then
            OmedetouCooldown = 3
            local delay = math.random(1, 2)

            C_Timer.After(delay, function()
              SendChatMessage(GetChatMessage(), "WHISPER", nil, playerName)
            end)

            C_Timer.After(OmedetouCooldown, function()
              OmedetouCooldown = 0
            end)
          end
        end
      end
    end)
  else
    print(OMEDETOU_LOG_PREFIX .. " is no longer listening for achievements.")
    OmedetouChatListener:UnregisterEvent("CHAT_MSG_GUILD")
    OmedetouChatListener:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
  end
end

SlashCmdList["OMEDETOU_TOGGLE"] = function(msg, editBox)
  OmedetouDB["OMEDETOU_ACTIVE"] = not OmedetouDB["OMEDETOU_ACTIVE"]
  ToggleOmedetou()
end

local function InitialiseOmedetou()
  OmedetouMiniMapButton = LibStub("LibDataBroker-1.1"):NewDataObject("Omedetou", {
    type = "data source",
    text = "Omedetou",
    icon = GetMiniMapIcon(),
    OnClick = function(self, btn)
      OmedetouDB["OMEDETOU_ACTIVE"] = not OmedetouDB["OMEDETOU_ACTIVE"]
      ToggleOmedetou()
    end,
    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then return end
      tooltip:AddLine("Click to toggle Omedetou")
    end,
  })

  local icon = LibStub("LibDBIcon-1.0", true)
  icon:Register("Omedetou", OmedetouMiniMapButton, OmedetouDB)
end

addonLoaded:SetScript(
  "OnEvent",
  function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Omedetou" then
      if OmedetouDB == nil then
        -- Seed preferences with defaults
        OmedetouDB = {}
        OmedetouDB["OMEDETOU_ACTIVE"] = false
      end

      InitialiseOmedetou()

      if OmedetouDB["OMEDETOU_ACTIVE"] then
        print(OMEDETOU_LOG_PREFIX .. " is loaded and is |cff0eff7dactive|r.")
      else
        print(OMEDETOU_LOG_PREFIX .. " is loaded and is |cffff0e40inactive|r.")
      end

      addonLoaded:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGOUT" then
      -- --
    end
  end
)
