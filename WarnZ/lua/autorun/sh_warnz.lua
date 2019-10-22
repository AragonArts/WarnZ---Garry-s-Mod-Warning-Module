if SERVER then
WarnZ = WarnZ or {}
WarnZ.DataTable = WarnZ.DataTable or {}

if !file.Exists("warnz/player.dat","DATA") then

    file.CreateDir("warnz")
    ReadWriteBase.WriteData( "warnz/player.dat", WarnZ.DataTable )  

end

function WarnZ.SaveDatabase()
    file.CreateDir("warnz")
    ReadWriteBase.WriteData( "warnz/player.dat", WarnZ.DataTable )  
end

function WarnZ.ReadDatabase()
    WarnZ.DataTable = ReadWriteBase.ReadData( "warnz/player.dat", "DATA" )  
end

local function WarnZ_QuickRefresh()
    WarnZ.SaveDatabase()
    WarnZ.ReadDatabase()
end

function WarnZ.WarnPlayer( target , warn_reason, admin_sid )
    local displayName = target
    local adminDisplayName = admin_sid

    if !admin_sid then admin_sid = "Console"; adminDisplayName = "Console" end
    if !warn_reason then warn_reason = "Unspecified" end

    if type(target) == "Player" then target_sid = target:SteamID(); displayName = target:Name() end
    if type(admin_sid) == "Player" then adminDisplayName = admin_sid:Name(); admin_sid = admin_sid:SteamID().."#"..adminDisplayName end

    local compactarray = {
    ["reason"]=warn_reason,
    ["date"] = os.date(),
    ["admin"]=admin_sid,
    }

    if !WarnZ.DataTable[target_sid] then WarnZ.DataTable[target_sid] = {} end
    table.insert(WarnZ.DataTable[target_sid], compactarray)
    ChatPrint( Color(255,0,0),"[WarnZ] ",Color(0,255,255), displayName, Color(255,255,255)," Was warned by ",Color(0,255,255),adminDisplayName,Color(255,255,255)," for ",Color(255,0,0),warn_reason )
    WarnZ_QuickRefresh()
end

function WarnZ.RemoveWarn( target, index )
    if type(target) == "Player" then target = target:SteamID() end
    WarnZ.DataTable[target][index] = nil
    if table.Count(WarnZ.DataTable[target]) < 1 then
        WarnZ.DataTable[target] = nil
    end
    WarnZ_QuickRefresh()
end

function WarnZ.ResetDatabase()
    WarnZ.DataTable = {}
    WarnZ_QuickRefresh()
end

function WarnZ.GetPlayerWarns( ply )

    local sid = ""
    if type(ply) == "Player" then sid = ply:SteamID() end

    if WarnZ.DataTable[sid] then return WarnZ.DataTable[sid] else return {nil} end

end


util.AddNetworkString("WarnZ_RequestWarns")
util.AddNetworkString("WarnZ_RequestPlayer")

net.Receive("WarnZ_RequestPlayer", function(len,ply)
    if !ply:IsAdmin() then return {nil} end

    local dat = {}
    for k,v in pairs(player.GetAll()) do
        dat[v:SteamID()] = WarnZ.GetPlayerWarns( v )
    end

    net.Start("WarnZ_RequestPlayer")
    net.WriteTable( dat )
    net.Send(ply)
end)

net.Receive("WarnZ_RequestWarns", function( len,ply )
    local warns = WarnZ.GetPlayerWarns( ply )
    net.Start("WarnZ_RequestWarns")
    net.WriteTable(warns)
    net.Send(ply)
end)

hook.Add( "PlayerInitialSpawn", "WarningAlert", function( ply ) 
if !WarnZ.DataTable[ply:SteamID()] then return end
local TotalWarnings = #WarnZ.DataTable[ply:SteamID()] or 0
if TotalWarnings > 0 then
    for k,v in pairs(player.GetAll()) do
        if !v:IsAdmin() then continue end
        v:ChatPrint(Color(255,0,0),"[WarnZ] ",Color(0,255,255),ply:Name(),"#",ply:SteamID(),Color(255,255,255)," has joined the server with ",Color(255,0,0),TotalWarnings,Color(255,0,0),Color(255,255,255)," Warnings!")
        v:EmitSound("NPC_CombineCamera.Click")
    end
    ply:ChatPrint(Color(255,0,0),"[WarnZ] ",Color(255,255,255),"You have ",Color(255,0,0),TotalWarnings,Color(255,0,0),Color(255,255,255)," Warnings on the server!",Color(255,255,255)," type ",Color(255,0,0),"!warns",Color(255,255,255)," to view your warnings!")
    ply:EmitSound("NPC_CombineCamera.Click")
end

end)

WarnZ.ReadDatabase()
end

