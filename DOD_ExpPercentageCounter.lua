function f(value)    
   local w = 4
   local p = math.ceil(math.log10(value))
   local prec = value <= 1 and w - 1 or p > w and 0 or w - p
   return string.format('%.' .. prec .. 'f', value)
end

local prevExp = UnitXP('player')

function DOD.CalculateExpPercentage()
    local max = UnitXPMax('player')
    local curr = UnitXP('player')
    local perccurr = curr / max * 100
    local diff = curr - prevExp
    local percdiff = diff / max * 100
    local t = f(diff) .. "(" .. f(percdiff) .. "%) - " .. f(perccurr) .. "% " .. f((max - curr) / diff)
    prevExp = curr

    return t
end
