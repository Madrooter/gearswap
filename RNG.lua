-- Current Owner: AlanWarren, aka ~ Orestes 
-- Orinal file credit KBEEZIE
-- current file resides @ https://github.com/AlanWarren/gearswap

-- //gs show_swaps()
 
-- === Some Notes On Sets ===
-- I've left in KBEEZIE's Unlimited Shot checks for now, but will remove soon since the JA no longer has
-- any use.  

-- === My Modes ===
-- 1) Normal is a  4/hit with Annihilator and Yoichi, but sacrifices some racc/ratk to get there.
-- 2) Mod adds STP to WS set, and either STP or Crit to normal build. 
-- 3) Racc is full blown racc with minimal concern on maintaining x-hit.

-- === Features ===
-- 1) Bow set will activate by equipping whichever bow you defined in gear.Bow
-- 2) Decoy set only applies while decoy is active AND you're using Bow. Standard Bow set uses
-- -enmity gear, while maintaining 4-hit with 4/4 recycle procs. When Decoy is up, 3/4 recycle for 4-hit.
-- 3) Gun only: Legs & Back STP pieces are dynamically added, depending on main equipment slot. If you're using Hurlbat
-- with shield, Sylvan Chlamys and Aetosaur Trousers +1 will be equipped in midcast to maintain 4-hit. 
-- Otherwise, if you're using Mekki Shakki / Bloodrain, we use Lutian Cape + Nahtirah trousers. 
-- 3) I use Fenrir's earring at night during WS. You can disable this by setting use_night_earring = false
-- 4) During Overkill, I use a special set for precast/midcast containing rapidshot gear. 

-- === In Precast ===
-- 1) Checks to make sure you're in an engaged state and have 100+ TP before firing a weaponskill
-- 2) Checks the distance to target to prevent WS from being fired when target is too far (prevents TP loss)
-- 3) Does not allow gear-swapping on weaponskills when Defense mode is enabled
-- 4) Checks to see of "Unlimited Shot" buff is on, if there's any special ammo defined in sets equipped
-- 5) Checks for empty ammo (or special without buff) and fills in the default ammunition for that weapon
--    ^ keeps empty if that ammo cannot be found, or there is no match to the weapon equipped
-- 6) Provides a low ammunition warning if current ammo in slot (counts all in inventory) is less than 15
--    ^ If you have 5 Tulfaire arrows in slot, but 20 also in inventory it see's it as 25 total
 
-- === In Midcast ===
-- If Sneak is active, sends the cancel command before Spectral Jig finish casting
 
-- === In Post-Midcast ===
-- If Barrage Buff is active, equips sets.BarrageMid
 
-- === In Buff Change ===
-- If Camouflage is active, disable body swaping
-- This is done to preserve the +100 Camouflage Duration given by Orion Jerkin
 
function get_sets()
        -- Load and initialize the include file.
        include('Mote-Include.lua')
        init_include()
 
        -- UserGlobals may define additional sets to be added to the local ones.
        if define_global_sets then
            define_global_sets()
        end
 
        -- Global default binds
        binds_on_load()
 
        send_command('bind f9 gs c cycle RangedMode')
        send_command('bind ^f9 gs c cycle DefenseMode')
        send_command('bind !f9 gs c cycle WeaponskillMode')
        send_command('bind ^[ input /lockstyle on')
end

function job_setup()
    determine_ranged()
    state.Buff.Camouflage = buffactive.camouflage or false
    state.Buff.Overkill = buffactive.overkill or false

    use_night_earring = true
end
 
-- Called when this job file is unloaded (eg: job change)
function file_unload()
    binds_on_unload()
end
 
