DEFAULT_WIDTH = 800
DEFAULT_HEIGHT = 600

ANIM_TIMER = 180
MAX_MOVE_TIMER = 80
INPUT_DELAY = 150
MAX_UNDO_DELAY = 150
MIN_UNDO_DELAY = 50
UNDO_SPEED = 5
UNDO_DELAY = MAX_UNDO_DELAY
repeat_keys = {"wasd","udlr","numpad","ijkl","space","undo"}

is_mobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
--is_mobile = true

PACK_UNIT_V1 = "hhhb" -- TILE, X, Y, DIR
PACK_UNIT_V2 = "hhhhbs" -- ID, TILE, X, Y, DIR, SPECIALS
PACK_UNIT_V3 = "llhhbs" -- ID, TILE, X, Y, DIR, SPECIALS

PACK_SPECIAL_V2 = "ss" -- KEY, VALUE

local defaultsettings = {
  music_on = true,
  fullscreen = false
}

if love.filesystem.read("Settings.bab") ~= nil then
  settings = json.decode(love.filesystem.read("Settings.bab"))
  for i in pairs(defaultsettings) do
    if settings[i] == nil then
      settings[i] = defaultsettings[i]
    end
  end
else
  settings = defaultsettings
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

main_palette_for_colour = {
blacc = {0, 4},
reed = {2, 2}, 
orang = {2, 3},
yello = {2, 4},
grun = {5, 2},
cyeann = {1, 4},
bleu = {1, 3},
purp = {3, 1},
whit = {0, 3},
}

colour_for_palette = {}
colour_for_palette[0] = {};
colour_for_palette[0][0] = "blacc";
colour_for_palette[0][1] = nil;
colour_for_palette[0][2] = nil;
colour_for_palette[0][3] = "whit";
colour_for_palette[0][4] = "blacc";
colour_for_palette[1] = {};
colour_for_palette[1][0] = "blacc";
colour_for_palette[1][1] = "bleu";
colour_for_palette[1][2] = "bleu";
colour_for_palette[1][3] = "bleu";
colour_for_palette[1][4] = "cyeann";
colour_for_palette[2] = {};
colour_for_palette[2][0] = "reed";
colour_for_palette[2][1] = "reed";
colour_for_palette[2][2] = "reed";
colour_for_palette[2][3] = "orang";
colour_for_palette[2][4] = "yelo";
colour_for_palette[3] = {};
colour_for_palette[3][0] = "purp";
colour_for_palette[3][1] = "purp";
colour_for_palette[3][2] = "purp";
colour_for_palette[3][3] = "purp";
colour_for_palette[3][4] = nil;
colour_for_palette[4] = {};
colour_for_palette[4][0] = "purp";
colour_for_palette[4][1] = nil;
colour_for_palette[4][2] = nil;
colour_for_palette[4][3] = nil;
colour_for_palette[4][4] = nil;
colour_for_palette[5] = {};
colour_for_palette[5][0] = "grun";
colour_for_palette[5][1] = "grun";
colour_for_palette[5][2] = "grun";
colour_for_palette[5][3] = "grun";
colour_for_palette[5][4] = nil;
colour_for_palette[6] = {};
colour_for_palette[6][0] = nil;
colour_for_palette[6][1] = nil;
colour_for_palette[6][2] = "orang";
colour_for_palette[6][3] = nil;
colour_for_palette[6][4] = "blak";

