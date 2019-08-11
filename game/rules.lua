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
  if units_by_name["text_nuek"] then
    addBaseRule("xplod","be","protecc")
    addBaseRule("xplod","be","moar")
    addBaseRule("xplod","ignor","lvl")
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
    should_parse_rules_at_turn_boundary = false
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

          if not been_here[x + y * mapwidth] then --can only go to each tile twice each first word; so that if we have a wrap/portal infinite loop we don't softlock
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
      addRule(final)
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
  -- print("parsing... "..fullDump(sentence_))
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
      local prevletter = {}
      while letter.type == "letter" do --find out where the letters end, throw all of them into a string tho
        --here's how umlauts / colons work: for every letter that could be affected by the presence of a colon, special case it here
        --when special casing, change the name to include the umlaut / colon in it. then, later, don't count colons when adding to the string, since the letter already accounts for it
        --for the letter u, it always needs to check the tile above it, so we don't need to use prevletter, since the umlaut might not be in the rule directly
        --for letters relating to making a face, such as ":)", the colon needs to be the letter before it, so just before we change letter we store it as prevletter for the next letter to use
        --then, when we find something like a parantheses, we check the previous letter to see if it's a colon and if it was facing the right direction, and if it meets both of those, set the name of the unit to both
        --since this all happens per rule, crosswording should be unaffected
        --...doesn't work yet but that was my plan
        local unit = letter.unit
        local prevunit = prevletter.unit or {}
        local name = letter.name
        if letter.name == "u" then
          local umlauts = getTextOnTile(unit.x,unit.y-1)
          for _,umlaut in ipairs(umlauts) do
            if umlaut.fullname == "letter_colon" and umlaut.dir == 3 then
              name = "..u"
            end
          end
        elseif letter.name == "o" then
          if prevletter.name == ":" and prevunit.dir == dir then
            name = ":o"
          end
        elseif letter.name == ")" then
          if prevletter.name == ":" and prevunit.dir == dir then
            name = ":)"
          end
        elseif letter.name == "(" then
          if prevletter.name == ":" and prevunit.dir == dir then
            name = ":("
          end
        end
        
        if name ~= ":" then
          new_word = new_word..name
        end
        
        prevletter = letter
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
  
  local function addUnits(list, set, root)
    if root.unit and not set[root.unit] then
      table.insert(list, root.unit)
      set[root.unit] = true
      if root.conds then
        for _,cond in ipairs(root.conds) do
          addUnits(list, set, cond)
        end
      end
      if root.others then
        for _,other in ipairs(root.others) do
          addUnits(list, set, other)
        end
      end
      if root.mods then
        for _,mod in ipairs(root.mods) do
          addUnits(list, set, mod)
        end
      end
    end
  end

  -- print("just after letters:", dump(sentence))
  while (#sentence > 2) do
    local words = copyTable(sentence)
    local valid, rules, extra_words = parse(words, dir)
    --print(dump(state))

    if valid then
      for i,rule in ipairs(rules) do
        local list = {}
        local set = {}
        for _,word in ipairs(extra_words) do
          addUnits(list, set, word)
        end
        addUnits(list, set, rule.subject)
        addUnits(list, set, rule.verb)
        addUnits(list, set, rule.object)
        local full_rule = {rule = rule, units = list, dir = dir}
        -- print(fullDump(full_rule))
        table.insert(final_rules, full_rule)
      end
      sentence = words
    else
      table.remove(sentence, 1)
    end
  end
end

function addRule(full_rule)
  -- print(fullDump(full_rule))
  local rules = full_rule.rule
  local units = full_rule.units
  local dir = full_rule.dir

  local subject = rules.subject.name
  local verb = rules.verb.name
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
    verb = rules.verb.name:sub(1, -4)
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
        addRuleSimple({v, rules.subject.conds}, rules.verb, rules.object, units, dir)
      end
    end
  elseif subject_not % 2 == 1 then
    if tiles_by_name[subject] or subject == "text" then
      local new_subjects = getEverythingExcept(subject)
      for _,v in ipairs(new_subjects) do
        addRuleSimple({v, rules.subject.conds}, rules.verb, rules.object, units, dir)
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
        -- print(fullDump(rules))
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
    table.insert(full_rules, {rule = {subject = rules.subject, verb = {name = verb .. "n't"}, object = rules.object}, units = units, dir = dir})
  elseif (verb == "be") and (subject == object or (subject:starts("text_") and object == "text")) then
    --print("protecting: " .. subject .. ", " .. object)
    addRuleSimple(rules.subject, {"ben't"}, {object .. "n't", rules.object.conds}, units, dir)
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
        local conds = {rule.subject.conds or {}, rule.object.conds or {}}

        local inverse_conds = {{},{}}
        for i=1,2 do
          for _,cond in ipairs(conds[i]) do
            local new_cond = copyTable(cond)
            if new_cond.name:ends("n't") then
              new_cond.name = new_cond.name:sub(1, -4)
            else
              new_cond.name = new_cond.name .. "n't"
            end
            table.insert(inverse_conds[i], new_cond)
          end
        end

        local has_conds = (#conds[1] > 0 or #conds[2] > 0)

        local function blockRules(t, n)
          local blocked_rules = {}
          for _,frules in ipairs(t) do
            local frule = frules.rule
            -- print(fullDump(frule))
            local fverb = frule.verb.name
            if n then
              fverb = fverb .. "n't"
            end
            -- print("frule:", fullDump(frule))
            if frule.subject.name == rule.subject.name and fverb == rule.verb.name and
            frule.object.name == rule.object.name and frule.object.name ~= "her" and frule.object.name ~= "thr" then
              -- print("matching rule", rule[1][1], rule[2], rule[3][1])
              if has_conds then
                for _,cond in ipairs(inverse_conds[1]) do
                  if not frule.subject.conds then frule.subject.conds = {} end
                  table.insert(frule.subject.conds, cond)
                end
                for _,cond in ipairs(inverse_conds[2]) do
                  if not frule.object.conds then frule.object.conds = {} end
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
        blockRules(full_rules, true)

        mergeTable(all_units, rules[2])
      end
    end
  end

  -- Step 2:
  -- Add all remaining rules to lookup tables
  for _,rules in ipairs(full_rules) do
    local rule = rules.rule

    local subject, verb, object = rule.subject.name, rule.verb.name, rule.object.name

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
  if shouldReparseRulesIfConditionalRuleExists("lvl", "be", "go arnd", true) then return true end
  if shouldReparseRulesIfConditionalRuleExists("lvl", "be", "mirr arnd", true) then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "ortho") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "diag") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "ben't", "wurd") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "za warudo") then return true end
  if shouldReparseRulesIfConditionalRuleExists("?", "be", "rong") then return true end
  if rules_with["poor toll"] then
    if shouldReparseRulesIfConditionalRuleExists("?", "be", "flye", true) then return true end
    if shouldReparseRulesIfConditionalRuleExists("?", "be", "tall", true) then return true end
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

