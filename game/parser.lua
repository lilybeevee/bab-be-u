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

--[[ texttypes:
  verb_all
  property
  and
  verb_object
  cond_prefix_or_property
  cond_infix
  cond_prefix
  not
  ellipses
  letter
  ditto
  group
  cond_infix_verb
  hideous_amalgamation (thatbe)
  verb_object_or_property_or_object
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

function parse(words)
  local extra_words = {}
  for i = #words,1,-1 do
    if words[i].type == "ellipses" then
      table.insert(extra_words, words[i])
      table.remove(words,i)
    end
  end
  if #words < 3 then return false end -- smallest rules are 3 words long (subject, verb, object)
  print(fullDump(words))
  
  local units = {}
  local verbs = {}
  while words[1].type ~= "verb_all"
  and   words[1].type ~= "verb_object"
  and   words[1].type ~= "verb_object_or_property_or_object" do
    local unit = findUnit(words, extra_words, true) -- outer unit doesn't need to worry about enclosure (nothing farther out to confuse it with)
    if not unit then
      return false
    end
    if #words == 0 then return false end
    table.insert(units, unit)
    if words[1].type == "and" then
      table.insert(extra_words, words[1])
      table.remove(words, 1)
      if #words == 0 then return false end
    else
      break -- prevents "bab keek be u"
    end
  end
  
  while words[1] and ( words[1].type == "verb_all"
  or words[1].type == "verb_object"
  or words[1].type == "verb_object_or_property_or_object" ) do
    local verb = findVerbPhrase(words, extra_words)
    if not verb then break end
    table.insert(verbs, verb)
    if words[1] and words[1].type == "and" then
      table.insert(extra_words, words[1])
      table.remove(words, 1)
      if #words == 0 then return false end
    else
      break -- prevents "bab keek be u"
    end
  end
  if #verbs == 0 then return false, {units, verbs}, extra_words end
  
  local rules = {}
  for _,subject in ipairs(units) do
    for _,verb_phrase in ipairs(verbs) do
      local verb = verb_phrase[1]
      for _,object in ipairs(verb_phrase[2]) do
        table.insert(rules, {subject = subject, verb = verb, object = object})
      end
    end
  end
  
  return true, rules, extra_words
end

function findUnit(words, extra_words, outer)
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
  if words[1].name == "(" then
    enclosed = true
    parenthesis = true
    print("(")
    table.insert(extra_words, words[1])
    table.remove(words, 1)
    if #words == 0 then return nil end
  end
  
  while words[1].type == "cond_prefix" or words[1].type == "cond_prefix_or_property" do
    local prefix = words[1]
    table.remove(words, 1)
    if #words == 0 then return nil end
    while words[1].type == "not" do
      prefix = {type = prefix.type, name = prefix.name.."n't", unit = prefix.unit, mods = prefix.mods or {}}
      table.insert(prefix.mods, words[1])
      table.remove(words, 1)
      if #words == 0 then return nil end
    end
    table.insert(conds, prefix)
    if enclosed and words[1].type == "and" and words[2] and words[2].type == "cond_prefix" then
      table.insert(extra_words, words[1])
      table.remove(words, 1)
      if #words == 0 then return nil end
    end -- we're not breaking here to allow "frenles lit bab" - add "else break" here if we want there to always be an and: "frenles & lit bab"
  end
  
  unit = findClass(words, extra_words)
  
  -- print(unit and unit.name.."?")
  
  if not unit then
    return nil 
  end
  
  local first_infix = true
  while words[1] and words[1].type == "cond_infix" and (first_infix or enclosed) do -- TODO: cond_infix_verb (that), hideous_amalgamation (thatbe)
    local infix = words[1]
    infix.mods = infix.mods or {}
    table.remove(words, 1)
    if #words == 0 then return nil end
    while words[1].type == "not" do
      infix = {type = infix.type, name = infix.name.."n't", unit = infix.unit, mods = infix.mods}
      table.insert(infix.mods, words[1])
      table.remove(words, 1)
      if #words == 0 then return nil end
    end
    
    local other = findUnit(words, extra_words, enclosed)
    if other == nil then return unit end
    infix.others = {other}
    table.insert(conds, infix)
    -- print(enclosed, words[1] and words[1].type, words[2] and words[2].type)
    while enclosed and words[1] and words[1].type == "and" and words[2].type ~= "cond_infix" do
      table.insert(extra_words, words[1])
      table.remove(words, 1)
      if #words == 0 then return nil end
      local other = findUnit(words, extra_words, enclosed)
      if other == nil then return unit end
      table.insert(infix.others, other)
    end
    if enclosed and words[1] and words[1].type == "and" and words[2].type == "cond_infix" then
      table.insert(extra_words, words[1])
      table.remove(words, 1)
      if #words == 0 then return nil end
    end -- no need to break here because "bab w/fren keek arond roc" is already covered, and is valid
    first_infix = false
  end
  
  if enclosed and words[1] and words[1].name == ")" then
    print(")")
    table.insert(extra_words, words[1])
    table.remove(words, 1)
  end
  -- print("found "..unit.name)
    
  unit.conds = conds
  return unit
end

function findClass(words, extra_words)
  if words[2] and words[2].name == "text" then
    if not words[1].mods then words[1].mods = {} end
    table.insert(words[1].mods, words[2].unit)
    words[1].name = (words[1].unit or {}).fullname or "no unit"
    table.remove(words, 2)
  elseif  words[1].type ~= "object"
  and words[1].type ~= "verb_object_or_property_or_object"
  and words[1].type ~= "group" then -- TODO: are there any other types that fit here?
    return nil
  end
  local unit = words[1]
  table.remove(words, 1)
  while words[1] and words[1].type == "not" do
    unit = {type = unit.type, name = unit.name.."n't", unit = unit.unit, mods = unit.mods or {}}
    table.insert(unit.mods, words[1])
    table.remove(words, 1)
  end
  return unit
end

function findVerbPhrase(words, extra_words, enclosed)
  local objects = {}
  local verb = words[1]
  table.remove(words, 1)
  if #words == 0 then return nil end
  while words[1].type == "not" do
    verb = {type = verb.type, name = verb.name.."n't", unit = verb.unit, mods = verb.mods or {}}
    table.insert(verb.mods, words[1])
    table.remove(words, 1)
    if #words == 0 then return nil end
  end
  if verb.type == "verb_all" then -- be (prop or class)
    while true do
      if words[1].type == "object"
      or words[1].type == "verb_object_or_property_or_object"
      or words[1].type == "group"
      or words[2] and words[2].name == "text" then
        table.insert(objects, findClass(words))
      elseif words[1].type == "property"
      or     words[1].type == "verb_object_or_property_or_object"
      or     words[1].type == "cond_prefix_or_property" then -- TODO: are there any other types that fit here?
        table.insert(objects, words[1])
        table.remove(words, 1)
        -- "bab be u n't" isn't valid, no need to allow nots here
      else
        return nil
      end
      if words[1] and words[1].type == "and" and words[2] and words[2].type ~= "verb_all" and words[2].type ~= "verb_object" then
        table.insert(extra_words, words[1])
        table.remove(words, 1)
      else
        break
      end
    end
  elseif verb.name == "got" or verb.name == "creat" then -- is this all? are there more? (class)
    while words[1].type == "object"
    or    words[1].type == "verb_object_or_property_or_object"
    or    words[1].type == "group"
    or    words[2] and words[2].name == "text" do
      table.insert(objects, findClass(words))
      if words[1] and words[1].type == "and" and words[2] and words[2].type ~= "verb_all" and words[2].type ~= "verb_object" then
        table.insert(extra_words, words[1])
        table.remove(words, 1)
      else
        break
      end
    end
  elseif verb.type == "verb_object" or verb.type == "verb_object_or_property_or_object" then -- (unit)
    while findUnit(copyTable(words)) do -- there has to be a better way to do this
      table.insert(objects, findUnit(words, extra_words, enclosed))
      if words[1] and words[1].type == "and" and words[2] and words[2].type ~= "verb_all" and words[2].type ~= "verb_object" then
        table.insert(extra_words, words[1])
        table.remove(words, 1)
      else
        break
      end
    end
  else
    return
  end
  return {verb, objects}
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
    for _,word in ipairs(text_in_tiles) do
      if substr == word then
        --print("found word: "..substr, sentences.start, fullDump(sentences.start), sentences.both, fullDump(sentences.both))
        if index == 1 then
          start = true
        end
        table.insert(curr_sentence, substr)
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
          curr_sentence = {}; --now we're done with that particular sentence attempt, so we're back to no words in the sentence
        end
      end
    end
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
      {name = "...", type = "ellipses"},
      {name = "be", type = "verb_all"},
      {name = "...", type = "ellipses"},
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

testParser()