selector_grid_contents = {
  -- page 1: default
  {
    0, "text_be", "text_&", "text_got", "text_nt", "text_every1", "text_no1", "text_text", "text_lvl", "text_sublvl", "text_mous", "text_wait", "text_sans", "text_selctr", "text_lin", "text_loop", "this", "selctr",
    "bab", "text_bab", "text_u", "kee", "text_kee", "text_for dor", "text_direction", "text_wurd", "text_tranz", "text_gay", "text_icy", "text_xwx", "text_liek", "text_nxt", "text_...", "text_u too", "text_u tres", "lvl",
    "keek", "text_keek", "text_walk", "dor", "text_dor", "text_ned kee", "text_visit fren", "text_behin u", "text_qt", "text_moar", "text_goooo", "text_icyyyy", "text_haet", "text_mayb", "text_an", "text_babn't", "text_ben't", "lin",
    "flog", "text_flog", "text_:)", "colld", "text_colld", "text_fridgd", "text_hotte", "text_ouch", "text_slep", "text_protecc", "text_sidekik", "text_brite", "text_lit", "text_opaque", "text_za warudo", "text_rocn't", "text_waln't", "text_ditto",
    "roc", "text_roc", "text_go away pls", "gras", "text_gras", "dayzy", "text_dayzy", "text_wfren", "text_arond", "text_frenles", "text_copkat", "text_go arnd", "text_mirr arnd", "text_meta", "text_frens", "text_pathz", "text_groop", "text_stay ther",
    "wal", "text_wal", "text_no go", "l..uv", "text_l..uv", "hurcane", "text_hurcane", "text_creat", "text_look at", "text_spoop", "text_yeet", "text_turn cornr", "text_corekt", "text_timles", "text_the", "text_that", "text_that be", "text_clikt",
    "watr", "text_watr", "text_no swim", "meem", "text_meem", "o", "text_o", "text_snacc", "text_seen by" , "text_stalk", "text_moov", "text_folo wal", "text_rong", "text_her", "text_thr", 0, 0, 0,
    "skul", "text_skul", "text_:(", "til", "text_til", "kirb", "text_kirb", "gunne", "text_gunne", "wog", "text_wog", "text_zip", "text_shy", "text_munwalk", "text_sidestep", "text_diagstep", "text_hopovr", "text_knightstep",
    "boux", "text_boux", "text_come pls", "os", "text_os", "bup", "text_bup", "han", "text_han", "tot", "text_tot", "lila", "text_lila", "hol", "text_hol", "text_poor toll", "text_blacc", "text_reed",
    "bellt", "text_bellt", "text_go", "tre", "text_tre", "piler", "text_piler", "hatt", "text_hatt", "laav", "text_laav", "fenss", "text_fenss", "riff", "text_riff", 0, "text_whit", "text_orang",
    "boll", "text_boll", "text_:o", "frut", "text_frut", "slippers", "text_slippers", "pata", "text_pata", "larry", "text_larry", "pepis", "text_pepis", "metl", "text_metl", 0, "text_colrful", "text_yello",
    "clok", "text_clok", "text_try again", "text_no undo", "text_undo", "zsoob", "text_zsoob", "katany", "text_katany", "petnygrame", "text_petnygrame", "hedg", "text_hedg", "lie", "text_lie", 0, "text_rave", "text_grun",
    "splittr", "text_splittr", "text_split", "steev", "text_steev", "boy", "text_boy", "scarr", "text_scarr", "firbolt", "text_firbolt", "icbolt", "text_icbolt", "lie/8", "text_lie/8", 0, "text_stelth", "text_cyeann",
    "chekr", "text_chekr", "text_diag", "text_ortho", "text_haet flor", "arro", "text_arro", "text_go my way", "text_spin", "text_no turn", "text_stubbn", "platfor", "text_platfor", "jail", "text_jail", 0, "text_paint", "text_bleu",
    "clowd", "text_clowd", "text_flye", "text_tall", "text_haet skye", "ghost fren", "text_ghost fren", "robobot", "text_robobot", "sparkl", "text_sparkl", "spik", "text_spik", "spiky", "text_spiky", "bordr", "text_bordr", "text_purp",
    nil
  },
  -- page 2: letters
  {
    "letter_a","letter_b","letter_c","letter_d","letter_e","letter_f","letter_g","letter_h","letter_i","letter_j","letter_k","letter_l","letter_m","letter_n","text_o","letter_p","letter_q","letter_r",
    "letter_s","letter_t","letter_u","letter_v","letter_w","letter_x","letter_y","letter_z","letter_.","letter_colon","letter_parenthesis","letter_'",0,0,0,0,0,0,
    "letter_go","letter_come","letter_pls","letter_away","letter_my","letter_no","letter_way",0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  },
  -- page 3: ui / instructions
  {
    "ui_1","ui_2","ui_3","ui_4","ui_6","ui_7","ui_8","ui_9","ui_w","ui_a","ui_s","ui_d","ui_i","ui_j","ui_k","ui_l","ui_e","ui_arrow",
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,"ui_walk",0,0,"ui_activat",0,0,"ui_clik",0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "text_press","text_f1","text_play","text_f2","text_edit","ui_left click","ui_right click",0,0,0,0,0,0,0,0,0,0,0,
  },
  -- page 4: objects
  {
    "bab","text_bab","flog","text_flog","wal","text_wal","gras","text_gras",0,0,0,0,0,0,"selctr","text_selctr","lvl","text_lvl",
    "keek","text_keek","roc","text_roc","til","text_til","sparkl","text_sparkl",0,0,0,0,0,0,"this","text_mous","lin","text_lin",
    "meem","text_meem","boux","text_boux","watr","text_watr","scarr","text_scarr","petnygrame","text_petnygrame",0,0,0,0,"text_text","text_frens","text_groop","text_pathz",
    "skul","text_skul","boll","text_boll","laav","text_laav","katany","text_katany","gunne","text_gunne",0,0,0,0,0,0,"text_every1","text_no1",
    "ghost fren","text_ghost fren","kee","text_kee","dor","text_dor","hatt","text_hatt","slippers","text_slippers",0,0,0,0,0,0,0,0,
    "robobot","text_robobot","l..uv","text_l..uv","hedg","text_hedg","hol","text_hol","riff","text_riff",0,0,0,0,0,0,0,0,
    "wog","text_wog","tre","text_tre","metl","text_metl","clok","text_clok",0,0,0,0,0,0,0,0,0,0,
    "kirb","text_kirb","frut","text_frut","jail","text_jail","sine","text_sine",0,0,0,0,0,0,0,0,0,0,
    "bup","text_bup","piler","text_piler","fenss","text_fenss","buble","text_buble","creb","text_creb","icecub","text_icecub",0,0,0,0,0,0,
    "boy","text_boy","dayzy","text_dayzy","platfor","text_platfor",0,0,0,0,0,0,0,0,"lila","text_lila","tot","text_tot",
    "steev","text_steev","splittr","text_splittr","colld","text_colld",0,0,0,0,0,0,0,0,"pata","text_pata","o","text_o",
    "han","text_han","clowd","text_clowd","bellt","text_bellt","arro","text_arro",0,0,0,0,0,0,"larry","text_larry","zsoob","text_zsoob",
    "os","text_os","hurcane","text_hurcane","spik","text_spik",0,0,0,0,0,0,0,0,0,0,"jill","text_jill",
    "firbolt","text_firbolt","lie","text_lie","spiky","text_spiky",0,0,0,0,0,0,0,0,0,0,0,0,
    "icbolt","text_icbolt","lie/8","text_lie/8","bordr","text_bordr",0,0,0,0,0,0,0,0,0,0,0,0,
  },
  -- page 5: properties, verbs and conditions
  {
    "text_be","text_&","text_got","text_creat","text_snacc","text_spoop","text_copkat","text_moov","text_yeet","text_liek","text_haet","text_stalk","text_look at","text_wfren","text_arond","text_sans","text_seen by","text_that",
    "text_u","text_u too","text_u tres","text_walk",0,"text_:)","text_:(","text_no swim","text_ouch",0,"text_nxt","text_stay ther","text_sublvl","text_loop",0,"text_frenles","text_corekt","text_rong",
    "text_go","text_goooo","text_icy","text_icyyyy",0,"text_ned kee","text_for dor","text_hotte","text_fridgd",0,0,0,0,0,0,"text_lit","text_timles","text_clikt",
    "text_no go","text_go away pls","text_come pls","text_sidekik",0,"text_protecc","text_:o","text_xwx",0,0,0,0,0,0,0,"text_mayb","text_an","text_wait",
    "text_visit fren","text_slep","text_shy","text_behin u",0,"text_moar","text_split","text_wurd","text_meta",0,0,0,0,0,0,0,0,0,
    "text_flye","text_tall","text_haet skye","text_haet flor",0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "text_diag","text_ortho","text_go my way","text_direction",0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "text_turn cornr","text_folo wal","text_zip","text_hopovr",0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "text_munwalk","text_sidestep","text_diagstep","text_knightstep",0,0,0,0,0,0,0,0,0,0,0,0,0,"text_reed",
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"text_orang",
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"text_yello",
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"text_gay","text_tranz","text_grun",
    0,0,0,0,0,"text_try again","text_no undo","text_undo","text_za warudo",0,0,0,0,0,0,"text_stelth","text_qt","text_cyeann",
    0,0,0,0,0,"text_poor toll","text_go arnd","text_mirr arnd","text_brite",0,0,0,0,0,0,"text_blacc","text_whit","text_bleu",
    0,0,0,0,0,"text_her","text_thr","text_the","text_opaque",0,0,0,0,0,0,"text_colrful","text_rave","text_purp",
  },
}
tile_grid_width = 18
tile_grid_height = 15

