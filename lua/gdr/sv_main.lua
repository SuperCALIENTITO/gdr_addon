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

hook.Add("PlayerSay", "gdr_chatreader", function(ply, text)
    SendMessage(ply:SteamID64(), ply:Nick(), text)
end)

local function SendMessageHook(img, name, text)
    local tHTTPRequest = {
        url = tGDRConfig.Endpoint.."/sendmessagehook",
        method = "POST",
        failed = OnHTTPFail,
        body = util.TableToJSON({ img, name, text }),
        type = "application/json"
    }

    HTTP(tHTTPRequest)
end

hook.Add("GDR_sendMessage", "gdr_sendmessagehook", function(img, name, text)
    if not img then return end
    if not name then return end
    if not text then return end

    SendMessageHook(img, name, text)
end)