include("sv_config.lua")

util.AddNetworkString("gdr_messagereceived")

local sLastErrorReason = ""

local function OnHTTPFail(sError)
    if sLastErrorReason == sError then return end
    MsgC(Color(255, 0, 0), "http failed with reason: ", sError.. "\n")
    if sError == "unsuccessful" then
        MsgC(Color(255, 0, 0), "is the nodejs server running? and is it properly configured?\n")
    end

    sLastErrorReason = sError
end

local function ParseMessages(code, body, header)
    local tMessages = util.JSONToTable(body)

    if #tMessages < 1 then return end

    for _, MessageInfo in pairs(tMessages) do
        local sAuthor = MessageInfo[1]
        local sContent = MessageInfo[2]

        net.Start("gdr_messagereceived")
        net.WriteString(sAuthor)
        net.WriteString(sContent)
        net.Broadcast()

        MsgC(Color(114, 137, 218), "["..sAuthor.."]: ", Color(255, 255, 255), sContent.."\n")
    end

    sLastErrorReason = ""
end

local function QueryMessages() 
    local tHTTPRequest = {
		url = tGDRConfig.Endpoint.."/getmessages",
		success = ParseMessages,
		failed = OnHTTPFail,
		method = "GET"
	}

	HTTP(tHTTPRequest);
end

timer.Create("gdr_querytimer", 1 / tGDRConfig.UpdateRate, 0, QueryMessages)

local function SendMessage(sID, sName, sChatMessage)
    local tHTTPRequest = {
		url = tGDRConfig.Endpoint.."/sendmessage",
		method = "POST",
        failed = OnHTTPFail,
        body = util.TableToJSON({ sID, sName, sChatMessage }),
        type = "application/json"
	}

    HTTP(tHTTPRequest)
end

local function OnPlayerSay(Ply, sChatMessage, bTeam, bDead)
    SendMessage(Ply:SteamID64(), Ply:Nick(), sChatMessage)
end

hook.Add("PlayerSay", "gdr_chatreader", OnPlayerSay)