function parseRules(undoing)
  full_rules = {}
  rules_with = {}

  rules_with["text"] = {}
  rules_with["be"] = {}
  rules_with["go away"] = {}
  local text_be_go_away = {{"text","be","go away",{{},{}}},{}}
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
  for _,first in ipairs(first_words) do
    local first_unit = first[1]

    local dir = dirs8[first[2]]
    local dx,dy = 0, 0

    local words = {}

    local stopped = false
    while not stopped do
      local x = first_unit.x + dx
      local y = first_unit.y + dy

      local units = getUnitsOnTile(x, y, "text")
      if #units > 0 then
        local new_word = {}

        new_word.name = units[1].textname
        new_word.type = units[1].texttype
        new_word.unit = units[1]

        table.insert(words, new_word)
      else
        stopped = true
      end

      dx = dx + dir[1]
      dy = dy + dir[2]
    end

    local valid, state = parse(words, parser)

    if not valid then
      if #words > 1 then
        table.insert(first_words, {words[2].unit, first[2]})
      end
    else
      if state.word_index <= #words then
        table.insert(first_words, {words[state.word_index-1].unit, first[2]})
      end

      local new_rules = {{},{},{},{{},{}}}

      local function simplify(t, allow_text)
        local name = ""
        local units = {}
        for _,v in ipairs(t) do
          table.insert(units, v.unit)
          if not v.connector then
            if name == "" then
              name = v.name
            elseif v.name == "text" and allow_text then
              name = "text_" .. name
            end
          end
        end
        return name, units
      end

      for _,matches in ipairs(state.matches) do
        for _,targets in ipairs(matches.target) do
          local name, units = simplify(targets, true)
          table.insert(new_rules[1], {name, units})
        end
        if matches.cond then
          for _,conds in ipairs(matches.cond) do
            local name, units = simplify(conds)

            local params = {}
            if conds.target then
              for _,targets in ipairs(conds.target) do
                local name, param_units = simplify(targets, true)
                table.insert(params, name)
                mergeTable(units, param_units)
              end
            end

            table.insert(new_rules[4][1], {name, params, units})
          end
        end
        for _,verbs in ipairs(matches.verb) do
          local name, units = simplify(verbs)
          table.insert(new_rules[2], {name, units})

          local verb_rules = {}
          table.insert(new_rules[3], verb_rules)
          for _,targets in ipairs(verbs.target) do
            local name, units = simplify(targets, true)
            table.insert(verb_rules, {name, units})
          end

          if verbs.cond then
            for _,conds in ipairs(verbs.cond) do
              local name, units = simplify(conds)
    
              local params = {}
              if conds.target then
                for _,targets in ipairs(conds.target) do
                  local name, param_units = simplify(targets, true)
                  table.insert(params, name)
                  mergeTable(units, param_units)
                end
              end
    
              table.insert(new_rules[4][2], {name, params, units})
            end
          end
        end
      end


      for _,a in ipairs(new_rules[1]) do
        for vi,b in ipairs(new_rules[2]) do
          for _,c in ipairs(new_rules[3][vi]) do
            local noun = a[1]
            local noun_texts = a[2]
            local verb = b[1]
            local verb_texts = b[2]
            local prop = c[1]
            local prop_texts = c[2]

            if noun_texts == nil then
              print("nil on: " .. noun .. " - " .. verb .. " - " .. prop)
            end

            if verb == "got" or a[1]:starts("text_") or c[1]:starts("text_") then
              print("added rule: " .. noun .. " " .. verb .. " " .. prop)
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

            local conds = {{},{}}
            for i=1,2 do
              for _,cond in ipairs(new_rules[4][i]) do
                for _,unit in ipairs(cond[3]) do
                  table.insert(all_units, unit)
                  unit.active = true
                  if not unit.old_active and not first_turn and not undoing then
                    addParticles("rule", unit.x, unit.y, unit.color)
                    has_new_rule = true
                  end
                end
                table.insert(conds[i], {cond[1], cond[2]})
              end
            end

            --[[for _,unit in ipairs(stupid_cond_units) do
              table.insert(all_units, unit)
              unit.active = true
              if not unit.old_active and not first_turn and not undoing then
                addParticles("rule", unit.x, unit.y, unit.color)
                has_new_rule = true
              end
              unit.old_active = unit.active
            end]]

            local rule = {{noun,verb,prop,conds},all_units}
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