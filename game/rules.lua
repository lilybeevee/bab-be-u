old_rules_with = {}

function clearRules()
  full_rules = {}
  old_rules_with = rules_with
  rules_with = {}
  not_rules = {}
  protect_rules = {}

  max_not_rules = 0
  portal_id = ""

  --text and level basically already exist, so no need to be picky.
  addBaseRule("text","be","go away pls")
  addBaseRule("lvl","be","no go")
  --TODO: This will need to be automatic on levels with letters/combined words, since a selectr/bordr might be made in a surprising way, and it will need to have its implicit rules apply immediately.
  if (units_by_name["selctr"] or units_by_name["text_selctr"]) then
    addBaseRule("selctr","be","u")
    addBaseRule("selctr","liek","pathz")
    addBaseRule("lvl","be","pathz")
		addBaseRule("lin","be","pathz")
    addBaseRule("selctr","be","flye")
  end
  if (units_by_name["bordr"] or units_by_name["text_bordr"]) then
    addBaseRule("bordr","be","no go")
    addBaseRule("bordr","be","tall")
		addBaseRule("bordr","be","opaque")
  end
  if units_by_name["this"] then
    addBaseRule("this","be","go away pls")
    addBaseRule("this","be","wurd")
  end

  has_new_rule = false
end

function getAllText()
  local hasCopied = false
  local result = units_by_name["text"];
  if (result == nil) then result = {}; end
  --remove ben't wurd text from result
  if rules_with["wurd"] ~= nil then
    result = copyTable(result);
    hasCopied = true;
    for i = #result,1,-1 do
      if hasRule(result[i],"ben't","wurd") then
        table.remove(result, i)
      end
    end
  end
  
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
  --remove ben't wurd text from result
  if rules_with ~= nil and rules_with["wurd"] ~= nil then
    for i = #result,1,-1 do
      if hasRule(result[i],"ben't","wurd") then
        table.remove(result, i)
      end
    end
  end
  
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
  if (should_parse_rules) then
    should_parse_rules = false
  else
    return
  end
  
  --refresh name/type/color of dittos in reading order (top to bottom)
  local dittos = units_by_name["text_ditto"]
  if (dittos ~= nil) then
  table.sort(dittos, function(a, b) return a.y < b.y end ) 
    for _,unit in ipairs(dittos) do
      local mimic = getTextOnTile(unit.x,unit.y-1)
      if #mimic == 1 then
        unit.textname = mimic[1].textname
        unit.texttype = mimic[1].texttype
        if mimic[1].color_override ~= nil then
          unit.color_override = mimic[1].color_override
        else
          unit.color_override = mimic[1].color
        end
      else
        unit.textname = "  "
      end
    end
  end
  
  local start_time = love.timer.getTime();
  
  clearRules()
  loop_rules = 0;
  changed_reparsing_rule = true
  
  local reparse_rule_counts = 
  {
    #matchesRule(nil, "be", "wurd"),
    #matchesRule(nil, "be", "poor toll"),
    --TODO: We care about text, specific text and wurd units - this can't be easily specified to matchesRule.
    #matchesRule(nil, "be", "go arnd"),
    #matchesRule(nil, "be", "mirr arnd"),
    #matchesRule(nil, "be", "ortho"),
    #matchesRule(nil, "be", "diag"),
    #matchesRule(nil, "ben't", "wurd"),
    #matchesRule(nil, "be", "za warudo"),
    #matchesRule(nil, "be", "rong"),
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
        parseSentence(sentence, {been_first, first_words, final_rules, first}, dir) -- split into a new function located below to organize this slightly more
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

            addRuleSimple({noun, conds[1]}, verb, {prop, conds[2]}, all_units, dir)
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
    --TODO: We care about text, specific text and wurd units - this can't be easily specified to matchesRule.
    #matchesRule(nil, "be", "go arnd"),
    #matchesRule(nil, "be", "mirr arnd"),
    #matchesRule(nil, "be", "ortho"),
    #matchesRule(nil, "be", "diag"),
    #matchesRule(nil, "ben't", "wurd"),
    #matchesRule(nil, "be", "za warudo"),
    #matchesRule(nil, "be", "rong"),
    #matchesRule(outerlvl, "be", "go arnd"),
    #matchesRule(outerlvl, "be", "mirr arnd"),
    --If and only if poor tolls exist, flyeness changing can affect rules parsing, because the text and portal have to match flyeness to go through.
    rules_with["poor toll"] and #matchesRule(nil, "be", "flye") or 0,
    rules_with["poor toll"] and #matchesRule(nil, "be", "tall") or 0,
    };
    
    for i = 1,#reparse_rule_counts do
      if reparse_rule_counts[i] ~= reparse_rule_counts_new[i] then
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
  if not unit_tests then print("parseRules() took: "..tostring(round((end_time-start_time)*1000)).."ms") end
end

