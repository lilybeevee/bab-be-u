DEFAULT_WIDTH = 800
DEFAULT_HEIGHT = 600

ANIM_TIMER = 180
MAX_MOVE_TIMER = 80
INPUT_DELAY = 150
MAX_UNDO_DELAY = 150
MIN_UNDO_DELAY = 50
UNDO_SPEED = 5
UNDO_DELAY = MAX_UNDO_DELAY
repeat_keys = {"wasd","udlr","numpad","space","undo"}

is_mobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
--is_mobile = true

PACK_UNIT_V1 = "hhhb" -- ID, X, Y, DIR

settings = {
  music_on = true
}

if love.filesystem.read("Settings.bab") ~= nil then
  settings = json.decode(love.filesystem.read("Settings.bab"))
end

debug = false
debug_values = {

}

if love.filesystem.getInfo("build_number") ~= nil then
  build_number = love.filesystem.read("build_number")
else
  build_number = "HEY, READ THE README!"
end

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

map_music = "bab be go"
map_ver = 1

default_map = '{"map":"eJwlzEEOgCAMRNEpGNSwEriLqPe/l39Cunjpb9Kk8GQlE7ArNmVvt04VxQTiA4djdfyA+AKx61pfmmnAbah7+wFtgAJz","width":21,"music":"bab be go","version":1,"height":15,"author":"","name":"new level","palette":"default"}'