function init_gear_sets()
        -- Overriding Global Defaults for this job
        gear.Gun = "Annihilator"
        gear.Bow = "Yoichinoyumi"

        -- legs/waist are dynamic depending on hurlbat/mekki shakki, with gun only
        -- it's assumed you'll use Mekki Shakki with Bow. If you don't, then
        -- add gear.Legs and gear.Waist to the Bow and Decoy tables. see determine_ranged()
        gear.Legs = "Nahtirah Trousers"
        gear.Waist = "Lutian Cape"

        gear.default.weaponskill_neck = "Ocachi Gorget"
        gear.default.weaponskill_waist = "Elanid Belt"
 
        -- List of ammunition that should only be used under unlimited shot
        U_Shot_Ammo = S{'Animikii Bullet'}
       
        -- Simply add a line of DefaultAmmo["Weapon"] = "Ammo Name"
        DefaultAmmo = {}
        DefaultAmmo[gear.Gun] = "Achiyalabopa Bullet"
        DefaultAmmo[gear.Bow] = "Achiyalabopa Arrow"
       
        -- Options: Override default values
 
        options.OffenseModes = {'Normal', 'Melee'}
        options.RangedModes = {'Normal', 'Acc', 'Mod'}
        options.DefenseModes = {'Normal', 'PDT'}
        options.WeaponskillModes = {'Normal', 'Acc', 'Mod'}
        options.PhysicalDefenseModes = {'PDT'}
        options.MagicalDefenseModes = {'MDT'}
        state.Defense.PhysicalMode = 'PDT'
 
        -- Misc. Job Ability precasts
        sets.precast.JA['Bounty Shot'] = {hands="Sylvan Glovelettes +2"}
        sets.precast.JA['Double Shot'] = {head="Sylvan Gapette +2"}
        sets.precast.JA['Camouflage'] = {body="Orion Jerkin +1"}
        sets.precast.JA['Sharpshot'] = {legs="Orion Braccae +1"}
        sets.precast.JA['Velocity Shot'] = {body="Sylvan Caban +2"}
        sets.precast.JA['Scavenge'] = {feet="Orion Socks +1"}

        sets.precast.JA['Eagle Eye Shot'] = {
            head="Ux'uxkaj Cap", 
            neck="Rancor Collar",
            back="Buquwik Cape",
            ring2="Pyrosoul Ring",
            legs="Arcadian Braccae", 
            feet="Arcadian Socks +1"
        }

        sets.NightEarring = {ear2="Fenrir's earring"}
        sets.DayEarring = {ear2="Flame Pearl"}

        sets.earring = select_earring()

        select_default_macro_book()

        sets.idle = {
            head="Arcadian Beret +1",
            neck="Twilight torque",
            ear1="Volley Earring",
            ear2="Clearview Earring",
            body="Kheper Jacket",
            hands="Iuitl Wristbands +1",
            ring1="Dark Ring",
            ring2="Paguroidea Ring",
            back="Shadow Mantle",
            waist="Elanid Belt",
            legs="Nahtirah Trousers",
            feet="Orion Socks +1"
        }

        sets.idle.Town = set_combine(sets.idle, {
            neck="Ocachi Gorget",
            ear1="Fenrir's Earring",
            ear2="Tripudio Earring",
            ring1="Rajas Ring",
            ring2="Pyrosoul Ring",
            back="Lutian Cape"
        })
 
        -- Engaged sets
        sets.engaged =  {
            head="Arcadian Beret +1",
            neck="Ocachi Gorget",
            ear1="Volley Earring",
            ear2="Tripudio Earring",
            body="Kyujutsugi",
            hands="Sigyn's Bazubands",
            ring1="Rajas Ring",
            ring2="Paguroidea Ring",
            back="Shadow Mantle",
            waist="Elanid Belt",
            legs="Nahtirah Trousers",
            feet="Orion Socks +1"
        }

        sets.engaged.Bow = set_combine(sets.engaged, {
            hands="Arcadian Bracers +1",
            feet="Arcadian Socks +1"
        })

        sets.engaged.Melee = {
            head="Whirlpool Mask",
            neck="Rancor Collar",
            ear1="Bladeborn Earring",
            ear2="Steelflash Earring",
            body="Thaumas Coat",
            hands="Iuitl Wristbands +1",
            ring1="Rajas Ring",
            ring2="Epona's Ring",
            back="Atheling Mantle",
            waist="Cetl Belt",
            legs="Manibozho Brais",
            feet="Manibozho Boots"
        }
       
        -- Ranged Attack Sets
        sets.precast.RangedAttack = set_combine(sets.engaged, {
            head="Sylvan Gapette +2",
            body="Sylvan Caban +2",
            hands="Iuitl Wristbands +1",
            legs="Nahtirah Trousers",
            waist="Impulse Belt",
            feet="Wurrukatte Boots"
        })

        sets.midcast.RangedAttack = set_combine(sets.engaged, {
            ring2="Paqichikaji Ring",
            back=gear.Waist,
            legs=gear.Legs
        })
        -- stack as much STP as we can.
        sets.midcast.RangedAttack.Mod = set_combine(sets.midcast.RangedAttack, {
            hands="Sylvan Glovelettes +2",
            legs="Sylvan Bragues +2"
        })

        sets.midcast.RangedAttack.Acc = set_combine(sets.midcast.RangedAttack, {
            ear2="Clearview Earring",
            neck="Iqabi Necklace",
            ring1="Hajduk Ring",
            back="Lutian Cape",
            legs="Orion Braccae +1"
        })
        
        -- Bow 35 STP (with Bloodrain) needs 4/4 recycle proc (while decoy is down)
        -- -46 Enmity
        sets.midcast.RangedAttack.Bow = {
            head="Arcadian Beret +1", -- Enmity -6
            neck="Huani Collar", -- Enmity -3
            ear1="Novia Earring", -- Enmity -7
            ear2="Tripudio Earring", -- STP 5
            body="Kyujutsugi", -- STP 5 Enmity -9
            hands="Iuitl Wristbands +1", -- Enmity -6
            ring1="Rajas Ring", -- STP 5
            ring2="Paqichikaji Ring", -- Enmity -3
            back="Sylvan Chlamys", -- STP 5 Enmity -3
            waist="Elanid Belt", -- Enmity -3
            legs="Sylvan Bragues +2", -- STP 9
            feet="Arcadian Socks +1" -- Enmity -6
        }
        -- Mod for Bow ignores any attempt to stack -enmity in favor of STP
        sets.midcast.RangedAttack.Mod.Bow = set_combine(sets.midcast.RangedAttack.Bow, {
            neck="Ocachi Gorget",
            ear1="Volley Earring",
            hands="Sylvan Glovelettes +2",
            legs="Aetosaur Trousers +1"
        })
        -- 5 hit
        sets.midcast.RangedAttack.Acc.Bow = set_combine(sets.midcast.RangedAttack.Bow, {
            hands="Seiryu's Kote",  -- STP 4 for now
            ring1="Hajduk Ring",
            legs="Orion Braccae +1",
            back="Lutian Cape", -- Enmity -5
            feet="Orion Socks +1"
        })

        -- Docoy is Up - don't care about -enmity so much (Bow only)
        -- 3/4 recycle necessary to 4 hit
        sets.midcast.RangedAttack.Decoy = set_combine(sets.midcast.RangedAttack.Bow, {
            ear1="Volley Earring",
            neck="Ocachi Gorget",
            hands="Sylvan Glovelettes +2",
            legs="Nahtirah Trousers",
            feet="Orion Socks +1"
        })
        -- 4/4 recycle proc necessary
        sets.midcast.RangedAttack.Decoy.Mod = set_combine(sets.midcast.RangedAttack.Decoy, {
            legs="Aetosaur Trousers +1"
        })
        -- 5 hit
        sets.midcast.RangedAttack.Decoy.Acc = set_combine(sets.midcast.RangedAttack.Decoy.Mod, {
            neck="Iqabi Necklace",
            ring1="Hajduk Ring",
            feet="Orion Socks +1"
        })

        -- Weaponskill sets  
        sets.precast.CustomWS = {}
        sets.precast.CustomWS = {
            head="Arcadian Beret +1",
            neck="Ocachi Gorget",
            ear1="Flame Pearl",
            ear2="Flame Pearl",
            body="Kyujutsugi",
            hands="Arcadian Bracers +1",
            ring1="Rajas Ring",
            ring2="Pyrosoul Ring",
            back="Buquwik Cape",
            waist="Elanid Belt",
            legs="Nahtirah Trousers",
            feet="Orion Socks +1"
        }

        sets.precast.WS = set_combine(sets.precast.CustomWS, sets.earring)
       
        sets.precast.WS.Mod = set_combine(sets.precast.WS, {
            ear2="Tripudio Earring",
            back="Sylvan Chlamys",
            legs="Aetosaur Trousers +1"
        })
        
        sets.precast.WS.Acc = set_combine(sets.precast.WS, {
           ear2="Clearview Earring",
           legs="Orion Braccae +1",
           back="Lutian Cape"
        })


        -- CORONACH
        sets.precast.WS['Coronach'] = set_combine(sets.precast.WS, {
           neck="Breeze Gorget",
           waist="Thunder Belt"
        })

        sets.precast.WS['Coronach'].Mod = set_combine(sets.precast.WS.Mod, sets.precast.WS['Coronach'])

        sets.precast.WS['Coronach'].Acc = set_combine(sets.precast.WS.Acc, {
            neck="Breeze Gorget",
            waist="Thunder Belt",
            legs="Orion Braccae +1",
            hands="Sigyn's Bazubands"
        })

        -- LAST STAND
        sets.precast.WS['Last Stand'] = set_combine(sets.precast.WS, {
           neck="Aqua Gorget",
           ring2="Stormsoul Ring",
           waist="Light Belt",
           feet="Arcadian Socks +1"
        })

        sets.precast.WS['Last Stand'].Mod = set_combine(sets.precast.WS.Mod, sets.precast.WS['Last Stand'])

        sets.precast.WS['Last Stand'].Acc = set_combine(sets.precast.WS.Acc, {
            neck="Aqua Gorget",
            ring2="Stormsoul Ring",
            waist="Light Belt",
            hands="Sigyn's Bazubands"
        })
        
        -- DETONATOR
        sets.precast.WS['Detonator'] = set_combine(sets.precast.WS, {
           neck="Flame Gorget",
           waist="Light Belt",
           feet="Arcadian Socks +1"
        })

        sets.precast.WS['Detonator'].Mod = set_combine(sets.precast.WS.Mod, sets.precast.WS['Detonator'])

        sets.precast.WS['Detonator'].Acc = set_combine(sets.precast.WS.Acc, {
           neck="Flame Gorget",
           waist="Light Belt",
           feet="Arcadian Socks +1",
           hands="Sigyn's Bazubands"
        })

        -- BOW
        sets.precast.WS['Namas Arrow'] = set_combine(sets.precast.WS, {
            neck="Aqua Gorget",
            waist="Light Belt",
            back="Sylvan Chlamys",
            feet="Arcadian Socks +1"
        })

        sets.precast.WS['Namas Arrow'].Mod = set_combine(sets.precast.WS['Namas Arrow'], {
            ear2="Tripudio Earring",
            hands="Sylvan Glovelettes +2",
            legs="Aetosaur Trousers +1"
        })

        sets.precast.WS['Namas Arrow'].Acc = set_combine(sets.precast.WS['Namas Arrow'], {
            back="Lutian Cape",
            ring2="Paqichikaji Ring",
            legs="Orion Braccae +1"
        })

        sets.precast.WS['Jishnu\'s Radiance'] = set_combine(sets.precast.WS, {
            neck="Flame Gorget",
            waist="Light Belt",
            feet="Arcadian Socks +1",
            ring2="Thundersoul Ring",
            back="Rancorous Mantle"
        })

        sets.precast.WS['Jishnu\'s Radiance'].Mod = set_combine(sets.precast.WS['Jishnu\'s Radiance'], {
            ear2="Tripudio Earring",
            legs="Sylvan Bragues +2",
            hands="Sylvan Glovelettes +2"
        })

        sets.precast.WS['Jishnu\'s Radiance'].Acc = set_combine(sets.precast.WS['Jishnu\'s Radiance'], {
            back="Lutian Cape",
            ring2="Paqichikaji Ring",
            legs="Orion Braccae +1",
            feet="Orion Socks +1"
        })

        sets.precast.WS['Sidewinder'] = set_combine(sets.precast.WS, {
            neck="Aqua Gorget",
            waist="Light Belt",
            back="Buquwik Cape",
            feet="Arcadian Socks +1"
        })

        sets.precast.WS['Sidewinder'].Mod = set_combine(sets.precast.WS['Sidewinder'], {
            ear2="Tripudio Earring",
            legs="Aetosaur Trousers +1",
            back="Sylvan Chlamys"
        })

        sets.precast.WS['Sidewinder'].Acc = set_combine(sets.precast.WS['Sidewinder'], {
            legs="Aetosaur Trousers +1",
            back="Lutian Cape"
        })

        sets.precast.WS['Refulgent Arrow'] = sets.precast.WS['Sidewinder']
        sets.precast.WS['Refulgent Arrow'].Mod = sets.precast.WS['Sidewinder'].Mod
        sets.precast.WS['Refulgent Arrow'].Acc = sets.precast.WS['Sidewinder'].Acc
       
        -- Resting sets
        sets.resting = {}
       
        -- Defense sets
        sets.defense.PDT = set_combine(sets.idle, {})
        sets.defense.MDT = set_combine(sets.idle, {})
        --sets.Kiting = {feet="Fajin Boots"}
       
        -- Barrage Set
        sets.BarrageMid = {
            head="Arcadian Beret +1",
            neck="Rancor Collar",
            ear1="Flame Pearl",
            ear2="Flame Pearl",
            body="Kyujutsugi",
            hands="Orion Bracers +1",
            ring1="Rajas Ring",
            ring2="Hajduk Ring",
            back="Buquwik Cape",
            waist="Elanid Belt",
            legs="Orion Braccae +1",
            feet="Orion Socks +1"
        }

        sets.buff.Camouflage =  {body="Orion Jerkin +1"}

        sets.Overkill =  {
            body="Arcadian Jerkin",
            feet="Arcadian Socks +1"
        }
        sets.Overkill.PreShot =  set_combine(sets.Overkill, {
            head="Orion Beret +1"
        })