function parseSentence(sentence_, params_, dir) --prob make this a local function? idk
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
        local words = fillTextDetails(s, sentence, orig_index, word_index)
        parseSentence(words, params_, dir)
      end
      for _,s in ipairs(lsentences.start) do
        local words = fillTextDetails(s, sentence, orig_index, word_index)
        local before_copy = copyTable(before_sentence) --copying is required because addTables puts results in the first table
        addTables(before_copy, words)
        parseSentence(before_copy, params_, dir)
      end
      for _,s in ipairs(lsentences.endd) do
        local words = fillTextDetails(s, sentence, orig_index, word_index)
        addTables(words, after_sentence)
        parseSentence(words, params_, dir)
      end
      for _,s in ipairs(lsentences.both) do
        local words = fillTextDetails(s, sentence, orig_index, word_index)
        local before_copy = copyTable(before_sentence)
        addTables(words, after_sentence)
        addTables(before_copy, words)
        --print("end dump: "..dumpOfProperty(before_copy, "name"))
        parseSentence(before_copy, params_, dir)
      end

      parseSentence(before_sentence, params_, dir)
      parseSentence(after_sentence, params_, dir)
      return --no need to continue past this point, since the letters suffice
    end
  end

  --print("just after letters:", dump(sentence))
  local valid, state = parse(sentence, parser)
  --print(dump(state))

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
      --print(dump(sentence[i]))
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
              else
                suffix = suffix .. " " .. mod.name
              end
            end
          end
          name = name .. suffix
        end
      end
      return name, units
    end

    --print(dump(state.extra_words))
    
    for _,matches in ipairs(state.matches) do
      for _,targets in ipairs(matches.target) do
        local name, units = simplify(targets, true)
        for _,extra_word in ipairs(state.extra_words) do
          table.insert(units, extra_word.unit);
        end
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
  -- print(fullDump(full_rule))
  local rules = full_rule.rule
  local units = full_rule.units
  local dir = full_rule.dir

  local subject = rules.subject.name
  local verb = rules.verb
  local object = rules.object.name

  local subject_not = 0
  local verb_not = 0
  local object_not = 0
  
  for _,unit in ipairs(units) do
    unit.active = true
    if not unit.old_active and not first_turn then
      addParticles("rule", unit.x, unit.y, unit.color)
      has_new_rule = true
    end
    unit.old_active = unit.active
  end
  
  for _,unit in ipairs(units) do
    if (not rong and old_rules_with["rong"] ~= nil) then
      local temp = rules_with; rules_with = old_rules_with;
      if hasProperty(unit, "rong") then
        for __,unit2 in ipairs(units) do
          unit2.blocked = true;
          unit2.blocked_dir = dir
        end
        rules_with = temp;
        return;
      end
      rules_with = temp;
    end
  end
  
  while subject:ends("n't") do subject, subject_not = subject:sub(1, -4), subject_not + 1 end
  while verb:ends("n't")    do verb,       verb_not =    verb:sub(1, -4),    verb_not + 1 end
  while object:ends("n't")  do object,   object_not =  object:sub(1, -4),  object_not + 1 end
	--print(subject, verb, object, subject_not, verb_not, object_not)

  if verb_not > 0 then
    verb = rules.verb:sub(1, -4)
  end
  
  --Special THIS check - if we write this be this or this ben't this, it should work like the tautology/paradox it does for other objects, even though they are TECHNICALLY different thises.
  if subject:starts("this") and object:starts("this") and subject_not == 0 and object_not == 0 and subject ~= object then
    addRuleSimple(rules.subject, rules.verb, {rules.subject.name, rules.object.conds}, units, dir)
    return
  end

  if subject == "every1" then
    if subject_not % 2 == 1 then
      return
    else
      for _,v in ipairs(referenced_objects) do
        addRuleSimple({v, rules.subject.conds}, rules.verbs, rules.object, units, dir)
      end
    end
  elseif subject_not % 2 == 1 then
    if tiles_by_name[subject] or subject == "text" then
      local new_subjects = getEverythingExcept(subject)
      for _,v in ipairs(new_subjects) do
        addRuleSimple({v, rules.subject.conds}, rules.verbs, rules.object, units, dir)
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
        addRuleSimple(rules.subject, rules.verb, {v, rules.object.conds}, units, dir)
      end
    end
  elseif object_not % 2 == 1 then
    if tiles_by_name[object] or object:starts("this") or object == "text" or object == "mous" then
      local new_objects = {}
      --skul be skul turns into skul ben't skuln't - but this needs to apply even to special objects (specific text, txt, no1, lvl, mous).
      if verb == "be" and verb_not % 2 == 1 then
        new_objects = getAbsolutelyEverythingExcept(object)
      else
        new_objects = getEverythingExcept(object)
      end
      for _,v in ipairs(new_objects) do
        addRuleSimple(rules.subject, rules.verb, {v, rules.object.conds}, units, dir)
      end
      --txt be txt needs to also apply for flog txt, bab txt, etc.
      if (object == "text" and verb == "be" and verb_not % 2 == 1) then
        for i,ref in ipairs(referenced_text) do
          for _,v in ipairs(new_objects) do
            addRuleSimple({ref, rules.subject.conds}, rules.verb, {v, rules.object.conds}, units, dir)
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
    -- print("full_rule:", fullDump(full_rule))
    table.insert(not_rules[verb_not], full_rule)

    -- for specifically checking NOT rules
    table.insert(full_rules, {rule = {subject = rules.subject, verb = verb .. "n't", object = rules.object}, units = units, dir = dir})
  elseif (verb == "be") and (subject == object or (subject:starts("text_") and object == "text")) then
    --print("protecting: " .. subject .. ", " .. object)
    addRuleSimple(rules.subject, "ben't", {object .. "n't", rules.object.conds}, units, dir)
  else
    table.insert(full_rules, full_rule)
  end
