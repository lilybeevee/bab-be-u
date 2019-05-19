function parseRules(undoing)
  full_rules = {}
  rules_with = {}

  rules_with["text"] = {}
  rules_with["be"] = {}
  rules_with["go away"] = {}
  local text_be_go_away = {{"text","be","go away",nil},{}}
  table.insert(full_rules, text_be_go_away)
  table.insert(rules_with["text"], text_be_go_away)
  table.insert(rules_with["be"], text_be_go_away)
  table.insert(rules_with["go away"], text_be_go_away)

  local first_words = {}
  if units_by_name["text"] then
    for _,unit in ipairs(units_by_name["text"]) do
      local x,y = unit.x,unit.y
      for i=1,3 do
        local dpos = dirs8[i]
        local ndpos = dirs8[rotate8(i)]

        local dx,dy = dpos[1],dpos[2]
        local ndx,ndy = ndpos[1],ndpos[2]

        local tileid = (x+dx) + (y+dy) * mapwidth
        local ntileid = (x+ndx) + (y+ndy) * mapwidth

        if #getUnitsOnTile(x+ndx, y+ndy, "text") == 0 and #getUnitsOnTile(x+dx, y+dy, "text") >= 1 then
          table.insert(first_words, {unit, i})
        end
      end
      unit.old_active = unit.active
      unit.active = false
    end
  end

  print("-- begin parse --")

  local has_new_rule = false
  --local already_parsed = {}
  local first_words_count = #first_words
  for i,first in ipairs(first_words) do
    local first_unit = first[1]
    local dir = dirs8[first[2]]

    local dx,dy = dir[1],dir[2]
    local prev_type = first_unit.texttype
    local extras = {}
    local first_units = {}
    local new_rules = {{{first_unit.textname,{first_unit}}},{},{},{}} --object, verb, prop, cond
    local unit_queue = {}
    local stage = "start"
    local allow_properties = false

    if i > first_words_count then
      print("extra parse for: " .. first_unit.textname)
    end

    local stopped = false

    while not stopped do
      stopped = true

      local x = first_unit.x + dx
      local y = first_unit.y + dy

      local new_stage = stage
      local found_units = {}
      local all_units = {}
      for _,unit in ipairs(getUnitsOnTile(x, y, "text")) do
        local type = unit.texttype
        local name = unit.textname
        
        table.insert(unit_queue, unit)

        local valid = false
        local valid_rule = false
        if first_unit.texttype ~= "object" then
          valid = false
        elseif stage == "start" then
          if type == "object" and prev_type == "and" then
            valid = true
            table.insert(new_rules[1], {name, copyTable(unit_queue)}) --copyTable(unit_queue) is the text units that make up this part of the rule
            unit_queue = {}
          elseif type == "verb" and prev_type == "object" then
            valid = true
            new_stage = "verb"
            allow_properties = unit.allowprops
            table.insert(new_rules[2], {name, copyTable(unit_queue)})
            unit_queue = {}
          elseif type == "and" and prev_type == "object" then
            valid = true
          elseif type == "cond_infix" and prev_type == "object" then
            valid = true
            new_stage = "cond_infix"
          end
        elseif stage == "cond_infix" then
          if type == "object" and prev_type == "cond_infix" then
            valid = true
            table.insert(new_rules[4], {{"on", {name}}, copyTable(unit_queue)}) --for now i will hardcode On just to see if it works
          elseif type == "verb" and prev_type == "object" then
            valid = true
            new_stage = "verb"
            allow_properties = unit.allowprops
            table.insert(new_rules[2], {name, copyTable(unit_queue)})
            unit_queue = {}
          end
        elseif stage == "verb" then
          if ((type == "property" and allow_properties) or type == "object") and (prev_type == "verb" or prev_type == "and") then
            valid = true
            extras = {}
            table.insert(new_rules[3], {name, copyTable(unit_queue)})
            unit_queue = {}
          elseif type == "and" and ((prev_type == "property" and allow_properties) or prev_type == "object") then
            valid = true
          end
        end

        table.insert(all_units, unit)
        if valid then
          stopped = false
          table.insert(found_units, unit)
        else
          print("false! " .. prev_type .. " > " .. type .. " (" .. stage .. ")")
        end
      end

      stage = new_stage

      if #extras == 0 then
        extras = all_units
      end

      if stopped then
        for _,unit in ipairs(extras) do
          table.insert(first_words, {unit, first[2]})
        end
      else
        prev_type = found_units[1].texttype

        dx = dx + dir[1]
        dy = dy + dir[2]
      end
      
      --table.insert(already_parsed, unit)
    end

    if #new_rules[3] > 0 then
      for _,a in ipairs(new_rules[1]) do
        for _,b in ipairs(new_rules[2]) do
          for _,c in ipairs(new_rules[3]) do
            local noun = a[1]
            local noun_texts = a[2]
            local verb = b[1]
            local verb_texts = b[2]
            local prop = c[1]
            local prop_texts = c[2]

            if noun_texts == nil then
              print("nil on: " .. noun .. " - " .. verb .. " - " .. prop)
            end

            local all_units = {}
            for _,unit in ipairs(noun_texts) do
              table.insert(all_units, unit)
              unit.active = true
              if not unit.old_active and not first_turn and not undoing then
                addParticles("rule", unit.x, unit.y, unit.color)
                has_new_rule = true
              end
              unit.old_active = unit.active
            end
            for _,unit in ipairs(verb_texts) do
              table.insert(all_units, unit)
              unit.active = true
              if not unit.old_active and not first_turn and not undoing then
                addParticles("rule", unit.x, unit.y, unit.color)
                has_new_rule = true
              end
              unit.old_active = unit.active
            end
            for _,unit in ipairs(prop_texts) do
              table.insert(all_units, unit)
              unit.active = true
              if not unit.old_active and not first_turn and not undoing then
                addParticles("rule", unit.x, unit.y, unit.color)
                has_new_rule = true
              end
              unit.old_active = unit.active
            end
            
            local cond = nil--{}
            for _,d in ipairs(new_rules[4]) do --cond's loop is here because conds are optional
              cond = d[1]
              local cond_texts = d[2]
              for _,unit in ipairs(cond_texts) do
                table.insert(all_units, unit)
                unit.active = true
                if not unit.old_active and not first_turn and not undoing then
                  addParticles("rule", unit.x, unit.y, unit.color)
                  has_new_rule = true
                end
                unit.old_active = unit.active
              end
            end
            
            if cond ~= nil then
              print("ok : " .. noun .. " - " .. verb .. " - " .. prop .. " - " .. cond[1] .. " " .. cond[2][1])
            else
              print("ok : " .. noun .. " - " .. verb .. " - " .. prop)
            end

            local rule = {{noun,verb,prop,cond},all_units}
            table.insert(full_rules, rule)

            if not rules_with[noun] then
              rules_with[noun] = {}
            end
            table.insert(rules_with[noun], rule)

            if not rules_with[verb] then
              rules_with[verb] = {}
            end
            table.insert(rules_with[verb], rule)

            if not rules_with[prop] then
              rules_with[prop] = {}
            end
            table.insert(rules_with[prop], rule)
            
            --[[if not rules_with[cond] then
              rules_with[cond] = {}
            end
            table.insert(rules_with[cond], rule)]]--
          end
        end
      end
    end
  end

  if has_new_rule then
    playSound("rule",0.5)
  end
end