end

 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
 
function job_precast(spell, action, spellMap, eventArgs)
        if spell.type:lower() == 'weaponskill' then
                if player.status ~= "Engaged" or player.tp < 100 then
                        eventArgs.cancel = true
                        return
                end
                if (spell.target.distance >8 and not bow_gun_weaponskills:contains(spell.english)) or (spell.target.distance >21) then
                        -- Cancel Action if distance is too great, saving TP
                        add_to_chat(122,"OUTSIDE WS RANGE! /Canceling")
                        eventArgs.cancel = true
                        return
                elseif state.Defense.Active then
                        -- Don't gearswap for weaponskills when Defense is on.
                        eventArgs.handled = true
                end
        end
       
        if spell.type == 'Waltz' then
                refine_waltz(spell, action, spellMap, eventArgs)
        end
       
        if spell.name == "Ranged" or spell.type:lower() == 'weaponskill' then
                -- If ammo is empty, or special ammo being used without buff, replace with default ammo
                if U_Shot_Ammo[player.equipment.ammo] and not buffactive['unlimited shot'] or player.equipment.ammo == 'empty' then
                        if DefaultAmmo[player.equipment.range] and player.inventory[DefaultAmmo[player.equipment.range]] then
                                add_to_chat(122,"Unlimited Shot not Active or Ammo Empty, Using Default Ammo")
                                equip({ammo=DefaultAmmo[player.equipment.range]})
                        else
                                add_to_chat(122,"Either Default Ammo is Unavailable or Unknown Weapon. Staying empty")
                                equip({ammo=empty})
                        end
                end
                if not buffactive['unlimited shot'] then
                        -- If not empty, and if unlimited shot is not active
                        -- Not doing it for unlimited shot to avoid excessive log
                        if player.equipment.ammo ~= 'empty' then
                                if player.inventory[player.equipment.ammo].count < 15 then
                                        add_to_chat(122,"Ammo '"..player.inventory[player.equipment.ammo].shortname.."' running low ("..player.inventory[player.equipment.ammo].count..")")
                                end
                        end
                end
        end
