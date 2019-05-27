local function common(arg, group)
  local has = {}
  for i,v in ipairs(arg) do
    has[v] = true
  end

  local full_options = {}

  if has["object"] then
    local options = {
      {
        {type = "object"}
      },
      {
        {type = "any"},
        {name = "text"}
      }
    }
    mergeTable(full_options, options)
  end
  if has["property"] then
    local options = {
      {
        {type = "property"}
      }
    }
    mergeTable(full_options, options)
  end

  return {group = group, options = full_options}
end

local and_repeat = {type = "and", connector = true}

local function commons(arg, group)
  local option = {
    group = group,
    repeatable = true,
    options = {
      {
        and_repeat,
        common(arg)
      }
    }
  }
  return option
end

local cond_prefixes = {
  group = "cond",
  optional = true,
  repeatable = true,
  options = {
    {
      and_repeat,
      {type = "cond_prefix"}
    }
  }
}

local directions_and_objects = {
  group = "target",
  repeatable = true,
  options = {
    {
      and_repeat,
      {
        options = {
          {common({"object"})},
          {{name = "up"}},
          {{name = "down"}},
          {{name = "left"}},
          {{name = "right"}}
        }
      }
    }
  }
}

local cond_infixes = {
  group = "cond",
  optional = true,
  repeatable = true,
  options = {
    {
      and_repeat,
      {
        options = {
          {
            {type = "cond_infix"},
            commons({"object"}, "target")
          },
          {
            {name = "look at"},
            directions_and_objects
          }
        }
      }
    }
  }
}

local verbs = {
  group = "verb",
  repeatable = true,
  options = {
    {
      and_repeat,
      {type = "verb"},
      cond_prefixes,
      commons({"object", "property"}, "target"),
      cond_infixes
    }
  }
}

parser = {
  options = {
    {
      cond_prefixes,
      commons({"object"}, "target"),
      cond_infixes,
      verbs,
    }
  }
}

--print(dump(parser))

function testParse(words, parser, state_, full_group_)
  local state = state_ or {}
  local full_group = copyTable(full_group_ or {})

  state.parent_rule = state.parent_rule or parser
  state.group = state.group or {}
  state.option = state.option or 1
  state.index = state.index or 1
  state.word_index = state.word_index or 1
  state.is_repeat = state.is_repeat or false

  local rule = state.parent_rule.options[state.option][state.index]
  local word = words[state.word_index]
  
  local current_group = full_group
  for _,k in ipairs(state.group) do
    if current_group[k] == nil then
      current_group[k] = {}
    end
    current_group = current_group[k]
  end

  if not rule then
    if state.parent_rule.repeatable then
      local new_state = {
        parent = state.parent,
        parent_rule = state.parent_rule,
        group = state.group,
        index = 1,
        word_index = state.word_index,
        is_repeat = true
      }
      local valid, new_matches = testParse(words, parser, new_state)
      if valid then
        return true, new_matches
      end
    end
    if state.parent then
      local new_state = {
        parent = state.parent.parent,
        parent_rule = state.parent.parent_rule,
        group = state.parent.group,
        option = state.parent.option,
        index = state.parent.index + 1,
        word_index = state.word_index,
        is_repeat = state.parent.is_repeat
      }
      return testParse(words, parser, new_state)
    else
      return true, ret_matches
    end
  else
    local next_state = {
      parent = state.parent,
      parent_rule = state.parent_rule,
      group = state.group,
      option = state.option,
      index = state.index + 1,
      word_index = state.word_index
    }
    if rule.type or rule.name then
      local valid = true
      if not rule.connector or state.is_repeat then
        if not word then
          if not rule.optional then
            --print(dump(rule))
            --print("FAILED AT TYPE/NAME - WORD IS NIL")
            return false
          end
        else
          if rule.type and rule.type ~= word.type and rule.type ~= "any" then
            valid = false
          elseif rule.name and rule.name ~= word.name then
            valid = false
          end
          next_state.word_index = state.word_index + 1
        end
      else
        valid = true
      end
      if valid then
        return testParse(words, parser, next_state)
      else
        --print(dump(rule))
        --print(dump(word))
        --print("FAILED AT TYPE/NAME")
      end
    elseif rule.options then
      local valid = false
      if #rule.options == 0 then
        valid = true
      else
        for i = 1, #rule.options do
          local new_state = {
            parent = state,
            parent_rule = rule,
            option = i,
            index = 1,
            word_index = state.word_index
          }
          if rule.repeatable then
            new_state.is_repeat = false
          else
            new_state.is_repeat = state.is_repeat
          end
          if testParse(words, parser, new_state) then
            valid = true
            break
          end
        end
      end
      if valid then
        return true
      elseif rule.optional then
        return testParse(words, parser, next_state)
      end
    else
      return true
    end
  end

  return false
end

local function testParser()
  local tests = {
    { -- Test 1 - TRUE
      {name = "bab", type = "object"},
      {name = "be", type = "verb"},
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
      {name = "be", type = "verb"},
      {name = "u", type = "property"}
    },
    { -- Test 4 - TRUE
      {name = "frenles", type = "cond_prefix"},
      {name = "bab", type = "object"},
      {name = "be", type = "verb"},
      {name = "keek", type = "object"}
    },
    { -- Test 5 - TRUE
      {name = "bab", type = "object"},
      {name = "&", type = "and"},
      {name = "keek", type = "object"},
      {name = "be", type = "verb"},
      {name = "u", type = "property"}
    },
    { -- Test 6 - FALSE
      {name = "bab", type = "object"},
      {name = "keek", type = "object"},
      {name = "be", type = "verb"},
      {name = "u", type = "property"}
    },
    { -- Test 7 - TRUE
      {name = "bab", type = "object"},
      {name = "text", type = "object"},
      {name = "be", type = "verb"},
      {name = "u", type = "property"}
    },
    { -- Test 8 - FALSE
      {name = "frenless", type = "cond_prefix"},
      {name = "be", type = "verb"},
      {name = "u", type = "property"}
    },
    { -- Test 9 - TRUE
      {name = "be", type = "property"},
      {name = "text", type = "object"},
      {name = "be", type = "verb"},
      {name = "u", type = "property"}
    },
    { -- Test 10 - TRUE
      {name = "bab", type = "object"},
      {name = "be", type = "verb"},
      {name = "u", type = "property"},
      {name = "be", type = "verb"}
    },
  }

  for i,v in ipairs(tests) do
    print("Test " .. i .. ": " .. tostring(testParse(v, parser)))
  end
end

--testParser()