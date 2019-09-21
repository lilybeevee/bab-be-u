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

debug_view= false
superduperdebugmode = false
debug_values = {

}

rainbowmode = false

if love.filesystem.getInfo("build_number") ~= nil then
  build_number = love.filesystem.read("build_number")
else
  build_number = "HEY, READ THE README!"
end

ruleparts = {"subject", "verb", "object"}

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

dirs8_by_name_set = {};
for _,dir in ipairs(dirs8_by_name) do
  dirs8_by_name_set[dir] = true
end

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
pinc = {4, 1},
graey = {0, 1},
brwn = {6, 0},
}
color_names = {"reed", "orang", "yello", "grun", "cyeann", "bleu", "purp", "pinc", "whit", "blacc", "graey", "brwn"}

colour_for_palette = {}
colour_for_palette[0] = {}
colour_for_palette[0][0] = "blacc"
colour_for_palette[0][1] = "graey"
colour_for_palette[0][2] = "graey"
colour_for_palette[0][3] = "whit"
colour_for_palette[0][4] = "blacc"
colour_for_palette[1] = {}
colour_for_palette[1][0] = "blacc"
colour_for_palette[1][1] = "bleu"
colour_for_palette[1][2] = "bleu"
colour_for_palette[1][3] = "bleu"
colour_for_palette[1][4] = "cyeann"
colour_for_palette[2] = {}
colour_for_palette[2][0] = "reed"
colour_for_palette[2][1] = "reed"
colour_for_palette[2][2] = "reed"
colour_for_palette[2][3] = "orang"
colour_for_palette[2][4] = "yello"
colour_for_palette[3] = {}
colour_for_palette[3][0] = "pinc"
colour_for_palette[3][1] = "purp"
colour_for_palette[3][2] = "purp"
colour_for_palette[3][3] = "purp"
colour_for_palette[3][4] = nil
colour_for_palette[4] = {}
colour_for_palette[4][0] = "pinc"
colour_for_palette[4][1] = "pinc"
colour_for_palette[4][2] = "pinc"
colour_for_palette[4][3] = nil
colour_for_palette[4][4] = nil
colour_for_palette[5] = {}
colour_for_palette[5][0] = "grun"
colour_for_palette[5][1] = "grun"
colour_for_palette[5][2] = "grun"
colour_for_palette[5][3] = "grun"
colour_for_palette[5][4] = nil
colour_for_palette[6] = {}
colour_for_palette[6][0] = "brwn"
colour_for_palette[6][1] = "brwn"
colour_for_palette[6][2] = "brwn"
colour_for_palette[6][3] = "brwn"
colour_for_palette[6][4] = "blacc"

selector_grid_contents = {
  -- page 1: default
  {
    0, "text_be", "text_&", "text_got", "text_n't", "text_every1", "text_no1", "text_text", "text_wurd", "text_meta", "text_sublvl", "text_wait...", "text_mous", "text_clikt", "text_nxt", "text_stay ther", "lvl", "text_lvl",
    "bab", "text_bab", "text_u", "kee", "text_kee", "text_for dor", "text_goooo", "text_icy", "text_icyyyy", "text_behin u", "text_moar", "text_sans", "text_liek", "text_loop", "lin", "text_lin", "selctr", "text_selctr",
    "keek", "text_keek", "text_walk", "dor", "text_dor", "text_ned kee", "text_frens", "text_pathz", "text_groop", "text_u too", "text_u tres", "text_xwx", "text_haet", "text_mayb", "text_an", "text_that", "text_ignor", "text_...",
    "flog", "text_flog", "text_:)", "colld", "text_colld", "text_fridgd", "text_direction", "text_ouch", "text_slep", "text_protecc", "text_sidekik", "text_brite", "text_lit", "text_opaque", "text_torc", "text_vs", "text_nuek", "text_''",
    "roc", "text_roc", "text_go away pls", "laav", "text_laav", "text_hotte","text_visit fren", "text_w/fren", "text_arond", "text_frenles", "text_copkat", "text_za warudo", "text_timles", "text_behind", "text_beside", "text_look away", "text_notranform", "this",
    "wal", "text_wal", "text_no go", "l..uv", "text_l..uv", "gras", "text_gras", "text_creat", "text_look at", "text_spoop", "text_yeet", "text_turn cornr", "text_corekt", "text_go arnd", "text_mirr arnd", 0, 0, "text_sing",
    "watr", "text_watr", "text_no swim", "meem", "text_meem", "dayzy", "text_dayzy", "text_snacc", "text_seen by" , "text_stalk", "text_moov", "text_folo wal", "text_rong", "text_her", "text_thr", "text_rithere", "text_the", 0,
    "skul", "text_skul", "text_:(", "til", "text_til", "hurcane", "text_hurcane", "gunne", "text_gunne", "wog", "text_wog", "text_zip", "text_shy", "text_munwalk", "text_sidestep", "text_diagstep", "text_hopovr", "text_knightstep",
    "boux", "text_boux", "text_come pls", "os", "text_os", "bup", "text_bup", "han", "text_han", "fenss", "text_fenss", 0, 0, "hol", "text_hol", "text_poor toll", "text_blacc", "text_reed",
    "bellt", "text_bellt", "text_go", "tre", "text_tre", "piler", "text_piler", "hatt", "text_hatt", "hedg", "text_hedg", 0, 0, "rif", "text_rif", "text_glued", "text_whit", "text_orang",
    "boll", "text_boll", "text_:o", "frut", "text_frut", "kirb", "text_kirb", "katany", "text_katany", "metl", "text_metl", 0, 0, 0, 0, "text_enby", "text_colrful", "text_yello",
    "clok", "text_clok", "text_try again", "text_no undo", "text_undo", "slippers", "text_slippers", "firbolt", "text_firbolt", "jail", "text_jail", 0, 0, 0, 0, "text_tranz", "text_rave", "text_grun",
    "splittr", "text_splittr", "text_split", "steev", "text_steev", "boy", "text_boy", "icbolt", "text_icbolt", "platfor", "text_platfor", "chain", "text_chain", 0, 0, "text_gay", "text_stelth", "text_cyeann",
    "chekr", "text_chekr", "text_diag", "text_ortho", "text_haet flor", "arro", "text_arro", "text_go my way", "text_spin", "text_no turn", "text_stubbn", "text_rotatbl", 0, 0, "text_pinc", "text_qt", "text_paint", "text_bleu",
    "clowd", "text_clowd", "text_flye", "text_tall", "text_haet skye", "ghost fren", "text_ghost fren", "robobot", "text_robobot", "sparkl", "text_sparkl", "spik", "text_spik", "spiky", "text_spiky", "bordr", "text_bordr", "text_purp",
    nil
  },
  -- page 2: letters
  {
    "letter_a","letter_b","letter_c","letter_d","letter_e","letter_f","letter_g","letter_h","letter_i","letter_j","letter_k","letter_l","letter_m","letter_n","letter_o","letter_p","letter_q","letter_r",
    "letter_s","letter_t","letter_u","letter_v","letter_w","letter_x","letter_y","letter_z","letter_.","letter_colon","letter_parenthesis","letter_'","letter_/","letter_1","letter_2","letter_3","letter_4","letter_5",
    0,0,0,0,0,0,0,0,0,"letter_;",0,0,0,"letter_6","letter_7","letter_8","letter_9","letter_o",
	"letter_go","letter_come","letter_pls","letter_away","letter_my","letter_no","letter_way","letter_ee","letter_fren","letter_ll","letter_bolt","letter_ol","text_sharp","text_flat",0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  },
  -- page 3: ui / instructions
  {
    0 ,"ui_w","ui_e","ui_r",0,0,0,"ui_i",0,0,0,0,0,0,0,"ui_7","ui_8","ui_9",
    "ui_a","ui_s","ui_d",0,0,0,"ui_j","ui_k","ui_l",0,0,0,0,0,0,"ui_4","ui_5","ui_6",
    "ui_z",0,0,0,0,0,0,0,0,0,0,0,0,0,0,"ui_1","ui_2","ui_3",
    0,0,0,0,"ui_space",0,0,0,0,0,0,0,0,0,0,"ui_arrow",0,0,
    "text_press","text_f1","text_play","text_f2","text_edit","ui_left click","ui_right click",0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,"ui_walk",0,0,"ui_reset",0,0,"ui_undo",0,0,"ui_wait",0,0,"ui_activat",0,0,"ui_clik",0,0,0,0,
  },
  -- page 4: characters and special objects
  {
    "bab","text_bab","bunmy","text_bunmy","moo","text_moo","migri","text_migri",0,0,0,0,0,0,"selctr","text_selctr","lvl","text_lvl",
    "keek","text_keek","creb","text_creb","shrim","text_shrim",0,0,0,0,0,0,0,0,"this","text_mous","lin","text_lin",
    "meem","text_meem","statoo","text_statoo","flamgo","text_flamgo",0,0,0,0,0,0,0,0,"text_text","text_frens","text_groop","text_pathz",
    "skul","text_skul","beeee","text_beeee","gul","text_gul",0,0,0,0,0,0,0,0,"text_lethers","text_every1","text_every2","text_every3",
    "ghost fren","text_ghost fren","fishe","text_fishe","starrfishe","text_starrfishe",0,0,0,0,0,0,0,0,0,0,0,"text_no1",
    "robobot","text_robobot","snek","text_snek","sneel","text_sneel",0,0,0,0,0,0,0,0,0,0,0,0,
    "wog","text_wog","bog","text_bog","enbybog","text_enbybog",0,0,0,0,0,0,0,0,0,0,0,0,
    "kirb","text_kirb","ripof","text_ripof","cavebab","text_cavebab",0,0,0,0,0,0,0,0,0,0,0,0,
    "bup","text_bup","butflye","text_butflye","boooo","text_boooo",0,0,0,0,0,0,0,0,0,0,0,0,
    "boy","text_boy","wurm","text_wurm","madi","text_madi",0,0,0,0,0,0,0,0,"lila","text_lila","tot","text_tot",
    "steev","text_steev","ratt","text_ratt","badi","text_badi",0,0,0,0,0,0,0,0,"pata","text_pata","jill","text_jill",
    "han","text_han","eyee","text_eyee","lisp","text_lisp","paw","text_paw",0,0,0,0,0,0,"larry","text_larry","zsoob","text_zsoob",
    "snoman","text_snoman","pingu","text_pingu",0,0,0,0,0,0,0,0,0,0,0,0,"o","text_o",
    "kapa","text_kapa","urei","text_urei","ryugon","text_ryugon",0,0,0,0,0,0,0,0,0,0,"square","text_square",
    "os","text_os","hors","text_hors",0,0,0,0,0,0,0,0,0,0,0,0,"triangle","text_triangle",
  },
  -- page 5: inanimate objects
  {
    "wal","text_wal","bellt","text_bellt","hurcane","text_hurcane","buble","text_buble","katany","text_katany","petnygrame","text_petnygrame","firbolt","text_firbolt","hol","text_hol","golf","text_golf",
    "til","text_til","arro","text_arro","clowd","text_clowd","sno","text_sno","gunne","text_gunne","scarr","text_scarr","litbolt","text_litbolt","rif","text_rif","paint","text_paint",
    "watr","text_watr","colld","text_colld","rein","text_rein","icecub","text_icecub","slippers","text_slippers","pudll","text_pudll","icbolt","text_icbolt","win","text_win","press","text_press",
    "laav","text_laav","dor","text_dor","kee","text_kee","roc","text_roc","hatt","text_hatt","extre","text_extre","poisbolt","text_poisbolt","smol","text_smol",0,0,
    "gras","text_gras","algay","text_algay","flog","text_flog","boux","text_boux","knif","text_knif","heg","text_heg","timbolt","text_timbolt","tor","text_tor",0,0,
    "hedg","text_hedg","banboo","text_banboo","boll","text_boll","l..uv","text_l..uv","wips","text_wips","pepis","text_pepis","do$h","text_do$h","dling","text_dling",0,0,
    "metl","text_metl","vien","text_vien","leef","text_leef","karot","text_karot","fir","text_fir","eeg","text_eeg","foreeg","text_foreeg","forbeeee","text_forbeeee",0,0,
    "jail","text_jail","ladr","text_ladr","pallm","text_pallm","coco","text_coco","rouz","text_rouz","noet","text_noet","lili","text_lili",0,0,0,0,
    "fenss","text_fenss","platfor","text_platfor","tre","text_tre","stum","text_stum","dayzy","text_dayzy","lie","text_lie","reffil","text_reffil",0,0,0,0,
    "cobll","text_cobll","spik","text_spik","frut","text_frut","fungye","text_fungye","red","text_red","lie/8","text_lie/8","vlc","text_vlc",0,0,0,0,
    "wuud","text_wuud","spiky","text_spiky","parsol","text_parsol","clok","text_clok","ufu","text_ufu","rockit","text_rockit","swim","text_swim","yanying","text_yanying",0,0,
    "brik","text_brik","sparkl","text_sparkl","sanglas","text_sanglas","bullb","text_bullb","son","text_son","muun","text_muun","bac","text_bac","warn","text_warn","piep","text_piep",
    "san","text_san","piler","text_piler","sancastl","text_sancastl","shel","text_shel","starr","text_starr","cor","text_cor","byc","text_byc","gorder","text_gorder","tuba","text_tuba",
    "glas","text_glas","bom","text_bom","sine","text_sine","kar","text_kar","can","text_can","ger","text_ger","sirn","text_sirn","chain","text_chain","reflecr","text_reflecr",
    "bordr","text_bordr","wut","text_wut","wat","text_wat","splittr","text_splittr","togll","text_togll","bon","text_bon","battry","text_battry","chekr","text_chekr","sloop","text_sloop",
  },
  -- page 6: properties, verbs and conditions
  {
    "text_be","text_&","text_got","text_creat","text_snacc","text_spoop","text_copkat","text_moov","text_yeet","text_liek","text_haet","text_stalk","text_ignor","text_paint","text_vs","text_sing","text_soko","text_look at",
    "text_u","text_u too","text_u tres","text_walk",0,"text_:)","text_no swim","text_ouch","text_protecc",0,"text_nxt","text_stay ther","text_sublvl",0,"text_w/fren","text_arond","text_frenles","text_sans",
    "text_go","text_goooo","text_icy","text_icyyyy",0,"text_:(","text_ned kee","text_for dor","text_wurd",0,"text_loop",0,0,0,"text_that got","text_that","text_that be","text_wait...",
    "text_no go","text_go away pls","text_come pls","text_sidekik","text_diagkik","text_:o","text_hotte","text_fridgd","text_meta",0,0,0,0,0,"text_corekt","text_rong","text_timles","text_lit",
    "text_visit fren","text_slep","text_shy","text_behin u",0,"text_xwx","text_moar","text_split","text_nuek",0,0,0,0,0,"text_samefloat","text_clikt","text_mayb","text_an",
    "text_flye","text_tall","text_haet skye","text_haet flor",0,"text_;d",0,0,"text_notranform",0,0,0,0,0,"text_look away","text_behind","text_seen by","text_beside",
    "text_diag","text_ortho","text_go my way","text_direction",0,0,0,0,0,0,0,0,0,0,0,0,0,"text_wun",
    "text_turn cornr","text_folo wal","text_zip","text_hopovr","text_reflecc",0,0,0,0,0,0,0,0,0,0,0,0,0,
    "text_munwalk","text_sidestep","text_diagstep","text_knightstep",0,0,0,0,0,0,0,0,0,0,0,0,0,"text_reed",
    "text_spin","text_rotatbl","text_noturn",0,0,0,0,0,0,0,0,0,0,0,0,0,"text_enby","text_orang",
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"text_brwn","text_tranz","text_yello",
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"text_blacc","text_gay","text_grun",
    0,0,0,0,0,"text_try again","text_no undo","text_undo","text_za warudo","text_brite",0,0,0,0,0,"text_graey","text_qt","text_cyeann",
    "text_every1","text_every2","text_every3","text_lethers",0,"text_poor toll","text_go arnd","text_mirr arnd","text_glued","text_torc",0,0,0,0,0,"text_whit","text_pinc","text_bleu",
    "text_...","text_''",0,0,0,"text_her","text_thr","text_rithere","text_the","text_opaque",0,0,0,0,"text_stelth","text_colrful","text_rave","text_purp",
  },
}
tile_grid_width = 18
tile_grid_height = 15

