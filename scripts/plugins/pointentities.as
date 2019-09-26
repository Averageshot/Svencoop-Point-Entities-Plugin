/**
// Point Entities - by Aperture
//
// Contains:
//		- point_trigger
//		- point_teleport
//		- point_wall
//		
// Bonus Entities:
//		- trigger_dispatchkeyvalue
//
**/

#include "../maps/point_trigger"

void PluginInit()
{	
	g_Module.ScriptInfo.SetAuthor( "Aperture" );
	g_Module.ScriptInfo.SetContactInfo("Svencoop Discord or Chenzen Discord");
}

void MapInit()
{
	RegisterPointTrigger();
	RegisterPointTeleport();
	RegisterPointWall();
	RegisterDispatchKeyvalue();
	
	g_Game.AlertMessage( at_logged, "[Point Entities] Entities successfully loaded!\n" );
}