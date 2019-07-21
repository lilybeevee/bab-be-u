function clearRules()
  full_rules = {}
  rules_with = {}
  not_rules = {}
  protect_rules = {}

  max_not_rules = 0
  portal_id = ""

  --text and level basically already exist, so no need to be picky.
  addRule({{"text","be","go away pls",{{},{}}},{},1})
  addRule({{"lvl","be","no go",{{},{}}},{},1})
  --TODO: This will need to be automatic on levels with letters/combined words, since a selectr/bordr might be made in a surprising way, and it will need to have its implicit rules apply immediately.
  if (units_by_name["selctr"] or units_by_name["text_selctr"]) then
    addRule({{"selctr","be","u",{{},{}}},{},1})
    addRule({{"selctr","liek","lvl",{{},{}}},{},1})
    addRule({{"selctr","liek","lin",{{},{}}},{},1})
    addRule({{"selctr","be","flye",{{},{}}},{},1})
  end
  if (units_by_name["bordr"] or units_by_name["text_bordr"]) then
    addRule({{"bordr","be","no go",{{},{}}},{},1})
    addRule({{"bordr","be","tall",{{},{}}},{},1})
  end
  if units_by_name["this"] then
    addRule({{"this","be","go away pls",{{},{}}},{},1})
    addRule({{"this","be","wurd",{{},{}}},{},1})
  end
  
  has_new_rule = false
end

function getAllText()
  local hasCopied = false
  local result = units_by_name["text"];
  if (result == nil) then result = {}; end
  
  for name,_ in pairs(rules_effecting_names) do
    if units_by_name[name] then
      for __,unit in ipairs(units_by_name[name]) do
        if hasProperty(unit, "wurd") then
          if not hasCopied then
            result = copyTable(result);
            hasCopied = true;
          end
          table.insert(result, unit);
        else
          unit.active = false
        end
      end
    end
  end
  return result;
end

function getTextOnTile(x, y)
  local result = getUnitsOnTile(x, y, "text");
  
  for name,_ in pairs(rules_effecting_names) do
    for __,unit in ipairs(getUnitsOnTile(x, y, name)) do
      if hasProperty(unit, "wurd") then
        table.insert(result, unit);
      end
    end
  end
  
  return result;
end

