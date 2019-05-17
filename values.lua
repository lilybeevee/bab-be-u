MAX_MOVE_TIMER = 80
INPUT_DELAY = 150
MAX_UNDO_DELAY = 150
MIN_UNDO_DELAY = 50
UNDO_SPEED = 5
UNDO_DELAY = MAX_UNDO_DELAY
repeat_keys = {"w","a","s","d","up","down","left","right","z"}

dirs = {{1,0},{0,1},{-1,0},{0,-1}}
dirs8 = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}
dirs_by_name = {
  right = 1,
  down = 2,
  left = 3,
  up = 4
}
TILE_SIZE = 32

mapwidth = 21
mapheight = 15
map = nil
--[[map = {
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{ 2},{ 3},{ 4},{  },{  },{  },{  },{  },{11},{  },{  },{  },{  },{  },{23},{ 3},{24},{  },{  },
  {  },{  },{25},{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{ 2},{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{22},{22},{22},{  },{  },{  },
  {  },{  },{ 1},{  },{  },{  },{  },{  },{  },{  },{14},{  },{  },{  },{  },{22},{22},{22},{  },{  },{  },
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{22},{22},{22},{  },{  },{  },
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{ 9},{17},{15},{ 3},{10},{  },{  },{  },{  },{  },{  },{  },{12},{ 3},{13},{17},{ 7},{  },{  },
  {  },{  },{  },{  },{ 3},{  },{  },{  },{  },{  },{25},{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
  {  },{  },{  },{  },{16},{  },{  },{  },{  },{  },{  },{  },{26},{27},{28},{  },{  },{  },{  },{  },{  },
  {  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },{  },
}]]
map = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{2},{3},{4},{},{},{},{},{},{},{},{},{},{},{},{},{},{19},{3},{20},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{1},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{18},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}

tiles_list = {
  -- 1
  {
    name = "bab",
    sprite = "bab",
    type = "object",
    color = {255,255,255},
    layer = 5,
    rotate = true,
  },
  -- 2
  {
    name = "text_bab",
    sprite = "text_bab",
    type = "text",
    color = {217,57,106},
    layer = 20,
  },
  -- 3
  {
    name = "text_be",
    sprite = "text_be",
    type = "text",
    texttype = "verb",
    allowprops = true,
    color = {255,255,255},
    layer = 20,
  },
  -- 4
  {
    name = "text_u",
    sprite = "text_u",
    type = "text",
    texttype = "property",
    color = {217,57,106},
    layer = 20,
  },
  -- 5
  {
    name = "wal",
    sprite = "wal",
    type = "object",
    color = {41,49,65},
    layer = 2,
  },
  -- 6
  {
    name = "text_wal",
    sprite = "text_wal",
    type = "text",
    color = {115,115,115},
    layer = 20,
  },
  -- 7
  {
    name = "text_no go",
    sprite = "text_nogo",
    type = "text",
    texttype = "property",
    color = {75,92,28},
    layer = 20,
  },
  -- 8
  {
    name = "roc",
    sprite = "roc",
    type = "object",
    color = {194,158,70},
    layer = 3,
  },
  -- 9
  {
    name = "text_roc",
    sprite = "text_roc",
    type = "text",
    color = {144,103,62},
    layer = 20,
  },
  -- 10
  {
    name = "text_go away",
    sprite = "text_goaway",
    type = "text",
    texttype = "property",
    color = {144,103,62},
    layer = 20,
  },
  -- 11
  {
    name = "dor",
    sprite = "dor",
    type = "object",
    color = {229,83,59},
    layer = 3,
  },
  -- 12
  {
    name = "text_dor",
    sprite = "text_dor",
    type = "text",
    color = {229,83,59},
    layer = 20,
  },
  -- 13
  {
    name = "text_ned kee",
    sprite = "text_nedkee",
    type = "text",
    texttype = "property",
    color = {229,83,59},
    layer = 20,
  },
  -- 14
  {
    name = "kee",
    sprite = "kee",
    type = "object",
    color = {237,226,133},
    layer = 4,
    rotate = true,
  },
  -- 15
  {
    name = "text_kee",
    sprite = "text_kee",
    type = "text",
    color = {237,226,133},
    layer = 20,
  },
  -- 16
  {
    name = "text_for dor",
    sprite = "text_fordor",
    type = "text",
    texttype = "property",
    color = {237,226,133},
    layer = 20,
  },
  -- 17
  {
    name = "text_&",
    sprite = "text_and",
    type = "text",
    texttype = "and",
    color = {255,255,255},
    layer = 20,
  },
  -- 18
  {
    name = "flog",
    sprite = "flog",
    type = "object",
    color = {237,226,133},
    layer = 3,
  },
  -- 19
  {
    name = "text_flog",
    sprite = "text_flog",
    type = "text",
    color = {237,226,133},
    layer = 20,
  },
  -- 20
  {
    name = "text_:)",
    sprite = "text_good",
    type = "text",
    texttype = "property",
    color = {237,226,133},
    layer = 20,
  },
  -- 21
  {
    name = "til",
    sprite = "til",
    type = "object",
    color = {21,24,31},
    layer = 1,
  },
  -- 22
  {
    name = "watr",
    sprite = "watr",
    type = "object",
    color = {95,157,209},
    layer = 1,
  },
  -- 23
  {
    name = "text_watr",
    sprite = "text_watr",
    type = "text",
    color = {95,157,209},
    layer = 20,
  },
  -- 24
  {
    name = "text_no swim",
    sprite = "text_no swim",
    type = "text",
    texttype = "property",
    color = {95,157,209},
    layer = 20,
  },
  -- 25
  {
    name = "text_got",
    sprite = "text_got",
    type = "text",
    texttype = "verb",
    color = {255,255,255},
    layer = 20,
  },
  --26
  {
    name = "text_colrful",
    sprite = "text_colrful",
    type = "text",
    texttype = "property",
    color = {255,255,255},
    layer = 20,
  },
  --27
  {
    name = "text_reed",
    sprite = "text_reed",
    type = "text",
    texttype = "property",
    color = {255,0,0},
    layer = 20,
  },
  --28
  {
    name = "text_bleu",
    sprite = "text_bleu",
    type = "text",
    texttype = "property",
    color = {0,0,255},
    layer = 20,
  },
  --29
  {
    name = "text_tranz",
    sprite = "text_tranz",
    type = "text",
    texttype = "property",
    color = {255,255,255},
    layer = 20,
  },
  --30
  {
    name = "text_mous",
    sprite = "text_mous",
    type = "text",
    color = {145,131,215},
    layer = 20,
  }
}