end
 
-- Run after the default precast() is done.
-- eventArgs is the same one used in job_precast, in case information needs to be persisted.
-- This is where you place gear swaps you want in precast but applied on top of the precast sets
function job_post_precast(spell, action, spellMap, eventArgs)
    if state.Buff.Camouflage then
        equip(sets.buff.Camouflage)
    elseif state.Buff.Overkill then
        equip(sets.Overkill.PreShot)
    end
    sets.earring = select_earring()
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
    if spell.name == 'Spectral Jig' and buffactive.sneak then
        -- If sneak is active when using, cancel before completion
        send_command('cancel 71')
    end
end
 
-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if buffactive.barrage then
        equip(sets.BarrageMid)
    end
    if state.Buff.Camouflage then
        equip(sets.buff.Camouflage)
    end
    if state.Buff.Overkill then
        equip(sets.Overkill)
    end
end
 
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if not spell.interrupted then
        if state.Buff[spell.name] ~= nil then
            state.Buff[spell.name] = true
        end

        if state.Buff['Camouflage'] then
            send_command('@wait .5;gs disable body')
        else
            enable('body')
        end
    end
end
 
-- Run after the default aftercast() is done.
-- eventArgs is the same one used in job_aftercast, in case information needs to be persisted.
function job_post_aftercast(spell, action, spellMap, eventArgs)
 
