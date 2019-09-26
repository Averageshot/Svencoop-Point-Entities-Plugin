/**
// Point Entities - by Aperture
//
// Contains:
//		- point_trigger
//		- point_teleport
//		- point_wall
//		- trigger_dispatchkeyvalue ( extra stuff )
**/

/*
===== point_trigger  ========================================================

  Triggers entities within a defined volume. Can be toggled.
  point_trigger is the base of all point trigger entities

*/

enum FLAGS_POINT_TRIGGER
{
	SF_MONSTERS 		= 1 << 0,
	SF_NOCLIENTS 		= 2 << 0,
	SF_PUSHABLES		= 4 << 0,
	SF_TRIGGERONCE		= 8 << 0,
	SF_STARTDISABLED	= 16 << 0,
	SF_USEDESTANGLES	= 32 << 0, // point_teleport entities only!!!
}

class point_trigger : ScriptBaseEntity
{
	float m_flNextTouchTime;
	float m_flWaitTime;
	
	void Spawn()
	{
		InitTrigger();
	}
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if ( szKey == "wait" ) 
			m_flWaitTime = atof( szValue );
		
		else 
			return BaseClass.KeyValue( szKey, szValue );
			
		return true;
	}
	
	void InitTrigger()
	{
		self.pev.solid = SOLID_TRIGGER;
		self.pev.movetype = MOVETYPE_NONE;
		
		if( ( self.pev.SpawnFlagBitSet( SF_STARTDISABLED ) ) )
			self.pev.solid = SOLID_NOT;
		
		g_EntityFuncs.SetOrigin( self, self.GetOrigin() + Vector( 0, 0, ( -self.pev.maxs.z + self.pev.mins.z ) * 0.5 )); // it just werks...
		
		// using this for 100% accurate dimensions when working with level editor
		g_EntityFuncs.SetSize( self.pev, Vector( self.pev.mins.x, self.pev.mins.y, self.pev.mins.z ) * 0.5, Vector( self.pev.maxs.x * 0.5, self.pev.maxs.y * 0.5, self.pev.maxs.z ) );
	}
	
	bool CanTouch( entvars_t@ pevToucher )
	{
		g_Engine.force_retouch++;
		
		// Only touch clients, monsters, or pushables (depending on flags)
		if ( pevToucher.flags & FL_CLIENT != 0 )
		{
			//g_Game.AlertMessage( at_console, "client!\n" );
			return !( self.pev.spawnflags & SF_NOCLIENTS != 0 );
		}
		else if ( pevToucher.flags & FL_MONSTER != 0 )
		{
			//g_Game.AlertMessage( at_console, "monster!\n" );
			return ( self.pev.spawnflags & SF_MONSTERS != 0 );
		}
		else if ( pevToucher.classname == "func_pushable" )
		{
			//g_Game.AlertMessage( at_console, "pushable!\n" );
			return ( self.pev.spawnflags & SF_PUSHABLES != 0 );
		}
		else
		{
			//g_Game.AlertMessage( at_console, "can't touch this!!\n" );
			return false;
		}
	}
	
	void Touch( CBaseEntity@ pOther )
	{
		entvars_t@ pevToucher = pOther.pev;
		
		// can the object touch it?
		if ( !( CanTouch( pevToucher ) ) )
			return;
		
		if ( m_flNextTouchTime > g_Engine.time )
			return;
		
		self.SUB_UseTargets( pOther, USE_TOGGLE, 0 );
		
		if ( self.pev.SpawnFlagBitSet( SF_TRIGGERONCE ) )
		{
			self.pev.solid = SOLID_NOT;
			return;
		}
		
		m_flNextTouchTime = g_Engine.time + m_flWaitTime;
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		ToggleTrigger();
	}
	
	void ToggleTrigger()
	{
		if ( self.pev.solid == SOLID_NOT )
		{
			self.pev.solid = SOLID_TRIGGER;
			
			// HACK - call forcetouch++ for a bit to update on monsters and pushables...
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		else
			self.pev.solid = SOLID_NOT;
			
		g_EntityFuncs.SetOrigin( self, self.GetOrigin() );
	}
	
	void Think()
	{
		g_Engine.force_retouch++;
		
		//DrawDebugBox( self.GetOrigin() + self.pev.mins, self.GetOrigin() + self.pev.maxs, 100, Math.RandomLong( 0, 255 ), Math.RandomLong( 0, 255 ), Math.RandomLong( 0, 255 ) );
		
		//self.pev.nextthink = g_Engine.time + 0.1;
		SetThink( null );
	}
	
	void DrawDebugBox( Vector &in mins, Vector &in maxs, uint time, int r, int g, int b )
	{
		NetworkMessage box( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
			box.WriteByte( TE_BOX );
			box.WriteCoord( mins.x );
			box.WriteCoord( mins.y );
			box.WriteCoord( mins.z );
			box.WriteCoord( maxs.x );
			box.WriteCoord( maxs.y );
			box.WriteCoord( maxs.z );
			box.WriteShort( time );
			box.WriteByte( r );
			box.WriteByte( g );
			box.WriteByte( b );
		box.End();
	}
}

void RegisterPointTrigger()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "point_trigger", "point_trigger" );
}
/*
===== point_teleport  ========================================================

  Teleports entities within a defined volume. Can be toggled.             

*/
	
class point_teleport : point_trigger
{
	void Spawn()
	{
		InitTrigger();
	}
	