tiles_list = {
  -- 1
  {
    name = "bab",
    sprite = "bab",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 6,
    rotate = true,
    eye = {x=22, y=10, w=2, h=2},
    tags = {"chars", "baba"},
    desc = "its bab bruh"
  },
  -- 2
  {
    name = "text_bab",
    sprite = "text_bab",
    metasprite = "text_bab meta",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"chars", "baba"},
    desc = "\"BAB\". thats what it says"
  },
  -- 3
  {
    name = "text_be",
    sprite = "text_be",
    type = "text",
    texttype = {verb = true, verb_be = true},
    color = {0, 3},
    layer = 20,
    tags = {"is"},
    desc = "BE (Verb): Causes the subject to become an object or have a property.",
  },
  -- 4
  {
    name = "text_u",
    sprite = "text_u",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"you","p1"},
    desc = "U: Controlled by you, the player!",
  },
  -- 5
  {
    name = "wal",
    sprite = "wal",
    type = "object",
    color = {1, 1},
    layer = 2,
    tags = {"wall"},
    desc = "ston briks"
  },
  -- 6
  {
    name = "text_wal",
    sprite = "text_wal",
    metasprite = "text_wal meta",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"wall"},
    desc = "uigi isn't gonna be in smash"
  },
  -- 7
  {
    name = "text_no go",
    sprite = "text_nogo",
    type = "text",
    texttype = {property = true},
    color = {5, 1},
    layer = 20,
    tags = {"stop"},
    desc = "NO GO: Can't be entered by objects. Overrides GO AWAY PLS!",
  },
  -- 8
  {
    name = "roc",
    sprite = "roc",
    type = "object",
    color = {6, 2},
    layer = 3,
    tags = {"rock"},
    desc = "roc: not a bord"
  },
  -- 9
  {
    name = "text_roc",
    sprite = "text_roc",
    metasprite = "text_roc meta",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"rock"},
  },
  -- 10
  {
    name = "text_go away pls",
    sprite = "text_goaway",
    type = "text",
    texttype = {property = true},
    color = {6, 1},
    layer = 20,
    tags = {"push"},
    desc = "GO AWAY: Pushed by movement into its tile.",
  },
  -- 11
  {
    name = "dor",
    sprite = "dor",
    type = "object",
    color = {2, 2},
    layer = 3,
    tags = {"door"},
    desc = "inherently FORDOR",
  },
  -- 12
  {
    name = "text_dor",
    sprite = "text_dor",
    metasprite = "text_dor meta",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"door"}
  },
  -- 13
  {
    name = "text_ned kee",
    sprite = "text_nedkee",
    type = "text",
    texttype = {property = true},
    color = {2, 2},
    layer = 20,
    tags = {"shut"},
    desc = "NED KEE: When a NED KEE and FOR DOR unit move into each other or are on each other, they are both destroyed.",
  },
  -- 14
  {
    name = "kee",
    sprite = "kee",
    type = "object",
    color = {2, 4},
    layer = 4,
    rotate = true,
    tags = {"key"},
    desc = "normally NEDKEE",
  },
  -- 15
  {
    name = "text_kee",
    sprite = "text_kee",
    metasprite = "text_kee meta",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"key"},
  },
  -- 16
  {
    name = "text_for dor",
    sprite = "text_fordor",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    tags = {"open"},
    desc = "FOR DOR: When a NED KEE and FOR DOR unit move into each other or are on each other, they are both destroyed.",
  },
  -- 17
  {
    name = "text_&",
    sprite = "text_and",
    type = "text",
    texttype = {["and"] = true}, -- and is a reserved word
    color = {0, 3},
    layer = 20,
    tags = {"and"},
    desc = "&: Joins multiple conditions, subjects or objects together in a rule. Rules with stacked text and &s don't work like in baba, be sure to experiment!",
  },
  -- 18
  {
    name = "flog",
    sprite = "flog",
    type = "object",
    color = {2, 4},
    layer = 3,
    tags = {"flag"},
    desc = "i want 1!!!",
  },
  -- 19
  {
    name = "text_flog",
    sprite = "text_flog",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"flag"},
  },
  -- 20
  {
    name = "text_:)",
    sprite = "text_good",
    slep = true,
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    eye = {x=21, y=6, w=3, h=4},
    tags = {"win", "smiley", "face", "happy", "yay"},
    desc = ":): At end of turn, if U is on :) and survives, U R WIN!",
  },
  -- 21
  {
    name = "til",
    sprite = "til",
    type = "object",
    color = {1, 0},
    layer = 1,
    tags = {"tile"},
    desc = "it goes under your feet"
  },
  -- 22
  {
    name = "watr",
    sprite = "watr",
    type = "object",
    color = {1, 3},
    layer = 1,
    desc = "splish sploosh",
    tags = {"water"},
  },
  -- 23
  {
    name = "text_watr",
    sprite = "text_watr",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"water"},
  },
  -- 24
  {
    name = "text_no swim",
    sprite = "text_no swim",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"sink"},
    desc = "NO SWIM: At end of turn, if a NO SWIM unit is touching another object, all objects on the tile are destroyed.",
  },

  -- 25
  {
    name = "text_got",
    sprite = "text_got",
    type = "text",
    texttype = {verb = true, verb_class = true},
    color = {0, 3},
    layer = 20,
    tags = {"has"},
    desc = "GOT (Verb): Causes the subject to drop the object when destroyed.",
  },
  --26
  {
    name = "text_colrful",
    sprite = "text_colrful",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    desc = "COLRFUL: Causes the unit to appear a variety of colours.",
  },
  --27
  {
    name = "text_reed",
    sprite = "text_reed_cond",
    sprite_transforms = {
      property = "text_reed"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {2, 2},
    layer = 20,
    tags = {"colors", "colours", "red"},
    desc = "REED: Causes the unit to appear red. Persistent and can be used as a prefix condition.",
  },
  --28
  {
    name = "text_bleu",
    sprite = "text_bleu_cond",
    sprite_transforms = {
      property = "text_bleu"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {1, 3},
    layer = 20,
    tags = {"colors", "colours", "blue"},
    desc = "BLEU: Causes the unit to appear blue. Persistent and can be used as a prefix condition.",
  },
  --29
  {
    name = "text_tranz",
    sprite = "text_tranz-colored",
    type = "text",
    texttype = {property = true},
    color = {255, 255, 255},
    layer = 20,
    tags = {"trans"},
    desc = "TRANZ: Causes the unit to appear pink, white and baby blue.",
  },
  --30
  {
    name = "text_gay",
    sprite = "text_gay-colored",
    type = "text",
    texttype = {property = true},
    color = {255, 255, 255},
    layer = 20,
    desc = "GAY: Causes the unit to appear rainbow coloured.",
  },
  --31
  {
    name = "text_mous",
    sprite = "text_mous",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"mouse","cursor"},
    desc = "MOUS: Refers to the mouse cursor. You can create, destroy and apply properties to mouse cursors!",
  },
  --32
  {
    name = "text_boux",
    sprite = "text_boux",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"box"},
  },
  --33
  {
    name = "boux",
    sprite = "boux",
    type = "object",
    color = {6, 2},
    layer = 3,
    desc = "ce n'est pas une boîte, c'est quelque chose DE MIEUX",
    tags = {"box"},
  },
  --34
  {
    name = "text_skul",
    sprite = "text_skul",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"skull"},
  },
  --35
  {
    name = "skul",
    sprite = "skul",
    slep = true,
    type = "object",
    color = {2, 1},
    layer = 5,
    rotate = true,
    eye = {x=21, y=8, w=4, h=4},
    tags = {"skull"},
    desc = "evillllll",
  },
  --36
  {
    name = "text_laav",
    sprite = "text_laav",
    type = "text",
    texttype = {object = true},
    color = {2, 3},
    layer = 20,
    desc = "very hot. not hotte tho unless u make it",
    tags = {"lava"},
  },
  --37
  {
    name = "laav",
    sprite = "watr",
    type = "object",
    color = {2, 3},
    layer = 1,
    tags = {"lava"},
  },
  --38
  {
    name = "text_keek",
    sprite = "text_keek",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"keke", "chars"},
  },
  --39
  {
    name = "keek",
    sprite = "keek",
    slep = true,
    type = "object",
    color = {2, 2},
    layer = 5,
    rotate = true,
    eye = {x=19, y=7, w=2, h=2},
    tags = {"keke", "chars"},
    desc = "babs bff"
  },
  --38
  {
    name = "text_meem",
    sprite = "text_meem",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"chars"},
  },
  --39
  {
    name = "meem",
    sprite = "meem",
    slep = true,
    type = "object",
    color = {3, 1},
    layer = 5,
    rotate = true,
    eye = {x=18, y=3, w=2, h=2},
    tags = {"chars"},
    desc = "meem is the true philosopher of our time. babs 3ff",
  },
  --40
  {
    name = "text_til",
    sprite = "text_til",
    metasprite = "text_til meta",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"tile"},
  },
  --41
  {
    name = "text_text",
    sprite = "text_txt",
    metasprite = "text_txt meta",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"txt"},
    desc = "TXT: An object class referring to all text objects, or just a specific one if you write e.g. BAB TXT BE GAY.",
  },
  --42
  {
    name = "text_os",
    sprite = "text_os",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"apple", "android", "windows", "linux", "operating system"},
  },
  --43
  {
    name = "os",
    sprite = "os",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 5,
    rotate = "true",
    eye = {x=14, y=8, w=2, h=2},
    tags = {"apple", "android", "windows", "linux", "operating system"},
    desc = "OS: Its sprites changes with the user's Operating System!",
  },
  --44
  {
    name = "text_slep",
    sprite = "text_slep",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"sleep"},
    desc = "SLEP: SLEP units can't move due to being U, WALK, COPKAT or SPOOPed.",
  },
  --45
  {
    name = "l..uv",
    sprite = "luv",
    type = "object",
    color = {4, 2},
    layer = 6,
    tags = {"love"},
    desc = "makes up the very fabric of reality of bab be u"
  },
  --46
  {
    name = "text_l..uv",
    sprite = "text_luv",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"love"},
    desc = "LÜV: To use with letters, you need an umlaut!",
  },
  --47
  {
    name = "frut",
    sprite = "frut",
    type = "object",
    color = {2, 2},
    layer = 3,
    rotate = "true",
    tags = {"fruit", "apple", "plants"},
    desc = "babs favorite snacc. not to be confused with OS appl",
  },
  --48
  {
    name = "text_frut",
    sprite = "text_frut",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"fruit", "apple", "plants"},
  },
  --49
  {
    name = "tre",
    sprite = "tre",
    type = "object",
    color = {5, 2},
    layer = 2,
    rotate = "true",
    tags = {"tree", "plants"},
  },
  --50
  {
    name = "text_tre",
    sprite = "text_tre",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"tree", "plants"},
  },
  --51
  {
    name = "wog",
    sprite = "wog",
    slep = true,
    type = "object",
    color = {2, 4},
    layer = 5,
    rotate = "true",
    eye = {x=16, y=9, w=3, h=3},
    desc = "smol frens who own pointy tridents, play with explosives, and bake good cake. nobody knows how to describe more than one of them",
    tags = {"wug", "chars", "bird"},
  },
  --52
  {
    name = "text_wog",
    sprite = "text_wog",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    desc = "wogs dream is to be a mad scientist and go evil with power using nothing but sheer linguistics. linguists' evil career options may be limited but that wont stop wog from trying their best",
    tags = {"wug", "chars", "bird"},
  },
  --tutorial sprites
  --53
  {
    name = "text_press",
    sprite = "tutorial_press",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    desc = "PRESS: Make PRESS F2 <property> to do something upon pressing F. Only some properties, like :(, will work!"
  },
  --54
  {
    name = "text_f2",
    sprite = "tutorial_f2",
    type = "text",
    texttype = {verb = true, verb_be = true},
    color = {0, 3},
    layer = 20,
    desc = "F2: Used with PRESS.",
  },
  --55
  {
    name = "text_edit",
    sprite = "tutorial_edit",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    desc = "EDIT: Make PRESS F2 EDIT to unlock the level editor!",
    tags = {"text_2edit"},
  },
  --56
  {
    name = "text_play",
    sprite = "tutorial_play",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"text_2play"},
  },
  --57
  {
    name = "text_f1",
    sprite = "tutorial_f1",
    type = "text",
    texttype = {verb = true, verb_be = true},
    color = {0, 3},
    layer = 20,
  },
  -- 58
  {
    name = "text_:(",
    sprite = "text_bad",
    slep = true,
    type = "text",
    texttype = {property = true},
    color = {2, 1},
    layer = 20,
    eye = {x=20, y=6, w=4, h=4},
    tags = {"defeat", "sad", "face", "aw"},
    desc = ":(: At end of turn, destroys any U objects on it.",
  },
  -- 59
  {
    name = "text_walk",
    sprite = "text_walk",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"move"},
    desc = "WALK: Moves in a straight line each turn, bouncing off walls.",
  },
  -- 60
  {
    name = "text_bup",
    sprite = "text_bup",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"toad", "simpleflips", "chars"},
  },
  -- 61
  {
    name = "bup",
    sprite = "bup",
    slep = true,
    type = "object",
    color = {6, 2},
    layer = 5,
    rotate = true,
    eye = {x=23, y=19, w=3, h=3},
    tags = {"toad", "simpleflips", "chars"},
    desc = "BUP: HELLO\nBUP DOES NOT WANT, BUP DOES NOT DREAM\nPLEASE HELP HIM\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  },
  -- 62
  {
    name = "text_boll",
    sprite = "text_boll",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"orb", "ball"},
  },
  -- 63
  {
    name = "boll",
    sprite = "orrb",
    type = "object",
    color = {4, 1},
    layer = 3,
    tags = {"orb", "ball"},
    desc = "hnmm... roun. colecc",
  },
  -- 64
  {
    name = "text_bellt",
    sprite = "text_bellt",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"belt"},
  },
  -- 65
  {
    name = "bellt",
    sprite = "bellt",
    type = "object",
    color = {1, 1},
    layer = 1,
    rotate = true,
    desc = "bells and bellts are both metal so theyre basically the same thing right? dont tell anyone",
    tags = {"belt"},
  },
  -- 66
  {
    name = "text_:o",
    sprite = "text_whoa",
    slep = true,
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    eye = {x=20, y=7, w=3, h=4},
    tags = {"bonus", "woah", "whoa", "face"},
    desc = ":o: If U is on :o, the :o is collected. Bonus!",
  },
  -- 67
  {
    name = "text_up",
    sprite = "text_goup",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
  },
  -- 68
  {
    name = "text_direction",
    sprite = "text_goright",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    rotate = true,
    tags = {"go arrow", "up", "down", "left", "right","go ->","go^"},
    desc = "GO ->: The unit is forced to face the indicated direction.",
  },
  -- 69
  {
    name = "text_left",
    sprite = "text_goleft",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    nice = true,
  },
  -- 70
  {
    name = "text_down",
    sprite = "text_godown",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
  },
  -- 71
  {
    name = "text_behin u",
    sprite = "text_behinu",
    type = "text",
    texttype = {property = true},
    color = {3, 1},
    layer = 20,
    tags = {"swap", "edgy"},
    desc = "BEHIN U: BEHIN U units swap with everything on tiles they move into, and swap with units that move onto their tile, then face their swapee. Nothing personnel, kid.",
  },
  -- 72
  {
    name = "text_w/fren",
    sprite = "text_wfren",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"on", "wfren"},
    desc = "W/ FREN (Infix Condition): True if the unit shares a tile with this object.",
  },
  -- 73
  {
    name = "text_look at",
    sprite = "text_look at",
    type = "text",
    texttype = {cond_infix = true, cond_infix_dir = true, verb = true, verb_unit = true},
    color = {0, 3},
    layer = 20,
    tags = {"follow", "facing", "lookat"},
    desc = "LOOK AT: As an infix condition, true if this object is on the tile in front of the unit. As a verb, makes the unit face this object at end of turn.",
  },
  -- 74
  {
    name = "text_frenles",
    sprite = "text_frenles",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2, 2},
    layer = 20,
    tags = {"lonely", "friendless"},
    desc = "FRENLES (Prefix Condition): True if the unit is alone on its tile.",
  },
  --75
  {
    name = "text_creat",
    sprite = "text_creat",
    type = "text",
    texttype = {verb = true, verb_class = true},
    color = {0, 3},
    layer = 20,
    tags = {"make", "create"},
    desc = "CREAT (Verb): At end of turn, the unit makes this object.",
  },
  --76
  {
    name = "text_snacc",
    sprite = "text_snacc",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    allowconds = true,
    color = {2, 2},
    layer = 20,
    tags = {"eat", "consume"},
    desc = "SNACC (Verb): Units destroy any other unit that they SNACC on contact, like a conditional OUCH.",
  },
  --77
  {
    name = "kirb",
    sprite = "kirb",
    slep = true,
    type = "object",
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=21, y=9, w=2, h=2},
    tags = {"kirby", "chars"},
    desc = "1, 2 oatmeal kirb be be a pincc guy"
  },
  --78
  {
    name = "text_kirb",
    sprite = "text_kirb",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"kirby", "chars"},
  },
  --79
  {
    name = "gunne",
    sprite = "gunne",
    type = "object",
    color = {0, 3},
    layer = 3,
    rotate = true,
    tags = {"weapon"},
  },
  --80
  {
    name = "text_gunne",
    sprite = "text_gunne",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"weapon"},
    desc = "GUNNE: Any object with GOT GUNNE will wield a GUNNE."
  },
  --81
  {
    name = "text_ouch",
    sprite = "text_ouch",
    type = "text",
    texttype = {property = true},
    color = {1, 2},
    layer = 20,
    tags = {"weak"},
    desc = "OUCH: This unit is destroyed if it shares a tile with another object, or if it tries to move/be moved into and can't.",
  },
  -- 82
  {
    name = "tot",
    sprite = "tot",
    slep = true,
    type = "object",
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=18, y=8, w=2, h=2},
    tags = {"anni", "chars", "devs"},
    desc = "the bab equivalent of anni",
  },
  -- 83
  {
    name = "text_tot",
    sprite = "text_tot",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"anni", "chars", "devs"},
  },
  -- 84
  {
    name = "text_qt",
    sprite = "text_qt",
    type = "text",
    texttype = {property = true},
    color = {4, 2},
    layer = 20,
    tags = {"cute","lily"},
    desc = "QT: Makes the unit emit love hearts.",
  },
  -- 85
  {
    name = "o",
    sprite = "o",
    slep = true,
    type = "object",
    texttype = {object = true, letter = true},
    color = {2, 4},
    layer = 5,
    eye = {x=19, y=7, w=2, h=2},
    tags = {"devs", "chars", "thefox", "puyopuyo tetris"},
    desc = "pi pi piiii!!!",
  },
  -- 86
  {
    name = "text_o",
    sprite = "letter_o",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"devs", "chars", "thefox", "puyopuyo tetris"},
  },
  -- 87
  {
    name = "han",
    sprite = "han",
    type = "object",
    color = {0, 3},
    layer = 7,
    rotate = true,
    tags = {"hand", "body part"},
  },
  -- 88
  {
    name = "text_han",
    sprite = "text_han",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"hand", "body part"},
  },
  -- 87
  {
    name = "gras",
    sprite = "gras",
    type = "object",
    color = {5, 1},
    layer = 1,
    desc = "don step on it. or do step on it. ur choice",
    tags = {"grass", "plants"},
  },
  -- 88
  {
    name = "text_gras",
    sprite = "text_gras",
    type = "text",
    texttype = {object = true},
    color = {5, 3},
    layer = 20,
    tags = {"grass", "plants"},
  },
  -- 89
  {
    name = "dayzy",
    sprite = "dayzy",
    type = "object",
    color = {3, 3},
    layer = 4,
    eye = {x=10, y=7, w=3, h=3},
    tags = {"violet", "daisy", "flower", "plants"},
  },
  -- 90
  {
    name = "text_dayzy",
    sprite = "text_dayzy",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"violet", "daisy", "flower", "plants"},
    desc = "dayzy me rollin, they haetin",
  },
  -- 91
  {
    name = "hurcane",
    sprite = "hurcane",
    type = "object",
    color = {3, 1},
    layer = 3,
    tags = {"hurricane","tornado"},
    desc = "woosh swoosh vwoosh aaaa",
    eye = {x=15, y=15, w=3, h=3},
  },
  -- 92
  {
    name = "text_hurcane",
    sprite = "text_hurcane",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"hurricane","tornado"},
  },
  -- 91
  {
    name = "hatt",
    sprite = "hat",
    type = "object",
    color = {3, 1},
    layer = 3,
    tags = {"clothing"},
  },
  -- 92
  {
    name = "text_hatt",
    sprite = "text_hatt",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"clothing"},
	desc = "HATT: Any object with GOT HATT will wear a HATT. (Aesthetic)"
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
    texttype = {verb = true, verb_unit = true},
    allowconds = true,
    color = {0, 3},
    layer = 20,
    tags = {"throw"},
    desc = "YEET (Verb): This unit will force things it yeets in its tile to hurtle across the level in its facing direction (until it hits an object that stops it).",
  },
  --- 95
  {
    name = "text_go",
    sprite = "text_go",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"shift"},
    desc = "GO: This unit will force all other objects in its tile to move in its facing direction.",
  },
  --- 96
  {
    name = "text_icy",
    sprite = "text_icy",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"slip", "patashu"},
    desc = "ICY: Objects on something ICY are forced to move in their facing direction until they either leave the ice or can't move any further.",
  },
  --- 97
  {
    name = "text_xwx",
    sprite = "text_xwx",
    slep = true,
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    eye = {x=19, y=5, w=4, h=5},
    tags = {"crash", "oops", "fucky wucky", "face"},
    desc = "XWX: At end of turn, if U is on XWX, the game crashes.",
  },
  --98
  {
    name = "text_sublvl",
    sprite = "text_sublvl",
    type = "text",
    texttype = {property = true},
    color = {4,1},
    layer = 20,
    tags = {"lvl", "level", "sublevel"},
    desc = "SUBLVL: An object that is sublvl will become enterable. Currently unimplemented.",
  },
  --- 99
  {
    name = "text_come pls",
    sprite = "text_comepls",
    type = "text",
    texttype = {property = true},
    color = {6, 1},
    layer = 20,
    tags = {"pull"},
    desc = "COME PLS: Pulled by movement on adjacent tiles facing away from this unit.",
  },
  --- 100
  {
    name = "text_sidekik",
    sprite = "text_sidekik",
    type = "text",
    texttype = {property = true},
    color ={6, 1},
    layer = 20,
    tags = {"sidekick"},
    desc = "SIDEKIK: If a unit moves perpendicularly away from a SIDEKIK, the SIDEKIK copies that movement.",
  },
  --- 101
  {
    name = "text_arond",
    sprite = "text_arond",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"near", "around"},
    desc = "AROND (Infix Condition): True if the indicated object is on any of the tiles surrounding the unit. (The unit's own tile is not checked.) ORTHO/DIAG AROND will only check the tiles orthogonally or diagonally. GO^ AROND will only check the tile in that direction.",
  },
  --- 102
  {
    name = "chekr",
    sprite = "chekr",
    type = "object",
    color ={3, 2},
    layer = 1,
    tags = {"checker","diamond"},
  },
  --- 103
  {
    name = "text_chekr",
    sprite = "text_chekr",
    type = "text",
    texttype = {object = true},
    color ={3, 2},
    layer = 20,
    tags = {"checker","diamond"},
  },
  --- 104
  {
    name = "text_diag",
    sprite = "text_diag",
    type = "text",
    texttype = {property = true, direction = true},
    color = {3, 2},
    layer = 20,
    tags = {"direction","diagonal"},
    desc = "DIAG: Prevents the unit from moving orthogonally, unless it is also ORTHO.",
  },
  --- 105
  {
    name = "text_go my way",
    sprite = "text_go my wey",
    type = "text",
    texttype = {property = true},
    color ={1, 3},
    layer = 20,
    tags = {"oneway", "go my wey"},
    desc = "GO MY WAY: Prevents movement onto its tile from the tile in front of it and the two tiles 45 degrees to either side.",
  },
  --- 106
  {
    name = "text_ortho",
    sprite = "text_ortho",
    type = "text",
    texttype = {property = true, direction = true},
    color ={3, 2},
    layer = 20,
    tags = {"direction","orthogonal"},
    desc = "ORTHO: Prevents the unit from moving diagonally, unless it is also DIAG.",
  },
  --- 107
  {
    name = "arro",
    sprite = "arro",
    type = "object",
    color ={0, 3},
    layer = 2,
    rotate = true,
    tags = {"arrow"},
    desc = "ARRO: Also acts as a letter.",
  },
  --- 108
  {
    name = "text_arro",
    sprite = "text_arro",
    type = "text",
    texttype = {object = true},
    color ={0, 3},
    layer = 20,
    tags = {"arrow"},
  },
  --- 109
  {
    name = "text_hotte",
    sprite = "text_hotte",
    type = "text",
    texttype = {property = true},
    color = {2, 3},
    layer = 20,
    tags = {"hot"},
    desc = "HOTTE: At end of turn, HOTTE units destroys all units that are FRIDGD on their tile.",
  },
  --- 110
  {
    name = "text_fridgd",
    sprite = "text_fridgd",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"melt"},
    desc = "FRIDGD: At end of turn, HOTTE units destroys all units that are FRIDGD on their tile.",
  },
  --- 111
  {
    name = "text_colld",
    sprite = "text_colld",
    type = "text",
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    tags = {"ice"},
  },
  --- 112
  {
    name = "colld",
    sprite = "colld",
    type = "object",
    color = {1, 4},
    layer = 1,
    desc = "nothin says colld like diagonal lines",
    tags = {"ice"},
  },
  --- 113
  {
    name = "text_goooo",
    sprite = "text_goooo",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"shift"},
    desc = "GOOOO: The instant an object steps on a GOOOO unit, it is forced to move in the GOOOO unit's direction.",
  },
  --- 114
  {
    name = "text_icyyyy",
    sprite = "text_icyyyy",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"slip", "slide", "patashu"},
    desc = "ICYYYY: The instant an object steps on an ICYYYY unit, it is forced to move again.",
  },
  -- 115
  {
    name = "text_protecc",
    sprite = "text_protecc",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"safe", "protect"},
    desc = "PROTECC: Cannot be destroyed (but can be converted).",
  },
  -- 116
  {
    name = "text_flye",
    sprite = "text_flye",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"float"},
    desc = "FLYE: A FLYE unit doesn't interact with other objects on its tile, and can ignore the collision of other objects, unless that other object has the same amount of FLYE as the unit. FLYE stacks with itself!",
  },
  --- 117
  {
    name = "text_piler",
    sprite = "text_piler",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"pillar"},
  },
  --- 118
  {
    name = "piler",
    sprite = "piler",
    type = "object",
    color = {0, 1},
    layer = 3,
     desc = "secretly made from several pairs of pliers sacrificed to keepin babs out (or in)",
    tags = {"pillar"},
  },
  -- 119
  {
    name = "text_n't",
    sprite = "text_nt",
    type = "text",
    texttype = {["not"] = true}, -- not is a reserved word,
    color = {2, 2},
    layer = 20,
    tags = {"not", "nt"},
    desc = "N'T: A suffix that negates the meaning of a verb, condition or object class. X txtn't will refer to all txt except that one.",
  },
  -- 120
  {
    name = "text_haet skye",
    sprite = "text_haet_skye",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"fall", "gravity"},
    desc = "HAET SKYE: After movement, this unit falls DOWN as far as it can.",
  },
  -- 121
  {
    name = "clowd",
    sprite = "clowd",
    type = "object",
    color = {0, 3},
    layer = 8,
    tags = {"cloud"},
  },
  -- 122
  {
    name = "text_clowd",
    sprite = "text_clowd",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"cloud"},
  },
  -- 123
  {
    name = "text_moar",
    sprite = "text_moar",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"more"},
    desc = "MOAR: At end of turn, this unit replicates to all free tiles that are orthogonally adjacent. MOAR stacks with itself!",
  },
  -- 124
  {
    name = "text_visit fren",
    sprite = "text_visitfren",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"warp", "teleport", "portal"},
    desc = "VISIT FREN: At end of turn, all other objects are sent to the next VISIT FREN unit with the same name in reading order (left to right, line by line, wrapping around). Higher levels of VISIT FREN will cause the target to be 1 backward, 2 forward, 2 backward, etc.",
  },
  -- 125
  {
    name = "infloop",
    sprite = "text_infloop",
    type = "object",
    color = {0, 3},
    layer = 20,
    tags = {"infinity", "infinite", "loop"},
  },
  -- 126
  {
    name = "text_wait...",
    sprite = "text_wait",
    type = "text",
    texttype = {cond_prefix = true},
    color = {0, 3},
    layer = 20,
    tags = {"idle"},
    desc = "WAIT... (Prefix Condition): True if the player waited last input. (This does not include clicks.)",
  },
  -- 127
  {
    name = "text_sans",
    sprite = "text_sans",
    sprite_transforms = {
      property = "text_sans_property"
    },
    type = "text",
    texttype = {cond_infix = true, property = true},
    color = {1, 4},
    layer = 20,
    tags = {"without", "w/o"},
    desc = "SANS (Infix Condition): True if none of the indicated object exist in the level.",
  },
  -- 128
  {
    name = "text_spoop",
    sprite = "text_spoop",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {2, 2},
    layer = 20,
    tags = {"fear", "spook"},
    desc = "SPOOP (Verb): A SPOOPY unit forces all objects it SPOOPS on adjacent tiles to move away!",
  },
  -- 129
  {
    name = "text_stalk",
    sprite = "text_stalk",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {5, 2},
    layer = 20,
    tags = {"follow", "find", "cg5"},
    desc = "STALK (Verb): If X stalks Y, X becomes an intelligent AI determined to get to Y. If it's also STUBBN, it'll try to track through walls if it can't reach its target. (actually that's not implemented yet)"
  },
  -- 130
  {
    name = "text_stelth",
    sprite = "text_stelth",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"stealth", "hide"},
    desc = "STELTH: A STELTHy unit doesn't draw. STELTHy text won't appear in the rules list (once someone gets around to writing that...)",
  },
  -- 131
  {
    name = "pata",
    sprite = "pata",
    slep = true,
    type = "object",
    color = {3, 3},
    layer = 5,
    rotate = true,
    eye = {x=17, y=4, w=1, h=2},
    tags = {"devs", "chars", "patashu"},
  },
  -- 132
  {
    name = "text_pata",
    sprite = "text_pata",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"devs", "chars", "patashu"},
  },
  -- 133
  {
    name = "larry",
    sprite = "larry",
    slep = true,
    type = "object",
    color = {2, 4},
    layer = 5,
    rotate = true,
    eye = {x=18, y=4, w=2, h=2},
    tags = {"devs", "chars", "vitellary"},
    desc = "larry be haetflor",
  },
  -- 134
  {
    name = "text_larry",
    sprite = "text_larry",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"devs", "chars", "vitellary"},
  },
  -- 135
  {
    name = "lila",
    sprite = "lila",
    slep = true,
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=19, y=8, w=2, h=2},
    tags = {"devs", "chars", "lily", "lili"},
    desc = "lila, represents the creator of bab be u herself! all hail lila",
  },
  -- 136
  {
    name = "text_lila",
    sprite = "text_lila",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"devs", "chars", "lily", "lili"},
  },
  -- 137
  {
    name = "text_every1",
    sprite = "text_every1",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"all", "everyone", "every1"},
    desc = "EVERY1: Every object type in the level, aside from special objects like TXT, NO1, LVL, BORDR, and MOUS.",
  },
  -- 138
  {
    name = "text_tall",
    sprite = "text_tall",
    type = "text",
    texttype = {property = true},
    color = {0, 1},
    layer = 20,
    desc = "TALL: Considered to be every FLYE amount at once.",
  },
  --- 139
  {
    name = "text_liek",
    sprite = "text_liek",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    allowconds = true,
    color = {5, 3},
    layer = 20,
    tags = {"bounded", "likes"},
    desc = "LIEK (Verb): If a unit LIEKs objects, it is picky, and cannot step onto a tile unless it has at least one object it LIEKs. If X LIEK GO^, X will fall in that direction.",
  },
  -- 140
  {
    name = "text_zip",
    sprite = "text_zip",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    desc = "ZIP: At end of turn, if it is on a tile it couldn't enter or shares a tile with another object of its name, it finds the nearest free tile (preferring backwards directions) and ejects to it.",
  },
  -- 141
  {
    name = "text_shy",
    sprite = "text_shy",
    type = "text",
    texttype = {property = true},
    color = {6, 2},
    layer = 20,
    tags = {"patashu"},
    desc = "SHY...: Can't initiate or continue a push, pull or sidekik movement."
  },
  -- 142
  {
    name = "text_folo wal",
    sprite = "text_folo_wal",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"follow wall"},
    desc = "FOLO WAL: At end of turn, faces the first direction that it could enter and that doesn't have another unit of its name: right, forward, left, backward. When combined with WALK, causes the unit to follow the right wall.",
  },
  -- 143
  {
    name = "text_turn cornr",
    sprite = "text_turn_cornr",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"turn corner"},
    desc = "TURN CORNR: At end of turn, faces the first direction that it could enter and that doesn't have another unit of its name: forward, right, left, backward. When combined with WALK, causes the unit to bounce off walls at 90 degree angles.",
  },
  -- 144
  {
    name = "petnygrame",
    sprite = "petnygrame",
    color = {2, 1},
    layer = 5,
    tags = {"pentagram", "edgy"},
  },
  -- 145
  {
    name = "text_petnygrame",
    sprite = "text_petnygrame",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"pentagram", "edgy"},
  },
  -- 146
  {
    name = "katany",
    sprite = "katany",
    color = {0, 1},
    layer = 5,
    rotate = true,
    tags = {"weapon", "japan", "asia", "edgy"},
  },
  -- 147
  {
    name = "text_katany",
    sprite = "text_katany",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"weapon", "japan", "asia", "edgy"},
	desc = "KATANY: Any object with GOT KATANY will have a KATANY."
  },
  -- 148
  {
    name = "scarr",
    sprite = "scarr",
    color = {2, 1},
    layer = 5,
    tags = {"scar", "edgy"},
  },
  -- 149
  {
    name = "text_scarr",
    sprite = "text_scarr",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"scar", "edgy"},
  },
  -- 150
  {
    name = "text_no1",
    sprite = "text_no1",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"none","empty", "no one"},
    desc = "NO1: Refers to tiles with nothing in them. Rotation status is kept on the tile. Cannot be colored."
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
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"level"},
    desc = "LVL: Refers to the level you're in, as well as any enterable levels in this level. (Middle-click it to edit.)"
  },
  -- 153
  {
    name = "text_nxt",
    sprite = "text_nxt",
    type = "text",
    texttype = {property = true},
    color = {0,3},
    layer = 20,
    tags = {"next"},
    desc = "NXT: If U is on NXT, go to the next level (specified in object settings)."
  },
  -- 154
  {
    name = "pepis",
    sprite = {"pepis","pepis_red","pepis_blue"},
    color = {{0,3},{2,2},{1,2}},
    colored = {false,true,true},
    layer = 5,
    tags = {"bepis", "pepsi"},
    desc = "pepis: tastes like tar and mud",
  },
  -- 155
  {
    name = "text_pepis",
    sprite = "text_pepis",
    type = "text",
    texttype = {object = true},
    color = {3, 2},
    layer = 20,
    tags = {"bepis", "pepsi"},
  },
  -- 156
  {
    name = "text_copkat",
    sprite = "text_copkat",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {0, 3},
    layer = 20,
    tags = {"copycat", "lily"},
    desc = "COPKAT (Verb): COPKAT units copy the successful movements of the indicated object, no matter how far away."
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
    tags = {"clock", "time"},
    desc = "keek look at'd the clok. 'oh no! im late for school!' keek shouted and raced out of bed."
  },
  -- 158
  {
    name = "text_clok",
    sprite = "text_clok",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"clock", "time"},
  },
  -- 159
  {
    name = "text_try again",
    sprite = "text_try again",
    type = "text",
    texttype = {property = true},
    color = {3, 3},
    layer = 20,
    tags = {"retry", "time", "reset", "lily"},
    desc = "TRY AGAIN: When U is on TRY AGAIN, the level is undone back to the starting state, except for NO UNDO objects. TRY AGAIN can be undone!"
  },
  -- 160
  {
    name = "text_no undo",
    sprite = "text_no undo",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"persist", "time", "lily"},
    desc = "NO UNDO: NO UNDO units aren't affected by undoing manually. LVL BE NO UNDO prevents undo inputs entirely.",
  },
  -- 161
  {
    name = "zsoob",
    sprite = "zsoob",
    slep = true,
    type = "object",
    color = {4,1},
    layer = 5,
    rotate = true,
    eye = {x=17, y=9, w=2, h=2},
    tags = {"devs","chars","szoob"},
    desc = "pinc keke",
  },
  -- 162
  {
    name = "text_zsoob",
    sprite = "text_zsoob",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"devs","chars","szoob"},
  },
  -- 163
  {
    name = "text_mayb",
    sprite = "text_mayb",
    type = "text",
    texttype = {cond_prefix = true},
    color = {0, 3},
    layer = 20,
    rotate = true,
    tags = {"/", "maybe", "random", "rng", "patashu"},
    desc = "? (MAYBE) (Prefix Condition): Has a chance of being true, independent for each MAYBE, affected unit and turn. The number on top indicates the % chance of being true. Compatible with N'T.",
  },
  -- 164
  {
    name = "text_stubbn",
    sprite = "text_stubbn",
    type = "text",
    texttype = {property = true},
    color = {6, 1},
    layer = 20,
    tags = {"stubborn","patashu"},
    desc = "STUBBN: STUBBN units ignore the special properties of WALK movers (bouncing off of walls, and declining to move if it would die due to being OUCH) and also makes attempted diagonal movement slide along walls. Stacks with itself - the more STUBBN, the more additional angles it will try, up to 180 degrees at 5 stacks! (2 stacks allows for 45 degree movement orthogonally.)",
  },
  -- 165
  {
    name = "text_seen by",
    sprite = "text_seen by",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"seenby", "looked at", "in front"},
    desc = "SEEN BY (Infix Condition): True if an indicated object is looking at this unit from an adjacent tile.",
  },
  -- 166
  {
    name = "steev",
    sprite = "steev",
    slep = true,
    type = "object",
    color = {2,3},
    layer = 5,
    rotate = true,
    eye = {x=20, y=13, w=2, h=2},
    tags = {"chars", "5 step steve", "cat"},
    desc = "can only moov 5 steps b4 dyin nya",
  },
  -- 167
  {
    name = "text_steev",
    sprite = "text_steev",
    type = "text",
    texttype = {object = true},
    color = {2,3},
    layer = 20,
    tags = {"chars", "5 step steve", "cat"},
  },
  -- 168
  {
    name = "text_go arnd",
    sprite = "text_go arnd",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"wrap around", "go around", "cg5"},
    desc = "GO ARND: GO ARND units wrap around the level, as though it were a torus. BORDR objects are used as the level border, and the wraparound doesn't go through BORDRs. Diagonal GO ARNDs on corners of non-square levels might not work as expected, as it simply traces backward until hitting a BORDR.",
  },
  -- 169
  {
    name = "text_poor toll",
    sprite = "text_poor_toll",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"portal","cg5"},
    desc = "POOR TOLL: If a unit would enter a POOR TOLL unit, it instead leaves the next POOR TOLL unit of the same name in reading order (left to right, line by line, wrapping around) out the corresponding same side. Does not stack.",
  },
  -- 170
  {
    name = "splittr",
    sprite = "splittr",
    type = "object",
    color = {0, 3},
    layer = 2,
    rotate = true,
    tags = {"splitter", "5 step"},
    eye = {x=22,y=12,w=3,h=5},
    desc = "specifically made to be used with SPLIT because it looks horrible otherwise (but other tiles like CHAIN can also work)."
  },
  -- 171
  {
    name = "text_splittr",
    sprite = "text_splittr",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"splitter", "5 step"},
  },
  -- 172
  {
    name = "text_split",
    sprite = "text_split",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"splitter", "5 step"},
    desc = "SPLIT: Objects on a SPLITer are split into two copies on adjacent tiles.",
  },
  -- 173
  {
    name = "text_cilindr",
    sprite = "text_cilindr",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    rotate = true,
    tags = {"cyllinder","space", "wrap"},
    desc = "CILINDR: CILINDR units wrap around the level, as though it were a cylinder with the indicated orientation.",
  },
  -- 174
  {
    name = "text_mobyus",
    sprite = "text_mobyus",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    rotate = true,
    tags = {"mobius","space", "wrap"},
    desc = "MOBYUS: MOBYUS units wrap around the level, as though it were a mobius strip with the indicated orientation.",
  },
  -- 175
  {
    name = "text_munwalk",
    sprite = "text_munwalk",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"moonwalk","patashu"},
    desc = "MUNWALK: MUNWALK units move 180 degrees opposite of their facing direction. Stacks will cancel each other out.",
  },
  -- 176
  {
    name = "text_mirr arnd",
    sprite = "text_mirr arnd",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"mirror around","cg5", "space", "wrap"},
    desc = "MIRR ARND: MIRR ARND units wrap around the level, as though it were a projective plane.",
  },
  -- 177
  {
    name = "text_sidestep",
    sprite = "text_sidestep",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"patashu", "drunk"},
    desc = "SIDESTEP: SIDESTEP units move 90 degrees clockwise off of their facing direction. Stacks!",
  },
  -- 178
  {
    name = "text_diagstep",
    sprite = "text_diagstep",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"patashu", "drunker"},
    desc = "DIAGSTEP: DIAGSTEP units move 45 degrees clockwise off of their facing direction. Stacks!",
  },
  -- 179
  {
    name = "text_hopovr",
    sprite = "text_hopovr",
    type = "text",
    texttype = {property = true},
    color = {5, 2},
    layer = 20,
    tags = {"patashu", "skip"},
    desc = "HOPOVR: HOPOVR units move two tiles ahead, skipping the intermediate tile. Stacks!",
  },
  -- 180
  {
    name = "text_undo",
    sprite = "text_undo",
    type = "text",
    texttype = {property = true},
    color = {6, 1},
    layer = 20,
    tags = {"time", "back"},
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
    eye = {x=14, y=15, w=2, h=5},
    tags = {"chars"},
    desc = "he's upsidedown b/c he lives on a Boy's surface"
  },
  -- 182
  {
    name = "text_boy",
    sprite = "text_boy",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"chars"},
  },
  -- 183
  {
    name = "text_spin",
    sprite = "text_spin",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    rotate = true,
    tags = {"rotate","lily"},
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
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    desc = "SLIPPERS: An object that GOT SLIPPERS will ignore ICY and ICYYYYY objects (and wear SLIPPERS)."
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
    slep = true,
    type = "object",
    color = {4, 2},
    layer = 5,
    rotate = true,
    eye = {x=26, y=10, w=2, h=4},
    desc = "its not spooky, its a fren.",
    tags = {"chars"},
  },
  -- 188
  {
    name = "text_ghost fren",
    sprite = "text_ghost fren",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    desc = "this text is very spooky tho",
    tags = {"chars"},
  },
  -- 189
  {
    name = "robobot",
    sprite = "robobot",
    slep = true,
    type = "object",
    color = {6, 1},
    layer = 5,
    rotate = true,
    eye = {x=17, y=7, w=2, h=4},
    desc = "the super scan mouth lazers that copy abilities are missing because they forgot to design a mouth",
    tags = {"robot", "chars"},
  },
  -- 190
  {
    name = "text_robobot",
    sprite = "text_robobot",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"robot", "chars"},
  },
  -- 191
  {
    name = "lvl",
    sprite = "lvl",
    type = "object",
    color = {0, 3},
    layer = 18,
    rotate = true,
    tags = {"level", "path"},
    desc = "its a lavel"
  },
  -- 192
  {
    name = "selctr",
    sprite = "selctr",
    type = "object",
    color = {3, 3},
    layer = 20,
    tags = {"cursor", "selector"},
    desc = "used to select levis"
  },
  -- 193
  {
    name = "text_selctr",
    sprite = "text_selctr",
    type = "text",
    texttype = {object = true},
    color = {2, 3},
    layer = 20,
    tags = {"cursor", "selector"},
  },
  -- 194
  {
    name = "lin",
    sprite = "lin",
    type = "object",
    color = {0, 3},
    layer = 17,
    tags = {"line", "path"},
    desc = "used to connect lovils"
  },
  -- 195
  {
    name = "text_lin",
    sprite = "text_lin",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"line", "path"},
  },
  -- 196
  {
    name = "text_moov",
    sprite = "text_moov",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {1,3},
    layer = 20,
    tags = {"shift"},
    desc = "MOOV (Verb): A verbified GO AWAY PLS/GO. x MOOV y means that x can push and shift y. y is not treated as solid if unable to be pushed. MOOV GO^ will make the unit move one unit in that direction per turn.",
  },
  --- 197
  {
    name = "text_haet",
    sprite = "text_haet",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    allowconds = true,
    color = {2, 3},
    layer = 20,
    tags = {"patashu", "hate", "hates", "collide"},
    desc = "HAET (Verb): A unit cannot stop onto a tile that has something it HAETs (treating it like NOGO). (x HAET LVL makes x unable to move.) X HAET GO^ makes the object fall in the direction opposite that.",
  },
  -- 198
  {
    name = "text_brite",
    sprite = "text_brite",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    tags = {"bright", "power"},
    desc = "BRITE: A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing OPAQUE is in the way.",
  },
  -- 199
  {
    name = "text_lit",
    sprite = "text_lit",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2, 4},
    layer = 20,
    tags = {"powered"},
    desc = "LIT (Prefix Condition): A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing OPAQUE is in the way.",
  },
  -- 200
  {
    name = "text_opaque",
    sprite = "text_opaque",
    type = "text",
    texttype = {property = true},
    color = {0, 1},
    layer = 20,
    desc = "OPAQUE: A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing OPAQUE is in the way.",
  },
  -- 201
  {
    name = "text_no turn",
    sprite = "text_no turn",
    type = "text",
    texttype = {property = true},
    color = {2, 3},
    layer = 20,
    tags = {"strafe"},
    desc = "NO TURN: A NO TURN unit's direction can't change (unless re-oriented by non-euclidean level geometry, i.e. POOR TOLL).",
  },
  -- 202
  {
    name = "text_an",
    sprite = "text_an",
    type = "text",
    texttype = {cond_prefix = true},
    color = {0, 3},
    layer = 20,
    tags = {"rng", "random"},
    desc = "AN (Prefix Condition): True for a single arbitrary unit per turn and condition. To get multiple results in one tile, rotate the ANs in different directions.",
  },
  -- 203
  {
    name = "text_wurd",
    sprite = "text_wurd",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"word"},
    desc = "WURD: A WURD unit forms rules as though it was its respective text. TXT BEN'T WURD makes that text not parse.",
  },
  -- 204
  {
    name = "firbolt",
    sprite = "firbolt",
    type = "object",
    color = {6, 2},
    layer = 5,
    rotate = true,
    tags = {"firebolt"},
    desc = "i cast FIRBOLT at the NO1!",
  },
  -- 205
  {
    name = "text_firbolt",
    sprite = "text_firbolt",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"firebolt"},
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
    tags = {"icebolt"},
  },
  -- 207
  {
    name = "text_icbolt",
    sprite = "text_icbolt",
    type = "text",
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    tags = {"icebolt"},
  },
  -- 206
  {
    name = "hedg",
    sprite = "hedg",
    type = "object",
    color = {5, 1},
    layer = 2,
    tags = {"hedge", "plants"},
    desc = "im hedg the hedg heg",
  },
  -- 207
  {
    name = "text_hedg",
    sprite = "text_hedg",
    type = "text",
    texttype = {object = true},
    color = {5, 1},
    layer = 20,
    tags = {"hedge", "plants"},
  },
  -- 208
  {
    name = "fenss",
    sprite = "fenss",
    type = "object",
    color = {6, 2},
    layer = 1,
    tags = {"fence"},
    desc = "keeps babs out!!",
  },
  -- 209
  {
    name = "text_fenss",
    sprite = "text_fenss",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"fence"},
  },
  -- 210
  {
    name = "metl",
    sprite = "metl",
    type = "object",
    color = {0, 2},
    layer = 1,
    tags = {"metal"},
    desc = "impervious metl...",
  },
  -- 211
  {
    name = "text_metl",
    sprite = "text_metl",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"metal"},
  },
  -- 210
  {
    name = "sparkl",
    sprite = "sparkl",
    type = "object",
    color = {2, 4},
    layer = 10,
    tags = {"sparkle", "dust"},
    desc = "as brite as a star... but also as hotte as one!!",
  },
  -- 211
  {
    name = "text_sparkl",
    sprite = "text_sparkl",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"sparkle", "dust"},
  },
  -- 212
  {
    name = "spik",
    sprite = "spik",
    type = "object",
    color = {0, 2},
    layer = 10,
    rotate = true,
    tags = {"spike"},
    desc = "finally, i can make my i wanna be the bab fangame in bab be u",
  },
  -- 213
  {
    name = "text_spik",
    sprite = "text_spik",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"spike"},
  },
  -- 214
  {
    name = "spiky",
    sprite = "spiky",
    type = "object",
    color = {0, 2},
    layer = 10,
    rotate = true,
    tags = {"spike"},
    desc = "ouch!! many spik at once.",
  },
  -- 215
  {
    name = "text_spiky",
    sprite = "text_spiky",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"spike"},
  },
  -- 216
  {
    name = "bordr",
    sprite = "bordr",
    type = "object",
    color = {1, 0},
    layer = 1,
    tags = {"border"},
    desc = "BORDR: OOB you can place manually. NOGO, TALL and BORDR by default."
  },
  -- 217
  {
    name = "text_bordr",
    sprite = "text_bordr",
    type = "text",
    texttype = {object = true},
    color = {2, 0},
    layer = 20,
    tags = {"border"},
  },
  -- 218
  {
    name = "text_loop",
    sprite = "text_infloop",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"infloop", "infinity", "infinite loop"},
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
    rotate = true,
    tags = {"platform"},
  },
  -- 220
  {
    name = "text_platfor",
    sprite = "text_platfor",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"platform"},
  },
  -- 221
  {
    name = "jail",
    sprite = "jail",
    type = "object",
    color = {0, 2},
    layer = 21,
    desc = "BAB W/FREN JAIL HAET LVL. now bab's in jail :(",
  },
  -- 222
  {
    name = "text_jail",
    sprite = "text_jail",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
  },
  -- 223
  {
    name = "text_haet flor",
    sprite = "text_haetflor",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"vall", "gravity"},
    desc = "HAET FLOR: After movement, this unit falls UP as far as it can.",
  },
  -- 224
  {
    name = "this",
    sprite = "this",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "THIS: Text that refers to itself. Each THIS is independant. THIS TXT refers to all THISs."
  },
  -- 225
  {
    name = "text_grun",
    sprite = "text_grun_cond",
    sprite_transforms = {
      property = "text_grun"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {5, 2},
    layer = 20,
    tags = {"colors", "colours", "green"},
    desc = "GRUN: Causes the unit to appear green. Persistent and can be used as a prefix condition."
  },
  -- 226
  {
    name = "text_yello",
    sprite = "text_yello_cond",
    sprite_transforms = {
      property = "text_yello"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {2, 4},
    layer = 20,
    tags = {"colors", "colours", "yellow"},
    desc = "YELLO: Causes the unit to appear yellow. Persistent and can be used as a prefix condition. Reed + Grun."
  },
  -- 227
  {
    name = "text_purp",
    sprite = "text_purp_cond",
    sprite_transforms = {
      property = "text_purp"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {3, 1},
    layer = 20,
    tags = {"colors", "colours", "purple"},
    desc = "PURP: Causes the unit to appear purple. Persistent and can be used as a prefix condition."
  },
  -- 228
  {
    name = "text_orang",
    sprite = "text_orang_cond",
    sprite_transforms = {
      property = "text_orang"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {2, 3},
    layer = 20,
    tags = {"colors", "colours", "orange"},
    desc = "ORANG: Causes the unit to appear orange. Persistent and can be used as a prefix condition."
  },
  -- 229
  {
    name = "text_cyeann",
    sprite = "text_cyeann_cond",
    sprite_transforms = {
      property = "text_cyeann"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {1, 4},
    layer = 20,
    tags = {"colors", "colours", "cyan"},
    desc = "CYEANN: Causes the unit to appear cyan. Persistent and can be used as a prefix condition."
  },
  -- 230
  {
    name = "text_whit",
    sprite = "text_whit_cond",
    sprite_transforms = {
      property = "text_whit"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {0, 3},
    layer = 20,
    tags = {"colors", "colours", "white"},
    desc = "WHIT: Causes the unit to appear white. Persistent and can be used as a prefix condition. Bleu + Yello, Reed + Cyeann, Grun + Purp."
  },
  -- 231
  {
    name = "text_blacc",
    sprite = "text_blacc_cond",
    sprite_transforms = {
      property = "text_blacc"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {0, 0},
    layer = 20,
    tags = {"colors", "colours", "black"},
    desc = "BLACC: Causes the unit to appear black. Persistent and can be used as a prefix condition."
  },
  -- 232
  {
    name = "text_rave",
    sprite = "text_rave",
    type = "text",
    texttype = {property = true},
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
    tags = {"portal"},
    desc = "the real poor toll"
  },
  -- 234
  {
    name = "text_hol",
    sprite = "text_hol",
    type = "text",
    texttype = {object = true},
    color = {3, 2},
    layer = 20,
    tags = {"portal"},
  },
  -- 235
  {
    name = "text_corekt",
    sprite = "text_corekt",
    type = "text",
    texttype = {cond_prefix = true},
    color = {5,2},
    layer = 20,
    tags = {"correct", "cg5"},
    desc = "COREKT (Prefix Condition): True if the unit is in an active rule.",
  },
  -- 236
  {
    name = "text_rong",
    sprite = "text_rong",
    sprite_transforms = {
      property = "text_rong_prop"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true},
    color = {2,2},
    layer = 20,
    tags = {"wrong", "false", "cg5"},
    desc = "RONG: As a prefix, true if the unit is in a negated rule (via rong, n't, or notranform). As a property, if a rule has a rong unit in it it'll be negated.",
  },
  -- 237
  {
    name = "text_...",
    sprite = "text_...",
    type = "text",
    texttype = {ellipsis = true},
    color = {0, 3},
    layer = 20,
    tags = {"ellipsis", "dotdotdot", "period"},
    desc = "... (ELLIPSIS): Extends rules. BAB ... BE ... ... U is the same as BAB BE U.",
  },
  -- 238
  {
	name = "text_u too",
	sprite = "text_utoo",
	type = "text",
	texttype = {property = true},
	color = {4,1},
  layer = 20,
  tags = {"you2", "p2", "u2"},
	desc = "player 2 has joined the game",
  },
  -- 239
  {
	name = "text_u tres",
	sprite = "text_utres",
	type = "text",
	texttype = {property = true},
	color = {4,1},
  layer = 20,
  tags = {"you3", "p3", "u3"},
	desc = "and player 3",
  },
  -- 240
  {
    name = "text_za warudo",
    sprite = "text_zawarudo",
    type = "text",
    texttype = {property = true},
    color = {2,4},
    layer = 20,
    tags = {"timeless", "the world", "dio", "lily"},
    desc = "ZA WARUDO: Can stop time and move without anything else moving. Faster than rule parsing itself! After forming the rule, press E (hourglass on mobile) to toggle. While stopped, a non-zawarudo object that would move at infinite speed will move one space per turn.",
  },
	-- 241
  {
    name = "text_babn't",
    sprite = {"text_bab meta", "n't"},
    color = {{4, 1}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {object = true},
    layer = 20,
		desc = "BAB N'T: The same as having these two text tiles in a row."
  },
	-- 242
  {
    name = "text_ben't",
    sprite = {"text_be n't", "n't (be)"},
    color = {{0, 3}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {verb = true, verb_be = true},
    layer = 20,
    tags = {"isn't", "is not", "verb"},
		desc = "BE N'T (Verb): The same as having these two text tiles in a row."
  },
	-- 243
   {
    name = "text_rocn't",
    sprite = {"text_roc meta", "n't"},
    color = {{6, 1}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {object = true},
    layer = 20,
		desc = "ROC N'T: The same as having these two text tiles in a row."
  },
	-- 243
   {
    name = "text_waln't",
    sprite = {"text_wal meta", "n't"},
    color = {{0, 1}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {object = true},
    layer = 20,
		desc = "WAL N'T: The same as having these two text tiles in a row."
  },
  -- 244
  {
    name = "letter_a",
    sprite = "letter_a",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 245
  {
    name = "letter_b",
    sprite = "letter_b",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 246
  {
    name = "letter_c",
    sprite = "letter_c",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 247
  {
    name = "letter_d",
    sprite = "letter_d",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 248
  {
    name = "letter_e",
    sprite = "letter_e",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 249
  {
    name = "letter_f",
    sprite = "letter_f",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "press F to pay respects",
  },
  -- 250
  {
    name = "letter_g",
    sprite = "letter_g",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 251
  {
    name = "letter_h",
    sprite = "letter_h",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 252
  {
    name = "letter_j",
    sprite = "letter_j",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "This is used in JAIL and JILL. Discrimination against J!"
  },
  -- 253
  {
    name = "letter_k",
    sprite = "letter_k",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 254
  {
    name = "letter_l",
    sprite = "letter_l",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 255
  {
    name = "letter_m",
    sprite = "letter_m",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 256
  {
    name = "letter_n",
    sprite = "letter_n",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 257
  {
    name = "letter_p",
    sprite = "letter_p",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 258
  {
    name = "letter_q",
    sprite = "letter_q",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 259
  {
    name = "letter_r",
    sprite = "letter_r",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 260
  {
    name = "letter_s",
    sprite = "letter_s",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 261
  {
    name = "letter_t",
    sprite = "letter_t",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 262
  {
    name = "letter_u",
    sprite = "letter_u",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 263
  {
    name = "letter_v",
    sprite = "letter_v",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 264
  {
    name = "letter_w",
    sprite = "letter_w",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 265
  {
    name = "letter_x",
    sprite = "letter_x",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 266
  {
    name = "letter_y",
    sprite = "letter_y",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 267
  {
    name = "letter_.",
    sprite = "letter_period",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"dot", "fullstop", "period"},
    desc = "You can make \"...\" with this!"
  },
  -- 268
  {
    name = "letter_colon",
    sprite = "letter_colon",
    type = "text",
    texttype = {letter = true},
    rotate = true,
    color = {0,3},
    layer = 20,
    tags = {";", "umlaut", "diaeresis"},
    desc = ":: Can also be an umlaut, or '..', if rotated in that way.",
  },
  -- 269
  {
    name = "letter_parenthesis",
    sprite = "letter_paranthesis",
    type = "text",
    texttype = {letter = true, parenthesis = true},
    rotate = true,
    color = {0,3},
    layer = 20,
    tags = {"9", "0", "brackets"},
    desc = "Used for :( and :). Rotation matters!"
  },
  -- 270
  {
    name = "letter_'",
    sprite = "letter_apostrophe",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for n't and \"."
  },
  -- 271
  {
    name = "letter_go",
    sprite = "letter_go",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "used in a whole lot of words",
  },
  -- 272
  {
    name = "letter_come",
    sprite = "letter_come",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used exclusively for COME PLS.",
  },
  -- 273
  {
    name = "letter_pls",
    sprite = "letter_pls",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for GO AWAY PLS and COME PLS.",
  },
  -- 274
  {
    name = "letter_away",
    sprite = "letter_away",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for GO AWAY PLS and LOOK AWAY.",
  },
  -- 275
  {
    name = "letter_my",
    sprite = "letter_my",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used exclusively for GO MY WAY.",
  },
  -- 276
  {
    name = "letter_no",
    sprite = "letter_no",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for NO GO and NO1.",
  },
  -- 277
  {
    name = "letter_way",
    sprite = "letter_way",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"wey"},
  },
  -- 278
  {
    name = "text_''",
    sprite = "text_ditto",
    type = "text",
    texttype = {ditto = true},
    color = {0,3},
    layer = 20,
    tags = {"ditto", "quotation marks"},
    desc = "DITTO: Acts like the text above it. \" TXT will refer to the ditto itself, not the text above it.",
  },
  -- 279
  {
    name = "text_meta",
    sprite = "text_meta",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"notnat"},
    desc = "META: BE META causes that object to be turned into its corresponding metatext. BEN'T META does the opposite and goes down one meta layer (disappearing if that is impossible).",
  },
  -- 280
  {
    name = "ui_1",
    sprite = "ui_1",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down left.",
  },
  -- 281
  {
    name = "ui_2",
    sprite = "ui_2",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down.",
  },
  -- 282
  {
    name = "ui_3",
    sprite = "ui_3",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down right.",
  },
  -- 283
  {
    name = "ui_4",
    sprite = "ui_4",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Left.",
  },
  -- 284
  {
    name = "ui_6",
    sprite = "ui_6",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Right.",
  },
  -- 285
  {
    name = "ui_7",
    sprite = "ui_7",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up left.",
  },
  -- 286
  {
    name = "ui_8",
    sprite = "ui_8",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up.",
  },
  -- 287
  {
    name = "ui_9",
    sprite = "ui_9",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up right.",
  },
  -- 288
  {
    name = "ui_w",
    sprite = "ui_w",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Up.",
  },
  -- 289
  {
    name = "ui_a",
    sprite = "ui_a",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Left.",
  },
  -- 290
  {
    name = "ui_s",
    sprite = "ui_s",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Down.",
  },
  -- 291
  {
    name = "ui_d",
    sprite = "ui_d",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Right.",
  },
  -- 292
  {
    name = "ui_arrow",
    sprite = "ui_right",
    type = "object",
    rotate = true,
    color = {0,3},
    layer = 20,
    tags = {"dpad", "d-pad", "directional pad", "arrow keys"},
    desc = "U TOO controls. Rotatable!",
  },
  -- 293
  {
    name = "ui_i",
    sprite = "ui_i",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up.",
  },
  -- 294
  {
    name = "ui_j",
    sprite = "ui_j",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Left.",
  },
  -- 295
  {
    name = "ui_k",
    sprite = "ui_k",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down.",
  },
  -- 296
  {
    name = "ui_l",
    sprite = "ui_l",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Right.",
  },
  -- 297
  {
    name = "ui_e",
    sprite = "ui_e",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The ZA WARUDO button.",
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
    texttype = {object = true, group = true},
    color = {3, 3},
    layer = 20,
    tags = {"group", "friends"},
    desc = "FRENS: A group you can be a member of. 'x BE FRENS' adds you to the FRENS group. 'FRENS BE x' applies the property to all FRENS.",
  },
	-- 301
  {
    name = "text_pathz",
    sprite = "text_pathz",
    type = "text",
    texttype = {object = true, group = true},
    color = {3, 3},
    layer = 20,
    tags = {"group","paths"},
    desc = "PATHZ: A variant of FRENS. SELCTR inherently lieks PATHZ.",
  },
	-- 302
  {
    name = "text_groop",
    sprite = "text_groop",
    type = "text",
    texttype = {object = true, group = true},
    color = {3, 3},
    layer = 20,
    tags = {"group"},
    desc = "GROOP: A variant of FRENS.",
  },
  -- 303
  {
    name = "text_her",
    sprite = "text_her",
    type = "text",
    texttype = {property = true},
    rotate = true,
    color = {1,3},
    layer = 20,
    tags = {"here","cg5"},
    desc = "HER ->: Sends objects to where the text indicates. N'T HER makes objects HAET that tile.",
  },
  -- 304
  {
    name = "text_thr",
    sprite = "text_thr",
    type = "text",
    texttype = {property = true},
    rotate = true,
    color = {3,2},
    layer = 20,
    tags = {"there","cg5"},
    desc = "THR ->: Sends objects as far away from it as possible (until hitting a wall) in the indicated direction. N'T THR makes objects HAET a line from the text.",
  },
  -- 305
  {
    name = "text_the",
    sprite = "text_the",
    type = "text",
    texttype = {object = true},
    rotate = true,
    color = {0,3},
    layer = 20,
    tags = {"that","those","cg5"},
    desc = "THE: Refers to the object it's pointing at.",
  },
  -- 306
  {
    name = "text_knightstep",
    sprite = "text_knightstep",
    type = "text",
    texttype = {property = true},
    color = {0, 2},
    layer = 20,
    tags = {"chess"},
    desc = "KNIGHTSTEP: KNIGHTSTEP units move like the Knight chess piece, rotated 22.5 degrees clockwise. Stacks add additional 1, 1 hops.",
  },
  -- 307
  {
    name = "text_that",
    sprite = "text_that",
    type = "text",
    texttype = {cond_infix = true, cond_infix_verb = true},
    color = {0, 3},
    layer = 20,
    tags = {"lily", "with", "w/"},
    desc = "THAT (Infix Condition): x THAT BE y is true if x BE y. x THAT GOT Y is true if x GOT y. And so on.",
  },
  -- 307
  {
    name = "text_that be",
    sprite = "text_that be",
    type = "text",
    --this is because while it's technically cond_infix, listing it as one makes it double count any n'ts after it because it saves the n'ts accumulated from the two different paths it can try it as? I think?? anyway this fixes it because it's special cased in parser.lua
    texttype = {cond_infix = true, cond_infix_verb = true, cond_infix_verb_plus = true},
    color = {0, 3},
    layer = 20,
    tags = {"lily", "with", "w/"},
    desc = "THAT BE (Infix Condition): x THAT BE y is true if x BE y.",
  },
  -- 308
  {
    name = "text_timles",
    sprite = "text_timles",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2,4},
    layer = 20,
    tags = {"timeless"},
    desc = "TIMLES (Prefix Condition): True if ZA WARUDO is active.",
  },
  --vitellary: added down here because i did not want to have to change the numbers for everything beyond "h", plus i think i heard that it would mess things up if i added it up there
  -- 309
  {
    name = "letter_i",
    sprite = "letter_i",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 310
  {
    name = "letter_z",
    sprite = "letter_z",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Z: it's just a rotated N"
  },
  -- 311
  {
    name = "rif",
    sprite = "riff",
    type = "object",
    rotate = true,
    portal = true,
    color = {2,4},
    layer = 8,
    tags = {"portal", "rift"},
    desc = "the fake poor toll"
  },
  -- 312
  {
    name = "text_rif",
    sprite = "text_rif",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"portal", "rift"},
  },
  -- 306
  {
    name = "text_stay ther",
    sprite = "text_stay ther",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"persist"},
    desc = "STAY THER: Objects with this property will be taken with you when you transition between levels.",
  },
  -- 313? why are the numbers weird
  {
    name = "lie",
    sprite = "caek",
    type = "object",
    color = {4,1},
    layer = 5,
    tags = {"portal", "cake"},
    desc = "caek be lie",
  },
  -- 314 happy pi day, have some caek
  {
    name = "text_lie",
    sprite = "text_caek",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"portal", "cake"},
    desc = "LIE: If LIE BE SPLIT, LIE becomes LIE/8 on all open adjacent tiles.",
  },
  -- 315
  {
    name = "lie/8",
    sprite = "slis",
    type = "object",
    color = {4,2},
    rotate = true,
    layer = 4,
    tags = {"portal", "cake","slice"},
    desc = "idc if it's a lie, it tastes good",
  },
  -- 316
  {
    name = "text_lie/8",
    sprite = "text_slis",
    type = "text",
    texttype = {object = true},
    color = {4,2},
    layer = 20,
    tags = {"portal", "cake","slice"},
    desc = "LIE/8: If LIE/8 BE MOAR, LIE/8 becomes LIE.",
  },
  -- 317
  {
    name = "ui_left click",
    sprite = "ui_left_click",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "Trigger CLIKT.",
  },
  -- 318
  {
    name = "ui_right click",
    sprite = "ui_right_click",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "See what's on the tile you clicked!",
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
    texttype = {cond_prefix = true},
    color = {3, 3},
    layer = 20,
    tags = {"clicked", "mouse"},
    desc = "CLIKT (Prefix Condition): CLIKT objects will be true when left-clicked. Clicks will pass a turn if this text exists.",
  },
  -- 321
  {
    name = "sine",
    sprite = "sine",
    type = "object",
    color = {6,2},
    layer = 4,
    tags = {"sign"},
    desc = "the sine says \"shoutouts to simpleflips\"",
  },
  -- 322
  {
    name = "text_sine",
    sprite = "text_sine",
    type = "text",
    texttype = {object = true},
    color = {6,2},
    layer = 20,
    tags = {"sign"},
  },
  -- 323
  {
    name = "buble",
    sprite = "buble",
    type = "object",
    color = {1,3},
    layer = 3,
    tags = {"bubble"},
  },
  -- 324
  {
    name = "text_buble",
    sprite = "text_buble",
    type = "text",
    texttype = {object = true},
    color = {1,3},
    layer = 20,
    tags = {"bubble"},
  },
  -- 325
  {
    name = "creb",
    sprite = "creb",
    slep = true,
    type = "object",
    color = {2,2},
    layer = 5,
    eye = {x=20, y=4, w=4, h=5},
    tags = {"crab"},
  },
  -- 326
  {
    name = "text_creb",
    sprite = "text_creb",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"crab"},
  },
  -- 327
  {
    name = "icecub",
    sprite = "icecub",
    type = "object",
    color = {1,4},
    layer = 4,
    tags = {"icecube"},
  },
  -- 328
  {
    name = "text_icecub",
    sprite = "text_icecub",
    type = "text",
    texttype = {object = true},
    color = {1,4},
    layer = 20,
    tags = {"icecube"},
  },
  -- 329
  {
    name = "jill",
    sprite = "jill",
    slep = true,
    type = "object",
    color = {1,3},
    layer = 5,
    rotate = true,
    eye = {x=17, y=8, w=2, h=3},
    tags = {"devs", "chars", "valhalla", "cynthia"},
    desc = "it time 2 mix drincc & chaeng life"
  },
  -- 330
  {
    name = "text_jill",
    sprite = "text_jill",
    type = "text",
    texttype = {object = true},
    color = {1,3},
    layer = 20,
    tags = {"devs", "chars", "va11 hall-a", "cynthia"},
  },
  -- 331
  {
    name = "text_paint",
    sprite = "text_paint",
    type = "text",
    texttype = {verb = true, verb_unit = true, property = true, object = true},
    color = {4,2},
    layer = 20,
    tags = {"colors", "colours"},
    desc = "PAINT (Verb): changes the second object's color to match the first if the objects are on each other. Supports color mixing."
  },
  -- 332
  {
    name = "paint",
    sprite = {"paint","paint_color"},
    type = "object",
    color = {{0,3},{0,3}},
    colored = {false,true},
    layer = 4,
    tags = {"colors", "colours"},
    desc = "X be PAINT turns into a paint bucket with the color of X."
  },
  -- 333
  {
    name = "text_glued",
    sprite = "text_glued",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    tags = {"sticky","lily"},
    desc = "GLUED: Stuck to adjacent units sharing its colour, and can't move unless the entire block can simultaneously move.",
  },
  --- 334
  {
    name = "ger",
    sprite = "ger",
    type = "object",
    color = {6,1},
    layer = 4,
    rotate = true,
    tags = {"gear", "time", "cog"},
  },
  -- 335
  {
    name = "text_ger",
    sprite = "text_ger",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"gear", "time", "cog"},
  },
  -- 336
  {
    name = "text_rithere",
    sprite = "text_rithere",
    type = "text",
    texttype = {property = true},
    color = {4,0},
    layer = 20,
    tags = {"right here"},
    desc = "RIT HERE: Sends objects to where the text is.",
  },
  -- 337
  {
    name = "text_torc",
    sprite = "text_torc",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"torchlight", "flashlight"},
    desc = "TORC: A TORC object emits light in the direction they're facing. The angle of the light determined by the number of TORC stacks. (WIP)",
  },
  -- 338
  {
    name = "text_ignor",
    sprite = "text_ignor",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {0,1},
    layer = 20,
    tags = {"ignore"},
    desc = "IGNOR (Verb): x IGNOR y causes x to not be able to interact with or move y in any way."
  },
  -- 339
  {
    name = "text_rotatbl",
    sprite = "text_rotatbl",
    type = "text",
    texttype = {property = true},
    color = {6,2},
    layer = 20,
    tags = {"rotatable"},
    desc = "ROTATBL: Makes any object able to be rotated."
  },
  -- 340
  {
    name = "text_vs",
    sprite = "text_vs",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {2,1},
    layer = 20,
    tags = {"versus"},
    desc = "VS (Verb): The two objects enter a 1 on 1 battle: whoever steps on the other wins.",
  },
  --- 334
  {
    name = "hors",
    sprite = "hors",
    slep = true,
    type = "object",
    color = {6,1},
    layer = 5,
    eye = {x=17,y=6,w=3,h=3},
    tags = {"chess", "knight", "horse"},
  },
  -- 335
  {
    name = "text_hors",
    sprite = "text_hors",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"chess", "knight", "horse"},
  },
  --- 334
  {
    name = "can",
    sprite = "can",
    type = "object",
    color = {2,1},
    layer = 4,
    rotate = true,
    tags = {"valhalla"},
  },
  -- 335
  {
    name = "text_can",
    sprite = "text_can",
    type = "text",
    texttype = {object = true},
    color = {2,1},
    layer = 20,
    tags = {"valhalla"},
  },
  --- 336
  {
    name = "togll",
    sprite = "togll",
    type = "object",
    color = {0,3},
    layer = 4,
    rotate = true,
    tags = {"toggle","lightswitch"},
  },
  -- 337
  {
    name = "text_togll",
    sprite = "text_togll",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"toggle","lightswitch"},
  },
  -- 338
  {
    name = "text_pinc",
    sprite = "text_pinc_cond",
    sprite_transforms = {
      property = "text_pinc"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {4, 1},
    layer = 20,
    tags = {"colors", "colours", "pink"},
    desc = "PINC: Causes the unit to become pink!"
  },
  -- 339
  {
    name = "text_nuek",
    sprite = "text_nuek",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"nuke", "bomb"},
    desc = "NUEK: A NUEK will begin destroying everything around it, its radius growing once per turn. Currently very laggy, for some reason."
  },
  -- 340
  {
    name = "letter_o",
    sprite = "letter_o",
    type = "text",
    texttype = {letter = true, object = true},
    color = {0,3},
    layer = 20,
    desc = "the most op letter",
  },
  -- 341
  {
    name = "text_samefloat",
    sprite = "text_samefloat",
    type = "text",
    texttype = {cond_infix = true},
    color = {1,4},
    layer = 20,
    tags = {"sameflye"},
    desc = "SAMEFLOAT( (Infix Condition): True if there is an instance of the subject on the same amount of flye as the object.",
  },
  -- 342
  {
    name = "bom",
    sprite = "bom",
    type = "object",
    color = {0,1},
    layer = 6,
    tags = {"bomb", "boom"},
    desc = "it go boom",
  },
  -- 343
  {
    name = "text_bom",
    sprite = "text_bom",
    type = "text",
    texttype = {object = true},
    color = {0,1},
    layer = 20,
    tags = {"bomb", "boom"},
  },
  -- 344
  {
    name = "xplod",
    sprite = "sparkl",
    type = "object",
    color = {2,2},
    layer = 10,
  },
  -- 345
  {
    name = "text_behind",
    sprite = "text_behind",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"back", "look"},
    desc = "BEHIND (Infix Condition): True if an indicated object is looking away from the unit on an adjacent tile.",
  },
  -- 346
  {
    name = "text_beside",
    sprite = "text_beside",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"look", "left", "right"},
    desc = "BESIDE (Infix Condition): True if an indicated object is at the side of the unit on an adjacent tile.",
  },
  -- 347
  {
    name = "text_look away",
    sprite = "text_look away",
    type = "text",
    texttype = {cond_infix = true, cond_infix_dir = true, verb = true, verb_unit = true},
    color = {0, 3},
    layer = 20,
    tags = {"unfollow", "facing away", "lookaway", "behind"},
    desc = "LOOK AWAY: As an infix condition, true if this object is on the tile behind the unit As a verb, makes the unit face away from this object at end of turn.",
  },
  --348
  {
    name = "square",
    sprite = "square",
    slep = true,
    type = "object",
    color = {2, 4},
    layer = 6,
    eye = {x=19, y=7, w=2, h=2},
    tags = {"chars", "thefox", "puyopuyo tetris"},
    desc = "oh no am square????"
  },
  --349
  {
    name = "triangle",
    sprite = "triangle",
    slep = true,
    type = "object",
    color = {2, 4},
    layer = 6,
    eye = {x=17, y=7, w=2, h=2},
    tags = {"chars", "thefox", "puyopuyo tetris"},
    desc = "TRIASNGLE?????? this is ridicouuolus",
  },
  --350
  {
    name = "text_square",
    sprite = "text_square",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    eye = {x=19, y=7, w=2, h=2},
    tags = {"chars", "thefox", "puyopuyo tetris"},
  },
  --351
  {
    name = "text_triangle",
    sprite = "text_triangle",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    eye = {x=19, y=7, w=2, h=2},
    tags = {"chars", "thefox", "puyopuyo tetris"},
  },
  --just adding these so they exist for letters
  -- 352
  {
    name = "text_right",
    sprite = "text_goup",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
  },
  -- 353
  {
    name = "text_upleft",
    sprite = "text_goup",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
  },
  -- 354
  {
    name = "text_upright",
    sprite = "text_goup",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
  },
  -- 355
  {
    name = "text_downleft",
    sprite = "text_goup",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
  },
  -- 356
  {
    name = "text_downright",
    sprite = "text_goup",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
  },
  -- 357
  {
    name = "letter_1",
    sprite = "letter_1",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"number", "digit", "one"},
    desc = "Used in EVERY1 and NO1.",
  },
  -- 358
  {
    name = "letter_/",
    sprite = "letter_slash",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"slash"},
    desc = "Used in W/FREN and LIE/8.",
  },
  -- 359
  {
    name = "letter_8",
    sprite = "letter_8",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"number", "digit", "eight"},
    desc = "Used in LIE/8.",
  },
  -- 360
  {
    name = "snoman",
    sprite = "snoman",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 5,
    eye = {x=17, y=8, w=3, h=3},
    tags = {"chars", "snowman"},
    desc = "do u wanna creat a snoman??",
  },
  -- 361
  {
    name = "text_snoman",
    sprite = "text_snoman",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"chars", "snowman"},
  },
  -- 362
  {
    name = "sno",
    sprite = "sno",
    type = "object",
    color = {0,3},
    layer = 4,
    tags = {"snowflake", "ice", "hail"},
    desc = "no 2 r the same...\nor is it?",
  },
  -- 363
  {
    name = "text_sno",
    sprite = "text_sno",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"snowflake", "ice", "hail"},
  },
  -- 364
  {
    name = "fir",
    sprite = "fir",
    type = "object",
    color = {2,2},
    layer = 4,
    tags = {"hot", "fire", "flame"},
    desc = "CAUTION HOTTE!!!",
  },
  -- 365
  {
    name = "text_fir",
    sprite = "text_fir",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"hot", "fire", "flame"},
  },
  -- 366
  {
    name = "sanglas",
    sprite = "sanglas",
    type = "object",
    color = {2,4},
    layer = 4,
    rotate = true,
    tags = {"time", "hourglass"},
    desc = "tim got broken",
  },
  -- 367
  {
    name = "text_sanglas",
    sprite = "text_sanglas",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"time", "hourglass"},
  },
  -- 368
  {
    name = "ui_5",
    sprite = "ui_5",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The other wait key.",
  },
  -- 369
  {
    name = "ui_space",
    sprite = "ui_space",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The wait key.",
  },
  -- 370
  {
    name = "ui_z",
    sprite = "ui_z",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The undo key.",
  },
  -- 371
  {
    name = "ui_r",
    sprite = "ui_r",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The restart key.",
  },
  -- 372
  {
    name = "letter_ee",
    sprite = "letter_ee",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 373
  {
    name = "letter_fren",
    sprite = "letter_fren",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "its a fren",
  },
  -- 374
  {
    name = "letter_ll",
    sprite = "letter_ll",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "welcome <3 he11",
  },
  -- 375
  {
    name = "letter_2",
    sprite = "letter_2",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 376
  {
    name = "letter_3",
    sprite = "letter_3",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 377
  {
    name = "letter_4",
    sprite = "letter_4",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 378
  {
    name = "letter_5",
    sprite = "letter_5",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 379
  {
    name = "letter_6",
    sprite = "letter_6",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 380
  {
    name = "letter_7",
    sprite = "letter_7",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 381
  {
    name = "letter_9",
    sprite = "letter_9",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 382
  {
    name = "ladr",
    sprite = "ladr",
    type = "object",
    color = {6,0},
    layer = 3,
    rotate = true,
    tags = {"ladder", "stairs", "climb"},
    desc = "jumpman be u",
  },
  -- 383
  {
    name = "text_ladr",
    sprite = "text_ladr",
    type = "text",
    texttype = {object = true},
    color = {6,0},
    layer = 20,
    tags = {"ladder", "stairs", "climb"},
  },
  -- 384
  {
    name = "text_gravy",
    sprite = "text_gravy",
    type = "text",
    texttype = {object = true},
    color = {6,2},
    layer = 20,
    tags = {"gravity", "fall", "lily"},
    desc = "GRAVY: Changes the direction of HAET SKYE and HAET FLOR. (Unimplemented)"
  },
  --- 385
  {
    name = "text_w/neighbor",
    sprite = "text_wneighbor",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"near", "around", "infix condition", "touching", "adjacent"},
    desc = "W/ NEIGHBOR (Infix Condition): True if the indicated object is on any of orthogonal tiles surrounding the unit. (The unit's own tile is not checked.)",
  },
  -- 386
  {
    name = "cobll",
    sprite = "cobll",
    type = "object",
    color = {0, 1},
    layer = 2,
    tags = {"cobblestone"},
    desc = "so we back in the mine"
  },
  -- 387
  {
    name = "text_cobll",
    sprite = "text_cobll",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"cobblestone"},
  },
  -- 388
  {
    name = "wuud",
    sprite = "wuud",
    type = "object",
    color = {6, 2},
    layer = 2,
    tags = {"wood", "planks"},
    desc = "wuud u cuud u"
  },
  -- 389
  {
    name = "text_wuud",
    sprite = "text_wuud",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"wood", "planks"},
  },
  -- 390
  {
    name = "ui_reset",
    sprite = "ui_reset",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 391
  {
    name = "ui_undo",
    sprite = "ui_undo",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 392
  {
    name = "ui_wait",
    sprite = "ui_wait",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 393
  {
    name = "wut",
    sprite = "wut",
    type = "object",
    color = {0,3},
    layer = 6,
    tags = {"what"},
    desc = "im confuse",
  },
  -- 394
  {
    name = "text_wut",
    sprite = "text_wut",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"what"},
  },
  -- 395
  {
    name = "wat",
    type = "object",
    color = {0,3},
    layer = 5,
    tags = {"what", "error"},
    desc = "whoops error"
  },
  -- 396
  {
    name = "text_wat",
    sprite = "text_wat",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"what", "error"},
  },
  -- 397
  {
    name = "brik",
    sprite = "brik",
    type = "object",
    color = {2, 1},
    layer = 2,
    tags = {"bricks", "wall"},
    desc = "just another brik in the wal",
  },
  -- 398
  {
    name = "text_brik",
    sprite = "text_brik",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"bricks", "wall"},
    desc = "reverse kirb",
  },
  -- 399
  {
    name = "litbolt",
    sprite = "litbolt",
    type = "object",
    color = {2, 4},
    layer = 5,
    rotate = true,
    desc = "made with lightning. REAL LIGHTNING.",
  },
  -- 400
  {
    name = "text_litbolt",
    sprite = "text_litbolt",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
  },
  -- 401
  {
    name = "text_;d",
    sprite = "text_ungood",
    slep = true,
    type = "text",
    texttype = {property = true},
    color = {1,2},
    layer = 20,
    eye = {x=23, y=8, w=3, h=4},
    tags = {"unwin", "wink", "face", "unyay", "patashu"},
    desc = ";D: When U touches ;D, the current level will no longer be considered won, without exiting the level. Imagine a win score equal to the number of Us on :) minus the Us on ;D. If positive, you win. If negative, you lose your win. If equal, nothing happens.",
  },
  --402
  {
    name = "text_enby",
    sprite = "text_enby-colored",
    type = "text",
    texttype = {property = true},
    color = {255, 255, 255},
    layer = 20,
    desc = "ENBY: Causes the unit to appear yellow, white, purple and black.",
  },
  -- 403
  {
    name = "beeee",
    sprite = {"beeee","no1"},
    slep = true,
    type = "object",
    color = {{2, 4},{0,0}},
    colored = {true,true},
    layer = 6,
    rotate = true,
    eye = {x=25, y=14, w=2, h=2},
    tags = {"honeybee", "chars", "insect"},
    desc = "the bab beeee be tranz",
  },
  -- 404
  {
    name = "text_beeee",
    sprite = "text_beeee",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"honeybee", "chars", "insect"},
    desc = "bab beeeeeeeee u",
  },
  -- 405
  {
    name = "rouz",
    sprite = "rouz",
    type = "object",
    color = {4, 1},
    layer = 4,
    eye = {x=8, y=6, w=3, h=3},
    tags = {"rose", "flower", "plants"},
  },
  -- 406
  {
    name = "text_rouz",
    sprite = "text_rouz",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"rose", "flower", "plants"},
  },
  -- 407
  {
    name = "san",
    sprite = "san",
    type = "object",
    color = {2, 4},
    layer = 2,
    tags = {"sand", "beach", "desert"},
    desc = "san undertales",
  },
  -- 408
  {
    name = "text_san",
    sprite = "text_san",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"sand", "beach", "desert"},
  },
  -- 409
  {
    name = "letter_;",
    sprite = "letter_semicolon",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"semicolon", "wink"},
    desc = "Used in ;D",
  },
  -- 410
  {
    name = "fungye",
    sprite = "fungye",
    type = "object",
    color = {6, 2},
    layer = 4,
    tags = {"fungus", "fungi", "mushroom"},
  },
  -- 411
  {
    name = "text_fungye",
    sprite = "text_fungye",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"fungus", "fungi", "mushroom"},
    desc = "not a very fun guy",
  },
  -- 411
  {
    name = "kar",
    sprite = "kar",
    type = "object",
    color = {5, 2},
    layer = 5,
    rotate = true,
    eye = {x=20,y=11,w=2,h=4},
    tags = {"car", "vehicle"},
    desc = "awaken my masters",
  },
  -- 412
  {
    name = "text_kar",
    sprite = "text_kar",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"car", "vehicle"},
  },
  -- 413
  {
    name = "tor",
    sprite = "tor",
    type = "object",
    color = {2, 1},
    layer = 8,
    portal = true,
    tags = {"portal", "japan", "torii", "asia"},
    desc = "the east poor toll",
  },
  -- 414
  {
    name = "text_tor",
    sprite = "text_tor",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"portal", "japan", "torii", "asia"},
  },
  -- 415
  {
    name = "son",
    sprite = "son",
    slep = true,
    type = "object",
    color = {2,4},
    layer = 4,
    tags = {"hot", "sunny", "day"},
    desc = "the son be a :( lazor",
  },
  -- 416
  {
    name = "text_son",
    sprite = "text_son",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"hot", "sunny", "day"},
  },
  -- 417
  {
    name = "muun",
    sprite = "muun",
    type = "object",
    color = {1,2},
    layer = 4,
    tags = {"moon", "night", "mun", "crescent"},
    desc = "unaffiliated with munwalk",
  },
  -- 418
  {
    name = "text_muun",
    sprite = "text_muun",
    type = "text",
    texttype = {object = true},
    color = {1,2},
    layer = 20,
    tags = {"moon", "night", "mun", "crescent"},
  },
  -- 419
  {
    name = "leef",
    sprite = "leef",
    type = "object",
    color = {5,2},
    layer = 4,
    rotate = true,
    tags = {"leaf", "weed lmao", "plants"},
    desc = "leef meem alone",
  },
  -- 420 blaze it
  {
    name = "text_leef",
    sprite = "text_leef",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"leaf", "weed lmao", "plants"},
    desc = "its the 420th object lmao",
    weed = true,
    nice = true,
  },
  -- 421
  {
    name = "starr",
    sprite = "starr",
    type = "object",
    color = {2,4},
    layer = 4,
    tags = {"star", "night"},
    desc = "starr starr nite",
  },
  -- 422
  {
    name = "text_starr",
    sprite = "text_starr",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"star", "night"},
  },
  -- 423
  {
    name = "shel",
    sprite = "shel",
    type = "object",
    color = {4,2},
    layer = 4,
    tags = {"shell", "scallop", "beach"},
    desc = "gas gas gas",
  },
  -- 424
  {
    name = "text_shel",
    sprite = "text_shel",
    type = "text",
    texttype = {object = true},
    color = {4,2},
    layer = 20,
    tags = {"shell", "scallop", "beach"},
  },
  -- 425
  {
    name = "sancastl",
    sprite = "sancastl",
    type = "object",
    color = {2,4},
    layer = 4,
    tags = {"sandcastle", "beach"},
    desc = "lets creat a sancastl",
  },
  -- 426
  {
    name = "text_sancastl",
    sprite = "text_sancastl",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"sandcastle", "beach"},
  },
  --- 427
  {
    name = "parsol",
    sprite = "parsol",
    type = "object",
    color = {2, 2},
    layer = 8,
    rotate = true,
    tags = {"parasol", "umbrella", "beach"},
    desc = "protecc from son thatbe :(",
  },
  --- 428
  {
    name = "text_parsol",
    sprite = "text_parsol",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"parasol", "umbrella", "beach"},
  },
  --429
  {
    name = "pallm",
    sprite = "pallm",
    type = "object",
    color = {5, 2},
    layer = 2,
    tags = {"palm tree", "coconut tree", "beach", "plants"},
  },
  --430
  {
    name = "text_pallm",
    sprite = "text_pallm",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"palm tree", "coconut tree", "beach", "plants"},
  },
  --431
  {
    name = "coco",
    sprite = "coco",
    type = "object",
    color = {6, 1},
    layer = 3,
    rotate = "true",
    eye = {x=20,y=12,w=2,h=3},
    tags = {"fruit", "coconut", "plants"},
    desc = "its a bigg bigg nutt",
  },
  --432
  {
    name = "text_coco",
    sprite = "text_coco",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"fruit", "coconut", "plants"},
  },
  --433
  {
    name = "glas",
    sprite = "glas",
    type = "object",
    color = {0,3},
    layer = 21,
    tags = {"glass"},
    desc = "a tranzlucent block?!",
  },
  --434
  {
    name = "text_glas",
    sprite = "text_glas",
    type = "text",
    texttype = {object = true},
    color = {0,2},
    layer = 20,
    tags = {"glass"},
  },
  --435
  {
    name = "fishe",
    sprite = "fishe",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 5,
    rotate = "true",
    eye = {x=24, y=11, w=2, h=2},
    tags = {"angelfish", "chars"},
    desc = "fishe be walk?? kinda quirky doe",
  },
  --436
  {
    name = "text_fishe",
    sprite = "text_fishe",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"angelfish", "chars"},
  },
  -- 437
  {
    name = "vien",
    sprite = "vien",
    type = "object",
    color = {5,1},
    layer = 3,
    rotate = true,
    tags = {"vines", "plants", "climb"},
    desc = "vinny viensauce",
  },
  -- 438
  {
    name = "text_vien",
    sprite = "text_vien",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"vines", "plants", "climb"},
    desc = "so she uploads a VIEN",
  },
  -- 439
  {
    name = "pudll",
    sprite = "pudll",
    type = "object",
    color = {1, 3},
    layer = 1,
    tags = {"water", "puddle"},
    desc = "its just a single watr",
  },
  -- 440
  {
    name = "text_pudll",
    sprite = "text_pudll",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"water", "puddle"},
  },
  -- 441
  {
    name = "red",
    sprite = "red",
    type = "object",
    color = {6,2},
    layer = 3,
    tags = {"reeds", "plants", "cattail", "swamp"},
  },
  -- 442
  {
    name = "text_red",
    sprite = "text_red",
    type = "text",
    texttype = {object = true},
    color = {6,2},
    layer = 20,
    tags = {"reeds", "plants", "cattail", "swamp"},
    desc = "wait what",
  },
  -- 443
  {
    name = "stum",
    sprite = "stum",
    type = "object",
    color = {6,1},
    layer = 3,
    tags = {"plants", "tree stump"},
    desc = "im stumped",
  },
  -- 444
  {
    name = "text_stum",
    sprite = "text_stum",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"plants", "tree stump"},
    unlucky = true,
  },
  -- 445
  {
    name = "bullb",
    sprite = "bullb",
    type = "object",
    color = {2, 4},
    layer = 4,
    tags = {"lightbulb", "power"},
  },
  -- 446
  {
    name = "text_bullb",
    sprite = "text_bullb",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"lightbulb", "power"},
  },
  --447
  {
    name = "battry",
    sprite = "battry",
    type = "object",
    color = {4, 1},
    layer = 4,
    rotate = "true",
    eye = {x=23,y=14,w=2,h=4},
    tags = {"battery", "power"},
    desc = "not responsible for hidden states",
  },
  --448
  {
    name = "text_battry",
    sprite = "text_battry",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"battery", "power"},
  },
  --449
  {
    name = "smol",
    sprite = "smol",
    type = object,
    color = {5,2},
    layer = 8,
    rotate = true,
    portal = true,
    tags = {"portal"},
    desc = "the tini poor toll",
  },
  --450
  {
    name = "text_smol",
    sprite = "text_smol",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"portal"},
  },
  --451
  {
    name = "win",
    sprite = "win",
    type = object,
    color = {1,4},
    layer = 8,
    rotate = true,
    portal = true,
    tags = {"portal", "window", "doorway"},
    desc = "the skware poor toll",
  },
  --452
  {
    name = "text_win",
    sprite = "text_win",
    type = "text",
    texttype = {object = true},
    color = {1,4},
    layer = 20,
    tags = {"portal", "window", "doorway"},
    desc = "not to be confused with :)",
  },
  --453
  {
    name = "statoo",
    sprite = "statoo",
    slep = true,
    type = "object",
    color = {0, 1},
    layer = 5,
    eye = {x=16, y=6, w=2, h=2},
    tags = {"statue", "chars", "janitor"},
    desc = "their occupation is a janitor",
  },
  --454
  {
    name = "text_statoo",
    sprite = "text_statoo",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"statue", "chars", "janitor"},
  },
  --- 455
  {
    name = "bon",
    sprite = "bon",
    type = "object",
    color = {0, 3},
    layer = 4,
    rotate = true,
    tags = {"bone"},
    desc = "bonles pizza",
  },
  --- 456
  {
    name = "text_bon",
    sprite = "text_bon",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"bone"},
  },
  --- 457
  {
    name = "rockit",
    sprite = "rockit",
    type = "object",
    color = {1, 3},
    layer = 6,
    rotate = true,
    eye = {x=18,y=13,w=3,h=4},
    tags = {"rocket", "spaceship"},
    desc = "goes to spce",
  },
  --- 458
  {
    name = "text_rockit",
    sprite = "text_rockit",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"rocket", "spaceship"},
  },
  --- 459
  {
    name = "ufu",
    sprite = "ufu",
    type = "object",
    color = {3, 3},
    layer = 6,
    eye = {x=15,y=10,w=4,h=5},
    tags = {"ufo", "spaceship"},
    desc = "comes from spce",
  },
  --- 460
  {
    name = "text_ufu",
    sprite = "text_ufu",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"ufo", "spaceship"},
  },
  -- 461
  {
    name = "rein",
    sprite = "rein",
    type = "object",
    color = {1, 3},
    layer = 8,
    tags = {"rain"},
    desc = "it pours",
  },
  -- 462
  {
    name = "text_rein",
    sprite = "text_rein",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"rain"},
  },
  -- 463
  {
    name = "algay",
    sprite = "algay",
    type = "object",
    color = {5,1},
    layer = 4,
    tags = {"algae", "plants"},
  },
  -- 464
  {
    name = "text_algay",
    sprite = "text_algay",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"algae", "plants"},
    desc = "very gay",
  },
  -- 465
  {
    name = "noet",
    sprite = "noet",
    type = "object",
    color = {4,1},
    layer = 8,
    tags = {"music note", "quarter note"},
  },
  -- 466
  {
    name = "text_noet",
    sprite = "text_noet",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"music note", "quarter note"},
  },
  -- 467
  {
    name = "banboo",
    sprite = "banboo",
    type = "object",
    color = {5,1},
    layer = 4,
    tags = {"bamboo", "plants"},
  },
  -- 468
  {
    name = "text_banboo",
    sprite = "text_banboo",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"bamboo", "plants"},
  },
  -- 469
  {
    name = "bunmy",
    sprite = "bunmy",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 6,
    rotate = true,
    eye = {x=23, y=12, w=2, h=2},
    tags = {"chars", "bunny rabbit"},
    desc = "looks kinda like bab???",
    nice = true,
  },
  -- 470
  {
    name = "text_bunmy",
    sprite = "text_bunmy",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "bunny rabbit"},
  },
  -- 471
  {
    name = "karot",
    sprite = "karot",
    type = "object",
    color = {2,2},
    layer = 4,
    rotate = true,
    tags = {"carrot", "plants", "fruit"},
    desc = "bunmy lüv this",
  },
  -- 472
  {
    name = "text_karot",
    sprite = "text_karot",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"carrot", "plants", "fruit"},
    desc = "is it a frut? is it a vege? i dont karot all!!!",
  },
  -- 473
  {
    name = "poisbolt",
    sprite = "poisbolt",
    type = "object",
    color = {5, 3},
    layer = 5,
    rotate = true,
    tags = {"poison"},
    desc = "how kids learn the triangular number series",
  },
  -- 474
  {
    name = "text_poisbolt",
    sprite = "text_poisbolt",
    type = "text",
    texttype = {object = true},
    color = {5, 3},
    layer = 20,
    tags = {"poison"},
  },
  -- 475
  {
    name = "knif",
    sprite = "knif",
    color = {0, 3},
    layer = 5,
    rotate = true,
    tags = {"weapon", "japan", "asia", "edgy"},
  },
  -- 476
  {
    name = "text_knif",
    sprite = "text_knif",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"weapon", "kitchen knife"},
	desc = "KNIF: Any object with GOT KNIF will wield a KNIF."
  },
  -- 477
  {
    name = "timbolt",
    sprite = "timbolt",
    type = "object",
    color = {3, 3},
    layer = 5,
    rotate = true,
    desc = "tim heals all wounds... unless its a bolt",
  },
  -- 478
  {
    name = "text_timbolt",
    sprite = "text_timbolt",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
  },
  -- 479
  {
    name = "bog",
    sprite = "bog",
    slep = true,
    type = "object",
    color = {6, 1},
    layer = 6,
    rotate = true,
    eye = {x=24, y=16, w=2, h=2},
    tags = {"chars", "bug", "insect", "cockroach"},
    desc = "icky",
  },
  -- 480
  {
    name = "text_bog",
    sprite = "text_bog",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"chars", "bug", "insect", "cockroach"},
  },
  -- 481
  {
    name = "pingu",
    sprite = "pingu",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 6,
    rotate = true,
    eye = {x=14, y=5, w=2, h=2},
    tags = {"chars", "penguin", "bird"},
    desc = "noot noot",
  },
  -- 482
  {
    name = "text_pingu",
    sprite = "text_pingu",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"chars", "penguin", "bird"},
  },
  -- 483
  {
    name = "snek",
    sprite = "snek",
    slep = true,
    type = "object",
    color = {5, 3},
    layer = 6,
    rotate = true,
    eye = {x=20, y=7, w=2, h=2},
    tags = {"chars", "snake"},
    desc = "sssssssssssssss",
  },
  -- 484
  {
    name = "text_snek",
    sprite = "text_snek",
    type = "text",
    texttype = {object = true},
    color = {5, 3},
    layer = 20,
    tags = {"chars", "snake"},
  },
  -- 485
  {
    name = "ripof",
    sprite = "ripof",
    slep = true,
    type = "object",
    color = {1, 3},
    layer = 6,
    rotate = true,
    eye = {x=25, y=17, w=3, h=3},
    tags = {"chars", "dev", "slime", "blob", "rip off"},
    desc = "from the hit game DEV IS YOU",
  },
  -- 486
  {
    name = "text_ripof",
    sprite = "text_ripof",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"chars", "dev", "slime", "blob", "rip off"},
    desc = "it needs to have the tag dev but i don't want it to be with the other devs",
  },
  -- 487
  {
    name = "butflye",
    sprite = "butflye",
    slep = true,
    type = "object",
    color = {1, 4},
    layer = 6,
    rotate = true,
    eye = {x=19, y=11, w=2, h=2},
    tags = {"butterfly", "chars", "insect"},
    desc = "of the bleu morpho variety",
  },
  -- 488
  {
    name = "text_butflye",
    sprite = "text_butflye",
    type = "text",
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    tags = {"butterfly", "chars", "insect"},
    desc = "but, flye??",
  },
  -- 489
  {
    name = "wurm",
    sprite = "wurm",
    slep = true,
    type = "object",
    color = {3, 3},
    layer = 6,
    rotate = true,
    eye = {x=20, y=4, w=2, h=2},
    tags = {"worm", "caterpillar", "bug", "chars", "insect"},
  },
  -- 490
  {
    name = "text_wurm",
    sprite = "text_wurm",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"worm", "caterpillar", "bug", "chars", "insect"},
  },
  -- 491
  {
    name = "letter_bolt",
    sprite = "letter_bolt",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for all of the bolt words; Firbolt, icbolt, litbolt, etc.",
  },
  -- 492
  {
    name = "letter_ol",
    sprite = "letter_ol",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 493
  {
    name = "cor",
    sprite = "cor",
    type = "object",
    color = {4,0},
    layer = 4,
    tags = {"coral", "beach"},
  },
  -- 494
  {
    name = "text_cor",
    sprite = "text_cor",
    type = "text",
    texttype = {object = true},
    color = {4,0},
    layer = 20,
    tags = {"coral", "beach"},
    desc = "ROC backwards",
  },
  -- 494
  {
    name = "sirn",
    sprite = "sirn",
    type = "object",
    color = {2,2},
    layer = 4,
    rotate = true,
    tags = {"siren", "alarm"},
    desc = "will steal ur tim machine,"
  },
  -- 495
  {
    name = "text_sirn",
    sprite = "text_sirn",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"siren", "alarm"},
  },
  -- 496
  {
    name = "ratt",
    sprite = "ratt",
    slep = true,
    type = "object",
    color = {0, 1},
    layer = 6,
    rotate = true,
    eye = {x=27, y=14, w=2, h=2},
    tags = {"chars", "rat", "mouse"},
    desc = "the real MOUS, they STALK at night and SNACC at night, they're the RATTs",
  },
  -- 497
  {
    name = "text_ratt",
    sprite = "text_ratt",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"chars", "rat", "mouse"},
    desc = "the stand of BOG-SNACCEN",
  },
  -- 496
  {
    name = "moo",
    sprite = "moo",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 6,
    rotate = true,
    eye = {x=27, y=7, w=2, h=2},
    tags = {"chars", "cow"},
    desc = "You found Moo, the Unfindable Cow! Now Time will collapse.",
  },
  -- 497
  {
    name = "text_moo",
    sprite = "text_moo",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "cow"},
    desc = "moooooo",
  },
  -- 498
  {
    name = "enbybog",
    sprite = "enbybog",
    slep = true,
    type = "object",
    color = {2, 2},
    layer = 6,
    rotate = true,
    eye = {x=23, y=17, w=2, h=2},
    tags = {"chars", "ladybug", "insect", "cockroach"},
    desc = "goes by they/them",
  },
  -- 499
  {
    name = "text_enbybog",
    sprite = "text_enbybog",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"chars", "ladybug", "insect", "cockroach"},
  },
  -- 500
  {
    name = "shrim",
    sprite = "shrim",
    slep = true,
    type = "object",
    color = {2, 2},
    layer = 6,
    rotate = true,
    eye = {x=20, y=9, w=2, h=2},
    tags = {"chars", "shrimp", "prawn"},
    desc = "shouldnt it be PINC",
  },
  -- 501
  {
    name = "text_shrim",
    sprite = "text_shrim",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"chars", "shrimp", "prawn"},
    desc = "shrims are pretty rich",
  },
  -- 502
  {
    name = "flamgo",
    sprite = "flamgo",
    slep = true,
    type = "object",
    color = {4, 1},
    layer = 6,
    eye = {x=23, y=3, w=2, h=2},
    tags = {"chars", "flamingo", "bird"},
    desc = "if ur COLRFUL thats cool too!!",
  },
  -- 503
  {
    name = "text_flamgo",
    sprite = "text_flamgo",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"chars", "flamingo", "bird"},
  },
  -- 504
  {
    name = "gul",
    sprite = "gul",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 7,
    eye = {x=21, y=11, w=2, h=2},
    tags = {"chars", "seagull", "bird", "beach"},
    desc = "7",
  },
  -- 505
  {
    name = "text_gul",
    sprite = "text_gul",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "seagull", "bird", "beach"},
  },
  -- 506
  {
    name = "starrfishe",
    sprite = "starrfishe",
    slep = true,
    type = "object",
    color = {4, 2},
    layer = 6,
    rotate = true,
    eye = {x=16, y=12, w=2, h=2},
    tags = {"chars", "starfish", "beach"},
    desc = "she's alive, and has 4 eyes",
  },
  -- 507
  {
    name = "text_starrfishe",
    sprite = "text_starrfishe",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"chars", "starfish", "beach"},
    desc = "what a long name",
  },
  -- 508
  {
    name = "sneel",
    sprite = "sneel",
    slep = true,
    type = "object",
    color = {4, 2},
    layer = 6,
    rotate = true,
    eye = {x=21, y=28, w=2, h=2},
    tags = {"chars", "snail"},
    desc = "winner of the undertale snail race gets into BAB",
  },
  -- 509
  {
    name = "text_sneel",
    sprite = "text_sneel",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"chars", "snail"},
  },
  -- 510
  {
    name = "kapa",
    sprite = "kapa",
    slep = true,
    type = "object",
    color = {5, 2},
    layer = 6,
    rotate = true,
    eye = {x=24, y=14, w=2, h=2},
    tags = {"chars", "japan", "youkai", "kappa"},
    desc = "now we need a CUMBER object",
  },
  -- 511
  {
    name = "text_kapa",
    sprite = "text_kapa",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"chars", "japan", "youkai", "kappa"},
  },
  -- 512
  {
    name = "urei",
    sprite = "urei",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 7,
    eye = {x=20, y=19, w=2, h=2},
    tags = {"chars", "japan", "youkai", "yuurei", "ghost"},
    desc = "GHOST FREN of the eastern variety",
  },
  -- 513
  {
    name = "text_urei",
    sprite = "text_urei",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "japan", "youkai", "yuurei", "ghost"},
  },
  -- 514
  {
    name = "wips",
    sprite = "wips",
    type = "object",
    color = {0, 3},
    layer = 7,
    tags = {"will o wisp", "japan", "ghost", "spirit"},
    desc = "WILL o WIPS?",
  },
  -- 515
  {
    name = "text_wips",
    sprite = "text_wips",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"will o wisp", "japan", "ghost", "spirit"},
    desc = "work in progress",
  },
  -- 516
  {
    name = "ryugon",
    sprite = "ryugon",
    slep = true,
    type = "object",
    color = {5, 2},
    layer = 7,
    rotate = true,
    eye = {x=21, y=7, w=3, h=2},
    tags = {"chars", "japan", "youkai", "dragon"},
    desc = "ryugon no ken wo kurae",
  },
  -- 517
  {
    name = "text_ryugon",
    sprite = "text_ryugon",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"chars", "japan", "youkai", "dragon"},
  },
  -- 518
  {
    name = "eyee",
    sprite = "eyee",
    slep = true,
    type = "object",
    color = {0, 3},
    layer = 5,
    rotate = true,
    eye = {x=17, y=12, w=7, h=8},
    tags = {"eye", "body part"},
    desc = "EYEE SEES ALL",
  },
  -- 519
  {
    name = "text_eyee",
    sprite = "text_eyee",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"eye", "body part"},
  },
  -- 520
  {
    name = "lisp",
    sprite = "lisp",
    type = "object",
    color = {2, 2},
    layer = 5,
    rotate = true,
    tags = {"mouth", "lips", "body part"},
    desc = "it speaks",
  },
  -- 521
  {
    name = "text_lisp",
    sprite = "text_lisp",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"mouth", "lips", "body part"},
    desc = "it altho hath a lithp",
  },
  -- 522
  {
    name = "eeg",
    sprite = "eeg",
    type = "object",
    color = {6, 2},
    layer = 5,
    rotate = true,
    tags = {"egg"},
  },
  -- 523
  {
    name = "text_eeg",
    sprite = "text_eeg",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"egg"},
  },
  -- 524
  {
    name = "foreeg",
    sprite = "foreeg",
    type = "object",
    color = {6, 1},
    layer = 3,
    rotate = true,
    tags = {"nest"},
  },
  -- 525
  {
    name = "text_foreeg",
    sprite = "text_foreeg",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"nest"},
  },
  -- 526
  {
    name = "paw",
    sprite = "paw",
    type = "object",
    color = {0, 3},
    layer = 5,
    rotate = true,
    tags = {"paw print"},
  },
  -- 527
  {
    name = "text_paw",
    sprite = "text_paw",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"paw print"},
  },
  -- 528
  {
    name = "cavebab",
    sprite = "cavebab",
    slep = true,
    type = "object",
    color = {3,3},
    layer = 7,
    eye = {x=18, y=10, w=2, h=2},
    tags = {"chars", "bat"},
    desc = "slep upside down",
  },
  -- 529
  {
    name = "text_cavebab",
    sprite = "text_cavebab",
    type = "text",
    texttype = {object = true},
    color = {3,3},
    layer = 20,
    tags = {"chars", "bat"},
  },
  -- 530
  {
    name = "extre",
    sprite = "extre",
    type = "object",
    color = {6, 1},
    layer = 2,
    rotate = "true",
    tags = {"tree", "plants", "husk"},
    desc = "a ded tre",
  },
  -- 531
  {
    name = "text_extre",
    sprite = "text_extre",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"tree", "plants", "husk"},
  },
  -- 532
  {
    name = "heg",
    sprite = "heg",
    type = "object",
    color = {5, 2},
    layer = 2,
    tags = {"plant", "cactus"},
    desc = "ouch",
  },
  -- 533
  {
    name = "text_heg",
    sprite = "text_heg",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"plant", "cactus"},
  },
  -- 534
  {
    name = "byc",
    sprite = "byc",
    type = "object",
    color = {2, 2},
    rotate = true,
    layer = 20,
    tags = {"playing card", "bicycle", "ace", "card"},
    desc = "haha get it, it's because bicycle is a specific brand of playing card",
  },
  -- 535
  {
    name = "text_byc",
    sprite = "text_byc",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 5,
    tags = {"playing card", "bicycle", "ace", "card"},
    desc = "BYC: has a random image every time it's loaded!",
  },
  -- 534
  {
    name = "bac",
    sprite = "bac",
    type = "object",
    color = {2, 2},
    rotate = true,
    layer = 5,
    tags = {"playing card back", "bicycle", "card"},
    desc = "cards have 2 sides",
  },
  -- 535
  {
    name = "text_bac",
    sprite = "text_bac",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"playing card back", "bicycle", "card"},
  },
  -- 536
  {
    name = "text_wun",
    sprite = "text_wun",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2,4},
    layer = 20,
    tags = {"won","patashu"},
    desc = "WUN: A prefix condition that's true if the unit is a won level. When referring to the level itself, true if the level's been won.",
  },
  -- 537
  {
    name = "text_notranform",
    sprite = "text_notranform",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"no transform"},
    desc = "NO TRANFORM: A property that prevents the object from transforming. LVL BE NO TRANFORM reverts any transformations it had.",
  },
  -- 538
  {
    name = "golf",
    sprite = "golf",
    type = "object",
    color = {1, 2},
    layer = 3,
    tags = {"flag", "unwin"},
    desc = "i want 0!!!",
  },
  -- 539
  {
    name = "text_golf",
    sprite = "text_golf",
    type = "text",
    texttype = {object = true},
    color = {1, 2},
    layer = 20,
    tags = {"flag", "unwin"},
    desc = "you see, in golf, a LOWER score is better",
  },
  -- 540
  {
    name = "text_sing",
    sprite = "text_sing",
    type = "text",
    texttype = {verb = true, verb_sing = true},
    color = {0, 3},
    layer = 20,
    tags = {"play", "music", "say"},
    desc = "SING (Verb): SING A-G with letters!",
  },
  --- 541
  {
    name = "text_diagkik",
    sprite = "text_diagkik",
    type = "text",
    texttype = {property = true},
    color ={6, 1},
    layer = 20,
    tags = {"sidekick", "diagkick"},
    desc = "DIAGKIK: If a unit moves 45 degrees away from a DIAGKIK, the DIAGKIK copies that movement. With two stacks, also copies 135 degree movement.",
  },
  -- 542
  {
    name = "migri",
    sprite = "migri",
    type = "object",
    color = {3, 0},
    layer = 5,
    rotate = true,
    eye = {x=12,y=14,w=2,h=3},
    tags = {"chars"},
    desc = "i don't actually know what this is, someone tell me",
  },
  -- 543
  {
    name = "text_migri",
    sprite = "text_migri",
    type = "text",
    texttype = {object = true},
    color = {3, 0},
    layer = 20,
    tags = {"chars"},
  },
  -- 544
  {
    name = "sloop",
    sprite = "sloop",
    type = "object",
    color = {0, 3},
    layer = 5,
    rotate = true,
    tags = {"triangle", "half", "slope"},
    desc = "really cool that bab be u 2 introduced slopes, GOTY",
  },
  -- 545
  {
    name = "text_sloop",
    sprite = "text_sloop",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"triangle", "half", "slope"},
    desc = "ideal for reflecc + go my way",
  },
  --- 546
  {
    name = "text_reflecc",
    sprite = "text_reflecc",
    type = "text",
    texttype = {property = true},
    color = {5, 2},
    layer = 20,
    tags = {"reflect", "slope", "bounce", "mirror"},
    desc = "REFLECC: When a unit moves onto a REFLECC unit from in front or behind, it will bounce back at 180 degrees. At a 45/135 angle, 90 degrees. At a 90 angle, it will be unable to enter.",
  },
  -- 547
  {
    name = "reflecr",
    sprite = "reflecr",
    type = "object",
    color = {0, 3},
    layer = 5,
    rotate = true,
    tags = {"mirror", "diagonal", "line", "slope"},
    desc = "imported directly from Deflektor",
  },
  -- 548
  {
    name = "text_reflecr",
    sprite = "text_reflecr",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"mirror", "diagonal", "line", "slope"},
    desc = "ideal for reflecc",
  },
  -- 549
  {
    name = "text_graey",
    sprite = "text_graey_cond",
    sprite_transforms = {
      property = "text_graey"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {0, 1},
    layer = 20,
    tags = {"colors", "colours", "gray", "grey"},
    desc = "GRAEY: Causes the unit to become gray/grey.\nColor or colour?"
  },
  -- 550
  {
    name = "text_brwn",
    sprite = "text_brwn_cond",
    sprite_transforms = {
      property = "text_brwn"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {6, 0},
    layer = 20,
    tags = {"colors", "colours", "brown"},
    desc = "BRWN: Causes the unit to become brown."
  },
  -- 551
  {
    name = "text_sharp",
    sprite = "letter_sharp",
    type = "text",
    texttype = {},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 552
  {
    name = "text_flat",
    sprite = "letter_flat",
    type = "text",
    texttype = {},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 553
  {
    name = "chain",
    sprite = "chain",
    type = "object",
    color = {0, 2},
    layer = 3,
    rotate = "true",
    desc = "EVERY1 W/FREN CHAIN STALK JAIL. now bab's in jail :(",
  },
  -- 554
  {
    name = "text_chain",
    sprite = "text_chain",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
  },
  -- 555
  {
    name = "lili",
    sprite = "lili",
    type = "object",
    color = {5,1},
    layer = 4,
    rotate = "true",
    tags = {"lilypad", "plants"},
  },
  -- 556
  {
    name = "text_lili",
    sprite = "text_lili",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"lilypad", "plants"},
    desc = "not to be confused with LILA",
  },
  -- 557
  {
    name = "swim",
    sprite = "swim",
    type = "object",
    color = {6,1},
    layer = 2,
    tags = {"boat", "ship"},
  },
  -- 558
  {
    name = "text_swim",
    sprite = "text_swim",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"boat", "ship"},
  },
  -- 559
  {
    name = "boooo",
    sprite = {"boooo","boooo_mouth"},
    type = "object",
    color = {{0,3},{2,2},{4,2}},
    colored = {true,false,false},
    layer = 8,
    rotate = true,
    eye = {x=23,y=9,w=4,h=5},
    tags = {"boo","mario","ghost"},
    desc = "very shy, don't lookat",
  },
  -- 560
  {
    name = "text_boooo",
    sprite = "text_boooo",
    type = "text",
    texttype = {object = true},
    color = {4,2},
    layer = 20,
    tags = {"boo","mario","ghost"},
  },
  --561
  {
    name = "gorder",
    sprite = "gorder",
    type = "object",
    color = {0,2},
    rotate = true,
    layer = 3,
    tags = {"girder","city"},
    desc = "constructon zone!",
  },
  -- 562
  {
    name = "text_gorder",
    sprite = "text_gorder",
    type = "text",
    texttype = {object = true},
    color = {0,2},
    layer = 20,
    tags = {"girder","city"},
  },
  -- 563
  {
    name = "piep",
    sprite = "piep",
    type = "object",
    color = {5,2},
    rotate = true,
    portal = true,
    layer = 4,
    tags = {"pipe","tube","mario"},
    desc = "enter the piep to skip world",
  },
  -- 564
  {
    name = "text_piep",
    sprite = "text_piep",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"pipe","tube","mario"},
  },
  -- 565
  {
    name = "tuba",
    sprite = "tuba",
    type = "object",
    color = {5,2},
    rotate = true,
    layer = 4,
    tags = {"pipe","tube","mario"},
    desc = "piep's bff",
  },
  -- 566
  {
    name = "text_tuba",
    sprite = "text_tuba",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"pipe","tube","mario"},
    desc = "pieps are musical instruments",
  },
  -- 567
  {
    name = "text_every2",
    sprite = "text_every2",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"all", "everyone", "every2"},
    desc = "EVERY2: EVERY1 + TXT. (Doesn't include innerlvls atm because lazy + hard to code + unlikely to come up. Sorry.)",
  },
  -- 568
  {
    name = "text_every3",
    sprite = "text_every3",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"all", "everyone", "every3"},
    desc = "EVERY3: Absolutely everything conceivable. The pinnacle of everything technology. (Infloop is not an object.)",
  },
  -- 568
  {
    name = "text_every3",
    sprite = "text_every3",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"all", "everyone", "every3"},
    desc = "EVERY3: Absolutely everything conceivable. The pinnacle of everything technology.",
  },
  -- 569
  {
    name = "madi",
    sprite = {"madi_hair","madi_skin","madi_shirt","madi_pants"},
    type = "object",
    color = {{2,2},{2,4},{1,3},{2,2}},
    colored = {true,false,false,false},
    rotate = true,
    eye = {x=21,y=9,w=1,h=2},
    layer = 9,
    tags = {"madeline","celeste","chars"},
    desc = "she clim mountain in very good game",
  },
  -- 570
  {
    name = "text_madi",
    sprite = "text_madi",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"madeline","celeste","chars"},
  },
  -- 571
  {
    name = "badi",
    sprite = {"madi_hair","madi_skin","madi_eyes","madi_shirt","madi_pants"},
    type = "object",
    color = {{3,1},{3,3},{2,2},{3,2},{3,0}},
    colored = {true,false,false,false,false},
    rotate = true,
    eye = {x=21,y=9,w=1,h=2},
    layer = 9,
    tags = {"badeline","celeste","chars"},
    desc = "emag doog yrev ni niatnuom milc ehs",
  },
  -- 572
  {
    name = "text_badi",
    sprite = "text_badi",
    type = "text",
    texttype = {object = true},
    color = {3,3},
    layer = 20,
    tags = {"badeline","celeste","chars"},
  },
  -- 573
  {
    name = "text_lethers",
    sprite = "text_lethers",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"letters"},
    desc = "LETHERS: Refers to all letters that exist in the level.",
  },
  -- 574
  {
    name = "text_that got",
    sprite = "text_that got",
    type = "text",
    texttype = {cond_infix = true, cond_infix_verb = true, cond_infix_verb_plus = true},
    color = {0, 3},
    layer = 20,
    tags = {"lily", "with", "w/", "infix condition"},
    desc = "THAT GOT (Infix Condition): x THAT GOT y is true if x GOT y.",
  },
  -- 575
  {
    name = "forbeeee",
    sprite = "forbeeee",
    type = "object",
    color = {6, 2},
    layer = 3,
    tags = {"beehive", "beecomb", "honeycomb"},
    desc = "trans rights",
  },
  -- 576
  {
    name = "text_forbeeee",
    sprite = "text_forbeeee",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"beehive", "beecomb", "honeycomb"},
  },
  -- 577
  {
    name = "do$h",
    sprite = "do$h",
    type = "object",
    color = {5, 2},
    layer = 4,
    tags = {"dosh", "cash money","money"},
    desc = "DO$H DO$H DO$H!"
  },
  -- 578
  {
    name = "text_do$h",
    sprite = "text_do$h",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"dosh", "cash money","money"},
    desc = "dollas",
  },
  -- 579
  {
    name = "dling",
    sprite = "dling",
    type = "object",
    color = {2, 4},
    layer = 4,
    rotate = "true",
    tags = {"coin","mario"},
    desc = "dling dling dling!"
  },
  -- 580
  {
    name = "text_dling",
    sprite = "text_dling",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"coin","mario"},
    desc = "the sound a coin makes",
  },
  -- 581
  {
    name = "warn",
    sprite = {"warn", "no1"},
    type = "object",
    color = {{2, 4}, {0,0}},
    colored = {true, false},
    layer = 2,
    tags = {"warning", "stripes"},
    desc = "cauntion",
  },
  -- 582
  {
    name = "text_warn",
    sprite = "text_warn",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"warning", "stripes"},
  },
  -- 583
  {
    name = "reffil",
    sprite = "reffil",
    type = "object",
    color = {5,3},
    layer = 5,
    tags = {"refill","celeste"},
    desc = "gives u dash bacc",
  },
  -- 584
  {
    name = "text_reffil",
    sprite = "text_reffil",
    type = "text",
    texttype = {object = true},
    color = {5,3},
    layer = 20,
    tags = {"refill","celeste"},
  },
  -- 585
  {
    name = "text_soko",
    sprite = "text_soko",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {6,2},
    layer = 20,
    tags = {"sokoban"},
    desc = "SOKO (Verb): If X SOKO Y, then X wins when all Y are not frenles.",
  },
  -- 586
  {
    name = "yanying",
    sprite = {"yan", "ying"},
    type = "object",
    color = {{0,3}, {2,2}},
    colored = {false, true},
    layer = 4,
    tags = {"yin yang orb", "taoism"},
  },
  -- 587
  {
    name = "text_yanying",
    sprite = "text_yanying",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"yin yang orb", "taoism"},
  },
  -- 588
  {
    name = "vlc",
    sprite = "vlc",
    type = "object",
    color = {2,2},
    layer = 5,
    tags = {"traffic cone"},
  },
  -- 589
  {
    name = "text_vlc",
    sprite = "text_vlc",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"traffic cone"},
  },
}

tiles_by_name = {}
group_names = {}
group_names_nt = {}
group_names_set = {}
group_names_set_nt = {}
for i,v in ipairs(tiles_list) do
  tiles_by_name[v.name] = i
  tiles_by_name[v.name:gsub(" ","")] = i
  if v.texttype and v.texttype.group then
		table.insert(group_names, v.name:sub(6, -1));
    table.insert(group_names_nt, v.name:sub(6, -1).."n't");
    group_names_set[v.name:sub(6, -1)] = true;
    group_names_set_nt[v.name:sub(6, -1).."n't"] = true;
	end
end

special_objects = {"mous", "lvl", "bordr", "no1", "this"}