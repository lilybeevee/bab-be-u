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

PACK_UNIT_V1 = "hhhb" -- TILE, X, Y, DIR
PACK_UNIT_V2 = "hhhhbs" -- ID, TILE, X, Y, DIR, SPECIALS

PACK_SPECIAL_V2 = "ss" -- KEY, VALUE

settings = {
  music_on = true
}

if love.filesystem.read("Settings.bab") ~= nil then
  settings = json.decode(love.filesystem.read("Settings.bab"))
end

debug = false
superduperdebugmode = false
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
  "right",
  "downright",
  "down",
  "downleft",
  "left",
  "upleft",
  "up",
  "upright",
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
    tags = {"char"},
    desc = "its bab bruh"
  },
  -- 2
  {
    name = "text_bab",
    sprite = "text_bab",
    type = "text",
    grid = {1, 1},
    color = {4, 1},
    layer = 20,
    desc = "\"BAB\". thats what it says"
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
    desc = "BE: Causes the subject to become an object or have a property.",
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
    desc = "U: Controlled by you, the player!",
  },
  -- 5
  {
    name = "wal",
    sprite = "wal",
    type = "object",
    grid = {0, 5},
    color = {1, 1},
    layer = 2,
    desc = "ston briks"
  },
  -- 6
  {
    name = "text_wal",
    sprite = "text_wal",
    type = "text",
    grid = {1, 5},
    color = {0, 1},
    layer = 20,
    desc = "uigi isn't gonna be in smash"
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
    desc = "NO GO: Can't be entered by objects.",
  },
  -- 8
  {
    name = "roc",
    sprite = "roc",
    type = "object",
    grid = {0, 4},
    color = {6, 2},
    layer = 3,
    desc = "roc: not a bord"
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
    desc = "GO AWAY: Pushed by movement into its tile.",
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
    desc = "NED KEE: When a NED KEE and FOR DOR unit move into each other, they are both destroyed.",
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
    desc = "FOR DOR: When a NED KEE and FOR DOR unit move into each other, they are both destroyed.",
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
    desc = "&: Joins multiple conditions, subjects or objects together in a rule.",
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
    desc = ":): At end of turn, if U is on :) and survives, U R WIN!",
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
    desc = "NO SWIM: At end of turn, if a NO SWIM unit is touching another object, both are destroyed.",
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
    desc = "GOT: Causes the subject to drop the object when destroyed.",
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
    desc = "COLRFUL: Causes the unit to appear a variety of colours.",
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
    desc = "REED: Causes the unit to appear red.",
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
    desc = "BLEU: Causes the unit to appear blue.",
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
    desc = "TRANZ: Causes the unit to appear pink, white and cyan.",
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
    desc = "GAY: Causes the unit to appear rainbow coloured.",
  },
  --31
  {
    name = "text_mous",
    sprite = "text_mous",
    type = "text",
    grid = {10, 0},
    color = {3, 3},
    layer = 20,
    desc = "MOUS: Refers to the mouse cursor. You can create, destroy and apply properties to mouse cursors!",
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
    desc = "TXT: An object class referring to all text objects, or just a specific one if you write e.g. BAB TXT BE GAY.",
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
    desc = "SLEP: SLEP units can't move due to being U, WALK or SPOOPed.",
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
    desc = ":(: At end of turn, destroys any U objects on it.",
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
    desc = "WALK: Moves in a straight line each turn, bouncing off walls.",
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
    desc = ":o: If U is on :o, the :o is collected. Bonus!",
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
    desc = "GO ->: The unit is forced to face the indicated direction.",
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
    desc = "BEHIN U: BEHIN U units swap with everything on tiles they move into, and swap with units that move onto their tile, then face their swapee. Nothing personnel, kid.",
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
    desc = "W/ FREN (Infix Condition): True if the unit shares a tile with this object.",
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
    desc = "LOOK AT: As an infix condition, true if this object is on the tile in front of the unit As a verb, makes the unit face this object at end of turn.",
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
    desc = "FRENLES (Prefix Condition): True if the unit is alone on its tile.",
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
    desc = "CREAT: At end of turn, the unit makes this object.",
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
    desc = "SNACC: Units destroy any other unit that they SNACC on contact, like a conditional OUCH.",
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
	desc = "GUNNE: Any object with GOT GUNNE will wield a GUNNE."
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
    desc = "OUCH: This unit is destroyed if it shares a tile with another object, or if it tries to move/be moved into and can't.",
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
    desc = "QT: Makes the unit emit love hearts.",
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
	desc = "HATT: Any object with GOT HATT will wear a HATT."
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
    desc = "YEET: This unit will force things it yeets in its tile to hurtle across the level in its facing direction.",
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
    desc = "GO: This unit will force all other objects in its tile to move in its facing direction.",
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
    desc = "ICY: Objects on something ICY are forced to move in their facing direction until they leave the ice or can't move any further.",
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
    desc = "XWX: At end of turn, if U is on XWX, the window crashes.",
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
    desc = "WINDO: Currently unimplemented, will let you manipulate the game window directly.",
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
    desc = "COME PLS: Pulled by movement on adjacent tiles facing away from this unit.",
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
    desc = "SIDEKIK: If a unit moves perpendicularly away from a SIDEKIK, the SIDEKIK copies that movement. If the SIDEKIK unit is also COME PLS, it copies movement on ANY surrounding tile.",
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
    desc = "AROND (Prefix Condition): True if the indicated object is on any of the tiles surrounding the unit. (The unit's own tile is not checked.)",
  },
  --- 102
  {
    name = "chekr",
    sprite = "chekr",
    type = "object",
    grid = {0, 13},
    color ={3, 2},
    layer = 1,
  },
  --- 103
  {
    name = "text_chekr",
    sprite = "text_chekr",
    type = "text",
    grid = {1, 13},
    color ={3, 2},
    layer = 20,
  },
  --- 104
  {
    name = "text_diagnal",
    sprite = "text_diagnal",
    type = "text",
    texttype = "property",
    grid = {2, 13},
    color = {3, 2},
    layer = 20,
    desc = "DIAGNAL: Prevents the unit moving orthogonally.",
  },
  --- 105
  {
    name = "text_go my wey",
    sprite = "text_go my wey",
    type = "text",
    texttype = "property",
    grid = {7, 13},
    color ={1, 4},
    layer = 20,
    desc = "GO MY WAY: Prevents movement onto its tile from the tile in front of it and the two tiles 45 degrees to either side.",
  },
  --- 106
  {
    name = "text_orthongl",
    sprite = "text_orthongl",
    type = "text",
    texttype = "property",
    grid = {3, 13},
    color ={3, 2},
    layer = 20,
    desc = "ORTHOGNL: Prevents the unit moving diagonally.",
  },
  --- 107
  {
    name = "arro",
    sprite = "arro",
    type = "object",
    grid = {5, 13},
    color ={0, 3},
    layer = 2,
    rotate = true,
  },
  --- 108
  {
    name = "text_arro",
    sprite = "text_arro",
    type = "text",
    grid = {6, 13},
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
    desc = "HOTTE: At end of turn, HOTTE units destroys all units that are FRIGID on their tile.",
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
    desc = "FRIDGD: At end of turn, HOTTE units destroys all units that are FRIGID on their tile.",
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
    desc = "GOOOO: The instant an object steps on a GOOOO unit, it is forced to move in the GOOOO unit's direction.",
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
    desc = "ICYYYY: The instant an object steps on an ICYYYY unit, it is forced to move again.",
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
    desc = "PROTECC: Cannot be destroyed (but can be converted).",
  },
  -- 116
  {
    name = "text_flye",
    sprite = "text_flye",
    type = "text",
    texttype = "property",
    grid = {2, 14},
    color = {1, 4},
    layer = 20,
    desc = "FLYE: A FLYE unit doesn't interact with other objects on its tile, and can ignore the collision of other objects, unless that other object has the same amount of FLYE as the unit. FLYE stacks with itself!",
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
    name = "text_nt",
    sprite = "text_nt",
    type = "text",
    texttype = "not",
    grid = {4, 0},
    color = {2, 2},
    layer = 20,
    desc = "N'T: A suffix that negates the meaning of a verb, condition or object class.",
  },
  -- 120
  {
    name = "text_haet skye",
    sprite = "text_haet_skye",
    type = "text",
    texttype = "property",
    grid = {4,14},
    color = {5, 3},
    layer = 20,
    desc = "HAET SKYE: After movement, this unit falls down as far as it can.",
  },
  -- 121
  {
    name = "clowd",
    sprite = "clowd",
    type = "object",
    grid = {0,14},
    color = {0, 3},
    layer = 7,
  },
  -- 122
  {
    name = "text_clowd",
    sprite = "text_clowd",
    type = "text",
    grid = {1,14},
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
    desc = "MOAR: At end of turn, this unit replicates to all free tiles that are orthogonally adjacent. MOAR stacks with itself!",
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
    desc = "VISIT FREN: At end of turn, all other objects are sent to the next VISIT FREN unit with the same name in reading order (left to right, line by line, wrapping around). Higher levels of VISIT FREN will cause the target to be 1 backward, 2 forward, 2 backward, etc.",
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
    desc = "WAIT... (Prefix Condition): True if the player waited last input.",
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
    desc = "SANS (Infix Condition): True if none of the indicated object exist in the level.",
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
    desc = "SPOOP: A SPOOPY unit forces all objects it SPOOPS on adjacent tiles to move away!",
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
    desc = "STELTH: A STELTHy unit doesn't draw. STELTHy text won't appear in the rules list (once someone gets around to writing that...)",
  },
  -- 131
  {
    name = "pata",
    sprite = "pata",
    sleepsprite = "pata_slep";
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
    desc = "EVERY1: Every object type in the level.",
  },
  -- 138
  {
    name = "text_tall",
    sprite = "text_tall",
    type = "text",
    texttype = "property",
    grid = {3, 14},
    color = {0, 1},
    layer = 20,
    desc = "TALL: Considered to be every FLYE amount at once.",
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
    desc = "BOUNDED: If a unit is BOUNDED, it cannot step onto a tile unless it has at least one object it is BOUNDED to.",
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
    desc = "ZIP: At end of turn, if it is on a tile it couldn't enter or shares a tile with another object of its name, it finds the nearest free tile (preferencing backwards directions) and ejects to it.",
  },
  -- 141
  {
    name = "text_shy",
    sprite = "text_shy",
    type = "text",
    texttype = "property",
    grid = {12, 5},
    color = {6, 2},
    layer = 20,
    desc = "SHY...: Can't initiate or continue a push, pull or sidekik movement."
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
    desc = "FOLO WAL: At end of turn, faces the first direction that it could enter and that doesn't have another unit of its name: right, forward, left, backward. When combined with WALK, causes the unit to follow the right wall.",
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
    desc = "TURN CORNR: At end of turn, faces the first direction that it could enter and that doesn't have another unit of its name: forward, right, left, backward. When combined with WALK, causes the unit to bounce off walls at 90 degree angles.",
  },
  -- 144
  {
    name = "petnygrame",
    sprite = "petnygrame",
    grid = {9, 11},
    color = {2, 1},
    layer = 5,
  },
  -- 145
  {
    name = "text_petnygrame",
    sprite = "text_petnygrame",
    type = "text",
    grid = {10, 11},
    color = {2, 1},
    layer = 20,
  },
  -- 146
  {
    name = "katany",
    sprite = "katany",
    grid = {7, 11},
    color = {0, 1},
    layer = 5,
    rotate = true,
	desc = "KATANY: Any object with GOT KATANY will have a KATANY."
  },
  -- 147
  {
    name = "text_katany",
    sprite = "text_katany",
    type = "text",
    grid = {8, 11},
    color = {0, 1},
    layer = 20,
  },
  -- 148
  {
    name = "scarr",
    sprite = "scarr",
    grid = {7, 12},
    color = {2, 1},
    layer = 5,
  },
  -- 149
  {
    name = "text_scarr",
    sprite = "text_scarr",
    type = "text",
    grid = {8, 12},
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
    desc = "NO1: Refers to tiles with nothing in them."
  },
  -- 151
  {
    name = "no1",
    sprite = "no1",
    type = "object",
    grid = {-1, -1},
    color = {0, 4},
    layer = 20,
    rotate = true,
  },
  -- 152
  {
    name = "text_lvl",
    sprite = "text_lvl",
    type = "text",
    grid = {8,0},
    color = {4,1},
    layer = 20,
    desc = "LVL: Refers to the level you're in, as well as any enterable levels in this level."
  },
  -- 153
  {
    name = "text_nxt",
    sprite = "text_nxt",
    type = "text",
    texttype = "property",
    grid = {14,1},
    color = {0,3},
    layer = 20,
    desc = "NXT: LVL IS NXT sends you to the next level. (Unimplemented.)"
  },
  -- 154
  {
    name = "pepis",
    sprite = "pepis",
    grid = {11, 10},
    color = {0, 3},
    layer = 5,
  },
  -- 155
  {
    name = "text_pepis",
    sprite = "text_pepis",
    type = "text",
    grid = {12, 10},
    color = {3, 2},
    layer = 20,
  },
  -- 156
  {
    name = "text_copkat",
    sprite = "text_copkat",
    type = "text",
    texttype = "verb_object",
    grid = {11, 7},
    color = {0, 3},
    layer = 20,
    desc = "COPKAT: COPKAT units copy the successful movements of the indicated object, no matter how far away."
  },
  --157
  {
    name = "clok",
    sprite = "clok",
    type = "object",
    grid = {0, 11},
    color = {3, 3},
    layer = 3,
    rotate = true,
    eye = {x=14, y=14, w=3, h=3},
  },
  -- 158
  {
    name = "text_clok",
    sprite = "text_clok",
    type = "text",
    grid = {1, 11},
    color = {3, 3},
    layer = 20,
  },
  -- 159
  {
    name = "text_try again",
    sprite = "text_try again",
    type = "text",
    texttype = "property",
    grid = {2, 11},
    color = {3, 3},
    layer = 20,
    desc = "TRY AGAIN: When U is on TRY AGAIN, the level is undone back to the starting state."
  },
  -- 160
  {
    name = "text_no undo",
    sprite = "text_no undo",
    type = "text",
    texttype = "property",
    grid = {3, 11},
    color = {5, 3},
    layer = 20,
    desc = "NO UNDO: NO UNDO units aren't affected by undoing.",
  },
  -- 161
  {
    name = "zsoob",
    sprite = "zsoob",
    sleepsprite = "zsoob_slep",
    type = "object",
    grid = {5,11},
    color = {4,1},
    layer = 5,
    rotate = true,
    eye = {x=17, y=9, w=2, h=2},
  },
  -- 162
  {
    name = "text_zsoob",
    sprite = "text_zsoob",
    type = "text",
    grid = {6,11},
    color = {4,1},
    layer = 20,
  },
  -- 163
  {
    name = "text_mayb",
    sprite = "text_mayb",
    type = "text",
    texttype = "cond_prefix",
    grid = {14, 2},
    color = {0, 3},
    layer = 20,
    rotate = true,
    desc = "? (MAYBE) (Prefix Condition): Has a chance of being true, independent for each MAYBE, affected unit and turn. The number on top indicates the % chance of being true.",
  },
  -- 164
  {
    name = "text_stubbn",
    sprite = "text_stubbn",
    type = "text",
    texttype = "property",
    grid = {12, 7},
    color = {1, 4},
    layer = 20,
    desc = "STUBBN: STUBBN units ignore the special properties of WALK movers (bouncing off of walls, and declining to move if it would die due to being OUCH) and also makes attempted diagonal movement slide along walls. Stacks with itself - the more STUBBN, the more additional angles it will try, up to 180 degrees at 5 stacks!",
  },
  -- 165
  {
    name = "text_seen by",
    sprite = "text_seen by",
    type = "text",
    texttype = "cond_infix",
    grid = {13, 7},
    color = {0, 3},
    layer = 20,
    desc = "SEEN BY (Infix Condition): True if an indicated object is looking at this unit from an adjacent tile.",
  },
  -- 166
  {
    name = "steev",
    sprite = "steev",
    sleepsprite = "steev_slep",
    type = "object",
    grid = {3,12},
    color = {2,3},
    layer = 5,
    rotate = true,
    eye = {x=20, y=13, w=2, h=2},
  },
  -- 167
  {
    name = "text_steev",
    sprite = "text_steev",
    type = "text",
    grid = {4,12},
    color = {2,3},
    layer = 20,
  },
  -- 168
  {
    name = "text_go arnd",
    sprite = "text_go arnd",
    type = "text",
    texttype = "property",
    grid = {14, 3},
    color = {3, 2},
    layer = 20,
    desc = "GO ARND: GO ARND units wrap around the level, as though it were a torus.",
  },
  -- 169
  {
    name = "text_poor toll",
    sprite = "text_poor_toll",
    type = "text",
    texttype = "property",
    grid = {14, 4},
    color = {3, 2},
    layer = 20,
    desc = "POOR TOLL: If a unit would enter a POOR TOLL unit, it instead leaves the next POOR TOLL unit of the same name in reading order (left to right, line by line, wrapping around) out the corresponding other side.",
  },
  -- 170
  {
    name = "splittr",
    sprite = "splittr",
    type = "object",
    grid = {0,12},
    color = {0, 3},
    layer = 2,
    rotate = true,
  },
  -- 171
  {
    name = "text_splittr",
    sprite = "text_splittr",
    type = "text",
    grid = {1,12},
    color = {0, 3},
    layer = 20,
  },
  -- 172
  {
    name = "text_split",
    sprite = "text_split",
    type = "text",
    texttype = "property",
    grid = {2, 12},
    color = {4, 1},
    layer = 20,
    desc = "SPLIT: Objects on a SPLITer are split into two copies on adjacent tiles.",
  },
  -- 173
  {
    name = "text_cilindr",
    sprite = "text_cilindr",
    type = "text",
    texttype = "property",
    grid = {-1, -1},
    color = {3, 2},
    layer = 20,
    rotate = true,
    desc = "CILINDR: CILINDR units wrap around the level, as though it were a cylinder with the indicated orientation.",
  },
  -- 174
  {
    name = "text_mobyus",
    sprite = "text_mobyus",
    type = "text",
    texttype = "property",
    grid = {-1, -1},
    color = {3, 2},
    layer = 20,
    rotate = true,
    desc = "MOBYUS: MOBYUS units wrap around the level, as though it were a mobius strip with the indicated orientation.",
  },
  -- 175
  {
    name = "text_munwalk",
    sprite = "text_munwalk",
    type = "text",
    texttype = "property",
    grid = {14, 7},
    color = {1, 4},
    layer = 20,
    desc = "MUNWALK: MUNWALK units move 180 degrees opposite of their facing direction.",
  },
  -- 176
  {
    name = "text_mirr arnd",
    sprite = "text_mirr arnd",
    type = "text",
    texttype = "property",
    grid = {15, 2},
    color = {3, 2},
    layer = 20,
    desc = "MIRR ARND: MIRR ARND units wrap around the level, as though it were a projective plane.",
  },
  -- 177
  {
    name = "text_sidestep",
    sprite = "text_sidestep",
    type = "text",
    texttype = "property",
    grid = {15, 7},
    color = {6, 2},
    layer = 20,
    desc = "SIDESTEP: SIDESTEP units move 90 degrees off of their facing direction.",
  },
  -- 178
  {
    name = "text_diagstep",
    sprite = "text_diagstep",
    type = "text",
    texttype = "property",
    grid = {16, 7},
    color = {3, 1},
    layer = 20,
    desc = "DIAGSTEP: DIAGSTEP units move 45 degrees off of their facing direction.",
  },
  -- 179
  {
    name = "text_hopovr",
    sprite = "text_hopovr",
    type = "text",
    texttype = "property",
    grid = {17, 7},
    color = {5, 3},
    layer = 20,
    desc = "HOPOVR: HOPOVR units move two tiles ahead, skipping the intermediate tile.",
  },
  -- 180
  {
    name = "text_undo",
    sprite = "text_undo",
    type = "text",
    texttype = "property",
    grid = {4, 11},
    color = {6, 1},
    layer = 20,
    desc = "UNDO: UNDO units, at end of turn, rewind a turn earlier, cumulatively. Stacks!",
  },
  -- 181
  {
    name = "boy",
    sprite = "boy",
    grid = {5, 12},
    color = {0, 2},
    layer = 5,
    rotate = true,
    eye = {x=16, y=12, w=2, h=4}
  },
  -- 182
  {
    name = "text_boy",
    sprite = "text_boy",
    type = "text",
    grid = {6, 12},
    color = {0, 2},
    layer = 20,
  },
  -- 183
  {
    name = "text_spin",
    sprite = "text_spin",
    type = "text",
    texttype = "property",
    grid = {8, 13},
    color = {1, 4},
    layer = 20,
    rotate = true,
    desc = "SPIN: SPIN units rotate clockwise, the number of times indicated on top of the property.",
  },
  -- 184
  {
    name = "lvl",
    sprite = "lvl",
    type = "object",
    grid = {-1,-1},
    color = {0,3},
    layer = 5,
  },
  -- 185
  {
    name = "text_slippers",
    sprite = "text_slippers",
    type = "text",
    grid = {6, 10},
    color = {1, 4},
    layer = 20,
    desc = "SLIPPERS: An object that GOT SLIPPERS will ignore ICY and ICYYYYY objects."
  },
  -- 186
  {
    name = "slippers",
    sprite = "slippers",
    type = "object",
    grid = {5, 10},
    color = {1, 3},
    layer = 6,
  },
  -- 187
  {
    name = "ghost fren",
    sprite = "ghost",
    sleepsprite = "ghost_slep",
    grid = {5, 14},
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=25, y=11, w=2, h=4}
  },
  -- 188
  {
    name = "text_ghost fren",
    sprite = "text_ghost fren",
    type = "text",
    grid = {6, 14},
    color = {4, 2},
    layer = 20,
  },
  -- 189
  {
    name = "robobot",
    sprite = "robobot",
    sleepsprite = "robobot_slep",
    grid = {7, 14},
    color = {6, 1},
    layer = 5,
    rotate = true,
    eye = {x=16, y=8, w=2, h=4}
  },
  -- 190
  {
    name = "text_robobot",
    sprite = "text_robobot",
    type = "text",
    grid = {8, 14},
    color = {6, 1},
    layer = 20,
  },
  -- 191
  {
    name = "lvl",
    sprite = "lvl",
    grid = {17, 1},
    color = {0, 3},
    layer = 2,
    rotate = true,
    desc = "its a lavel"
  },
  -- 192
  {
    name = "selctr",
    sprite = "selctr",
    grid = {17, 0},
    color = {3, 3},
    layer = 20,
    desc = "used to select levis"
  },
  -- 193
  {
    name = "text_selctr",
    sprite = "text_selctr",
    type = "text",
    grid = {13, 0},
    color = {2, 3},
    layer = 20,
  },
  -- 194
  {
    name = "lin",
    sprite = "lin",
    grid = {17, 2},
    color = {0, 3},
    layer = 1,
    desc = "used to connect lovils"
  },
  -- 195
  {
    name = "text_lin",
    sprite = "text_lin",
    type = "text",
    grid = {14, 0},
    color = {0, 3},
    layer = 20,
  },
  -- 196
  {
    name = "text_copdog",
    sprite = "text_copdog",
    type = "text",
    texttype = "verb_object",
    grid = {15, 6},
    color = {0, 3},
    layer = 20,
    desc = "COPDOG: COPKAT, but it copies ALL of the movement (e.g. if COPDOG ROC and you push 3 ROCs, it moves 3 steps)."
  },
}