function parseRules(undoing)
  if timeless and not hasProperty("text","za warudo") then
    return
  end
  
  local dittos = units_by_name["text_ditto"]
  table.sort(dittos, function(a, b) return a.y < b.y end )
  
  for _,unit in ipairs(dittos) do
    local mimic = getTextOnTile(unit.x,unit.y-1)
    if #mimic == 1 then
      if mimic[1].textname ~= unit.textname then should_parse_rules = true end
      unit.textname = mimic[1].textname
      unit.texttype = mimic[1].texttype
      if mimic[1].color_override ~= nil then
        unit.color_override = mimic[1].color_override
      else
        unit.color_override = mimic[1].color
      end
    else
      unit.textname = "  "
      unit.texttype = "ditto"
      unit.color_override = nil
    end
  end
  
  if (should_parse_rules) then
    should_parse_rules = false
  else
    return
  end
  
  local start_time = love.timer.getTime();
  
  clearRules()
  loop_rules = 0;
  changed_reparsing_rule = true
  
  local reparse_rule_counts = 
  {
    #matchesRule(nil, "be", "wurd"),
    #matchesRule(nil, "be", "poor toll"),
    --TODO: If any wurd rules exist, then these need to check things that are wurd, too - though at that point we may as well just make it easy on ourselves and check everything.
    #matchesRule("text", "be", "go arnd"),
    #matchesRule("text", "be", "mirr arnd"),
    #matchesRule("text", "be", "ortho"),
    #matchesRule("text", "be", "diag"),
    #matchesRule("text", "ben't", "wurd"),
    #matchesRule(outerlvl, "be", "go arnd"),
    #matchesRule(outerlvl, "be", "mirr arnd"),
    --If and only if poor tolls exist, flyeness changing can affect rules parsing, because the text and portal have to match flyeness to go through.
    rules_with["poor toll"] and #matchesRule(nil, "be", "flye") or 0,
    rules_with["poor toll"] and #matchesRule(nil, "be", "tall") or 0,
  };
  
  while (changed_reparsing_rule) do
    changed_reparsing_rule = false
    loop_rules = loop_rules + 1
    if (loop_rules > 100) then
      print("parseRules infinite loop! (100 attempts)")
      destroyLevel("infloop");
    end
  
    local first_words = {}
    local been_first = {}
    for i=1,8 do
      been_first[i] = {}
    end
    
    local units_to_check = getAllText();
    
    if units_to_check then
      for _,unit in ipairs(units_to_check) do
        local x,y = unit.x,unit.y
        for i=1,3 do --right, down-right, down
          local dpos = dirs8[i]
          local ndpos = dirs8[rotate8(i)] --opposite direction

          local dx,dy = dpos[1],dpos[2]
          local ndx,ndy = ndpos[1],ndpos[2]

          local tileid = (x+dx) + (y+dy) * mapwidth
          local ntileid = (x+ndx) + (y+ndy) * mapwidth
          
          local validrule = true
          
          if ((i == 1) or (i == 3)) and hasRule(unit,"be","diag") and not hasRule(unit,"be","ortho") then
            validrule = false
          end
          
          if (i == 2) and hasRule(unit,"be","ortho") and not hasRule(unit,"be","diag") then
            validrule = false
          end
          
          if hasRule(unit,"ben't","wurd") then
            validrule = false
          end

          --print(tostring(x)..","..tostring(y)..","..tostring(dx)..","..tostring(dy)..","..tostring(ndx)..","..tostring(ndy)..","..tostring(#getUnitsOnTile(x+ndx, y+ndy, "text"))..","..tostring(#getUnitsOnTile(x+dx, y+dy, "text")))
          if (#getTextOnTile(x+ndx, y+ndy) == 0) and validrule then
            if not been_first[i][x + y * mapwidth] then
              table.insert(first_words, {unit, i})
              been_first[i][x + y * mapwidth] = true
            end
          end
        end
        if (loop_rules == 1) then
          unit.old_active = unit.active
        end
        unit.active = false
        unit.blocked = false
        unit.used_as = {}
      end
    end

    local final_rules = {}
    --local already_parsed = {}
    local first_words_count = #first_words
    for _,first in ipairs(first_words) do 
      local first_unit = first[1] -- {unit,direction}
      local last_unit = first[1]

      local dir = first[2]
      local x,y = first_unit.x, first_unit.y
      local dx,dy = dirs8[dir][1], dirs8[dir][2]

      local words = {}
      local been_here = {}

      local stopped = false
      while not stopped do
        if been_here[x + y * mapwidth] == 2 then
          stopped = true
        else
          local new_words = {}
          local get_next_later = false

          local units = getTextOnTile(x, y)
          if #units > 0 then
            for _,unit in ipairs(units) do
              local new_word = {}

              new_word.name = unit.textname
              new_word.type = unit.texttype
              new_word.unit = unit

              last_unit = unit

              table.insert(new_words, new_word)
            end

            table.insert(words, new_words)
          else
            stopped = true
          end

          dx, dy, dir, x, y = getNextTile(last_unit, dx, dy, dir)

          if not been_here[x + y * mapwidth] then --can only go to each tile twice each first word; why?
            been_here[x + y * mapwidth] = 1
          else
            been_here[x + y * mapwidth] = 2
          end
        end
      end --while not stopped

      local sentences = getCombinations(words)
      if #sentences > 10 then
        --print(fullDump(words, 2))
      end

      for _,sentence in ipairs(sentences) do
        parseSentence(sentence, {been_first, first_words, final_rules, first}) -- split into a new function located below to organize this slightly more
      end
    end
    
    clearRules()
    
    for _,final in ipairs(final_rules) do
      local new_rules = final[1]
      local dir = final[2]
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

            --if verb == "got" or a[1]:starts("text_") or c[1]:starts("text_") then
              --print("added rule: " .. noun .. " " .. verb .. " " .. prop)
            --end

            local all_units = {}
            for _,unit in ipairs(noun_texts) do
              if not table.has_value(unit.used_as, "noun") then table.insert(unit.used_as, "noun") end
              table.insert(all_units, unit)
            end
            for _,unit in ipairs(verb_texts) do
              if not table.has_value(unit.used_as, "verb") then table.insert(unit.used_as, "verb") end
              table.insert(all_units, unit)
            end
            for _,unit in ipairs(prop_texts) do
              if not table.has_value(unit.used_as, "property") then table.insert(unit.used_as, "property") end
              table.insert(all_units, unit)
            end

            local conds = {{},{}}
            for i=1,2 do
              for _,cond in ipairs(new_rules[4][i]) do
                for _,unit in ipairs(cond[3]) do
                  table.insert(all_units, unit)
                end
                table.insert(conds[i], {cond[1], cond[2], cond[3]})
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

            local rule = {{noun,verb,prop,conds},all_units,dir}
            addRule(rule)
          end
        end
      end
    end
    
    postRules()
    
    --TODO: This works in non-contrived examples, but isn't necessarily robust - for example, if after reparsing, you add one word rule while subtracting another word rule, it'll think nothing has changed. The only way to be ABSOLUTELY robust is to compare that the exact set of parsing effecting rules hasn't changed.
    local reparse_rule_counts_new = 
    {
    #matchesRule(nil, "be", "wurd"),
    #matchesRule(nil, "be", "poor toll"),
    #matchesRule("text", "be", "go arnd"),
    #matchesRule("text", "be", "mirr arnd"),
    #matchesRule("text", "be", "ortho"),
    #matchesRule("text", "be", "diag"),
    #matchesRule("text", "ben't", "wurd"),
    #matchesRule(outerlvl, "be", "go arnd"),
    #matchesRule(outerlvl, "be", "mirr arnd"),
    --If and only if poor tolls exist, flyeness changing can affect rules parsing, because the text and portal have to match flyeness to go through.
    rules_with["poor toll"] and #matchesRule(nil, "be", "flye") or 0
    };
    
    for i = 1,#reparse_rule_counts do
      if reparse_rule_counts[i] ~= reparse_rule_counts_new[i] then
        --print(reparse_rule_counts[i]..reparse_rule_counts_new[i])
        changed_reparsing_rule = true
        break
      end
    end
    
    reparse_rule_counts = reparse_rule_counts_new;
    
    rules_effecting_names = {}
  
    populateRulesEffectingNames("?", "be", "wurd");
    populateRulesEffectingNames("?", "be", "poor toll");
  end
  
  shouldReparseRules()
  
  local end_time = love.timer.getTime();
  print("parseRules() took: "..tostring(round((end_time-start_time)*1000)).."ms")
end

function parseSentence (sentence_, params_) --prob make this a local function? idk
  --print("parsing... "..fullDump(sentence_))
  local been_first = params_[1] --splitting up the params like this was because i was too lazy
  local first_words = params_[2] -- all of them are tables anyway, so it ends up referencing properly
  local final_rules = params_[3]
  local first = params_[4]
  local sentence = copyTable(sentence_, 1)

  for orig_index,word in ipairs(sentence) do
    if word.type == "letter" then --letter handling
      --print("found a letter"..orig_index)

      local new_word = ""
      local word_index = orig_index
      local letter = sentence[word_index]
      while letter.type == "letter" do --find out where the letters end, throw all of them into a string tho
        new_word = new_word..letter.name
        word_index = word_index + 1
        letter = sentence[word_index]
        --print("looping... "..new_word.." "..word_index)
        if letter == nil then break end --end of array ends up hitting this case
      end

      local lsentences = findLetterSentences(new_word) --get everything valid out of the letter string (this should be [both], hmm)
      --[[if (#lsentences.start ~= 0 or #lsentences.endd ~= 0 or #lsentences.middle ~= 0 or #lsentences.both ~= 0) then
        print(new_word.." --> "..fullDump(lsentences))
      end]]

      local before_sentence = {}
      for i=1,orig_index-1 do
        table.insert(before_sentence,sentence[i])
      end
      local after_sentence = {}
      if word_index <= #sentence then
        for i=word_index,#sentence do
          table.insert(after_sentence,sentence[i])
        end
      end

      local pos_x = sentence[orig_index].unit.x
      local pos_y = sentence[orig_index].unit.y
      --print("coords: "..pos_x..", "..pos_y)

      local len = word_index-orig_index
      for _,s in ipairs(lsentences.middle) do
        local words = fillTextDetails(s, pos_x, pos_y, first[2], len)
        parseSentence(words, params_)
      end
      for _,s in ipairs(lsentences.start) do
        local words = fillTextDetails(s, pos_x, pos_y, first[2], len)
        local before_copy = copyTable(before_sentence) --copying is required because addTables puts results in the first table
        addTables(before_copy, words)
        parseSentence(before_copy, params_)
      end
      for _,s in ipairs(lsentences.endd) do
        local words = fillTextDetails(s, pos_x, pos_y, first[2], len)
        addTables(words, after_sentence)
        parseSentence(words, params_)
      end
      for _,s in ipairs(lsentences.both) do
        local words = fillTextDetails(s, pos_x, pos_y, first[2], len)
        local before_copy = copyTable(before_sentence)
        addTables(words, after_sentence)
        addTables(before_copy, words)
        --print("end dump: "..dumpOfProperty(before_copy, "name"))
        parseSentence(before_copy, params_)
      end

      parseSentence(before_sentence, params_)
      parseSentence(after_sentence, params_)
      return --no need to continue past this point, since the letters suffice
    end
  end

  local valid, state = parse(sentence, parser)

  if not valid then
    if #sentence > 1 then
      local unit = sentence[2].unit --the second word, so the condition?
      if not been_first[first[2]][unit.x + unit.y * mapwidth] then --first[2] is direction
        table.insert(first_words, {sentence[2].unit, first[2]})
        been_first[first[2]][unit.x + unit.y * mapwidth] = true
      end
    end
  else
    if state.word_index <= #sentence then
      local unit = sentence[state.word_index-1].unit
      if not been_first[first[2]][unit.x + unit.y * mapwidth] then
        table.insert(first_words, {sentence[state.word_index-1].unit, first[2]})
        been_first[first[2]][unit.x + unit.y * mapwidth] = true
      end
    end
    for i = 1, state.word_index-1 do
      local unit = sentence[i].unit
      --print(sentence[i].name)
      been_first[first[2]][unit.x + unit.y * mapwidth] = true
    end

    local new_rules = {{},{},{},{{},{}}}

    local function simplify(t)
      local name = ""
      local units = {}
      for _,v in ipairs(t) do
        table.insert(units, v.unit)
        if not v.connector then
          name = v.name
          local suffix = ""
          if v.mods then
            for _,mod in ipairs(v.mods) do
              table.insert(units, mod.unit)
              if mod.name == "text" then
                name = v.unit.fullname
              elseif mod.name == "nt" then
                suffix = suffix .. "n't"
              end
            end
          end
          name = name .. suffix
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

    table.insert(final_rules, {new_rules, dir})
  end
end

function addRule(full_rule)
  local rules = full_rule[1]
  local units = full_rule[2]
  local dir = full_rule[3]

  local subject = rules[1]
  local verb = rules[2]
  local object = rules[3]
  local conds = rules[4]

  local subject_not = 0
  local verb_not = 0
  local object_not = 0

  while subject:ends("n't") do subject, subject_not = subject:sub(1, -4), subject_not + 1 end
  while verb:ends("n't")    do verb,       verb_not =    verb:sub(1, -4),    verb_not + 1 end
  while object:ends("n't")  do object,   object_not =  object:sub(1, -4),  object_not + 1 end
	print(subject, verb, object, subject_not, verb_not, object_not)

  if verb_not > 0 then
    verb = rules[2]:sub(1, -4)
  end

  for _,unit in ipairs(units) do
    unit.active = true
    if not unit.old_active and not first_turn then
      addParticles("rule", unit.x, unit.y, unit.color)
      has_new_rule = true
    end
    unit.old_active = unit.active
  end

  if subject == "every1" then
    if subject_not % 2 == 1 then
      return
    else
      for _,v in ipairs(referenced_objects) do
        addRule({{v, rules[2], rules[3], rules[4]}, units, dir})
      end
    end
  elseif subject_not % 2 == 1 then
    if tiles_by_name[subject] or subject == "text" then
      local new_subjects = getEverythingExcept(subject)
      for _,v in ipairs(new_subjects) do
        addRule({{v, rules[2], rules[3], rules[4]}, units, dir})
      end
      return
    end
  end 

  if object == "every1" then
    if object_not % 2 == 1 then
      return
    elseif verb ~= "be" and verb ~= "ben't" then
      --we'll special case x be every1 in convertUnit now
      for _,v in ipairs(referenced_objects) do
        addRule({{rules[1], rules[2], v, rules[4]}, units, dir})
      end
    end
  elseif object_not % 2 == 1 then
    if tiles_by_name[object] or object == "text" or object == "mous" then
      local new_objects = {}
      --skul be skul turns into skul ben't skuln't - but this needs to apply even to special objects (specific text, txt, no1, lvl, mous).
      if verb == "be" and verb_not % 2 == 1 then
        new_objects = getAbsolutelyEverythingExcept(object)
      else
        new_objects = getEverythingExcept(object)
      end
      for _,v in ipairs(new_objects) do
        addRule({{rules[1], rules[2], v, rules[4]}, units, dir})
      end
      --txt be txt needs to also apply for flog txt, bab txt, etc.
      if (object == "text" and verb == "be" and verb_not % 2 == 1) then
        for i,ref in ipairs(referenced_text) do
          for _,v in ipairs(new_objects) do
            addRule({{ref, rules[2], v, rules[4]}, units, dir})
          end
        end
      end
      return
    end
  end

  if verb_not > 0 then
    if not not_rules[verb_not] then
      not_rules[verb_not] = {}
      max_not_rules = math.max(max_not_rules, verb_not)
    end
    table.insert(not_rules[verb_not], {{subject, verb, object, conds}, units, dir})

    -- for specifically checking NOT rules
    table.insert(full_rules, {{subject, verb .. "n't", object, conds}, units, dir})
  elseif (verb == "be") and (subject == object or (subject:starts("text_") and object == "text")) then
    --print("protecting: " .. subject .. ", " .. object)
    addRule({{subject, "ben't", object .. "n't", conds}, units, dir})
  else
    table.insert(full_rules, {{subject, verb, object, conds}, units, dir})
  end
end

function postRules()
  local all_units = {}

  -- Step 1:
  -- Block & remove rules if they're N'T'd out
  for n = max_not_rules, 1, -1 do
    if not_rules[n] then
      for _,rules in ipairs(not_rules[n]) do
        local rule = rules[1]
        local conds = rule[4]

        local inverse_conds = {{},{}}
        for i=1,2 do
          for _,cond in ipairs(conds[i]) do
            local new_cond = copyTable(cond)
            if new_cond[1]:ends("n't") then
              new_cond[1] = new_cond[1]:sub(1, -4)
            else
              new_cond[1] = new_cond[1] .. "n't"
            end
            table.insert(inverse_conds[i], new_cond)
          end
        end

        local has_conds = (#conds[1] > 0 or #conds[2] > 0)

        local function blockRules(t, n)
          local blocked_rules = {}
          for _,frules in ipairs(t) do
            local frule = frules[1]
            local fverb = frule[2]
            if n then
              fverb = fverb .. "n't"
            end
            if frule[1] == rule[1] and fverb == rule[2] and frule[3] == rule[3] then
              --print("matching rule", rule[1], rule[2], rule[3])
              if has_conds then
                for i=1,2 do
                  for _,cond in ipairs(inverse_conds[i]) do
                    table.insert(frule[4][i], cond)
                  end
                end
              else
                table.insert(blocked_rules, frules)
              end
            end
          end

          for _,blocked in ipairs(blocked_rules) do
            for _,unit in ipairs(blocked[2]) do
              unit.blocked = true
              unit.blocked_dir = blocked[3]
            end
            removeFromTable(t, blocked)
          end
        end

        if not_rules[n - 1] then
          blockRules(not_rules[n - 1], true)
        end
        blockRules(full_rules)

        mergeTable(all_units, rules[2])
      end
    end
  end

  -- Step 2:
  -- Add all remaining rules to lookup tables
  for _,rules in ipairs(full_rules) do
    local rule = rules[1]

    local subject, verb, object = rule[1], rule[2], rule[3]

    if not rules_with[subject] then
      rules_with[subject] = {}
    end
    table.insert(rules_with[subject], rules)

    if not rules_with[verb] then
      rules_with[verb] = {}
    end
    if (verb ~= subject) then
      table.insert(rules_with[verb], rules)
    end

    if not rules_with[object] then
      rules_with[object] = {}
    end
    if (object ~= subject and object ~= verb) then
      table.insert(rules_with[object], rules)
    end

    mergeTable(all_units, rules[2])
  end

  -- Step 3:
  -- Unblock any units in an unblocked rule
  for _,unit in ipairs(all_units) do
    unit.blocked = false
  end

  if has_new_rule then
    playSound("rule", 0.5)
  end
end

function shouldReparseRules()
  if should_parse_rules then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "wurd") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "poor toll") then return true end
  --TODO: If any wurd rules exist, then these need to check things that are wurd, too - though at that point we may as well just make it easy on ourselves and check everything.
  if shouldReparseRulesIfConditionalRuleExists("text", "be", "go arnd") then return true end
  if shouldReparseRulesIfConditionalRuleExists("text", "be", "mirr arnd") then return true end
  if shouldReparseRulesIfConditionalRuleExists("text", "be", "ortho") then return true end
  if shouldReparseRulesIfConditionalRuleExists("text", "be", "diag") then return true end
  if shouldReparseRulesIfConditionalRuleExists("text", "ben't", "wurd") then return true end
  if shouldReparseRulesIfConditionalRuleExists(outerlvl, "be", "go arnd") then return true end
  if shouldReparseRulesIfConditionalRuleExists(outerlvl, "be", "mirr arnd") then return true end
  if rules_with["poor toll"] then
    if shouldReparseRulesIfConditionalRuleExists("?", "be", "flye") then return true end
    if shouldReparseRulesIfConditionalRuleExists("?", "be", "tall") then return true end
  end
  return false
end

function populateRulesEffectingNames(r1, r2, r3)
  local rules = matchesRule(r1, r2, r3);
  for _,rule in ipairs(rules) do
    local subject = rule[1][1];
    if (subject:sub(1, 4) ~= "text") then
      rules_effecting_names[subject] = true;
    end
  end
end

function shouldReparseRulesIfConditionalRuleExists(r1, r2, r3)
  local rules = matchesRule(r1, r2, r3);
  for _,rule in ipairs(rules) do
    local subject_cond = rule[1][4][1];
    if (#subject_cond > 0) then
      should_parse_rules = true;
    return true;
    end
  end
  return false;
end