end
 
-- Called before the Include starts constructing melee/idle/resting sets.
-- Can customize state or custom melee class values at this point.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_handle_equipping_gear(status, eventArgs)
    sets.earring = select_earring()
end
 
function customize_idle_set(idleSet)
	if state.Buff.Camouflage then
		idleSet = set_combine(idleSet, sets.buff.Camouflage)
	end
    return idleSet
end
 
function customize_melee_set(meleeSet)
    if state.Buff.Camouflage then
    	meleeSet = set_combine(meleeSet, sets.buff.Camouflage)
    end
    if state.Buff.Overkill then
    	meleeSet = set_combine(meleeSet, sets.Overkill)
    end
    return meleeSet
end
 
function job_status_change(newStatus, oldStatus, eventArgs)
    if camo_active() then
        send_command('@wait .5;gs disable body')
    else
        enable('body')
    end
end
 
-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    --if S{"courser's roll"}:contains(buff:lower()) then
    --if string.find(buff:lower(), 'samba') then

    if state.Buff[buff] ~= nil then
        state.Buff[buff] = gain
        handle_equipping_gear(player.status)
    end

	determine_ranged()

    --if not camo_active() then
    --   handle_equipping_gear(player.status) -- XXX: this may not be necessary to call for each buff. See Mote's MNK/DNC.lua's
    --end
