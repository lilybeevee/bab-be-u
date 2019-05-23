MAX_MOVE_TIMER = 80
INPUT_DELAY = 150
MAX_UNDO_DELAY = 150
MIN_UNDO_DELAY = 50
UNDO_SPEED = 5
UNDO_DELAY = MAX_UNDO_DELAY
repeat_keys = {"wasd","udlr","space","z"}

settings = {
  music_on = true
}

if love.filesystem.read("Settings.bab") ~= nil then
  settings = json.decode(love.filesystem.read("Settings.bab"))
end

debug = false

dirs = {{1,0},{0,1},{-1,0},{0,-1}}
dirs_by_name = {
  right = 1,
  down = 2,
  left = 3,
  up = 4
}
dirs_by_offset = {}
dirs_by_offset[-1],dirs_by_offset[0],dirs_by_offset[1] = {},{},{}
dirs_by_offset[1][0] = 1
dirs_by_offset[0][1] = 2
dirs_by_offset[-1][0] = 3
dirs_by_offset[0][-1] = 4
dirs8 = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}
dirs8_by_name = {
  right = 1,
  downright = 2,
  down = 3,
  downleft = 4,
  left = 5,
  upleft = 6,
  up = 7,
  upright = 8,
}
dirs8_by_offset = {}
dirs8_by_offset[-1],dirs8_by_offset[0],dirs8_by_offset[1] = {},{},{}
dirs8_by_offset[1][0] = 1
dirs8_by_offset[1][1] = 2
dirs8_by_offset[0][1] = 3
dirs8_by_offset[-1][1] = 4
dirs8_by_offset[-1][0] = 5
dirs8_by_offset[-1][-1] = 6
dirs8_by_offset[0][-1] = 7
dirs8_by_offset[1][-1] = 8
TILE_SIZE = 32

mapwidth = 21
mapheight = 15

map = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{2},{3},{4},{},{},{},{},{},{},{},{},{},{},{},{},{},{19},{3},{20},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{55},{},{55},{},{},{},{},{},{},{},{},{},{},{},{1},{},{},{},{},{},{},{56},{},{59},{},{},{},{},{},{},{18},{},{},{},{},{},{},{},{},{},{},{},{57},{},{58},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}