tiles_list = {
  -- 1
  {
    name = "bab",
    sprite = "bab",
    sleepsprite = "bab_slep",
    type = "object",
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
    metasprite = "text_bab meta",
    type = "text",
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
    color = {4, 1},
    layer = 20,
    desc = "U: Controlled by you, the player!",
  },
  -- 5
  {
    name = "wal",
    sprite = "wal",
    metasprite = "text_wal meta",
    type = "object",
    color = {1, 1},
    layer = 2,
    desc = "ston briks"
  },
  -- 6
  {
    name = "text_wal",
    sprite = "text_wal",
    type = "text",
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
    color = {5, 1},
    layer = 20,
    desc = "NO GO: Can't be entered by objects.",
  },
  -- 8
  {
    name = "roc",
    sprite = "roc",
    type = "object",
    color = {6, 2},
    layer = 3,
    desc = "roc: not a bord"
  },
  -- 9
  {
    name = "text_roc",
    sprite = "text_roc",
    metasprite = "text_roc meta",
    type = "text",
    color = {6, 1},
    layer = 20,
  },
  -- 10
  {
    name = "text_go away pls",
    sprite = "text_goaway",
    type = "text",
    texttype = "property",
    color = {6, 1},
    layer = 20,
    desc = "GO AWAY: Pushed by movement into its tile.",
  },
  -- 11
  {
    name = "dor",
    sprite = "dor",
    type = "object",
    color = {2, 2},
    layer = 3,
  },
  -- 12
  {
    name = "text_dor",
    sprite = "text_dor",
    metasprite = "text_dor meta",
    type = "text",
    color = {2, 2},
    layer = 20,
  },
  -- 13
  {
    name = "text_ned kee",
    sprite = "text_nedkee",
    type = "text",
    texttype = "property",
    color = {2, 2},
    layer = 20,
    desc = "NED KEE: When a NED KEE and FOR DOR unit move into each other, they are both destroyed.",
  },
  -- 14
  {
    name = "kee",
    sprite = "kee",
    type = "object",
    color = {2, 4},
    layer = 4,
    rotate = true,
  },
  -- 15
  {
    name = "text_kee",
    sprite = "text_kee",
    metasprite = "text_kee meta",
    type = "text",
    color = {2, 4},
    layer = 20,
  },
  -- 16
  {
    name = "text_for dor",
    sprite = "text_fordor",
    type = "text",
    texttype = "property",
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
    color = {0, 3},
    layer = 20,
    desc = "&: Joins multiple conditions, subjects or objects together in a rule.",
  },
  -- 18
  {
    name = "flog",
    sprite = "flog",
    type = "object",
    color = {2, 4},
    layer = 3,
  },
  -- 19
  {
    name = "text_flog",
    sprite = "text_flog",
    type = "text",
    color = {2, 4},
    layer = 20,
  },
  -- 20
  {
    name = "text_:)",
    sprite = "text_good",
    type = "text",
    texttype = "property",
    color = {2, 4},
    layer = 20,
    desc = ":): At end of turn, if U is on :) and survives, U R WIN!",
  },
  -- 21
  {
    name = "til",
    sprite = "til",
    type = "object",
    color = {1, 0},
    layer = 1,
  },
  -- 22
  {
    name = "watr",
    sprite = "watr",
    type = "object",
    color = {1, 3},
    layer = 1,
  },
  -- 23
  {
    name = "text_watr",
    sprite = "text_watr",
    type = "text",
    color = {1, 3},
    layer = 20,
  },
  -- 24
  {
    name = "text_no swim",
    sprite = "text_no swim",
    type = "text",
    texttype = "property",
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
    color = {0, 3},
    layer = 20,
    desc = "COLRFUL: Causes the unit to appear a variety of colours.",
  },
  --27
  {
    name = "text_reed",
    sprite = "text_reed",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {2, 2},
    layer = 20,
    desc = "REED: Causes the unit to appear red.",
  },
  --28
  {
    name = "text_bleu",
    sprite = "text_bleu",
    type = "text",
    texttype = "cond_prefix_or_property",
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
    color = {255, 255, 255},
    layer = 20,
    desc = "GAY: Causes the unit to appear rainbow coloured.",
  },
  --31
  {
    name = "text_mous",
    sprite = "text_mous",
    type = "text",
    color = {3, 3},
    layer = 20,
    desc = "MOUS: Refers to the mouse cursor. You can create, destroy and apply properties to mouse cursors!",
  },
  --32
  {
    name = "text_boux",
    sprite = "text_boux",
    type = "text",
    color = {6, 1},
    layer = 20,
  },
  --33
  {
    name = "boux",
    sprite = "boux",
    type = "object",
    color = {6, 2},
    layer = 3,
  },
  --34
  {
    name = "text_skul",
    sprite = "text_skul",
    type = "text",
    color = {2, 1},
    layer = 20,
  },
  --35
  {
    name = "skul",
    sprite = "skul",
    sleepsprite = "skul_slep",
    type = "object",
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
    color = {2, 3},
    layer = 20,
  },
  --37
  {
    name = "laav",
    sprite = "watr",
    type = "object",
    color = {2, 3},
    layer = 1,
  },
  --38
  {
    name = "text_keek",
    sprite = "text_keek",
    type = "text",
    color = {2, 2},
    layer = 20,
  },
  --39
  {
    name = "keek",
    sprite = "keek",
    sleepsprite = "keek_slep",
    type = "object",
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
    color = {3, 1},
    layer = 20,
  },
  --39
  {
    name = "meem",
    sprite = "meem",
    sleepsprite = "meem_slep",
    type = "object",
    color = {3, 1},
    layer = 5,
    rotate = true,
    eye = {x=18, y=3, w=2, h=2},
  },
  --40
  {
    name = "text_til",
    sprite = "text_til",
    metasprite = "text_til meta",
    type = "text",
    color = {0, 1},
    layer = 20
  },
  --41
  {
    name = "text_text",
    sprite = "text_txt",
    metasprite = "text_txt meta",
    type = "text",
    color = {4, 1},
    layer = 20,
    desc = "TXT: An object class referring to all text objects, or just a specific one if you write e.g. BAB TXT BE GAY.",
  },
  --42
  {
    name = "text_os",
    sprite = "text_os",
    type = "text",
    color = {4, 1},
    layer = 20,
  },
  --43
  {
    name = "os",
    sprite = "os",
    type = "object",
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
    color = {1, 3},
    layer = 20,
    desc = "SLEP: SLEP units can't move due to being U, WALK, COPKAT or SPOOPed.",
  },
  --45
  {
    name = "l..uv",
    sprite = "luv",
    type = "object",
    color = {4, 2},
    layer = 6,
    rotate = "true",
  },
  --46
  {
    name = "text_l..uv",
    sprite = "text_luv",
    type = "text",
    color = {4, 2},
    layer = 20,
  },
  --47
  {
    name = "frut",
    sprite = "frut",
    type = "object",
    color = {2, 2},
    layer = 3,
    rotate = "true",
  },
  --48
  {
    name = "text_frut",
    sprite = "text_frut",
    type = "text",
    color = {2, 2},
    layer = 20,
  },
  --49
  {
    name = "tre",
    sprite = "tre",
    type = "object",
    color = {5, 2},
    layer = 2,
    rotate = "true",
  },
  --50
  {
    name = "text_tre",
    sprite = "text_tre",
    type = "text",
    color = {5, 2},
    layer = 20,
  },
  --51
  {
    name = "wog",
    sprite = "wog",
    sleepsprite = "wog_slep",
    type = "object",
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
    color = {2, 4},
    layer = 20,
  },
  --tutorial sprites
  --53
  {
    name = "text_press",
    sprite = "tutorial_press",
    type = "text",
    color = {0, 3},
    layer = 20,
  },
  --54
  {
    name = "text_f2",
    sprite = "tutorial_f2",
    type = "text",
    texttype = "verb_all",
    color = {0, 3},
    layer = 20,
  },
  --55
  {
    name = "text_edit",
    sprite = "tutorial_edit",
    type = "text",
    texttype = "property",
    color = {0, 3},
    layer = 20,
  },
  --56
  {
    name = "text_play",
    sprite = "tutorial_play",
    type = "text",
    texttype = "property",
    color = {0, 3},
    layer = 20,
  },
  --57
  {
    name = "text_f1",
    sprite = "tutorial_f1",
    type = "text",
    texttype = "verb_all",
    color = {0, 3},
    layer = 20,
  },
  -- 58
  {
    name = "text_:(",
    sprite = "text_bad",
    type = "text",
    texttype = "property",
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
    color = {5, 3},
    layer = 20,
    desc = "WALK: Moves in a straight line each turn, bouncing off walls.",
  },
  -- 60
  {
    name = "text_bup",
    sprite = "text_bup",
    type = "text",
    color = {6, 2},
    layer = 20,
  },
  -- 61
  {
    name = "bup",
    sprite = "bup",
    sleepsprite = "bup_slep",
    type = "object",
    color = {6, 2},
    layer = 5,
    rotate = true,
    eye = {x=23, y=18, w=3, h=3},
    desc = "BUP: HELLO or BUP DOES NOT WANT\nBUP DOES NOT DREAM\nPLEASE HELP HIM\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n",
  },
  -- 62
  {
    name = "text_boll",
    sprite = "text_boll",
    type = "text",
    color = {4, 1},
    layer = 20,
  },
  -- 63
  {
    name = "boll",
    sprite = "orrb",
    type = "object",
    color = {4, 1},
    layer = 3,
  },
  -- 64
  {
    name = "text_bellt",
    sprite = "text_bellt",
    type = "text",
    color = {1, 3},
    layer = 20,
  },
  -- 65
  {
    name = "bellt",
    sprite = "bellt",
    type = "object",
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
    color = {1, 4},
    layer = 20,
  },
  -- 68
  {
    name = "text_direction",
    sprite = "text_goright",
    type = "text",
    texttype = "property",
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
    color = {1, 4},
    layer = 20,
  },
  -- 71
  {
    name = "text_behin u",
    sprite = "text_behinu",
    type = "text",
    texttype = "property",
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
    color = {4, 2},
    layer = 20,
  },
  --79
  {
    name = "gunne",
    sprite = "gun",
    type = "object",
    color = {0, 3},
    layer = 3,
  },
  --80
  {
    name = "text_gunne",
    sprite = "text_gun",
    type = "text",
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
    color = {4, 2},
    layer = 20,
  },
  -- 84
  {
    name = "text_qt",
    sprite = "text_qt",
    type = "text",
    texttype = "property",
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
    color = {2, 4},
    layer = 5,
    eye = {x=19, y=7, w=2, h=2},
  },
  -- 86
  {
    name = "text_o",
    sprite = "text_o",
    type = "text",
    color = {2, 4},
    layer = 20,
  },
  -- 87
  {
    name = "han",
    sprite = "han",
    type = "object",
    color = {0, 3},
    layer = 7,
    rotate = true,
  },
  -- 88
  {
    name = "text_han",
    sprite = "text_han",
    type = "text",
    color = {0, 3},
    layer = 20,
  },
  -- 87
  {
    name = "gras",
    sprite = "gras",
    type = "object",
    color = {5, 1},
    layer = 1,
  },
  -- 88
  {
    name = "text_gras",
    sprite = "text_gras",
    type = "text",
    color = {5, 3},
    layer = 20,
  },
  -- 89
  {
    name = "dayzy",
    sprite = "dayzy",
    type = "object",
    color = {3, 3},
    layer = 5,
    eye = {x=10, y=7, w=3, h=3},
  },
  -- 90
  {
    name = "text_dayzy",
    sprite = "text_dayzy",
    type = "text",
    color = {3, 3},
    layer = 20,
  },
  -- 91
  {
    name = "hurcane",
    sprite = "hurcane",
    type = "object",
    color = {3, 1},
    layer = 3,
    eye = {x=15, y=15, w=3, h=3},
  },
  -- 92
  {
    name = "text_hurcane",
    sprite = "text_hurcane",
    type = "text",
    color = {3, 1},
    layer = 20,
  },
  -- 91
  {
    name = "hatt",
    sprite = "hat",
    type = "object",
    color = {3, 1},
    layer = 3,
  },
  -- 92
  {
    name = "text_hatt",
    sprite = "text_hatt",
    type = "text",
    color = {3, 1},
    layer = 20,
	desc = "HATT: Any object with GOT HATT will wear a HATT."
  },
  -- 93
  {
    name = "press",
    sprite = "press",
    type = "object",
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
    color = {3, 2},
    layer = 20,
    desc = "XWX: At end of turn, if U is on XWX, the game crashes.",
  },
  --98
  {
    name = "text_sublvl",
    sprite = "text_sublvl",
    type = "text",
    texttype = "property",
    color = {4,1},
    layer = 20,
    desc = "SUBLVL: An object that is sublvl will become enterable. Currently unimplemented.",
  },
  --- 99
  {
    name = "text_come pls",
    sprite = "text_comepls",
    type = "text",
    texttype = "property",
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
    color = {0, 3},
    layer = 20,
    desc = "AROND (Prefix Condition): True if the indicated object is on any of the tiles surrounding the unit. (The unit's own tile is not checked.)",
  },
  --- 102
  {
    name = "chekr",
    sprite = "chekr",
    type = "object",
    color ={3, 2},
    layer = 1,
  },
  --- 103
  {
    name = "text_chekr",
    sprite = "text_chekr",
    type = "text",
    color ={3, 2},
    layer = 20,
  },
  --- 104
  {
    name = "text_diag",
    sprite = "text_diag",
    type = "text",
    texttype = "property",
    color = {3, 2},
    layer = 20,
    desc = "DIAG: Prevents the unit moving orthogonally.",
  },
  --- 105
  {
    name = "text_go my way",
    sprite = "text_go my wey",
    type = "text",
    texttype = "property",
    color ={1, 3},
    layer = 20,
    desc = "GO MY WAY: Prevents movement onto its tile from the tile in front of it and the two tiles 45 degrees to either side.",
  },
  --- 106
  {
    name = "text_ortho",
    sprite = "text_ortho",
    type = "text",
    texttype = "property",
    color ={3, 2},
    layer = 20,
    desc = "ORTHO: Prevents the unit moving diagonally.",
  },
  --- 107
  {
    name = "arro",
    sprite = "arro",
    type = "object",
    color ={0, 3},
    layer = 2,
    rotate = true,
  },
  --- 108
  {
    name = "text_arro",
    sprite = "text_arro",
    type = "text",
    color ={0, 3},
    layer = 20,
  },
  --- 109
  {
    name = "text_hotte",
    sprite = "text_hotte",
    type = "text",
    texttype = "property",
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
    color = {1, 4},
    layer = 20,
    desc = "FRIDGD: At end of turn, HOTTE units destroys all units that are FRIGID on their tile.",
  },
  --- 111
  {
    name = "text_colld",
    sprite = "text_colld",
    type = "text",
    color = {1, 4},
    layer = 20,
  },
  --- 112
  {
    name = "colld",
    sprite = "colld",
    type = "object",
    color = {1, 4},
    layer = 1,
  },
  --- 113
  {
    name = "text_goooo",
    sprite = "text_goooo",
    type = "text",
    texttype = "property",
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
    color = {1, 4},
    layer = 20,
    desc = "FLYE: A FLYE unit doesn't interact with other objects on its tile, and can ignore the collision of other objects, unless that other object has the same amount of FLYE as the unit. FLYE stacks with itself!",
  },
  --- 117
  {
    name = "text_piler",
    sprite = "text_piler",
    type = "text",
    color = {0, 1},
    layer = 20,
  },
  --- 118
  {
    name = "piler",
    sprite = "piler",
    type = "object",
    color = {0, 1},
    layer = 3,
  },
  -- 119
  {
    name = "text_nt",
    sprite = "text_nt",
    type = "text",
    texttype = "not",
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
    color = {5, 3},
    layer = 20,
    desc = "HAET SKYE: After movement, this unit falls down as far as it can.",
  },
  -- 121
  {
    name = "clowd",
    sprite = "clowd",
    type = "object",
    color = {0, 3},
    layer = 7,
  },
  -- 122
  {
    name = "text_clowd",
    sprite = "text_clowd",
    type = "text",
    color = {0, 3},
    layer = 20,
  },
  -- 123
  {
    name = "text_moar",
    sprite = "text_moar",
    type = "text",
    texttype = "property",
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
    color = {1, 4},
    layer = 20,
    desc = "VISIT FREN: At end of turn, all other objects are sent to the next VISIT FREN unit with the same name in reading order (left to right, line by line, wrapping around). Higher levels of VISIT FREN will cause the target to be 1 backward, 2 forward, 2 backward, etc.",
  },
  -- 125
  {
    name = "infloop",
    sprite = "text_infloop",
    type = "object",
    color = {0, 3},
    layer = 20,
  },
  -- 126
  {
    name = "text_wait",
    sprite = "text_wait",
    type = "text",
    texttype = "cond_prefix",
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
    color = {2, 2},
    layer = 20,
    desc = "SPOOP: A SPOOPY unit forces all objects it SPOOPS on adjacent tiles to move away!",
  },
  -- 129
  {
    name = "text_stalk",
    sprite = "text_stalk",
    type = "text",
    texttype = "verb_object",
    color = {5, 2},
    layer = 20,
    desc = "STALK: If X stalks Y, X becomes an intelligent AI determined to get to Y."
  },
  -- 130
  {
    name = "text_stelth",
    sprite = "text_stelth",
    type = "text",
    texttype = "property",
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
    color = {3, 3},
    layer = 20,
  },
  -- 133
  {
    name = "larry",
    sprite = "larry",
    sleepsprite = "larry_slep",
    type = "object",
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
    color = {2, 4},
    layer = 20,
  },
  -- 135
  {
    name = "lila",
    sprite = "lila",
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
    color = {4, 2},
    layer = 20,
  },
  -- 137
  {
    name = "text_every1",
    sprite = "text_every1",
    type = "text",
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
    color = {0, 1},
    layer = 20,
    desc = "TALL: Considered to be every FLYE amount at once.",
  },
  --- 139
  {
    name = "text_liek",
    sprite = "text_liek",
    type = "text",
    texttype = "verb_object",
    allowconds = true,
    color = {5, 3},
    layer = 20,
    desc = "LIEK: If a unit LIEKs objects, it is picky, and cannot step onto a tile unless it has at least one object it LIEKs.",
  },
  -- 140
  {
    name = "text_zip",
    sprite = "text_zip",
    type = "text",
    texttype = "property",
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
    color = {5, 3},
    layer = 20,
    desc = "TURN CORNR: At end of turn, faces the first direction that it could enter and that doesn't have another unit of its name: forward, right, left, backward. When combined with WALK, causes the unit to bounce off walls at 90 degree angles.",
  },
  -- 144
  {
    name = "petnygrame",
    sprite = "petnygrame",
    color = {2, 1},
    layer = 5,
  },
  -- 145
  {
    name = "text_petnygrame",
    sprite = "text_petnygrame",
    type = "text",
    color = {2, 1},
    layer = 20,
  },
  -- 146
  {
    name = "katany",
    sprite = "katany",
    color = {0, 1},
    layer = 5,
    rotate = true,
  },
  -- 147
  {
    name = "text_katany",
    sprite = "text_katany",
    type = "text",
    color = {0, 1},
    layer = 20,
	desc = "KATANY: Any object with GOT KATANY will have a KATANY."
  },
  -- 148
  {
    name = "scarr",
    sprite = "scarr",
    color = {2, 1},
    layer = 5,
  },
  -- 149
  {
    name = "text_scarr",
    sprite = "text_scarr",
    type = "text",
    color = {2, 1},
    layer = 20,
  },
  -- 150
  {
    name = "text_no1",
    sprite = "text_no1",
    type = "text",
    color = {0, 3},
    layer = 20,
    desc = "NO1: Refers to tiles with nothing in them."
  },
  -- 151
  {
    name = "no1",
    sprite = "no1",
    type = "object",
    color = {0, 4},
    layer = 20,
    rotate = true,
  },
  -- 152
  {
    name = "text_lvl",
    sprite = "text_lvl",
    metasprite = "text_lvl meta",
    type = "text",
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
    color = {0,3},
    layer = 20,
    desc = "NXT: LVL IS NXT sends you to the next level. (Unimplemented.)"
  },
  -- 154
  {
    name = "pepis",
    sprite = "pepis",
    color = {0, 3},
    layer = 5,
  },
  -- 155
  {
    name = "text_pepis",
    sprite = "text_pepis",
    type = "text",
    color = {3, 2},
    layer = 20,
  },
  -- 156
  {
    name = "text_copkat",
    sprite = "text_copkat",
    type = "text",
    texttype = "verb_object",
    color = {0, 3},
    layer = 20,
    desc = "COPKAT: COPKAT units copy the successful movements of the indicated object, no matter how far away."
  },
  --157
  {
    name = "clok",
    sprite = "clok",
    type = "object",
    color = {3, 3},
    layer = 3,
    rotate = true,
    eye = {x=14, y=14, w=3, h=3},
    desc = "keek look at'd the clok. 'oh no! im late for school!' keek shouted and raced out of bed."
  },
  -- 158
  {
    name = "text_clok",
    sprite = "text_clok",
    type = "text",
    color = {3, 3},
    layer = 20,
  },
  -- 159
  {
    name = "text_try again",
    sprite = "text_try again",
    type = "text",
    texttype = "property",
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
    color = {4,1},
    layer = 20,
  },
  -- 163
  {
    name = "text_mayb",
    sprite = "text_mayb",
    type = "text",
    texttype = "cond_prefix",
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
    color = {6, 1},
    layer = 20,
    desc = "STUBBN: STUBBN units ignore the special properties of WALK movers (bouncing off of walls, and declining to move if it would die due to being OUCH) and also makes attempted diagonal movement slide along walls. Stacks with itself - the more STUBBN, the more additional angles it will try, up to 180 degrees at 5 stacks!",
  },
  -- 165
  {
    name = "text_seen by",
    sprite = "text_seen by",
    type = "text",
    texttype = "cond_infix",
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
    color = {2,3},
    layer = 20,
  },
  -- 168
  {
    name = "text_go arnd",
    sprite = "text_go arnd",
    type = "text",
    texttype = "property",
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
    color = {3, 2},
    layer = 20,
    desc = "POOR TOLL: If a unit would enter a POOR TOLL unit, it instead leaves the next POOR TOLL unit of the same name in reading order (left to right, line by line, wrapping around) out the corresponding same side. Respects FLYE!",
  },
  -- 170
  {
    name = "splittr",
    sprite = "splittr",
    type = "object",
    color = {0, 3},
    layer = 2,
    rotate = true,
  },
  -- 171
  {
    name = "text_splittr",
    sprite = "text_splittr",
    type = "text",
    color = {0, 3},
    layer = 20,
  },
  -- 172
  {
    name = "text_split",
    sprite = "text_split",
    type = "text",
    texttype = "property",
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
    color = {6, 1},
    layer = 20,
    desc = "UNDO: UNDO units, at end of turn, rewind a turn earlier, cumulatively. Stacks!",
  },
  -- 181
  {
    name = "boy",
    sprite = "boy",
    type = "object",
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
    color = {0, 2},
    layer = 20,
  },
  -- 183
  {
    name = "text_spin",
    sprite = "text_spin",
    type = "text",
    texttype = "property",
    color = {4, 1},
    layer = 20,
    rotate = true,
    desc = "SPIN: SPIN units rotate clockwise, the number of times indicated on top of the property.",
  },
  -- 184
  {
    name = "lvl",
    sprite = "lvl",
    type = "object",
    color = {0,3},
    layer = 5,
  },
  -- 185
  {
    name = "text_slippers",
    sprite = "text_slippers",
    type = "text",
    color = {1, 4},
    layer = 20,
    desc = "SLIPPERS: An object that GOT SLIPPERS will ignore ICY and ICYYYYY objects."
  },
  -- 186
  {
    name = "slippers",
    sprite = "slippers",
    type = "object",
    color = {1, 3},
    layer = 6,
  },
  -- 187
  {
    name = "ghost fren",
    sprite = "ghost",
    sleepsprite = "ghost_slep",
    type = "object",
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
    color = {4, 2},
    layer = 20,
  },
  -- 189
  {
    name = "robobot",
    sprite = "robobot",
    sleepsprite = "robobot_slep",
    type = "object",
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
    color = {6, 1},
    layer = 20,
  },
  -- 191
  {
    name = "lvl",
    sprite = "lvl",
    type = "object",
    color = {0, 3},
    layer = 18,
    rotate = true,
    desc = "its a lavel"
  },
  -- 192
  {
    name = "selctr",
    sprite = "selctr",
    type = "object",
    color = {3, 3},
    layer = 20,
    desc = "used to select levis"
  },
  -- 193
  {
    name = "text_selctr",
    sprite = "text_selctr",
    type = "text",
    color = {2, 3},
    layer = 20,
  },
  -- 194
  {
    name = "lin",
    sprite = "lin",
    type = "object",
    color = {0, 3},
    layer = 17,
    desc = "used to connect lovils"
  },
  -- 195
  {
    name = "text_lin",
    sprite = "text_lin",
    type = "text",
    color = {0, 3},
    layer = 20,
  },
  -- 196
  {
    name = "text_moov",
    sprite = "text_moov",
    type = "text",
    texttype = "verb_object",
    color = {1,3},
    layer = 20,
    desc = "MOOV: A verbified GO. x MOOV y means that only x can shift y around.",
  },
  --- 197
  {
    name = "text_haet",
    sprite = "text_haet",
    type = "text",
    texttype = "verb_object",
    allowconds = true,
    color = {5, 3},
    layer = 20,
    desc = "HAET: A unit cannot stop onto a tile that has something it HAETs. (x HAET LVL makes x unable to move.)",
  },
  -- 198
  {
    name = "text_brite",
    sprite = "text_brite",
    type = "text",
    texttype = "property",
    color = {2, 4},
    layer = 20,
    desc = "BRITE: A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing OPAQUE is in the way.",
  },
  -- 199
  {
    name = "text_lit",
    sprite = "text_lit",
    type = "text",
    texttype = "cond_prefix",
    color = {2, 4},
    layer = 20,
    desc = "LIT: A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing OPAQUE is in the way.",
  },
  -- 200
  {
    name = "text_opaque",
    sprite = "text_opaque",
    type = "text",
    texttype = "property",
    color = {0, 1},
    layer = 20,
    desc = "OPAQUE: A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing OPAQUE is in the way.",
  },
  -- 201
  {
    name = "text_no turn",
    sprite = "text_no turn",
    type = "text",
    texttype = "property",
    color = {2, 3},
    layer = 20,
    desc = "NO TURN: A NO TURN unit's direction can't change (unless re-oriented by non-euclidean level geometry, i.e. POOR TOLL).",
  },
  -- 202
  {
    name = "text_an",
    sprite = "text_an",
    type = "text",
    texttype = "cond_prefix",
    color = {0, 3},
    layer = 20,
    desc = "AN (Prefix Condition): True for a single arbitrary unit per turn and condition.",
  },
  -- 203
  {
    name = "text_wurd",
    sprite = "text_wurd",
    type = "text",
    texttype = "property",
    color = {0, 3},
    layer = 20,
    desc = "WURD: A WURD unit forms rules as though it was its respective text.",
  },
  -- 204
  {
    name = "firbolt",
    sprite = "firbolt",
    type = "object",
    color = {6, 2},
    layer = 5,
    rotate = true,
    desc = "i cast FIRBOLT at the NO1!",
  },
  -- 205
  {
    name = "text_firbolt",
    sprite = "text_firbolt",
    type = "text",
    color = {6, 2},
    layer = 20,
  },
  -- 206
  {
    name = "icbolt",
    sprite = "icbolt",
    type = "object",
    color = {1, 4},
    layer = 5,
    rotate = true,
    desc = "its time for u to CHILL out. stay FROSTY.",
  },
  -- 207
  {
    name = "text_icbolt",
    sprite = "text_icbolt",
    type = "text",
    color = {1, 4},
    layer = 20,
  },
  -- 206
  {
    name = "hedg",
    sprite = "hedg",
    type = "object",
    color = {5, 1},
    layer = 1,
    desc = "im hedg the hedg heg",
  },
  -- 207
  {
    name = "text_hedg",
    sprite = "text_hedg",
    type = "text",
    color = {5, 1},
    layer = 20,
  },
  -- 208
  {
    name = "fenss",
    sprite = "fenss",
    type = "object",
    color = {6, 2},
    layer = 1,
    desc = "keeps babs out!!",
  },
  -- 209
  {
    name = "text_fenss",
    sprite = "text_fenss",
    type = "text",
    color = {6, 2},
    layer = 20,
  },
  -- 210
  {
    name = "metl",
    sprite = "metl",
    type = "object",
    color = {0, 2},
    layer = 1,
    desc = "impervious metl...",
  },
  -- 211
  {
    name = "text_metl",
    sprite = "text_metl",
    type = "text",
    color = {0, 2},
    layer = 20,
  },
  -- 210
  {
    name = "sparkl",
    sprite = "sparkl",
    type = "object",
    color = {2, 4},
    layer = 10,
    desc = "as brite as a star... but also as hotte as one!!",
  },
  -- 211
  {
    name = "text_sparkl",
    sprite = "text_sparkl",
    type = "text",
    color = {2, 4},
    layer = 20,
  },
  -- 212
  {
    name = "spik",
    sprite = "spik",
    type = "object",
    color = {0, 2},
    layer = 10,
    rotate = true,
    desc = "finally, I can make my i wanna be the bab fangame in bab be u",
  },
  -- 213
  {
    name = "text_spik",
    sprite = "text_spik",
    type = "text",
    color = {0, 2},
    layer = 20,
  },
  -- 214
  {
    name = "spiky",
    sprite = "spiky",
    type = "object",
    color = {0, 2},
    layer = 10,
    rotate = true,
    desc = "ouch!! many spik at once.",
  },
  -- 215
  {
    name = "text_spiky",
    sprite = "text_spiky",
    type = "text",
    color = {0, 2},
    layer = 20,
  },
  -- 216
  {
    name = "bordr",
    sprite = "bordr",
    type = "object",
    color = {1, 0},
    layer = 99,
    desc = "fake oob to hide stuff under"
  },
  -- 217
  {
    name = "text_bordr",
    sprite = "text_bordr",
    type = "text",
    color = {2, 0},
    layer = 20,
  },
  -- 218
  {
    name = "text_loop",
    sprite = "text_infloop",
    type = "text",
    color = {0, 3},
    layer = 20,
    desc = "INFLOOP: A special word that describes the infinite loop state."
  },
  -- 219
  {
    name = "platfor",
    sprite = "platfor",
    type = "object",
    color = {6, 2},
    layer = 5,
    desc = "good for use with go my way",
    rotate = true
  },
  -- 220
  {
    name = "text_platfor",
    sprite = "text_platfor",
    type = "text",
    color = {6, 2},
    layer = 20,
  },
  -- 221
  {
    name = "jail",
    sprite = "jail",
    type = "object",
    color = {0, 2},
    layer = 21,
    desc = "EVERY1 W/FREN JAIL HAET LVL. now bab's in jail :(",
  },
  -- 222
  {
    name = "text_jail",
    sprite = "text_jail",
    type = "text",
    color = {0, 2},
    layer = 20,
  },
  -- 223
  {
    name = "text_haet flor",
    sprite = "text_haetflor",
    type = "text",
    texttype = "property",
    color = {2,2},
    layer = 20,
    desc = "HAET FLOR: After movement, this unit falls UP as far as it can.",
  },
  -- 224
  {
    name = "this",
    sprite = "this",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "THIS: An object that pretends like it's text."
  },
  -- 225
  {
    name = "text_grun",
    sprite = "text_grun",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {5, 2},
    layer = 20,
    desc = "grun: Causes the unit to appear green."
  },
  -- 226
  {
    name = "text_yello",
    sprite = "text_yello",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {2, 4},
    layer = 20,
    desc = "YELLO: Causes the unit to appear yellow."
  },
  -- 227
  {
    name = "text_purp",
    sprite = "text_purp",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {3, 2},
    layer = 20,
    desc = "PURP: Causes the unit to appear purple."
  },
  -- 228
  {
    name = "text_orang",
    sprite = "text_orang",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {2, 3},
    layer = 20,
    desc = "ORANG: Causes the unit to appear orange."
  },
  -- 229
  {
    name = "text_cyeann",
    sprite = "text_cyeann",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {1, 4},
    layer = 20,
    desc = "CYEANN: Causes the unit to appear cyan."
  },
  -- 230
  {
    name = "text_whit",
    sprite = "text_whit",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {0, 3},
    layer = 20,
    desc = "whit: Causes the unit to appear white."
  },
  -- 231
  {
    name = "text_blacc",
    sprite = "text_blacc",
    type = "text",
    texttype = "cond_prefix_or_property",
    color = {0, 0},
    layer = 20,
    desc = "BLACC: Causes the unit to appear black."
  },
  -- 232
  {
    name = "text_rave",
    sprite = "text_rave",
    type = "text",
    texttype = "property",
    color = {0, 3},
    layer = 20,
    desc = "RAVE: Causes the unit to flash through the rainbow extremely quickly."
  },
  -- 233
  {
    name = "hol",
    sprite = "hol",
    type = "object",
    color = {3, 3},
    layer = 8,
    rotate = true,
    portal = true,
    desc = "the real poor toll"
  },
  -- 234
  {
    name = "text_hol",
    sprite = "text_hol",
    type = "text",
    color = {3, 2},
    layer = 20,
  },
  -- 235
  {
    name = "text_corekt",
    sprite = "text_corekt",
    type = "text",
    texttype = "cond_prefix",
    color = {5,2},
    layer = 20,
    desc = "COREKT: Prefix condition that is true if the unit is in an active rule.",
  },
  -- 236
  {
    name = "text_rong",
    sprite = "text_rong",
    sprite_transforms = {
      property = "text_rong_prop"
    },
    type = "text",
    texttype = "cond_prefix",
    color = {2,2},
    layer = 20,
    desc = "RONG: As a prefix, true if the unit is in a negated rule. As a property, causes associated units to return a negated form of the rule.",
  },
  -- 237
  {
    name = "text_...",
    sprite = "text_...",
    type = "text",
    texttype = "ellipses",
    color = {0, 3},
    layer = 20,
    desc = "... (ELLIPSES): Extends rules. BAB ... BE ... ... U is the same as BAB BE U.",
  },
  -- 238
  {
	name = "text_u too",
	sprite = "text_utoo",
	type = "text",
	texttype = "property",
	color = {4,1},
	layer = 20,
	desc = "player 2 has joined the game",
  },
  -- 239
  {
	name = "text_u tres",
	sprite = "text_utres",
	type = "text",
	texttype = "property",
	color = {4,1},
	layer = 20,
	desc = "and player 3",
  },
  -- 240
  {
    name = "text_za warudo",
    sprite = "text_zawarudo",
    type = "text",
    texttype = "property",
    color = {2,4},
    layer = 20,
    desc = "ZA WARUDO: Can stop time and move without anything else moving. Faster than rule parsing itself! After forming the rule, press E (hourglass on mobile) to toggle.",
  },
	-- 241
  {
    name = "text_babn't",
    sprite = "text_bab n't",
    type = "text",
    color = {0, 3},
    layer = 20,
		desc = "BAB N'T: The same as having these two text tiles in a row."
  },
	-- 242
  {
    name = "text_ben't",
    sprite = "text_be n't",
    type = "text",
    texttype = "verb_all",
    color = {0, 3},
    layer = 20,
		desc = "BE N'T: The same as having these two text tiles in a row."
  },
	-- 243
   {
    name = "text_rocn't",
    sprite = "text_roc n't",
    type = "text",
    color = {0, 3},
    layer = 20,
		desc = "ROC N'T: The same as having these two text tiles in a row."
  },
	-- 243
   {
    name = "text_waln't",
    sprite = "text_wal n't",
    type = "text",
    color = {0, 3},
    layer = 20,
		desc = "WAL N'T: The same as having these two text tiles in a row."
  },
  -- 244
  {
    name = "letter_a",
    sprite = "letter_a",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 245
  {
    name = "letter_b",
    sprite = "letter_b",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 246
  {
    name = "letter_c",
    sprite = "letter_c",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 247
  {
    name = "letter_d",
    sprite = "letter_d",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 248
  {
    name = "letter_e",
    sprite = "letter_e",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 249
  {
    name = "letter_f",
    sprite = "letter_f",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 250
  {
    name = "letter_g",
    sprite = "letter_g",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 251
  {
    name = "letter_h",
    sprite = "letter_h",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 252
  {
    name = "letter_j",
    sprite = "letter_j",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 253
  {
    name = "letter_k",
    sprite = "letter_k",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 254
  {
    name = "letter_l",
    sprite = "letter_l",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 255
  {
    name = "letter_m",
    sprite = "letter_m",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 256
  {
    name = "letter_n",
    sprite = "letter_n",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 257
  {
    name = "letter_p",
    sprite = "letter_p",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 258
  {
    name = "letter_q",
    sprite = "letter_q",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 259
  {
    name = "letter_r",
    sprite = "letter_r",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 260
  {
    name = "letter_s",
    sprite = "letter_s",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 261
  {
    name = "letter_t",
    sprite = "letter_t",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 262
  {
    name = "letter_u",
    sprite = "letter_u",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 263
  {
    name = "letter_v",
    sprite = "letter_v",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 264
  {
    name = "letter_w",
    sprite = "letter_w",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 265
  {
    name = "letter_x",
    sprite = "letter_x",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 266
  {
    name = "letter_y",
    sprite = "letter_y",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 267
  {
    name = "letter_.",
    sprite = "letter_period",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 268
  {
    name = "letter_colon",
    sprite = "letter_colon",
    type = "text",
    texttype = "letter",
    rotate = true,
    color = {0,3},
    layer = 20,
  },
  -- 269
  {
    name = "letter_parenthesis",
    sprite = "letter_paranthesis",
    type = "text",
    texttype = "letter",
    rotate = true,
    color = {0,3},
    layer = 20,
  },
  -- 270
  {
    name = "letter_'",
    sprite = "letter_apostrophe",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 271
  {
    name = "letter_go",
    sprite = "letter_go",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 272
  {
    name = "letter_come",
    sprite = "letter_come",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 273
  {
    name = "letter_pls",
    sprite = "letter_pls",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 274
  {
    name = "letter_away",
    sprite = "letter_away",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 275
  {
    name = "letter_my",
    sprite = "letter_my",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 276
  {
    name = "letter_no",
    sprite = "letter_no",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 277
  {
    name = "letter_way",
    sprite = "letter_way",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 278
  {
    name = "text_ditto",
    sprite = "text_ditto",
    type = "text",
    texttype = "ditto",
    color = {0,3},
    layer = 20,
    desc = "DITTO: Acts like the text above it."
  },
  -- 279
  {
    name = "text_meta",
    sprite = "text_meta",
    type = "text",
    texttype = "property",
    color = {4, 1},
    layer = 20,
    desc = "META: BE META causes that object to be turned into its corresponding metatext. BEN'T META does the opposite and goes down one meta layer (disappearing if that is impossible).",
  },
  -- 280
  {
    name = "ui_1",
    sprite = "ui_1",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 281
  {
    name = "ui_2",
    sprite = "ui_2",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 282
  {
    name = "ui_3",
    sprite = "ui_3",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 283
  {
    name = "ui_4",
    sprite = "ui_4",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 284
  {
    name = "ui_6",
    sprite = "ui_6",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 285
  {
    name = "ui_7",
    sprite = "ui_7",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 286
  {
    name = "ui_8",
    sprite = "ui_8",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 287
  {
    name = "ui_9",
    sprite = "ui_9",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 288
  {
    name = "ui_w",
    sprite = "ui_w",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 289
  {
    name = "ui_a",
    sprite = "ui_a",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 290
  {
    name = "ui_s",
    sprite = "ui_s",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 291
  {
    name = "ui_d",
    sprite = "ui_d",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 292
  {
    name = "ui_arrow",
    sprite = "ui_right",
    type = "object",
    rotate = true,
    color = {0,3},
    layer = 20,
  },
  -- 293
  {
    name = "ui_i",
    sprite = "ui_i",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 294
  {
    name = "ui_j",
    sprite = "ui_j",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 295
  {
    name = "ui_k",
    sprite = "ui_k",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 296
  {
    name = "ui_l",
    sprite = "ui_l",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 297
  {
    name = "ui_e",
    sprite = "ui_e",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 298
  {
    name = "ui_walk",
    sprite = "ui_walk",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 299
  {
    name = "ui_activat",
    sprite = "ui_activat",
    type = "object",
    color = {0,3},
    layer = 20,
  },
	-- 300
  {
    name = "text_frens",
    sprite = "text_frens",
    type = "text",
    texttype = "group",
    color = {3, 3},
    layer = 20,
    desc = "FRENS: A group you can be a member of. 'x BE FRENS' adds you to the FRENS group. 'FRENS BE x' applies the property to all FRENS.",
  },
	-- 301
  {
    name = "text_pathz",
    sprite = "text_pathz",
    type = "text",
    texttype = "group",
    color = {3, 3},
    layer = 20,
    desc = "PATHZ: A variant of FRENZ. SELCTR inherently lieks PATHZ.",
  },
	-- 302
  {
    name = "text_groop",
    sprite = "text_groop",
    type = "text",
    texttype = "group",
    color = {3, 3},
    layer = 20,
    desc = "GROOP: A variant of FRENZ.",
  },
  -- 303
  {
    name = "text_her",
    sprite = "text_her",
    type = "text",
    texttype = "property",
    rotate = true,
    color = {1,3},
    layer = 20,
    desc = "HER ->: Sends objects to where the text indicates.",
  },
  -- 304
  {
    name = "text_thr",
    sprite = "text_thr",
    type = "text",
    texttype = "property",
    rotate = true,
    color = {3,2},
    layer = 20,
    desc = "THR ->: Sends objects as far away from it as possible in the indicated direction.",
  },
  -- 305
  {
    name = "text_the",
    sprite = "text_the",
    type = "text",
    rotate = true,
    color = {0,3},
    layer = 20,
    desc = "THE: Refers to the object it's pointing at. Currently not functional.",
  },
  -- 306
  {
    name = "text_knightstep",
    sprite = "text_knightstep",
    type = "text",
    texttype = "property",
    color = {0, 2},
    layer = 20,
    desc = "KNIGHTSTEP: KNIGHTSTEP units move like the Knight chess piece.",
  },
  -- 307
  {
    name = "text_that",
    sprite = "text_that",
    type = "text",
    texttype = "cond_infix_verb",
    color = {0, 3},
    layer = 20,
    desc = "THAT (Infix Condition): x THAT BE y is true if x BE y. x THAT GOT Y is true if x GOT y. And so on."
  },
  -- 307
  {
    name = "text_that be",
    sprite = "text_that be",
    type = "text",
    --this is because while it's technically cond_infix, listing it as one makes it double count any n'ts after it because it saves the n'ts accumulated from the two different paths it can try it as? I think?? anyway this fixes it because it's special cased in parser.lua
    texttype = "hideous_amalgamation",
    color = {0, 3},
    layer = 20,
    desc = "THAT BE (Infix Condition): x THAT BE y is true if x BE y."
  },
  -- 308
  {
    name = "text_timles",
    sprite = "text_timles",
    type = "text",
    texttype = "cond_prefix",
    color = {2,4},
    layer = 20,
    desc = "TIMLES: A prefix condition that is true if ZA WARUDO is active."
  },
  --vitellary: added down here because i did not want to have to change the numbers for everything beyond "h", plus i think i heard that it would mess things up if i added it up there
  -- 309
  {
    name = "letter_i",
    sprite = "letter_i",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 310
  {
    name = "letter_z",
    sprite = "letter_z",
    type = "text",
    texttype = "letter",
    color = {0,3},
    layer = 20,
  },
  -- 311
  {
    name = "riff",
    sprite = "riff",
    type = "object",
    rotate = true,
    portal = true,
    color = {2,4},
    layer = 8,
    desc = "the fake poor toll"
  },
  -- 312
  {
    name = "text_riff",
    sprite = "text_riff",
    type = "text",
    color = {2,4},
    layer = 20,
  },
  -- 306
  {
    name = "text_stay ther",
    sprite = "text_stay ther",
    type = "text",
    texttype = "property",
    color = {0, 3},
    layer = 20,
    desc = "STAY THER: Will be taken with you the next time you change levels.",
  },
  -- 313? why are the numbers weird
  {
    name = "lie",
    sprite = "caek",
    type = "object",
    color = {4,1},
    layer = 5,
    desc = "caek be lie",
  },
  -- 314 happy pi day, have some caek
  {
    name = "text_lie",
    sprite = "text_caek",
    type = "text",
    color = {4,1},
    layer = 20,
  },
  -- 315
  {
    name = "lie/8",
    sprite = "slis",
    type = "object",
    color = {4,2},
    rotate = true,
    layer = 4,
    desc = "idc if it's a lie, it tastes good",
  },
  -- 316
  {
    name = "text_lie/8",
    sprite = "text_slis",
    type = "text",
    color = {4,2},
    layer = 20,
  },
  -- 317
  {
    name = "ui_left click",
    sprite = "ui_left_click",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 318
  {
    name = "ui_right click",
    sprite = "ui_right_click",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 319
  {
    name = "ui_clik",
    sprite = "ui_clik",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 320
  {
    name = "text_clikt",
    sprite = "text_clikt",
    type = "text",
    texttype = "cond_prefix",
    color = {3, 3},
    layer = 20,
    desc = "CLIKT (Prefix Condition): CLIKT objects will be true when left-clicked. Clicks will pass a turn if this text exists.",
  },
  -- 321
  {
    name = "sine",
    sprite = "sine",
    type = "object",
    color = {6,2},
    layer = 4
  },
  -- 322
  {
    name = "text_sine",
    sprite = "text_sine",
    type = "text",
    color = {6,2},
    layer = 20,
  },
  -- 323
  {
    name = "buble",
    sprite = "buble",
    type = "object",
    color = {1,3},
    layer = 3,
  },
  -- 324
  {
    name = "text_buble",
    sprite = "text_buble",
    type = "text",
    color = {1,3},
    layer = 20,
  },
  -- 325
  {
    name = "creb",
    sprite = "creb",
    type = "object",
    color = {2,2},
    layer = 5,
    eye = {x=17, y=5, w=9, h=7},
  },
  -- 326
  {
    name = "text_creb",
    sprite = "text_creb",
    type = "text",
    color = {2,2},
    layer = 20,
  },
  -- 327
  {
    name = "icecub",
    sprite = "icecub",
    type = "object",
    color = {1,4},
    layer = 4,
  },
  -- 328
  {
    name = "text_icecub",
    sprite = "text_icecub",
    type = "text",
    color = {1,4},
    layer = 20,
  },
  -- 329
  {
    name = "jill",
    sprite = "jill",
    sleepsprite = "jill_slep";
    type = "object",
    color = {1,3},
    layer = 5,
    rotate = true,
    eye = {x=17, y=8, w=2, h=3},
    desc = "it time 2 mix drincc & chaeng life"
  },
  -- 330
  {
    name = "text_jill",
    sprite = "text_jill",
    type = "text",
    color = {1,3},
    layer = 20,
  },
  -- 331
  {
    name = "text_paint",
    sprite = "text_paint",
    type = "text",
    texttype = "verb_object",
    color = {4, 2},
    layer = 20,
    desc = "PAINT: changes the second object's color to match."
  },
  -- 332
  {
    name = "paint",
    sprite = "paint",
    type = "object",
    color = {0, 3},
    layer = 4,
    desc = "X be PAINT turns into a paint bucket with the color of X."
  },
}

tiles_by_name = {}
for i,v in ipairs(tiles_list) do
  tiles_by_name[v.name] = i
end

group_names = {}
for i,tile in ipairs(tiles_list) do
  if tile.texttype == "group" then
		table.insert(group_names, tile.name:sub(6, -1));
	end
end