end

function postRules()
  local all_units = {}

	-- Step 0:
	-- Determine group membership, and rewrite rules involving groups into their membership versions
	-- TODO: this probably malfunctions horribly if you reference two different groups in the same rule, and it doesn't handle groups in conditions, and it doesn't handle conditional membership, and it doesn't handle ben't group, and whatever other special cases you can come up with
	group_membership = {}
	
	for _,group in ipairs(group_names) do
		group_membership[group] = {}
		for _,rules in ipairs(full_rules) do
			local rule = rules.rule

			local subject, verb, object = rule.subject, rule.verb, rule.object
			if verb == "be" and object == group then
				group_membership[group][subject] = true
			end
		end
	end
	
	for _,group in ipairs(group_names) do
		for _,rules in ipairs(full_rules) do
			local rule = rules.rule

			local subject, verb, object = rule.subject, rule.verb, rule.object
			if object == group and verb ~= "be" then
				if subject == group then
					for member1,_ in pairs(group_membership[group]) do
						for member2,_ in pairs(group_membership[group]) do
							local newRules = deepCopy(rules);
							newRules.subject.name = member1;
							newRules.object.name = member2;
							addRuleSimple(unpack(newRules));
						end
					end
				else
					for member,_ in pairs(group_membership[group]) do
						local newRules = deepCopy(rules);
						newRules.object.name = member;
						addRuleSimple(unpack(newRules));
					end
				end
			elseif subject == group then
				for member,_ in pairs(group_membership[group]) do
					local newRules = deepCopy(rules);
					newRules.subject.name = member;
					addRuleSimple(unpack(newRules));
				end
			end
		end
	end
	
  -- Step 1:
  -- Block & remove rules if they're N'T'd out
  for n = max_not_rules, 1, -1 do
    if not_rules[n] then
      for _,rules in ipairs(not_rules[n]) do
        local rule = rules.rule
        local conds = {rule.subject.conds, rule.object.conds}

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
            local frule = frules.rule
            local fverb = frule.verb
            if n then
              fverb = fverb .. "n't"
            end
            -- print("frule:", fullDump(frule))
            if frule.subject.name == rule.subject.name and fverb == rule.verb and
            frule.object.name == rule.object.name and frule.object.name ~= "her" and frule.object.name ~= "thr" then
              -- print("matching rule", rule[1][1], rule[2], rule[3][1])
              if has_conds then
                for _,cond in ipairs(inverse_conds[1]) do
                  table.insert(frule.subject.conds, cond)
                end
                for _,cond in ipairs(inverse_conds[2]) do
                  table.insert(frule.object.conds, cond)
                end
              else
                table.insert(blocked_rules, frules)
              end
            end
          end

          for _,blocked in ipairs(blocked_rules) do
            for _,unit in ipairs(blocked.units) do
              unit.blocked = true
              unit.blocked_dir = blocked.dir
            end
            -- print("blocked:", fullDump(blocked))
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
    local rule = rules.rule

    local subject, verb, object = rule.subject.name, rule.verb, rule.object.name

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
  --TODO: We care about text, specific text and wurd units - this can't be easily specified to matchesRule.
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "go arnd") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "mirr arnd") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "ortho") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "diag") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "ben't", "wurd") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "za warudo") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "rong") then return true end
  if rules_with["poor toll"] then
    if shouldReparseRulesIfConditionalRuleExists("?", "be", "flye") then return true end
    if shouldReparseRulesIfConditionalRuleExists("?", "be", "tall") then return true end
  end
  return false
end

function populateRulesEffectingNames(r1, r2, r3)
  local rules = matchesRule(r1, r2, r3);
  for _,rule in ipairs(rules) do
    local subject = rule.rule.subject.name;
    if (subject:sub(1, 4) ~= "text") then
      rules_effecting_names[subject] = true;
    end
  end
end

function shouldReparseRulesIfConditionalRuleExists(r1, r2, r3)
  local rules = matchesRule(r1, r2, r3);
  for _,rule in ipairs(rules) do
    local subject_cond = rule.rule.subject.conds;
    if (#subject_cond > 0) then
      should_parse_rules = true;
    return true;
    end
  end
  return false;
end