tiles_list = {
  -- 1
  {
    name = "bab",
    sprite = "bab",
    sleepsprite = "bab_slep",
    type = "object",
    grid = {0, 1},
    color = {255,255,255},
    layer = 5,
    rotate = true,
  },
  -- 2
  {
    name = "text_bab",
    sprite = "text_bab",
    type = "text",
    grid = {1, 1},
    color = {217,57,106},
    layer = 20,
  },
  -- 3
  {
    name = "text_be",
    sprite = "text_be",
    type = "text",
    texttype = "verb",
    argtypes = {"object", "property"},
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
    grid = {0, 5},
    color = {41,49,65},
    layer = 2,
  },
  -- 6
  {
    name = "text_wal",
    sprite = "text_wal",
    type = "text",
    grid = {1, 5},
    color = {115,115,115},
    layer = 20,
  },
  -- 7
  {
    name = "text_no go",
    sprite = "text_nogo",
    type = "text",
    texttype = "property",
    grid = {2, 5},
    color = {75,92,28},
    layer = 20,
  },
  -- 8
  {
    name = "roc",
    sprite = "roc",
    type = "object",
    grid = {0, 4},
    color = {194,158,70},
    layer = 3,
  },
  -- 9
  {
    name = "text_roc",
    sprite = "text_roc",
    type = "text",
    grid = {1, 4},
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
    grid = {3, 2},
    color = {229,83,59},
    layer = 3,
  },
  -- 12
  {
    name = "text_dor",
    sprite = "text_dor",
    type = "text",
    grid = {4, 2},
    color = {229,83,59},
    layer = 20,
  },
  -- 13
  {
    name = "text_ned kee",
    sprite = "text_nedkee",
    type = "text",
    texttype = "property",
    grid = {5, 2},
    color = {229,83,59},
    layer = 20,
  },
  -- 14
  {
    name = "kee",
    sprite = "kee",
    type = "object",
    grid = {3, 1},
    color = {237,226,133},
    layer = 4,
    rotate = true,
  },
  -- 15
  {
    name = "text_kee",
    sprite = "text_kee",
    type = "text",
    grid = {4, 1},
    color = {237,226,133},
    layer = 20,
  },
  -- 16
  {
    name = "text_for dor",
    sprite = "text_fordor",
    type = "text",
    texttype = "property",
    grid = {5, 1},
    color = {237,226,133},
    layer = 20,
  },
  -- 17
  {
    name = "text_&",
    sprite = "text_and",
    type = "text",
    texttype = "and",
    grid = {2, 0},
    color = {255,255,255},
    layer = 20,
  },
  -- 18
  {
    name = "flog",
    sprite = "flog",
    type = "object",
    grid = {0, 3},
    color = {237,226,133},
    layer = 3,
  },
  -- 19
  {
    name = "text_flog",
    sprite = "text_flog",
    type = "text",
    grid = {1, 3},
    color = {237,226,133},
    layer = 20,
  },
  -- 20
  {
    name = "text_:)",
    sprite = "text_good",
    type = "text",
    texttype = "property",
    grid = {2, 3},
    color = {237,226,133},
    layer = 20,
  },
  -- 21
  {
    name = "til",
    sprite = "til",
    type = "object",
    grid = {3, 7},
    color = {21,24,31},
    layer = 1,
  },
  -- 22
  {
    name = "watr",
    sprite = "watr",
    type = "object",
    grid = {0, 6},
    color = {95,157,209},
    layer = 1,
  },
  -- 23
  {
    name = "text_watr",
    sprite = "text_watr",
    type = "text",
    grid = {1, 6},
    color = {95,157,209},
    layer = 20,
  },
  -- 24
  {
    name = "text_no swim",
    sprite = "text_no swim",
    type = "text",
    texttype = "property",
    grid = {2, 6},
    color = {95,157,209},
    layer = 20,
  },
  -- 25
  {
    name = "text_got",
    sprite = "text_got",
    type = "text",
    texttype = "verb",
    grid = {3, 0},
    color = {255,255,255},
    layer = 20,
  },
  --26
  {
    name = "text_colrful",
    sprite = "text_colrful",
    type = "text",
    texttype = "property",
    grid = {8, 6},
    color = {255,255,255},
    layer = 20,
  },
  --27
  {
    name = "text_reed",
    sprite = "text_reed",
    type = "text",
    texttype = "property",
    grid = {10, 6},
    color = {229,83,59},
    layer = 20,
  },
  --28
  {
    name = "text_bleu",
    sprite = "text_bleu",
    type = "text",
    texttype = "property",
    grid = {9, 6},
    color = {145,131,215},
    layer = 20,
  },
  --29
  {
    name = "text_tranz",
    sprite = "text_tranz-colored",
    type = "text",
    texttype = "property",
    grid = {9, 1},
    color = {255,255,255},
    layer = 20,
  },
  --30
  {
    name = "text_gay",
    sprite = "text_gay-colored",
    type = "text",
    texttype = "property",
    grid = {10, 1},
    color = {255,255,255},
    layer = 20,
  },
  --31
  {
    name = "text_mous",
    sprite = "text_mous",
    type = "text",
    grid = {10, 0},
    color = {145,131,215},
    layer = 20,
  },
  --32
  {
    name = "text_boux",
    sprite = "text_boux",
    type = "text",
    grid = {1, 8},
    color = {144,103,62},
    layer = 20,
  },
  --33
  {
    name = "boux",
    sprite = "boux",
    type = "object",
    grid = {0, 8},
    color = {194,158,70},
    layer = 16,
  },
  --34
  {
    name = "text_skul",
    sprite = "text_skul",
    type = "text",
    grid = {1, 7},
    color = {130,38,28},
    layer = 20,
  },
  --35
  {
    name = "skul",
    sprite = "skul",
    sleepsprite = "skul_slep",
    type = "object",
    grid = {0, 7},
    color = {130,38,28},
    layer = 16,
    rotate = true,
  },
  --36
  {
    name = "text_laav",
    sprite = "text_laav",
    type = "text",
    grid = {10, 9},
    color = {228,153,80},
    layer = 20,
  },
  --37
  {
    name = "laav",
    sprite = "watr",
    type = "object",
    grid = {9, 9},
    color = {228,153,80},
    layer = 2,
  },
  --38
  {
    name = "text_keek",
    sprite = "text_keek",
    type = "text",
    grid = {1, 2},
    color = {229,83,59},
    layer = 20,
  },
  --39
  {
    name = "keek",
    sprite = "keek",
    sleepsprite = "keek_slep",
    type = "object",
    grid = {0, 2},
    color = {229,83,59},
    layer = 18,
    rotate = true,
  },
  --38
  {
    name = "text_meem",
    sprite = "text_meem",
    type = "text",
    grid = {4, 6},
    color = {142,94,156},
    layer = 20,
  },
  --39
  {
    name = "meem",
    sprite = "meem",
    sleepsprite = "meem_slep",
    type = "object",
    grid = {3, 6},
    color = {142,94,156},
    layer = 18,
    rotate = true,
  },
  --40
  {
    name = "text_til",
    sprite = "text_til",
    type = "text",
    grid = {4, 7},
    color = {115,115,115},
    layer = 20
  },
  --41
  {
    name = "text_text",
    sprite = "text_txt",
    type = "text",
    grid = {7, 0},
    color = {217,57,106},
    layer = 20,
  },
  --42
  {
    name = "text_os",
    sprite = "text_os",
    type = "text",
    grid = {4, 8},
    color = {217,57,106},
    layer = 20,
  },
  --43
  {
    name = "os",
    sprite = "os",
    type = "object",
    grid = {3, 8},
    color = {255,255,255},
    layer = 18,
    rotate = "true",
  },
  --44
  {
    name = "text_slep",
    sprite = "text_slep",
    type = "text",
    texttype = "property",
    grid = {8, 3},
    color = {131,200,229},
    layer = 20,
  },
  --45
  {
    name = "luv",
    sprite = "luv",
    type = "object",
    grid = {3, 5},
    color = {235,145,202},
    layer = 10,
    rotate = "true",
  },
  --46
  {
    name = "text_luv",
    sprite = "text_luv",
    type = "text",
    grid = {4, 5},
    color = {235,145,202},
    layer = 20,
  },
  --47
  {
    name = "frut",
    sprite = "frut",
    type = "object",
    grid = {3, 10},
    color = {229,83,59},
    layer = 10,
    rotate = "true",
  },
  --48
  {
    name = "text_frut",
    sprite = "text_frut",
    type = "text",
    grid = {4, 10},
    color = {229,83,59},
    layer = 20,
  },
  --49
  {
    name = "tre",
    sprite = "tre",
    type = "object",
    grid = {3, 9},
    color = {92,131,57},
    layer = 10,
    rotate = "true",
  },
  --50
  {
    name = "text_tre",
    sprite = "text_tre",
    type = "text",
    grid = {4, 9},
    color = {92,131,57},
    layer = 20,
  },
  --51
  {
    name = "wog",
    sprite = "wog",
    sleepsprite = "wog_slep",
    type = "object",
    grid = {9, 7},
    color = {237,226,133},
    layer = 10,
    rotate = "true",
  },
  --52
  {
    name = "text_wog",
    sprite = "text_wog",
    type = "text",
    grid = {10, 7},
    color = {237,226,133},
    layer = 20,
  },
  --tutorial sprites
  --53
  {
    name = "text_press",
    sprite = "tutorial_press",
    type = "text",
    grid = {-1, -1},
    color = {255,255,255},
    layer = 20,
  },
  --54
  {
    name = "text_f2",
    sprite = "tutorial_f2",
    type = "text",
    texttype = "verb",
    argtypes = {"object", "property"},
    grid = {-1, -1},
    color = {255,255,255},
    layer = 20,
  },
  --55
  {
    name = "text_edit",
    sprite = "tutorial_edit",
    type = "text",
    texttype = "property",
    grid = {-1, -1},
    color = {255,255,255},
    layer = 20,
  },
  --56
  {
    name = "text_play",
    sprite = "tutorial_play",
    type = "text",
    texttype = "property",
    grid = {-1, -1},
    color = {255,255,255},
    layer = 20,
  },
  --57
  {
    name = "text_f1",
    sprite = "tutorial_f1",
    type = "text",
    texttype = "verb",
    argtypes = {"object", "property"},
    grid = {-1, -1},
    color = {255,255,255},
    layer = 20,
  },
  -- 58
  {
    name = "text_:(",
    sprite = "text_bad",
    type = "text",
    texttype = "property",
    grid = {2, 7},
    color = {130,38,28},
    layer = 20,
  },
  -- 59
  {
    name = "text_walk",
    sprite = "text_walk",
    type = "text",
    texttype = "property",
    grid = {2, 2},
    color = {165,177,63},
    layer = 20,
  },
  -- 60
  {
    name = "text_fax",
    sprite = "text_fax",
    type = "text",
    grid = {6, 8},
    color = {142,94,156},
    layer = 20,
  },
  -- 61
  {
    name = "fax",
    sprite = "fax",
    type = "object",
    grid = {5, 8},
    color = {142,94,156},
    layer = 5,
  },
  -- 62
  {
    name = "text_boll",
    sprite = "text_boll",
    type = "text",
    grid = {1, 10},
    color = {257,57,106},
    layer = 20,
  },
  -- 63
  {
    name = "boll",
    sprite = "orrb",
    type = "object",
    grid = {0, 10},
    color = {257,57,106},
    layer = 5,
  },
  -- 64
  {
    name = "text_bellt",
    sprite = "text_bellt",
    type = "text",
    grid = {1, 9},
    color = {95,157,209},
    layer = 20,
  },
  -- 65
  {
    name = "bellt",
    sprite = "bellt",
    type = "object",
    grid = {0, 9},
    color = {41,49,65},
    layer = 3,
  },
  -- 66
  {
    name = "text_:o",
    sprite = "text_whoa",
    type = "text",
    texttype = "property",
    grid = {2, 10},
    color = {257,57,106},
    layer = 20,
  },
  -- 67
  {
    name = "text_up",
    sprite = "text_goup",
    type = "text",
    texttype = "property",
    grid = {6, 1},
    color = {131,200,229},
    layer = 20,
  },
  -- 68
  {
    name = "text_right",
    sprite = "text_goright",
    type = "text",
    texttype = "property",
    grid = {7, 1},
    color = {131,200,229},
    layer = 20,
  },
  -- 69
  {
    name = "text_left",
    sprite = "text_goleft",
    type = "text",
    texttype = "property",
    grid = {6, 2},
    color = {131,200,229},
    layer = 20,
    nice = true,
  },
  -- 70
  {
    name = "text_down",
    sprite = "text_godown",
    type = "text",
    texttype = "property",
    grid = {7, 2},
    color = {131,200,229},
    layer = 20,
  },
  -- 71
  {
    name = "text_edgy",
    sprite = "text_edgy",
    type = "text",
    texttype = "property",
    grid = {8, 2},
    color = {142,94,156},
    layer = 20,
  },
  -- 72
  {
    name = "text_on",
    sprite = "text_on",
    type = "text",
    texttype = "cond_infix",
    grid = {7, 4},
    color = {255,255,255},
    layer = 20,
  },
  -- 73
  {
    name = "text_look at",
    sprite = "text_look at",
    type = "text",
    texttype = "cond_infix",
    grid = {10, 4},
    color = {255,255,255},
    layer = 20,
  },
  -- 74
  {
    name = "text_frenles",
    sprite = "text_frenles",
    type = "text",
    texttype = "cond_prefix",
    grid = {9, 4},
    color = {229,83,59},
    layer = 20,
  },
  --75
  {
    name = "text_creat",
    sprite = "text_creat",
    type = "text",
    texttype = "verb",
    grid = {7, 5},
    color = {255,255,255},
    layer = 20,
  },
  --76
  {
    name = "text_consume",
    sprite = "text_consume",
    type = "text",
    texttype = "verb",
    grid = {8, 5},
    color = {229,83,59},
    layer = 20,
  },
  --77
  {
    name = "kirb",
    sprite = "kirb",
    type = "object",
    grid = {5, 7},
    color = {235,145,202},
    layer = 6,
    rotate = true,
  },
  --78
  {
    name = "text_kirb",
    sprite = "text_kirb",
    type = "text",
    grid = {6, 7},
    color = {235,145,202},
    layer = 20,
  },
  --79
  {
    name = "gun",
    sprite = "gun",
    type = "object",
    grid = {7, 7},
    color = {255,255,255},
    layer = 4,
  },
  --80
  {
    name = "text_gun",
    sprite = "text_gun",
    type = "text",
    grid = {8, 7},
    color = {255,255,255},
    layer = 20,
  },
  --81
  {
    name = "text_ouch",
    sprite = "text_ouch",
    type = "text",
    texttype = "property",
    grid = {7, 3},
    color = {62, 118, 136},
    layer = 20,
  },
  -- 82
  {
    name = "tot",
    sprite = "tot",
    sleepsprite = "tot_slep",
    type = "object",
    grid = {9, 8},
    color = {235,145,202},
    layer = 5,
    rotate = true,
  },
  -- 83
  {
    name = "text_tot",
    sprite = "text_tot",
    type = "text",
    grid = {10, 8},
    color = {235,145,202},
    layer = 20,
  },
  -- 84
  {
    name = "text_qt",
    sprite = "text_qt",
    type = "text",
    texttype = "property",
    grid = {9, 2},
    color = {235,145,202},
    layer = 20,
  },
  -- 85
  {
    name = "o",
    sprite = "o",
    type = "object",
    grid = {5, 6},
    color = {237,226,133},
    layer = 5,
  },
  -- 86
  {
    name = "text_o",
    sprite = "text_o",
    type = "text",
    grid = {6, 6},
    color = {237,226,133},
    layer = 20,
  },
  -- 87
  {
    name = "han",
    sprite = "han",
    type = "object",
    grid = {7, 8},
    color = {255,255,255},
    layer = 5,
    rotate = true,
  },
  -- 88
  {
    name = "text_han",
    sprite = "text_han",
    type = "text",
    grid = {8, 8},
    color = {255,255,255},
    layer = 20,
  },
  -- 87
  {
    name = "gras",
    sprite = "gras",
    type = "object",
    grid = {3, 4},
    color = {48,56,36},
    layer = 5,
  },
  -- 88
  {
    name = "text_gras",
    sprite = "text_gras",
    type = "text",
    grid = {4, 4},
    color = {165,177,63},
    layer = 20,
  },
  -- 89
  {
    name = "dayzy",
    sprite = "dayzy",
    type = "object",
    grid = {5, 4},
    color = {145,131,215},
    layer = 5,
  },
  -- 90
  {
    name = "text_dayzy",
    sprite = "text_dayzy",
    type = "text",
    grid = {6, 4},
    color = {145,131,215},
    layer = 20,
  },
  -- 91
  {
    name = "hurcane",
    sprite = "hurcane",
    type = "object",
    grid = {5, 5},
    color = {142,94,156},
    layer = 12,
  },
  -- 92
  {
    name = "text_hurcane",
    sprite = "text_hurcane",
    type = "text",
    grid = {6, 5},
    color = {142,94,156},
    layer = 20,
  },
  -- 91
  {
    name = "hatt",
    sprite = "hat",
    type = "object",
    grid = {7, 9},
    color = {142,94,156},
    layer = 12,
  },
  -- 92
  {
    name = "text_hatt",
    sprite = "text_hatt",
    type = "text",
    grid = {8, 9},
    color = {142,94,156},
    layer = 20,
  },
}