--[[ rule format:
  main: unit nt* (& unit nt*)* verb_phrase (& verb_phrase)*
  verb_phrase:
  ( "be" nt* (property|class nt*) (& property|& class nt*)*
  | ("got"|"creat") nt* class (& class)*
  | otherverb nt* unit (& unit)*
  )
  unit: (prefix nt* (&? prefix nt*)*)? class nt* (infix unit (& infix unit)*)?
  
  verbs will have to be in 3 categories now, not 2
  BE - x be property, x be class
  GOT/CREAT - x got/creat class
  everything else - x spoop unit
    
  class - a type of object, doesn't require there to be any units of that type - the concept of "bab"
  unit - an individual (or a list) of units - each individual "frenles bab arond keek"
]]

--[[ words structure:
  {
    {
      type = "object",
      name = "bab",
      unit = {...}
    },
    {
      type = "verb_all",
      name = "be",
      unit = {...},
    {
      type = "property",
      name = "u",
      unit = {...}
    }
  }
]]

local found = {}

function parse(words, dir, no_verb_cond)
  local extra_words = {}
  for i = #words,1,-1 do
    if words[i].type and words[i].type.ellipsis then
      table.insert(extra_words, words[i])
      table.remove(words,i)
    end
  end
  if #words < 3 then return false end -- smallest rules are 3 words long (subject, verb, object)
  -- print(fullDump(words))
  
  local units = {}
  local verbs = {}
  while words[1].type and (words[1].type.object or words[1].type.cond_prefix or words[1].type.parenthesis) or (words[2] and (words[2].name == "text" or words[2].name == "textn't")) do
    local unit, words_ = findUnit(copyTable(words), extra_words, dir, true, no_verb_cond, true) -- outer unit doesn't need to worry about enclosure (nothing farther out to confuse it with)
    if not unit then break end
    words = words_
    if not unit then return false end
    if #words == 0 then return false end
    table.insert(units, unit)
    if words[1].type and words[1].type["and"] and words[2] and (words[2].type.object or words[2].type.parenthesis or words[3] and (words[3].name == "text" or words[3].name == "textn't")) then
      table.insert(extra_words, words[1])
      table.remove(words, 1)
      if #words == 0 then return false end
    else
      break -- prevents "bab keek be u"
    end
  end
  if #units == 0 then return false end
  
  while words[1] and words[1].type and words[1].type.verb do
    local verb, words_ = findVerbPhrase(copyTable(words), extra_words, dir, true, false, no_verb_cond)
    if not verb then break end
    words = words_
    table.insert(verbs, verb)
    if words[1] and words[1].type and words[1].type["and"] and words[2] and words[2].type and words[2].type.verb and words[3] then
      table.insert(extra_words, words[1])
      table.remove(words, 1)
      if #words == 0 then return false end
    else
      break -- prevents "bab be u :)"
    end
  end
  if #verbs == 0 then return false end
  
  local rules = {}
  for _,subject in ipairs(units) do
    for _,verb_phrase in ipairs(verbs) do
      local verb = verb_phrase[1]
      for _,object in ipairs(verb_phrase[2]) do
        table.insert(rules, {subject = subject, verb = verb, object = object})
      end
    end
  end
  
  return true, words, rules, extra_words
end

function findUnit(words, extra_words_, dir, outer, no_verb_cond, is_subject)
  local extra_words = {}
  -- find all the prefix conditions
  -- find the unit itself
  -- find all the infix conditions, including nesting
  local conds = {}
  local unit
  -- print(fullDump(words))
  local enclosed = outer
  local parenthesis = false
  -- print(enclosed, words[1].name)
  -- print("finding unit")
  if #words == 0 then return end
  
  if (words[1].name == "(" or words[1].name == "parenthesis") and words[1].unit and words[1].unit.dir == dir then
    enclosed = true
    parenthesis = true
    -- print("(")
    table.insert(extra_words, words[1])
    table.remove(words, 1)
    if #words == 0 then return end
  end
  
  local andd
  while words[1].type and (words[1].type.cond_prefix or (words[1].type.cond_compare and not is_subject)) do
    local prefix = copyTable(words[1])
    table.remove(words, 1)
    if #words == 0 then return end
    prefix.mods = prefix.mods or {}
    local nt = false
    while words[1].type["not"] do
      nt = not nt
      table.insert(prefix.mods, words[1])
      table.remove(words, 1)
      if #words == 0 then return end
    end
    if nt then
      if prefix.name:ends("n't") then
        prefix.name = prefix.name:sub(1, -4)
      else
        prefix.name = prefix.name.."n't"
      end
    end
    table.insert(conds, prefix)
    if andd then
      table.insert(extra_words, andd)
      andd = nil
    end
    if enclosed and words[1].type["and"] and words[2] then
      andd = table.remove(words, 1)
      if #words == 0 then return end
    end -- we're not breaking here to allow "frenles lit bab" - add "else break" here if we want there to always be an and: "frenles & lit bab"
  end
  
  local words_
  unit, words_ = findClass(copyTable(words))
  if not unit then return end
  words = words_
  
  local first_infix = true
  while words[1] and words[1].type and (words[1].type.cond_infix or (words[1].type.direction and words[2] and words[2].name == "arond")) and (first_infix or enclosed) and (not no_verb_cond or not words[1].type.verb) do
    local infix = copyTable(words[1])
    local infix_orig = infix
    infix.mods = infix.mods or {}
    if words[1].type.direction and words[2].name == "arond" then
      infix.name = infix.name.." arond"
      table.insert(infix.mods, words[2])
    end
    table.remove(words, 1)
    if words[1] and words[1].name == "arond" then
      table.remove(words, 1)
    end
    if #words == 0 then break end
    if infix.type.cond_infix_verb then
      local words_ = copyTable(words)
      if infix.type.cond_infix_verb_plus then
        local verb = infix.name:sub(6)
        table.insert(words_, 1, {name = verb, type = tiles_list[tiles_by_name["text_"..verb]].texttype})
      end
      local verb
      verb_phrase, words_ = findVerbPhrase(words_, extra_words, dir, enclosed, true)
      if not verb_phrase then
        break
      end
      words = words_
      if not infix.type.cond_infix_verb_plus then
        local verb = verb_phrase[1]
        infix.name = infix.name.." "..verb.name
        table.insert(infix.mods, verb)
      end
      infix.others = {}
      for _,object in ipairs(verb_phrase[2]) do
        table.insert(infix.mods, object)
        table.insert(infix.others, object)
      end
      table.insert(conds, infix)
    else
      local nt = false
      while words[1].type["not"] do
        nt = not nt
        table.insert(infix.mods, words[1])
        table.remove(words, 1)
        if #words == 0 then break end
      end
      if nt then
        if infix.name:ends("n't") then
          infix.name = infix.name:sub(1, -4)
        else
          infix.name = infix.name.."n't"
        end
      end
      
      if infix.type.cond_infix_dir and words[1].type.direction then
        infix.others = {words[1]}
        table.remove(words, 1)
        table.insert(conds, infix)
      else
        local other, words_ = findUnit(copyTable(words), extra_words, dir)
        if not other then
          table.insert(words, 1, infix_orig)
          break
        end
        if andd then
          table.insert(extra_words, andd)
          andd = nil
        end
        words = words_
        infix.others = {other}
        table.insert(conds, infix)
        -- print(enclosed, words[1] and words[1].type, words[2] and words[2].type)
        if #words == 0 then break end
        while enclosed and words[1] and words[1].type["and"] and words[2] and words[3] and (words[2].type.object or words[2].type.parenthesis or (words[3].name == "text" or words[3].name == "textn't")) do
          table.insert(extra_words, words[1])
          table.remove(words, 1)
          if #words == 0 then break end
          local other, words_ = findUnit(copyTable(words), extra_words)
          if not other then
            if parenthesis then
              return
            end
            unit.conds = conds
            mergeTable(extra_words_, extra_words)
            found = {unit, words}
            return unit, words
          end
          words = words_
          table.insert(infix.others, other)
        end
        if #words == 0 then break end
      end
    end
    if enclosed and words[1] and words[1].type["and"] and words[2] and (words[2].type.cond_infix or (words[2].type.direction and words[3].name == "arond")) and (not no_verb_cond or not words[1].type.verb)  then
      andd = words[1]
      table.remove(words, 1)
      if #words == 0 then break end
    else
      break -- need to break for the case of "bab that got keek w/fren bab" (should need an & in there)
    end
    first_infix = false
  end
  if andd then
    table.insert(words, 1, andd)
  end
  
  -- print(fullDump(words[1]), dir)
  if parenthesis then
    if words[1] and (words[1].name == ")" or words[1].name == "parenthesis") and words[1].unit and words[1].unit.dir == (rotate8(dir)) then
    -- print(")")
      table.insert(extra_words, words[1])
      table.remove(words, 1)
    else
      return
    end
  end
  -- print("found "..unit.name)
    
  unit.conds = conds
  mergeTable(extra_words_, extra_words)
  found = {unit, words}
  return unit, words
end

function findClass(words)
  local prefix
  if words[1].type and words[1].type.class_prefix then -- in cases where conditions can also be used, things should be caught there first
    prefix = table.remove(words, 1)
    if #words == 0 then return end
  end
  
  local unit = copyTable(words[1])
  unit.mods = unit.mods or {}
  if words[2] and (words[2].name == "text" or words[2].name == "textn't") then
    table.insert(unit.mods, words[2])
    if (unit.name ~= unit.unit.textname) then --many letters in a row
      unit.name = "text_"..unit.name..words[2].name:sub(5)
    else --every other case
      unit.name = (unit.unit or {fullname = "no unit"}).fullname..words[2].name:sub(5)
    end
    table.remove(words, 2)
  elseif not words[1].type.object then
    return nil
  end
  
  table.remove(words, 1)
  local nt = false
  while words[1] and words[1].type and words[1].type["not"] do
    nt = not nt
    table.insert(unit.mods, words[1])
    table.remove(words, 1)
  end
  if nt then
    if unit.name:ends("n't") then
      unit.name = unit.name:sub(1, -4)
    else
      unit.name = unit.name.."n't"
    end
  end
  
  if prefix then
    table.insert(unit.mods, prefix)
    unit.prefix = prefix.name
  end
  found = {unit, words}
  return unit, words
end

function findVerbPhrase(words, extra_words_, dir, enclosed, noconds, no_verb_cond)
  local extra_words = {}
  local objects = {}
  local verb = copyTable(words[1])
  verb.mods = verb.mods or {}
  table.remove(words, 1)
  if #words == 0 then return nil end
  while words[1].type and words[1].type["not"] do
    verb.name = verb.name.."n't"
    table.insert(verb.mods, words[1])
    table.remove(words, 1)
    if #words == 0 then return nil end
  end
  local andd
  while true do
    local valid
    if (verb.type.verb_class or (verb.type.verb_unit and noconds)) and findClass(copyTable(words)) then
      table.insert(objects, found[1])
      words = found[2]
      valid = true
    elseif verb.type.verb_property and words[1].type.property then
      table.insert(objects, table.remove(words, 1))
      valid = true
    elseif verb.type.verb_unit and not noconds and findUnit(copyTable(words), extra_words, dir, enclosed, no_verb_cond) then
      table.insert(objects, found[1])
      words = found[2]
      valid = true
    elseif verb.type.verb_direction and words[1].type.direction then
      table.insert(objects, table.remove(words, 1))
      valid = true
    elseif verb.type.verb_sing and words[1].type.note then
      local note = table.remove(words, 1)
      if words[1] and words[1].type.note_modifier then
        note.name = note.name.."_"..words[1].name
        table.insert(extra_words, table.remove(words, 1))
      end
      table.insert(objects, note)
      valid = true
    else
      break
    end
    if valid then
      if andd then
        table.insert(extra_words, andd)
        andd = nil
      end
      if not noconds and words[1] and words[1].type and words[1].type["and"] and words[2] and not (words[2].type and words[2].type.verb) then
        andd = table.remove(words, 1)
      else
        break
      end
    end
  end
  mergeTable(extra_words_, extra_words)
  return {verb, objects}, words
end

function findLetterSentences(str, index_, sentences_, curr_sentence_, start_) --copied from parser_old.lua
  -- finds words out of letters
  local index = index_ or 1
  local initial_index = index
  local sentences = sentences_ or {
    start = {},
    endd = {}, --sadly, end is a reserved word in lua
    both = {},
    middle = {},
  }
  local curr_sentence = copyTable(curr_sentence_ or {})
  local start = start_ or false
  --print("start of findLetterSentences:",str,index,fullDump(sentences),fullDump(curr_sentence),start, sentences.start, sentences.endd, sentences.both, sentences.middle)

  if #curr_sentence == 0 and not index == string.len(str) then --go to the next letter if we don't have anything in this one... or if we do
    findLetterSentences(str, index+1, sentences, {}, false)
  end

  for i=0,string.len(str)-index do
    local substr = str.sub(str,index,index+i)
    --print("trying:",i,index,substr)
    --print(substr, text_in_tiles[substr])
    if text_in_tiles[substr] then
      --print("found word: "..substr, sentences.start, fullDump(sentences.start), sentences.both, fullDump(sentences.both))
      if index == 1 then
        start = true
      end
      table.insert(curr_sentence, text_in_tiles[substr])
      if index+i == string.len(str) then --last letter, this sentence is valid to connect to other words
        --print("last letter:",index,i,str,substr)
        if start then
          table.insert(sentences.both, copyTable(curr_sentence)) --connected to both the start and end, so the parser has to treat this like a string of words
        else
          table.insert(sentences.endd, copyTable(curr_sentence))
        end
        return sentences --just in case there's a 1 letter U that gets used or something idk
      else
        --print("not last letter:",index,i,str,substr)
        if start then
          table.insert(sentences.start,copyTable(curr_sentence))
        else
          table.insert(sentences.middle,copyTable(curr_sentence))
        end
        findLetterSentences(str, index+i+1, sentences, curr_sentence, start) --we got one word, now keep going
        curr_sentence = {} --now we're done with that particular sentence attempt, so we're back to no words in the sentence
      end
    end
    --then try again with index one higher (fixes b b a b be u)
    --[[if (index < string.len(str)) then
      findLetterSentences(str, index+1, sentences, curr_sentence, start)
    end]]
  end

  return sentences -- i can do this like this because the first function call is the one that gets passed back, and it finishes last
end


local function testParser()
  local tests = {
    { -- Test 1 - TRUE
      {name = "bab", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"}
    },
    { -- Test 2 - FALSE
      {name = "bab", type = "object"},
      {name = "keek", type = "object"},
      {name = "u", type = "property"}
    },
    { -- Test 3 - TRUE
      {name = "frenles", type = "cond_prefix"},
      {name = "bab", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"}
    },
    { -- Test 4 - TRUE
      {name = "frenles", type = "cond_prefix"},
      {name = "bab", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "keek", type = "object"}
    },
    { -- Test 5 - TRUE
      {name = "bab", type = "object", unit = {fullname = "text_bab"}},
      {name = "text", type = "object"},
      {name = "&", type = "and"},
      {name = "keek", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"}
    },
    { -- Test 6 - FALSE
      {name = "bab", type = "object"},
      {name = "keek", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"}
    },
    { -- Test 7 - TRUE
      {name = "bab", type = "object", unit = {fullname = "text_bab"}},
      {name = "text", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"}
    },
    { -- Test 8 - FALSE
      {name = "frenles", type = "cond_prefix"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"}
    },
    { -- Test 9 - TRUE
      {name = "be", type = "property", unit = {fullname = "text_be"}},
      {name = "text", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"}
    },
    { -- Test 10 - TRUE
      {name = "bab", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"},
      {name = "be", type = "verb"}
    },
    { -- Test 11 - TRUE
      {name = "bab", type = "object"},
      {name = "on", type = "cond_infix"},
      {name = "til", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"},
      {name = "be", type = "verb_all"}
    },
    { -- Test 12 - TRUE
      {name = "bab", type = "object"},
      {name = "...", type = "ellipsis"},
      {name = "be", type = "verb"},
      {name = "...", type = "ellipsis"},
      {name = "u", type = "property"},
    },
    { -- Test 13 - TRUE
      {name = "bab", type = "object"},
      {name = "arond", type = "cond_infix"},
      {name = "keek", type = "object"},
      {name = "arond", type = "cond_infix"},
      {name = "roc", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"},
    },
    { -- Test 14 - TRUE
      {name = "bab", type = "object"},
      {name = "arond", type = "cond_infix"},
      {name = "keek", type = "object"},
      {name = "arond", type = "cond_infix"},
      {name = "roc", type = "object"},
      {name = "and", type = "and"},
      {name = "facing", type = "cond_infix"},
      {name = "wal", type = "object"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"},
    },
    { -- Test 14 - TRUE
      {name = "bab", type = "object"},
      {name = "arond", type = "cond_infix"},
      {name = "(", type = "I forget but it doesn't matter"},
      {name = "keek", type = "object"},
      {name = "arond", type = "cond_infix"},
      {name = "roc", type = "object"},
      {name = "and", type = "and"},
      {name = "facing", type = "cond_infix"},
      {name = "wal", type = "object"},
      {name = ")", type = "I forget but it doesn't matter"},
      {name = "be", type = "verb_all"},
      {name = "u", type = "property"},
    },
  }

  for i,test in ipairs(tests) do
    print("--- TEST " .. i .. " ---")
    local result, rule = parse(test)
    print("Result: " .. tostring(result))
    -- print("Words: " .. state.word_index-1 .. "/" .. #v)
    -- print("Matches: " .. fullDump(state.matches))
    print("Rule:" .. fullDump(rule))
  end
end

-- testParser()