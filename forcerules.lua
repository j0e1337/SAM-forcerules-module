
if SAM_LOADED then return end

if SERVER then
    AddCSLuaFile("autorun/client/cl_sam_force_rules.lua")

    util.AddNetworkString("SAM.ForceRules")
    util.AddNetworkString("SAM.ForceRulesEnd")

    local function FreezePlayer(ply)
        if not IsValid(ply) then return end
        ply:Freeze(true)
        ply:Lock()
    end

    local function UnfreezePlayer(ply)
        if not IsValid(ply) then return end
        ply:Freeze(false)
        ply:UnLock()
    end

    sam.command.set_category("Regeln")

    sam.command.new("forcerules")
        :SetPermission("forcerules", "admin")
        :Help("Freeze a player and force them to read the rules for a set amount of time (in seconds).")
        :AddArg("player", { single_target = true })
        :AddArg("number", { hint = "time (seconds)" })
        :OnExecute(function(admin, targets, time)
            local target = targets[1]
            if not IsValid(target) then return end

            time = math.Clamp(time, 5, 300)

            if time < 5 then
                sam.player.send_message(admin, "Time must be at least 5 seconds.")
                return
            end

            if time > 300 then
                sam.player.send_message(admin, "You can’t force someone to read the rules for more than 300 seconds.")
                time = 300
            end

            FreezePlayer(target)
            net.Start("SAM.ForceRules")
            net.WriteInt(time, 32)
            net.Send(target)
            timer.Create("SAM_ForceRules_" .. target:SteamID64(), time, 1, function()
                if not IsValid(target) then return end
                UnfreezePlayer(target)
                net.Start("SAM.ForceRulesEnd")
                net.Send(target)
            end)
        end)
    :End()
end