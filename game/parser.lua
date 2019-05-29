--[[

PARSER TODO:
  Make "mod" only apply to previously added words
  Dont count other mod rules as added words

repeating N'Ts will not work until this is made!


local not_suffix = {
  repeatable = true,
  optional = true,
  options = {{{type = "not", mod = -1}}}
}]]
local not_suffix = {type = "not", optional = true, mod = -1}

local and_repeat = {type = "and", connector = true}

local function common(arg, group)
  local has = {}
  for i,v in ipairs(arg) do
    has[v] = true
  end

  local full_options = {}

  if has["object"] then
    local options = {
      {
        {type = "object"},
        not_suffix
      },
      {
        {type = "any"},
        {name = "text", mod = -1},
        {type = "not", optional = true, mod = -2}
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
      {type = "cond_prefix"},
      not_suffix
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
            not_suffix,
            commons({"object"}, "target")
          },
          {
            {name = "look at"},
            not_suffix,
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
      not_suffix,
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
    },
  }
}

--print(dump(parser))

function parse(words, parser, state_)
  local state = state_ or {}

  state.parent_rule = state.parent_rule or parser
  state.group = state.group or "root"
  state.current_matches = copyTable(state.current_matches or {})
  state.matches = copyTable(state.matches or {})
  state.option = state.option or 1
  state.index = state.index or 1
  state.word_index = state.word_index or 1
  state.is_repeat = state.is_repeat or false

  local rule = state.parent_rule.options[state.option][state.index]
  local word = words[state.word_index]

  if not rule then
    if keyCount(state.current_matches) > 0 then
      table.insert(state.matches, state.current_matches)
    end
    if state.parent_rule.repeatable then
      local new_state = {
        parent = state.parent,
        parent_rule = state.parent_rule,
        group = state.group,
        current_matches = {},
        matches = state.matches,
        index = 1,
        word_index = state.word_index,
        is_repeat = true
      }
      local valid, ret_state = parse(words, parser, new_state)
      if valid then
        return true, ret_state
      end
    end
    if state.parent then
      local new_matches = copyTable(state.parent.current_matches)
      if state.parent_rule.group then
        if not new_matches[state.group] then
          new_matches[state.group] = {}
        end
        if keyCount(state.matches) > 0 then
          mergeTable(new_matches[state.group], state.matches)
        end
      else
        if keyCount(state.matches) > 0 then
          for _,a in ipairs(state.matches) do
            mergeTable(new_matches, a)
          end
        end
      end
      local new_state = {
        parent = state.parent.parent,
        parent_rule = state.parent.parent_rule,
        group = state.parent.group,
        current_matches = new_matches,
        matches = state.parent.matches,
        option = state.parent.option,
        index = state.parent.index + 1,
        word_index = state.word_index,
        is_repeat = state.parent.is_repeat
      }
      return parse(words, parser, new_state)
    else
      return true, state
    end
  else
    local next_state = {
      parent = state.parent,
      parent_rule = state.parent_rule,
      group = state.group,
      current_matches = state.current_matches,
      matches = state.matches,
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
            return false, state
          end
        else
          if rule.type and rule.type ~= word.type and rule.type ~= "any" then
            valid = false
          elseif rule.name and rule.name ~= word.name then
            valid = false
          else
            if rule.connector then
              word.connector = true
            end
            if rule.mod then
              local mod_word = words[state.word_index + rule.mod]
              if mod_word ~= nil then
                if mod_word.mods == nil then
                  mod_word.mods = {}
                end
                table.insert(mod_word.mods, word)
              end
            else
              table.insert(state.current_matches, word)
            end
          end
          if valid then
            next_state.word_index = state.word_index + 1
          end
        end
      elseif rule.connector and not state.is_repeat then
        valid = true
      end
      if valid or rule.optional then
        return parse(words, parser, next_state)
      else
        --print(fullDump(rule, true))
        --print(fullDump(word, true))
        --print("FAILED AT TYPE/NAME")
      end
    elseif rule.options then
      local valid = false
      local failed_state
      local ret_state
      if #rule.options == 0 then
        valid = true
        ret_state = state
      else
        local best_word_index = 0
        for i = 1, #rule.options do
          local new_state = {
            parent = state,
            parent_rule = rule,
            group = rule.group or state.group,
            current_matches = {},
            matches = {},
            option = i,
            index = 1,
            word_index = state.word_index
          }
          if rule.repeatable then
            new_state.is_repeat = false
          else
            new_state.is_repeat = state.is_repeat
          end
          local new_ret_state
          valid, new_ret_state = parse(words, parser, new_state)
          if valid then
            if new_ret_state.word_index > best_word_index then
              best_word_index = new_ret_state.word_index
              ret_state = new_ret_state
            end
          else
            failed_state = ret_state
          end
        end
        if best_word_index > 0 then
          valid = true
        end
      end
      if valid then
        return true, ret_state
      elseif rule.optional then
        return parse(words, parser, next_state)
      else
        if failed_state then
          return false, failed_state
        end
      end
    else
      return true, state
    end
  end

  return false, state
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
      {name = "text", type = "object"},
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
    { -- Test 11 - TRUE
      {name = "bab", type = "object"},
      {name = "on", type = "cond_infix"},
      {name = "til", type = "object"},
      {name = "be", type = "verb"},
      {name = "u", type = "property"},
      {name = "be", type = "verb"}
    },
  }

  for i,v in ipairs(tests) do
    print("--- TEST " .. i .. " ---")
    local result, state = parse(v, parser)
    print("Result: " .. tostring(result))
    print("Words: " .. state.word_index-1 .. "/" .. #v)
    print("Matches: " .. fullDump(state.matches))
  end
end

testParser()