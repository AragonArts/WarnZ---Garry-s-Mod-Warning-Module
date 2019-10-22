function ulx.warn( calling_ply, target_ply, reason )
	WarnZ.WarnPlayer(target_ply,reason,calling_ply)
end

local mywarn = ulx.command( "WarnZ", "ulx warn", ulx.warn, "!warn" )
mywarn:addParam{ type=ULib.cmds.PlayerArg, target="*", default="^", ULib.cmds.optional }
mywarn:addParam{ type=ULib.cmds.StringArg, hint="Reason"}
mywarn:defaultAccess( ULib.ACCESS_ADMIN )
mywarn:help( "Warn a player" )