end
 
function select_earring()
    -- world.time is given in minutes into each day
    -- 7:00 AM would be 420 minutes
    -- 17:00 PM would be 1020 minutes
    if world.time >= (18*60) or world.time <= (8*60) and use_night_earring then
        return sets.NightEarring
    else
        return sets.DayEarring
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------
 
-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
end
 
-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    determine_ranged()
    -- called here incase buff_change failed to update value
    state.Buff.Camouflage = buffactive.camouflage or false
    state.Buff.Overkill = buffactive.overkill or false
    state.Buff['Decoy Shot'] = buffactive['Decoy Shot'] or false

    if camo_active() then
        send_command('@wait .5;gs disable body')
    else
        enable('body')
    end
end
 
-- Job-specific toggles.
function job_toggle(field)
end
 
-- Request job-specific mode lists.
-- Return the list, and the current value for the requested field.
function job_get_mode_list(field)
 
end
 
-- Set job-specific mode values.
-- Return true if we recognize and set the requested field.
function job_set_mode(field, val)
 
end
 
-- Handle auto-targetting based on local setup.
function job_auto_change_target(spell, action, spellMap, eventArgs)
 
end
 
-- Handle notifications of user state values being changed.
function job_state_change(stateField, newValue)
 
end
 
-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
 
end

function determine_ranged()
	classes.CustomRangedGroups:clear()
	classes.CustomMeleeGroups:clear()

    if player.equipment.range == gear.Bow then
        if buffactive['Decoy Shot'] or state.Buff['Decoy Shot'] then
            classes.CustomMeleeGroups:append('Decoy')
		    classes.CustomRangedGroups:append('Decoy')
        else
            classes.CustomMeleeGroups:append('Bow')
		    classes.CustomRangedGroups:append('Bow')
        end
	end
    -- We either use Hurlbat or Mekki Shakki
    if player.equipment.main == "Hurlbat" then
        gear.Legs = "Aetosaur Trousers +1"
        gear.Waist = "Sylvan Chlamys"
    else
        gear.Legs = "Nahtirah Trousers"
        gear.Waist = "Lutian Cape"
    end
end

function camo_active()
    return state.Buff['Camouflage']
end
-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	-- Default macro set/book
	if player.sub_job == 'WAR'then
		    set_macro_page(3, 5)
	elseif player.sub_job == 'SAM' then
		    set_macro_page(4, 5)
	else
		set_macro_page(3, 5)
	end
end

