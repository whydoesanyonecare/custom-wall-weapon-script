#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;
init()
{
    level._effect["wall_m16"] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" ); 
    flag_wait( "initial_blackscreen_passed" );
    thread wallweaponmonitorbox(( 2273.641, 167.5, 140.125 ), ( 0, 180, 0 ), "m16_zm", 1200, 600 );
    thread playchalkfx("wall_m16", ( 2274.641, 168, 140.125 ), ( 0, 180, 0 ));

}

playchalkfx(effect, origin, angles)
{
    for(;;)
	{
		fx = SpawnFX(level._effect[ effect ], origin,AnglesToForward(angles),AnglesToUp(angles));
		TriggerFX(fx);
		level waittill("connected", player);
		fx Delete();
	}
}

wallweaponmonitorbox(origin, angles, weapon, cost, ammo )
{
    name = get_weapon_display_name( weapon );
	model = spawn("script_model", origin);
	model.angles = angles;
	model setmodel(getweaponmodel( weapon ));
	trigger = spawn("trigger_radius", origin, 0, 35, 80);
	trigger SetCursorHint("HINT_NOICON");
	trigger SetHintString("Hold ^3&&1^7 For Buy " + name + " [Cost: " + cost + "] Ammo [Cost: " + ammo + "] Upgraded Ammo [Cost: 4500]");
    for(;;)
    {
		trigger waittill("trigger", player);
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
		wait .1;
	}
}