if CLIENT then

    warnz = warnz or {}

    surface.CreateFont( "warnz_title", {
        font = "Roboto",
        extended = false,
        size = 16,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )
    
    surface.CreateFont( "warnz_small", {
        font = "Roboto",
        extended = false,
        size = 13,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )
    
    function warnz.menu()
    local Base = vgui.Create( "DFrame" )
    Base:SetTitle( " " )
    Base:SetSize( ScrW()/2, 0 )
    Base:Center()
    Base:ShowCloseButton(false)
    Base.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 120, 122, 124, 255 ) )
    end
    
    function Base:Think()
    Base:Center()
    end
    
    local header = vgui.Create( "DPanel", Base )
    header:Dock(TOP)
    header:SetHeight(5)
    
    header.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 157, 161, 165, 0 ) )
    end
    
    local sx,sy = Base:GetSize()
    
    local Title = vgui.Create( "DButton", Base )
    Title:SetText( "WarnZ Menu" )
    Title:SetTextColor( Color( 255, 255, 255 ) )
    Title:SetPos( 0,0 )
    Title:SetFont("warnz_title")
    Title:SetSize( sx-50, 30 )
    Title.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 157, 161, 165, 250 ) )
    end
    
    local Close = vgui.Create( "DButton", Base )
    Close:SetText( "X" )
    Close:SetTextColor( Color( 255, 255, 255 ) )
    Close:SetPos( sx-50,0 )
    Close:SetFont("warnz_title")
    Close:SetSize( 50, 30 )
    Close.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 143, 11, 11, 250 ) )
    end
    
    Close.DoClick = function()
        Close:SetEnabled(false)
        Base:SizeTo( ScrW()/2, 0, 0.2, 0, -1, function() Base:Close() end) 
    end
    
    local sheet = vgui.Create( "DPropertySheet", Base )
    sheet:Dock( FILL )
    
    
    local MyWarns = vgui.Create( "DPanel", sheet )
    MyWarns.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 121, 123, 125, 255 ) ) end
    sheet:AddSheet( "Your Warnings", MyWarns, "icon16/user.png" )
    
    local WarnShowcase = vgui.Create( "DListView", MyWarns )
    WarnShowcase:Dock( FILL )
    WarnShowcase:SetMultiSelect( false )
    WarnShowcase:AddColumn( "Reason" )
    WarnShowcase:AddColumn( "Date" )
    WarnShowcase:AddColumn( "Admin" )
    
    net.Start("WarnZ_RequestWarns")
    net.SendToServer()

    WarnShowcase.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 121, 123, 125, 250 ) )
    end

    net.Receive("WarnZ_RequestWarns", function()
        local mywarns = net.ReadTable()
        if #mywarns == 0 then
            WarnShowcase:AddLine( "No Warns.","","" )
            return
        end
        for k,v in pairs(mywarns) do
            if type(v) != "table" then continue end
            WarnShowcase:AddLine( v["reason"],v["date"],v["admin"] )
        end
    end)
    
    if LocalPlayer():IsAdmin() then

    local PlyWarns = {}

    net.Start("WarnZ_RequestPlayer")
    net.SendToServer()

    local AdminTab = vgui.Create( "DPanel", sheet )
    AdminTab.Paint = function( self, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 38, 56, 89, 250 ) ) end
    sheet:AddSheet( "Admin", AdminTab, "icon16/shield.png" )

    local PlayerShowcase = vgui.Create( "DListView", AdminTab )
    PlayerShowcase:SetWidth( sx/2-15 )
    PlayerShowcase:Dock( LEFT )
    PlayerShowcase:SetMultiSelect( false )
    PlayerShowcase:AddColumn( "Player" )
    PlayerShowcase:AddColumn( "SteamID" )
    PlayerShowcase:AddColumn( "Warns" )

    PlayerShowcase.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 121, 123, 125, 250 ) )
    end

    local PlayerWarns = vgui.Create( "DListView", AdminTab )
    PlayerWarns:SetWidth( sx/2-15 )
    PlayerWarns:Dock( RIGHT )
    PlayerWarns:SetMultiSelect( false )
    PlayerWarns:AddColumn( "Reason" )
    PlayerWarns:AddColumn( "Date" )
    PlayerWarns:AddColumn( "Admin" )

    PlayerWarns.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 121, 123, 125, 250 ) )
    end

    PlayerShowcase.OnRowSelected = function( panel, rowIndex, row )
        local data = PlyWarns[row:GetValue( 2 )]
        PlayerWarns:Clear()
        if #data > 0 then
            for k,v in pairs(data) do
            PlayerWarns:AddLine( v["reason"],v["date"],v["admin"] )
            end
        else
            PlayerWarns:AddLine( "Player has no warnings!","","" )
        end
    end

    net.Receive("WarnZ_RequestPlayer", function()
        PlyWarns = net.ReadTable()
        for k,v in pairs(player.GetAll()) do
            PlayerShowcase:AddLine( v:Name(),v:SteamID(), #PlyWarns[v:SteamID()] )
        end
    end)

    end

    Base:MakePopup()
    Base:SizeTo( ScrW()/2, ScrH()/2, 0.3, 0, -1, nil ) 

    end
    
    concommand.Add("warnz_menu", warnz.menu )
    
    concommand.Add("vgui_cleanup", function()
        for k, v in pairs( vgui.GetWorldPanel():GetChildren() ) do
            if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then
                v:Remove()
            end
        end
    end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)")

end