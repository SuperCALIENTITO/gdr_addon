local function OnMessageReceived()
    local sAuthor = net.ReadString()
    local sContent = net.ReadString()

    chat.AddText( Color(114, 137, 218), "["..sAuthor.."]: ", Color(255, 255, 255), sContent )
end

net.Receive("gdr_messagereceived", OnMessageReceived)