function shouldReparseRulesIfConditionalRuleExists(r1, r2, r3, even_non_wurd)
  local rules = matchesRule(r1, r2, r3);
  for _,rule in ipairs(rules) do
    local subject_cond = rule.rule.subject.conds or {}
    local subject = rule.rule.subject.name;
    --We only care about conditional rules that effect text, specific text, wurd units and maybe portals too.
    --We can also distinguish between different conditions (todo).
    if (#subject_cond > 0 and (even_non_wurd or subject:starts("text") or rules_effecting_names[subject])) then
      for _,cond in ipairs(subject_cond) do
        local cond_name = cond[1]
        local cond_units = cond[2]
        --TODO: This needs to change for condition stacking.
        --An infix condition that references another unit just dumps the second unit into rules_effecting_names (This is fine for all infix conditions, for now, but maybe not perpetually? for example sameFloat() might malfunction since the floatness of the other unit could change unexpectedly due to a SECOND conditional rule).
        if (#cond_units > 0) then
          for _,unit in ipairs(cond_units) do
            rules_effecting_names[unit] = true
            if unit == "mous" then
              should_parse_rules_at_turn_boundary = true;
            end
          end
        else
          --Handle specific prefix conditions.
          --Frenles is hard to do since it could theoretically be triggered by ANY other unit. Instead, just make it reparse rules all the time, sorry.
          if cond_name == "frenles" or cond_name == "frenlesn't" then
            should_parse_rules = true;
            return true;
          else
            --What are the others? WAIT... only changes at turn boundary. MAYBE can only change on turn boundary or if the unit or text moves (by definition these already reparse rules). AN only changes on turn boundary. COREKT/RONG can only change when text reparses anyway by definition, so it should never trigger it. TIMELES only changes at turn boundary. CLIKT only changes at turn boundary. Colours only change at turn boundary. So every other prefix condition, for now, just needs one check per turn, but new ones will need to be considered.
            should_parse_rules_at_turn_boundary = true;
          end
          
          --As another edge to consider, what if the level geometry changes suddenly? Well, portals already trigger reparsing rules when they update, which is the only kind of external level geometry change. In addition, text/wurds changing flye/tall surprisingly would already trigger rule reparsing since we checked those rules. But, what about a non-wurd changing flye/tall, allowing it to go through a portal, changing the condition of a different parse effecting rule? This can also happen with level be go arnd/mirr arnd turning on or off. parseRules should fire in such cases. So specifically for these cases, even though they aren't wurd/text, we do want to fire     parseRules when their conditions change.
          
          --One final edge case to consider: MOUS, which just moves around on its own. This also triggers should_parse_rules_at_turn_boundary, since that's how often we care about MOUS moving.
        end
      end
    end
  end
  return false;
end