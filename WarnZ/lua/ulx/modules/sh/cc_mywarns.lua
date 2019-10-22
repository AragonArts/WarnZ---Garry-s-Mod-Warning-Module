function ulx.warns( calling_ply )
	calling_ply:ConCommand("warnz_menu")
end

local mywarn = ulx.command( "WarnZ", "ulx warns", ulx.warns, "!warns" )
mywarn:defaultAccess( ULib.ACCESS_DEFAULT )
mywarn:help( "View your warnings" )