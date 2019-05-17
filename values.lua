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
    grid = {1, 1},
    color = {255,255,255},
    layer = 5,
    rotate = true,
  },
  -- 2
  {
    name = "text_bab",
    sprite = "text_bab",
    type = "text",
    grid = {0, 1},
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
    grid = {1, 0},
    color = {255,255,255},
    layer = 20,
  },
  -- 4
  {
    name = "text_u",
    sprite = "text_u",
    type = "text",
    texttype = "property",
    grid = {2, 1},
    color = {217,57,106},
    layer = 20,
  },
  -- 5
  {
    name = "wal",
    sprite = "wal",
    type = "object",
    grid = {1, 3},
    color = {41,49,65},
    layer = 2,
  },
  -- 6
  {
    name = "text_wal",
    sprite = "text_wal",
    type = "text",
    grid = {0, 3},
    color = {115,115,115},
    layer = 20,
  },
  -- 7
  {
    name = "text_no go",
    sprite = "text_nogo",
    type = "text",
    texttype = "property",
    grid = {2, 3},
    color = {75,92,28},
    layer = 20,
  },
  -- 8
  {
    name = "roc",
    sprite = "roc",
    type = "object",
    grid = {1, 4},
    color = {194,158,70},
    layer = 3,
  },
  -- 9
  {
    name = "text_roc",
    sprite = "text_roc",
    type = "text",
    grid = {0, 4},
    color = {144,103,62},
    layer = 20,
  },
  -- 10
  {
    name = "text_go away",
    sprite = "text_goaway",
    type = "text",
    texttype = "property",
    grid = {2, 4},
    color = {144,103,62},
    layer = 20,
  },
  -- 11
  {
    name = "dor",
    sprite = "dor",
    type = "object",
    grid = {1, 5},
    color = {229,83,59},
    layer = 3,
  },
  -- 12
  {
    name = "text_dor",
    sprite = "text_dor",
    type = "text",
    grid = {0, 5},
    color = {229,83,59},
    layer = 20,
  },
  -- 13
  {
    name = "text_ned kee",
    sprite = "text_nedkee",
    type = "text",
    texttype = "property",
    grid = {2, 5},
    color = {229,83,59},
    layer = 20,
  },
  -- 14
  {
    name = "kee",
    sprite = "kee",
    type = "object",
    grid = {1, 6},
    color = {237,226,133},
    layer = 4,
    rotate = true,
  },
  -- 15
  {
    name = "text_kee",
    sprite = "text_kee",
    type = "text",
    grid = {0, 6},
    color = {237,226,133},
    layer = 20,
  },
  -- 16
  {
    name = "text_for dor",
    sprite = "text_fordor",
    type = "text",
    texttype = "property",
    grid = {2, 6},
    color = {237,226,133},
    layer = 20,
  },
  -- 17
  {
    name = "text_&",
    sprite = "text_and",
    type = "text",
    texttype = "and",
    grid = {3, 0},
    color = {255,255,255},
    layer = 20,
  },
  -- 18
  {
    name = "flog",
    sprite = "flog",
    type = "object",
    grid = {1, 2},
    color = {237,226,133},
    layer = 3,
  },
  -- 19
  {
    name = "text_flog",
    sprite = "text_flog",
    type = "text",
    grid = {0, 2},
    color = {237,226,133},
    layer = 20,
  },
  -- 20
  {
    name = "text_:)",
    sprite = "text_good",
    type = "text",
    texttype = "property",
    grid = {2, 2},
    color = {237,226,133},
    layer = 20,
  },
  -- 21
  {
    name = "til",
    sprite = "til",
    type = "object",
    grid = {6, 7},
    color = {21,24,31},
    layer = 1,
  },
  -- 22
  {
    name = "watr",
    sprite = "watr",
    type = "object",
    grid = {1, 7},
    color = {95,157,209},
    layer = 1,
  },
  -- 23
  {
    name = "text_watr",
    sprite = "text_watr",
    type = "text",
    grid = {0, 7},
    color = {95,157,209},
    layer = 20,
  },
  -- 24
  {
    name = "text_no swim",
    sprite = "text_no swim",
    type = "text",
    texttype = "property",
    grid = {2, 7},
    color = {95,157,209},
    layer = 20,
  },
  -- 25
  {
    name = "text_got",
    sprite = "text_got",
    type = "text",
    texttype = "verb",
    grid = {2, 0},
    color = {255,255,255},
    layer = 20,
  },
  --26
  {
    name = "text_colrful",
    sprite = "text_colrful",
    type = "text",
    texttype = "property",
    grid = {3, 1},
    color = {255,255,255},
    layer = 20,
  },
  --27
  {
    name = "text_reed",
    sprite = "text_reed",
    type = "text",
    texttype = "property",
    grid = {4, 1},
    color = {255,0,0},
    layer = 20,
  },
  --28
  {
    name = "text_bleu",
    sprite = "text_bleu",
    type = "text",
    texttype = "property",
    grid = {5, 1},
    color = {0,0,255},
    layer = 20,
  },
  --29
  {
    name = "text_tranz",
    sprite = "text_tranz",
    type = "text",
    texttype = "property",
    grid = {3, 2},
    color = {255,255,255},
    layer = 20,
  },
  --30
  {
    name = "text_gay",
    sprite = "text_gay-colored",
    type = "text",
    texttype = "property",
    grid = {4, 2},
    color = {255,255,255},
    layer = 20,
  },
  --31
  {
    name = "text_mous",
    sprite = "text_mous",
    type = "text",
    grid = {6, 1},
    color = {145,131,215},
    layer = 20,
  },
  --32
  {
    name = "text_boux",
    sprite = "text_boux",
    type = "text",
    grid = {3, 7},
    color = {144,103,62},
    layer = 20,
  },
  --33
  {
    name = "boux",
    sprite = "boux",
    type = "object",
    grid = {4, 7},
    color = {194,158,70},
    layer = 16,
  },
  --34
  {
    name = "text_skul",
    sprite = "text_skul",
    type = "text",
    grid = {3, 6},
    color = {130,38,28},
    layer = 20,
  },
  --35
  {
    name = "skul",
    sprite = "skul",
    type = "object",
    grid = {4, 6},
    color = {130,38,28},
    layer = 16,
    rotate = true,
  },
  --36
  {
    name = "text_laav",
    sprite = "text_laav",
    type = "text",
    grid = {5, 6},
    color = {228,153,80},
    layer = 20,
  },
  --37
  {
    name = "laav",
    sprite = "watr",
    type = "object",
    grid = {6, 6},
    color = {228,153,80},
    layer = 2,
  },
  --38
  {
    name = "text_keek",
    sprite = "text_keek",
    type = "text",
    grid = {3, 4},
    color = {229,83,59},
    layer = 20,
  },
  --39
  {
    name = "keek",
    sprite = "keek",
    type = "object",
    grid = {4, 4},
    color = {229,83,59},
    layer = 18,
    rotate = true,
  },
  --38
  {
    name = "text_meem",
    sprite = "text_meem",
    type = "text",
    grid = {3, 5},
    color = {142,94,156},
    layer = 20,
  },
  --39
  {
    name = "meem",
    sprite = "meem",
    type = "object",
    grid = {4, 5},
    color = {142,94,156},
    layer = 18,
    rotate = true,
  },
  --40
  {
    name = "text_til",
    sprite = "text_til",
    type = "text",
    grid = {5, 7},
    color = {115,115,115},
    layer = 20
  }
}