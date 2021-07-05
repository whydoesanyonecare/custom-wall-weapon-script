#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_weapons;
init()
{
    level._effect["wall_m16"] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" ); 
    level thread onPlayerConnect();
	wallweapons( "m16_zm", ( 2273.641, 167.5, 140.125 ), ( 0, 130, 0 ), 1200, 600 );
}

onPlayerConnect()
{
	while( 1 )
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self waittill( "spawned_player" );
	self thread init_wall_fx();
}

init_wall_fx()
{
    self thread playchalkfx("wall_m16", ( 2274.641, 168, 140.125 ), ( 0, 180, 0 ));
}

playchalkfx(effect, origin, angles)
{
    fx = SpawnFX(level._effect[ effect ], origin,AnglesToForward(angles),AnglesToUp(angles));
    TriggerFX(fx);
    level waittill("connected", player);
    fx Delete();
}

wallweapons( weapon, origin, angles, cost, ammo )
{
	wallweap = spawnentity( "script_model", getweaponmodel( weapon ), origin, angles + ( 0, 50, 0 ) );
	wallweap thread wallweaponmonitor( weapon, cost, ammo );
}

wallweaponmonitor( weapon, cost, ammo ) 
{
	self endon( "game_ended" );
	weap = get_weapon_display_name( weapon );
	upgradedammocost = 4500;
	in_use = 0;
	while( 1 )
	{
		foreach( player in level.players )
		{
			if( distance( self.origin, player.origin ) <= 70 )
			{
            	player thread SpawnHint( self.origin, 30, 30, "HINT_ACTIVATE", "Hold &&1 For Buy " + weap + " [Cost: " + cost + "] Ammo [Cost: 600] Upgraded Ammo [Cost: 4500]" );
				if( player usebuttonpressed() && !(player hasWeapon("m16_gl_upgraded_zm")) && !(player hasWeapon(weapon)) && !(in_use) && player.score >= cost && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
				{
					player playsound( "zmb_cha_ching" );
					in_use = 1;
					player.score -= cost;
					player thread weapon_give( weapon, 0, 1 );
					player iprintln( "^2" + ( weap + " Buy" ) );
                 	wait 3;
			     	in_use = 0;
				}
				if( player usebuttonpressed() && (player hasWeapon(weapon)) && !(in_use) && player.score >= ammo && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
				{
					player playsound( "zmb_cha_ching" );
					in_use = 1;
					player.score -= ammo;
					player setweaponammoclip(weapon, 150);
					player setWeaponAmmostock(weapon, 900 );
					player iprintln( "^2" + ( weap + " Ammo Buy" ) );
                   	wait 3;
			       	in_use = 0;
				}	
				if( player usebuttonpressed() && (player hasWeapon("m16_gl_upgraded_zm")) && !(in_use) && player.score >= upgradedammocost && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
				{
					player playsound( "zmb_cha_ching" );
					in_use = 1;
					player.score -= upgradedammocost;
					player setweaponammoclip("m16_gl_upgraded_zm", 150);
					player setWeaponAmmostock("m16_gl_upgraded_zm", 900 );
					player iprintln( "^2" + ( weap + " Upgraded Ammo Buy" ) );
                	wait 3;
			    	in_use = 0;
				}
				else
				{
					if( player usebuttonpressed() && player.score < cost && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
					{
						player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
					}
				}
			}
		}
		wait 0.1;
	}
}

spawnentity( class, model, origin, angle )
{
	entity = spawn( class, origin );
	entity.angles = angle;
	entity setmodel( model );
	return entity;
}

SpawnHint( origin, width, height, cursorhint, string )
{
	hint = spawn( "trigger_radius", origin, 1, width, height );
	hint setcursorhint( cursorhint, hint );
	hint sethintstring( string );
	hint setvisibletoall();
	wait 0.2;
	hint delete();
}
