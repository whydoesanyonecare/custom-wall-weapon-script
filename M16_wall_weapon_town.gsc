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
	name = get_weapon_display_name( weapon );
	self.in_use_weap = 0;
	while( 1 )
	{
		foreach( player in level.players )
		{
			if( distance( self.origin, player.origin ) <= 70 )
			{
                player thread SpawnHint( self.origin, 30, 30, "HINT_ACTIVATE", "Hold ^3&&1^7 For Buy " + name + " [Cost: " + cost + "] Ammo [Cost: " + ammo + "] Upgraded Ammo [Cost: 4500]" );
                if(player usebuttonpressed() && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
                {
    				if( !(player has_weapon_or_upgrade(weapon)) && player.score >= cost && player can_buy_weapon())
	    			{
		    			player playsound( "zmb_cha_ching" );
			    		player.score -= cost;
				    	player thread weapon_give( weapon, 0, 1 );
                        wait 3;
	    			}
                    else
    			    {
	    			    if(player has_upgrade(weapon) && player.score >= 4500)
		    		    {
			    		    if(player ammo_give(get_upgrade_weapon(weapon)))
				    	    {
					    	    player.score -= 4500;
						        player playsound("zmb_cha_ching");
						        wait 3;
					        }
    				    }
	    			    else if(player hasweapon(weapon) && player.score >= ammo)
		    		    {
			    		    if(player ammo_give(weapon))
				    	    {
					    	    player.score -= ammo;
						        player playsound("zmb_cha_ching");
						        wait 3;
		    			    }
			    	    }
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