	void Touch( CBaseEntity@ pOther )
	{
		entvars_t@ pevToucher = pOther.pev;
		
		// can the object touch it?
		if ( !( CanTouch( pevToucher ) ) ) return;
		
		if ( m_flNextTouchTime > g_Engine.time )
			return;
		
		CBaseEntity @pTarget = g_EntityFuncs.FindEntityByTargetname( pTarget, self.pev.message );
		
		TeleportEntity( EHandle( pOther ), EHandle( pTarget ) );
		
		m_flNextTouchTime = g_Engine.time + m_flWaitTime;
	}
	
	void TeleportEntity( EHandle &in eEntity, EHandle &in eTarget )
	{
		CBaseEntity@ pEntity = eEntity.GetEntity();
		CBaseEntity@ pTarget = eTarget.GetEntity();
		
		pEntity.SetOrigin( pTarget.pev.origin );
		
		if( ( self.pev.SpawnFlagBitSet( SF_USEDESTANGLES ) ) ) // use the target dest angles instead of player's?
		{
			pEntity.pev.angles.x = pTarget.pev.v_angle.x;
			pEntity.pev.angles.y = pTarget.pev.angles.y;
			pEntity.pev.angles.z = 0;
		}
		else
		{
			pEntity.pev.angles.x = pEntity.pev.v_angle.x;
			pEntity.pev.angles.y = pEntity.pev.angles.y;
			pEntity.pev.angles.z = 0;
		}
		
		pEntity.pev.fixangle = FAM_FORCEVIEWANGLES;
		pEntity.pev.velocity = g_vecZero;
		pEntity.pev.flags &= ~FL_ONGROUND;
		
		self.SUB_UseTargets( pEntity, USE_TOGGLE, 0 );
		
		if ( self.pev.SpawnFlagBitSet( SF_TRIGGERONCE ) )
		{
			self.pev.target = "";
		}
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		ToggleTrigger();
	}
}

void RegisterPointTeleport()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "point_teleport", "point_teleport" );
}

/*
===== point_wall  ========================================================

  A simple invisible wall that blocks things. Can be toggled.             

*/

enum FLAGS_POINT_WALL
{
	SF_STARTOFF	= 1 << 0,
}

class point_wall : ScriptBaseEntity // not basing off point_trigger because we're not actually a trigger lol
{
	void Spawn()
	{
		self.pev.movetype = MOVETYPE_NONE;	// doesn't move
		
		self.pev.solid = SOLID_BBOX;
		
		if( ( self.pev.SpawnFlagBitSet( SF_STARTOFF ) ) )
			self.pev.solid = SOLID_NOT;
		
		//self.pev.nextthink = g_Engine.time + 0.1;
		
		g_EntityFuncs.SetOrigin( self, self.GetOrigin() + Vector( 0, 0, ( -self.pev.maxs.z + self.pev.mins.z ) * 0.5 )); // it just werks...
		g_EntityFuncs.SetSize( self.pev, Vector( self.pev.mins.x, self.pev.mins.y, self.pev.mins.z ) * 0.5, Vector( self.pev.maxs.x * 0.5, self.pev.maxs.y * 0.5, self.pev.maxs.z ) );
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		ToggleWall();
	}
	
	void ToggleWall()
	{
		if ( self.pev.solid == SOLID_NOT )
		{
			self.pev.solid = SOLID_BBOX;
		}
		else
			self.pev.solid = SOLID_NOT;
			
		g_EntityFuncs.SetOrigin( self, self.GetOrigin() );
	}
	
	void DrawDebugBox( Vector &in mins, Vector &in maxs, uint time, int r, int g, int b )
	{
		NetworkMessage box( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
			box.WriteByte( TE_BOX );
			box.WriteCoord( mins.x );
			box.WriteCoord( mins.y );
			box.WriteCoord( mins.z );
			box.WriteCoord( maxs.x );
			box.WriteCoord( maxs.y );
			box.WriteCoord( maxs.z );
			box.WriteShort( time );
			box.WriteByte( r );
			box.WriteByte( g );
			box.WriteByte( b );
		box.End();
	}
	
	/*
	void Think()
	{
		DrawDebugBox( self.GetOrigin() + self.pev.mins, self.GetOrigin() + self.pev.maxs, 100, Math.RandomLong( 0, 255 ), Math.RandomLong( 0, 255 ), Math.RandomLong( 0, 255 ) );
		
		self.pev.nextthink = g_Engine.time + 0.1;
		//SetThink( null );
	}
	*/
}

void RegisterPointWall()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "point_wall", "point_wall" );
}

/*
===== trigger_dispatchkeyvalue  ========================================================

  Explicitly dispatches a keyvalue to an entity during runtime.

*/

class trigger_dispatchkeyvalue : ScriptBaseEntity
{
	CBaseEntity@ pTarget = null;
	
	string m_iValue;
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if ( szKey == "Value" )
			m_iValue = szValue;
		
		else
			return BaseClass.KeyValue( szKey, szValue );
			
		return true;
	}
	
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		while(( @pTarget = g_EntityFuncs.FindEntityByTargetname( pTarget, self.pev.target)) !is null ) // loop through entities using the same targetname
		{
			if( pTarget !is null )
			{
				g_Game.AlertMessage( at_console, "trigger_dispatchkeyvalue '%1' modified '%2', '%3' : '%4'\n", self.pev.targetname, pTarget.pev.targetname, self.pev.netname, m_iValue );
				g_EntityFuncs.DispatchKeyValue( pTarget.edict(), self.pev.netname, m_iValue );
			}
		}
	}
}

void RegisterDispatchKeyvalue()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_dispatchkeyvalue", "trigger_dispatchkeyvalue" );
}