tiles_list = {
  -- 1
  {
    name = "bab",
    sprite = "bab",
    sleepsprite = "bab_slep",
    type = "object",
    grid = {0, 1},
    color = {0, 3},
    layer = 6,
    rotate = true,
    eye = {x=22, y=10, w=2, h=2},
  },
  -- 2
  {
    name = "text_bab",
    sprite = "text_bab",
    type = "text",
    grid = {1, 1},
    color = {4, 1},
    layer = 20,
  },
  -- 3
  {
    name = "text_be",
    sprite = "text_be",
    type = "text",
    texttype = "verb_all",
    grid = {1, 0},
    color = {0, 3},
    layer = 20,
  },
  -- 4
  {
    name = "text_u",
    sprite = "text_u",
    type = "text",
    texttype = "property",
    grid = {2, 1},
    color = {4, 1},
    layer = 20,
  },
  -- 5
  {
    name = "wal",
    sprite = "wal",
    type = "object",
    grid = {0, 5},
    color = {1, 1},
    layer = 2,
  },
  -- 6
  {
    name = "text_wal",
    sprite = "text_wal",
    type = "text",
    grid = {1, 5},
    color = {0, 1},
    layer = 20,
  },
  -- 7
  {
    name = "text_no go",
    sprite = "text_nogo",
    type = "text",
    texttype = "property",
    grid = {2, 5},
    color = {5, 1},
    layer = 20,
  },
  -- 8
  {
    name = "roc",
    sprite = "roc",
    type = "object",
    grid = {0, 4},
    color = {6, 2},
    layer = 3,
  },
  -- 9
  {
    name = "text_roc",
    sprite = "text_roc",
    type = "text",
    grid = {1, 4},
    color = {6, 1},
    layer = 20,
  },
  -- 10
  {
    name = "text_go away",
    sprite = "text_goaway",
    type = "text",
    texttype = "property",
    grid = {2, 4},
    color = {6, 1},
    layer = 20,
  },
  -- 11
  {
    name = "dor",
    sprite = "dor",
    type = "object",
    grid = {3, 2},
    color = {2, 2},
    layer = 3,
  },
  -- 12
  {
    name = "text_dor",
    sprite = "text_dor",
    type = "text",
    grid = {4, 2},
    color = {2, 2},
    layer = 20,
  },
  -- 13
  {
    name = "text_ned kee",
    sprite = "text_nedkee",
    type = "text",
    texttype = "property",
    grid = {5, 2},
    color = {2, 2},
    layer = 20,
  },
  -- 14
  {
    name = "kee",
    sprite = "kee",
    type = "object",
    grid = {3, 1},
    color = {2, 4},
    layer = 4,
    rotate = true,
  },
  -- 15
  {
    name = "text_kee",
    sprite = "text_kee",
    type = "text",
    grid = {4, 1},
    color = {2, 4},
    layer = 20,
  },
  -- 16
  {
    name = "text_for dor",
    sprite = "text_fordor",
    type = "text",
    texttype = "property",
    grid = {5, 1},
    color = {2, 4},
    layer = 20,
  },
  -- 17
  {
    name = "text_&",
    sprite = "text_and",
    type = "text",
    texttype = "and",
    grid = {2, 0},
    color = {0, 3},
    layer = 20,
  },
  -- 18
  {
    name = "flog",
    sprite = "flog",
    type = "object",
    grid = {0, 3},
    color = {2, 4},
    layer = 3,
  },
  -- 19
  {
    name = "text_flog",
    sprite = "text_flog",
    type = "text",
    grid = {1, 3},
    color = {2, 4},
    layer = 20,
  },
  -- 20
  {
    name = "text_:)",
    sprite = "text_good",
    type = "text",
    texttype = "property",
    grid = {2, 3},
    color = {2, 4},
    layer = 20,
  },
  -- 21
  {
    name = "til",
    sprite = "til",
    type = "object",
    grid = {3, 7},
    color = {1, 0},
    layer = 1,
  },
  -- 22
  {
    name = "watr",
    sprite = "watr",
    type = "object",
    grid = {0, 6},
    color = {1, 3},
    layer = 1,
  },
  -- 23
  {
    name = "text_watr",
    sprite = "text_watr",
    type = "text",
    grid = {1, 6},
    color = {1, 3},
    layer = 20,
  },
  -- 24
  {
    name = "text_no swim",
    sprite = "text_no swim",
    type = "text",
    texttype = "property",
    grid = {2, 6},
    color = {1, 3},
    layer = 20,
  },
  -- 25
  {
    name = "text_got",
    sprite = "text_got",
    type = "text",
    texttype = "verb_object",
    grid = {3, 0},
    color = {0, 3},
    layer = 20,
  },
  --26
  {
    name = "text_colrful",
    sprite = "text_colrful",
    type = "text",
    texttype = "property",
    grid = {7, 6},
    color = {0, 3},
    layer = 20,
  },
  --27
  {
    name = "text_reed",
    sprite = "text_reed",
    type = "text",
    texttype = "property",
    grid = {9, 6},
    color = {2, 2},
    layer = 20,
  },
  --28
  {
    name = "text_bleu",
    sprite = "text_bleu",
    type = "text",
    texttype = "property",
    grid = {8, 6},
    color = {1, 3},
    layer = 20,
  },
  --29
  {
    name = "text_tranz",
    sprite = "text_tranz-colored",
    type = "text",
    texttype = "property",
    grid = {9, 1},
    color = {255, 255, 255},
    layer = 20,
  },
  --30
  {
    name = "text_gay",
    sprite = "text_gay-colored",
    type = "text",
    texttype = "property",
    grid = {10, 1},
    color = {255, 255, 255},
    layer = 20,
  },
  --31
  {
    name = "text_mous",
    sprite = "text_mous",
    type = "text",
    grid = {10, 0},
    color = {3, 3},
    layer = 20,
  },
  --32
  {
    name = "text_boux",
    sprite = "text_boux",
    type = "text",
    grid = {1, 8},
    color = {6, 1},
    layer = 20,
  },
  --33
  {
    name = "boux",
    sprite = "boux",
    type = "object",
    grid = {0, 8},
    color = {6, 2},
    layer = 3,
  },
  --34
  {
    name = "text_skul",
    sprite = "text_skul",
    type = "text",
    grid = {1, 7},
    color = {2, 1},
    layer = 20,
  },
  --35
  {
    name = "skul",
    sprite = "skul",
    sleepsprite = "skul_slep",
    type = "object",
    grid = {0, 7},
    color = {2, 1},
    layer = 5,
    rotate = true,
    eye = {x=21, y=8, w=4, h=4},
  },
  --36
  {
    name = "text_laav",
    sprite = "text_laav",
    type = "text",
    grid = {10, 9},
    color = {2, 3},
    layer = 20,
  },
  --37
  {
    name = "laav",
    sprite = "watr",
    type = "object",
    grid = {9, 9},
    color = {2, 3},
    layer = 2,
  },
  --38
  {
    name = "text_keek",
    sprite = "text_keek",
    type = "text",
    grid = {1, 2},
    color = {2, 2},
    layer = 20,
  },
  --39
  {
    name = "keek",
    sprite = "keek",
    sleepsprite = "keek_slep",
    type = "object",
    grid = {0, 2},
    color = {2, 2},
    layer = 5,
    rotate = true,
    eye = {x=19, y=7, w=2, h=2},
  },
  --38
  {
    name = "text_meem",
    sprite = "text_meem",
    type = "text",
    grid = {4, 6},
    color = {3, 1},
    layer = 20,
  },
  --39
  {
    name = "meem",
    sprite = "meem",
    sleepsprite = "meem_slep",
    type = "object",
    grid = {3, 6},
    color = {3, 1},
    layer = 5,
    rotate = true,
    eye = {x=18, y=3, w=2, h=2},
  },
  --40
  {
    name = "text_til",
    sprite = "text_til",
    type = "text",
    grid = {4, 7},
    color = {0, 1},
    layer = 20
  },
  --41
  {
    name = "text_text",
    sprite = "text_txt",
    type = "text",
    grid = {7, 0},
    color = {4, 1},
    layer = 20,
  },
  --42
  {
    name = "text_os",
    sprite = "text_os",
    type = "text",
    grid = {4, 8},
    color = {4, 1},
    layer = 20,
  },
  --43
  {
    name = "os",
    sprite = "os",
    type = "object",
    grid = {3, 8},
    color = {0, 3},
    layer = 5,
    rotate = "true",
    eye = {x=14, y=8, w=2, h=2},
  },
  --44
  {
    name = "text_slep",
    sprite = "text_slep",
    type = "text",
    texttype = "property",
    grid = {8, 3},
    color = {1, 3},
    layer = 20,
  },
  --45
  {
    name = "luv",
    sprite = "luv",
    type = "object",
    grid = {3, 5},
    color = {4, 2},
    layer = 3,
    rotate = "true",
  },
  --46
  {
    name = "text_luv",
    sprite = "text_luv",
    type = "text",
    grid = {4, 5},
    color = {4, 2},
    layer = 20,
  },
  --47
  {
    name = "frut",
    sprite = "frut",
    type = "object",
    grid = {3, 10},
    color = {2, 2},
    layer = 3,
    rotate = "true",
  },
  --48
  {
    name = "text_frut",
    sprite = "text_frut",
    type = "text",
    grid = {4, 10},
    color = {2, 2},
    layer = 20,
  },
  --49
  {
    name = "tre",
    sprite = "tre",
    type = "object",
    grid = {3, 9},
    color = {5, 2},
    layer = 2,
    rotate = "true",
  },
  --50
  {
    name = "text_tre",
    sprite = "text_tre",
    type = "text",
    grid = {4, 9},
    color = {5, 2},
    layer = 20,
  },
  --51
  {
    name = "wog",
    sprite = "wog",
    sleepsprite = "wog_slep",
    type = "object",
    grid = {9, 7},
    color = {2, 4},
    layer = 5,
    rotate = "true",
    eye = {x=16, y=9, w=3, h=3},
  },
  --52
  {
    name = "text_wog",
    sprite = "text_wog",
    type = "text",
    grid = {10, 7},
    color = {2, 4},
    layer = 20,
  },
  --tutorial sprites
  --53
  {
    name = "text_press",
    sprite = "tutorial_press",
    type = "text",
    grid = {-1, -1},
    color = {0, 3},
    layer = 20,
  },
  --54
  {
    name = "text_f2",
    sprite = "tutorial_f2",
    type = "text",
    texttype = "verb_all",
    grid = {-1, -1},
    color = {0, 3},
    layer = 20,
  },
  --55
  {
    name = "text_edit",
    sprite = "tutorial_edit",
    type = "text",
    texttype = "property",
    grid = {-1, -1},
    color = {0, 3},
    layer = 20,
  },
  --56
  {
    name = "text_play",
    sprite = "tutorial_play",
    type = "text",
    texttype = "property",
    grid = {-1, -1},
    color = {0, 3},
    layer = 20,
  },
  --57
  {
    name = "text_f1",
    sprite = "tutorial_f1",
    type = "text",
    texttype = "verb_all",
    grid = {-1, -1},
    color = {0, 3},
    layer = 20,
  },
  -- 58
  {
    name = "text_:(",
    sprite = "text_bad",
    type = "text",
    texttype = "property",
    grid = {2, 7},
    color = {2, 1},
    layer = 20,
  },
  -- 59
  {
    name = "text_walk",
    sprite = "text_walk",
    type = "text",
    texttype = "property",
    grid = {2, 2},
    color = {5, 3},
    layer = 20,
  },
  -- 60
  {
    name = "text_fax",
    sprite = "text_fax",
    type = "text",
    grid = {6, 8},
    color = {3, 1},
    layer = 20,
  },
  -- 61
  {
    name = "fax",
    sprite = "fax",
    sleepsprite = "fax_slep",
    type = "object",
    grid = {5, 8},
    color = {3, 1},
    layer = 5,
    eye = {x=21, y=13, w=2, h=3},
  },
  -- 62
  {
    name = "text_boll",
    sprite = "text_boll",
    type = "text",
    grid = {1, 10},
    color = {4, 1},
    layer = 20,
  },
  -- 63
  {
    name = "boll",
    sprite = "orrb",
    type = "object",
    grid = {0, 10},
    color = {4, 1},
    layer = 3,
  },
  -- 64
  {
    name = "text_bellt",
    sprite = "text_bellt",
    type = "text",
    grid = {1, 9},
    color = {1, 3},
    layer = 20,
  },
  -- 65
  {
    name = "bellt",
    sprite = "bellt",
    type = "object",
    grid = {0, 9},
    color = {1, 1},
    layer = 1,
    rotate = true,
  },
  -- 66
  {
    name = "text_:o",
    sprite = "text_whoa",
    type = "text",
    texttype = "property",
    grid = {2, 10},
    color = {4, 1},
    layer = 20,
  },
  -- 67
  {
    name = "text_up",
    sprite = "text_goup",
    type = "text",
    texttype = "property",
    --grid = {6, 1},
    color = {1, 4},
    layer = 20,
  },
  -- 68
  {
    name = "text_direction",
    sprite = "text_goright",
    type = "text",
    texttype = "property",
    grid = {6, 1},
    color = {1, 4},
    layer = 20,
    rotate = true,
  },
  -- 69
  {
    name = "text_left",
    sprite = "text_goleft",
    type = "text",
    texttype = "property",
    --grid = {6, 2},
    color = {1, 4},
    layer = 20,
    nice = true,
  },
  -- 70
  {
    name = "text_down",
    sprite = "text_godown",
    type = "text",
    texttype = "property",
    --grid = {7, 2},
    color = {1, 4},
    layer = 20,
  },
  -- 71
  {
    name = "text_behin u",
    sprite = "text_behinu",
    type = "text",
    texttype = "property",
    grid = {8, 2},
    color = {3, 1},
    layer = 20,
  },
  -- 72
  {
    name = "text_wfren",
    sprite = "text_wfren",
    type = "text",
    texttype = "cond_infix",
    grid = {7, 4},
    color = {0, 3},
    layer = 20,
  },
  -- 73
  {
    name = "text_look at",
    sprite = "text_look at",
    type = "text",
    texttype = "verb_object",
    grid = {10, 4},
    color = {0, 3},
    layer = 20,
  },
  -- 74
  {
    name = "text_frenles",
    sprite = "text_frenles",
    type = "text",
    texttype = "cond_prefix",
    grid = {9, 4},
    color = {2, 2},
    layer = 20,
  },
  --75
  {
    name = "text_creat",
    sprite = "text_creat",
    type = "text",
    texttype = "verb_object",
    grid = {7, 5},
    color = {0, 3},
    layer = 20,
  },
  --76
  {
    name = "text_snacc",
    sprite = "text_snacc",
    type = "text",
    texttype = "verb_object",
    allowconds = true,
    grid = {8, 5},
    color = {2, 2},
    layer = 20,
  },
  --77
  {
    name = "kirb",
    sprite = "kirb",
    sleepsprite = "kirb_slep",
    type = "object",
    grid = {5, 7},
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=21, y=9, w=2, h=2},
  },
  --78
  {
    name = "text_kirb",
    sprite = "text_kirb",
    type = "text",
    grid = {6, 7},
    color = {4, 2},
    layer = 20,
  },
  --79
  {
    name = "gun",
    sprite = "gun",
    type = "object",
    grid = {7, 7},
    color = {0, 3},
    layer = 3,
  },
  --80
  {
    name = "text_gun",
    sprite = "text_gun",
    type = "text",
    grid = {8, 7},
    color = {0, 3},
    layer = 20,
  },
  --81
  {
    name = "text_ouch",
    sprite = "text_ouch",
    type = "text",
    texttype = "property",
    grid = {7, 3},
    color = {1, 2},
    layer = 20,
  },
  -- 82
  {
    name = "tot",
    sprite = "tot",
    sleepsprite = "tot_slep",
    type = "object",
    grid = {9, 8},
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=18, y=8, w=2, h=2},
  },
  -- 83
  {
    name = "text_tot",
    sprite = "text_tot",
    type = "text",
    grid = {10, 8},
    color = {4, 2},
    layer = 20,
  },
  -- 84
  {
    name = "text_qt",
    sprite = "text_qt",
    type = "text",
    texttype = "property",
    grid = {9, 2},
    color = {4, 2},
    layer = 20,
  },
  -- 85
  {
    name = "o",
    sprite = "o",
    sleepsprite = "o_slep",
    type = "object",
    grid = {5, 6},
    color = {2, 4},
    layer = 5,
    eye = {x=19, y=7, w=2, h=2},
  },
  -- 86
  {
    name = "text_o",
    sprite = "text_o",
    type = "text",
    grid = {6, 6},
    color = {2, 4},
    layer = 20,
  },
  -- 87
  {
    name = "han",
    sprite = "han",
    type = "object",
    grid = {7, 8},
    color = {0, 3},
    layer = 7,
    rotate = true,
  },
  -- 88
  {
    name = "text_han",
    sprite = "text_han",
    type = "text",
    grid = {8, 8},
    color = {0, 3},
    layer = 20,
  },
  -- 87
  {
    name = "gras",
    sprite = "gras",
    type = "object",
    grid = {3, 4},
    color = {5, 1},
    layer = 1,
  },
  -- 88
  {
    name = "text_gras",
    sprite = "text_gras",
    type = "text",
    grid = {4, 4},
    color = {5, 3},
    layer = 20,
  },
  -- 89
  {
    name = "dayzy",
    sprite = "dayzy",
    type = "object",
    grid = {5, 4},
    color = {3, 3},
    layer = 5,
    eye = {x=10, y=7, w=3, h=3},
  },
  -- 90
  {
    name = "text_dayzy",
    sprite = "text_dayzy",
    type = "text",
    grid = {6, 4},
    color = {3, 3},
    layer = 20,
  },
  -- 91
  {
    name = "hurcane",
    sprite = "hurcane",
    type = "object",
    grid = {5, 5},
    color = {3, 1},
    layer = 3,
    eye = {x=15, y=15, w=3, h=3},
  },
  -- 92
  {
    name = "text_hurcane",
    sprite = "text_hurcane",
    type = "text",
    grid = {6, 5},
    color = {3, 1},
    layer = 20,
  },
  -- 91
  {
    name = "hatt",
    sprite = "hat",
    type = "object",
    grid = {7, 9},
    color = {3, 1},
    layer = 3,
  },
  -- 92
  {
    name = "text_hatt",
    sprite = "text_hatt",
    type = "text",
    grid = {8, 9},
    color = {3, 1},
    layer = 20,
  },
  -- 93
  {
    name = "press",
    sprite = "press",
    type = "object",
    grid = {-1,-1},
    color = {255, 255, 255},
    layer = 3,
  },
  --- 94
  {
    name = "text_yeet",
    sprite = "text_yeet",
    type = "text",
    texttype = "verb_object",
    allowconds = true,
    grid = {10, 5},
    color = {0, 3},
    layer = 20,
  },
  --- 95
  {
    name = "text_go",
    sprite = "text_go",
    type = "text",
    texttype = "property",
    grid = {2, 9},
    color = {1, 3},
    layer = 20,
  },
  --- 96
  {
    name = "text_icy",
    sprite = "text_icy",
    type = "text",
    texttype = "property",
    grid = {11, 1},
    color = {1, 4},
    layer = 20,
  },
  --- 97
  {
    name = "text_xwx",
    sprite = "text_xwx",
    type = "text",
    texttype = "property",
    grid = {12, 1},
    color = {3, 2},
    layer = 20,
  },
  --98
  {
    name = "text_windo",
    sprite = "text_windo",
    type = "text",
    texttype = "object",
    grid = {9, 0},
    color = {0, 3},
    layer = 20,
  },
  --- 99
  {
    name = "text_come pls",
    sprite = "text_comepls",
    type = "text",
    texttype = "property",
    grid = {2, 8},
    color = {6, 1},
    layer = 20,
  },
  --- 100
  {
    name = "text_sidekik",
    sprite = "text_sidekik",
    type = "text",
    texttype = "property",
    grid = {10, 3},
    color ={6, 1},
    layer = 20,
  },
  --- 101
  {
    name = "text_arond",
    sprite = "text_arond",
    type = "text",
    texttype = "cond_infix",
    grid = {8,4},
    color = {0, 3},
    layer = 20,
  },
  --- 102
  {
    name = "chekr",
    sprite = "chekr",
    type = "object",
    grid = {11, 3},
    color ={3, 2},
    layer = 1,
  },
  --- 103
  {
    name = "text_chekr",
    sprite = "text_chekr",
    type = "text",
    grid = {12, 3},
    color ={3, 2},
    layer = 20,
  },
  --- 104
  {
    name = "text_diagnal",
    sprite = "text_diagnal",
    type = "text",
    texttype = "property",
    grid = {13, 3},
    color ={3, 2},
    layer = 20,
  },
  --- 105
  {
    name = "text_go my wey",
    sprite = "text_go my wey",
    type = "text",
    texttype = "property",
    grid = {13, 4},
    color ={1, 4},
    layer = 20,
  },
  --- 106
  {
    name = "text_orthongl",
    sprite = "text_orthongl",
    type = "text",
    texttype = "property",
    grid = {13, 2},
    color ={3, 2},
    layer = 20,
  },
  --- 107
  {
    name = "arro",
    sprite = "arro",
    type = "object",
    grid = {11, 4},
    color ={0, 3},
    layer = 1,
    rotate = true,
  },
  --- 108
  {
    name = "text_arro",
    sprite = "text_arro",
    type = "text",
    grid = {12, 4},
    color ={0, 3},
    layer = 20,
  },
  --- 109
  {
    name = "text_hotte",
    sprite = "text_hotte",
    type = "text",
    texttype = "property",
    grid = {6,3},
    color = {2, 3},
    layer = 20,
  },
  --- 110
  {
    name = "text_fridgd",
    sprite = "text_fridgd",
    type = "text",
    texttype = "property",
    grid = {5,3},
    color = {1, 3},
    layer = 20,
  },
  --- 111
  {
    name = "text_colld",
    sprite = "text_colld",
    type = "text",
    grid = {4,3},
    color = {1, 3},
    layer = 20,
  },
  --- 112
  {
    name = "colld",
    sprite = "colld",
    type = "object",
    grid = {3,3},
    color = {1, 2},
    layer = 1,
  },
  --- 113
  {
    name = "text_goooo",
    sprite = "text_goooo",
    type = "text",
    texttype = "property",
    grid = {11, 2},
    color = {1, 3},
    layer = 20,
  },
  --- 114
  {
    name = "text_icyyyy",
    sprite = "text_icyyyy",
    type = "text",
    texttype = "property",
    grid = {12, 2},
    color = {1, 4},
    layer = 20,
  },
  -- 115
  {
    name = "text_protecc",
    sprite = "text_protecc",
    type = "text",
    texttype = "property",
    grid = {9, 3},
    color = {0, 3},
    layer = 20,
  },
  -- 116
  {
    name = "text_flye",
    sprite = "text_flye",
    type = "text",
    texttype = "property",
    grid = {8, 1},
    color = {1, 4},
    layer = 20,
  },
  --- 117
  {
    name = "text_piler",
    sprite = "text_piler",
    type = "text",
    grid = {6, 9},
    color = {0, 1},
    layer = 20,
  },
  --- 118
  {
    name = "piler",
    sprite = "piler",
    type = "object",
    grid = {5, 9},
    color = {0, 1},
    layer = 3,
  },
  -- 119
  {
    name = "text_n't",
    sprite = "text_nt",
    type = "text",
    texttype = "not",
    grid = {4, 0},
    color = {2, 2},
    layer = 20,
  },
  -- 120
  {
    name = "text_haet skye",
    sprite = "text_haet_skye",
    type = "text",
    texttype = "property",
    grid = {7,2},
    color = {5, 3},
    layer = 20,
  },
  -- 121
  {
    name = "clowd",
    sprite = "clowd",
    type = "object",
    grid = {5,10},
    color = {0, 3},
    layer = 7,
  },
  -- 122
  {
    name = "text_clowd",
    sprite = "text_clowd",
    type = "text",
    grid = {6,10},
    color = {0, 3},
    layer = 20,
  },
  -- 123
  {
    name = "text_moar",
    sprite = "text_moar",
    type = "text",
    texttype = "property",
    grid = {10,2},
    color = {4, 1},
    layer = 20,
  },
  -- 124
  {
    name = "text_visit fren",
    sprite = "text_visitfren",
    type = "text",
    texttype = "property",
    grid = {6, 2},
    color = {1, 4},
    layer = 20,
  },
  -- 125
  {
    name = "infloop",
    sprite = "text_infloop",
    type = "object",
    grid = {-1, -1},
    color = {0, 3},
    layer = 20,
  },
  -- 126
  {
    name = "text_wait",
    sprite = "text_wait",
    type = "text",
    texttype = "cond_prefix",
    grid = {11, 0},
    color = {0, 3},
    layer = 20,
  },
  -- 127
  {
    name = "text_sans",
    sprite = "text_sans",
    sprite_transforms = {
      property = "text_sans_property"
    },
    type = "text",
    texttype = "cond_infix",
    grid = {12, 0},
    color = {1, 4},
    layer = 20,
  },
  -- 128
  {
    name = "text_spoop",
    sprite = "text_spoop",
    type = "text",
    texttype = "verb_object",
    grid = {9, 5},
    color = {2, 2},
    layer = 20,
  },
  -- 129
  {
    name = "text_stalk",
    sprite = "text_stalk",
    texttype = "verb_object",
    type = "text",
    grid = {-1, -1},
    color = {5, 2},
    layer = 20,
  },
  -- 130
  {
    name = "text_stelth",
    sprite = "text_stelth",
    type = "text",
    texttype = "property",
    grid = {10, 6},
    color = {1, 3},
    layer = 20,
  },
  -- 131
  {
    name = "pata",
    sprite = "pata",
    type = "object",
    grid = {7, 10},
    color = {3, 3},
    layer = 5,
    rotate = true,
    eye = {x=17, y=4, w=1, h=2},
  },
  -- 132
  {
    name = "text_pata",
    sprite = "text_pata",
    type = "text",
    grid = {8, 10},
    color = {3, 3},
    layer = 20,
  },
  -- 133
  {
    name = "larry",
    sprite = "larry",
    sleepsprite = "larry_slep",
    type = "object",
    grid = {9, 10},
    color = {2, 4},
    layer = 5,
    rotate = true,
    eye = {x=18, y=4, w=2, h=2},
  },
  -- 134
  {
    name = "text_larry",
    sprite = "text_larry",
    type = "text",
    grid = {10, 10},
    color = {2, 4},
    layer = 20,
  },
  -- 135
  {
    name = "lila",
    sprite = "lila",
    grid = {11, 8},
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=19, y=8, w=2, h=2}
  },
  -- 136
  {
    name = "text_lila",
    sprite = "text_lila",
    type = "text",
    grid = {12, 8},
    color = {4, 2},
    layer = 20,
  },
  -- 137
  {
    name = "text_every1",
    sprite = "text_every1",
    type = "text",
    grid = {5, 0},
    color = {0, 3},
    layer = 20,
  },
  -- 138
  {
    name = "text_tall",
    sprite = "text_tall",
    type = "text",
    texttype = "property",
    grid = {7, 1},
    color = {0, 1},
    layer = 20,
  },
  --- 139
  {
    name = "text_bounded",
    sprite = "text_bounded",
    type = "text",
    texttype = "verb_object",
    allowconds = true,
    grid = {13, 1},
    color = {5, 3},
    layer = 20,
  },
  -- 140
  {
    name = "text_zip",
    sprite = "text_zip",
    type = "text",
    texttype = "property",
    grid = {11, 5},
    color = {5, 3},
    layer = 20,
  },
  -- 141
  {
    name = "text_lazzy",
    sprite = "text_lazzy",
    type = "text",
    texttype = "property",
    grid = {12, 5},
    color = {6, 2},
    layer = 20,
  },
  -- 142
  {
    name = "text_folo wal",
    sprite = "text_folo_wal",
    type = "text",
    texttype = "property",
    grid = {11, 6},
    color = {5, 3},
    layer = 20,
  },
  -- 143
  {
    name = "text_turn cornr",
    sprite = "text_turn_cornr",
    type = "text",
    texttype = "property",
    grid = {12, 6},
    color = {5, 3},
    layer = 20,
  },
  -- 144
  {
    name = "petnygrame",
    sprite = "petnygrame",
    grid = {13, 0},
    color = {2, 1},
    layer = 5,
  },
  -- 145
  {
    name = "text_petnygrame",
    sprite = "text_petnygrame",
    type = "text",
    grid = {14, 0},
    color = {2, 1},
    layer = 20,
  },
  -- 146
  {
    name = "katany",
    sprite = "katany",
    grid = {13, 5},
    color = {0, 1},
    layer = 5,
    rotate = true,
  },
  -- 147
  {
    name = "text_katany",
    sprite = "text_katany",
    type = "text",
    grid = {14, 5},
    color = {0, 1},
    layer = 20,
  },
  -- 148
  {
    name = "scarr",
    sprite = "scarr",
    grid = {13, 6},
    color = {2, 1},
    layer = 5,
  },
  -- 149
  {
    name = "text_scarr",
    sprite = "text_scarr",
    type = "text",
    grid = {14, 6},
    color = {2, 1},
    layer = 20,
  },
  -- 150
  {
    name = "text_no1",
    sprite = "text_no1",
    type = "text",
    grid = {6, 0},
    color = {0, 3},
    layer = 20,
  },
  -- 151
  {
    name = "no1",
    sprite = "no1",
    type = "object",
    grid = {-1, -1},
    color = {0, 0},
    layer = 20,
    rotate = true,
  },
  -- 152
  {
    name = "pepis",
    sprite = "pepis",
    grid = {11, 10},
    color = {0, 3},
    layer = 5,
  },
  -- 153
  {
    name = "text_pepis",
    sprite = "text_pepis",
    type = "text",
    grid = {12, 10},
    color = {3, 2},
    layer = 20,
  },
}
