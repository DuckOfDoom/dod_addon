local filepath = "C:\Users\DuckOfDoom\Desktop\wow_stats.txt"

function DOD.DetailsInit()
  print('init')
end

function DOD.DetailsDump()
  local combat = Details:GetCurrentCombat(-1)
  local combatTime = combat:GetCombatTime()
  local damageContainer = combat:GetContainer(DEAAILS_ATTRIBUTE_DAMAGE)
  local damageActor = combat:GetActor (DETAILS_ATTRIBUTE_DAMAGE, UnitName ("player"))
  
  print(damageActor.damage_taken )

  
end
