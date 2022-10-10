OMEDETOU_ACTIVE = false
OMEDETOU_LOG_PREFIX = "|cff5fedf7[|r|cff1ae5f3Omedetou|r|cff5fedf7]|r"

SLASH_OMEDETOU_TOGGLE1 = "/garts"

local OmedetouCooldown = 0
local OmedetouChatListener = CreateFrame("Frame")

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

local function ToggleOmedetou()
  if OMEDETOU_ACTIVE then
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

      local isAchievementText = startswith(tostring(message), "has earned the achievement ") or
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
  OMEDETOU_ACTIVE = not OMEDETOU_ACTIVE
  ToggleOmedetou()
end
