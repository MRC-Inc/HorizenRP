hook.Add( "CanPlayerSuicide", "BESHooks_CanPlayerSuicide_Prevent", function( ply )
    if( ply:GetNWBool( "BES_CUFFED", false ) or ply:GetNWBool( "BES_TASERED", false ) ) then
        return false
    end
end )