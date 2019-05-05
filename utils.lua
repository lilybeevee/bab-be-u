function hasProperty(unit,prop)
  if rules_with[unit.name] then
    for _,v in ipairs(rules_with[unit.name]) do
      local rule = v[1]
      if rule[1] == unit.name and rule[2] == "be" and rule[3] == prop then
        return true
      end
    end
  end
  return false
end

function inBounds(x,y)
  return x >= 0 and x < mapwidth and y >= 0 and y < mapheight
end

function removeFromTable(t, obj)
  if not t then
    return
  end
  for i,v in ipairs(t) do
    if v == obj then
      table.remove(t, i)
      return
    end
  end
end

function rotate(dir)
  return (dir-1 + 2) % 4 + 1
end

function rotate8(dir)
  return (dir-1 + 4) % 8 + 1
end

function nameIs(unit,name)
  return unit.name == name or unit.fullname == name
end

function tileHasUnitName(name,x,y)
  local tileid = x + y * mapwidth
  for _,v in ipairs(units_by_tile[tileid]) do
    if nameIs(v, name) then
      return true
    end
  end
end

function getUnitsOnTile(x,y,name)
  if not inBounds(x,y) then
    return {}
  else
    local result = {}
    local tileid = x + y * mapwidth
    for _,unit in ipairs(units_by_tile[tileid]) do
      if not name or (name and nameIs(unit, name)) then
        table.insert(result, unit)
      end
    end
    return result
  end
end

function copyTable(table)
  local new_table = {}
  for k,v in pairs(table) do
    new_table[k] = v
  end
  return new_table
end

function lerp(a,b,t) return (1-t)*a + t*b end

function dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end