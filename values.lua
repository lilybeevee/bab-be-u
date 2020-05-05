RELEASE_BUILD = false

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

profile = {
  name = "bab"
}

defaultsettings = {
  master_vol = 1,
  music_on = true,
  music_vol = 1,
  sfx_on = true,
  sfx_vol = 1,
  particles_on = true,
  shake_on = true,
  scribble_anim = true,
  light_on = true,
  epileptic = false,
  int_scaling = true,
  grid_lines = false,
  mouse_lines = false,
  stopwatch_effect = true,
  fullscreen = false,
  focus_pause = false,
  level_compression = "zlib",
  draw_editor_lins = true,
  infomode = false,
  scroll_on = true,
  menu_anim = true,
  themes = true,
  autoupdate = true,
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

displayids = false

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

map_music = "map"
map_ver = 1

default_map = '{"width":21,"version":5,"extra":false,"author":"","compression":"zlib","background_sprite":"","height":15,"next_level":"","puffs_to_clear":0,"parent_level":"","is_overworld":false,"palette":"default","music":"map","name":"new level","map":"eJyNkUEKgzAQRa8i7gpZdGKrtpKziJqxBIJKjKCId2+SFu2mJotk9d7nM5/3keybSkYlW1ctJLJYz7qsqzomMwMiuPkW88YBG1FJtm6EC8VgI784Wppamp7T32CHJgbNzoMnCycWvvlbDArH0QoPK9yNkJ4LLd3p1N+FIhd6FzIj5IF9wN0xDygEB/4IaDRIXA4Drv5OrexfzsicEbwt5I73rLunf+iAgZ8Xx7uTwp+Nt0KhnlQXlQV2/A10B+gd"}'

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

--anti replacements for easy words
anti_word_replacements = {
  stubbn = "shy...",
  ["shy..."] = "stubbn",
  nogo = "icyyyy",
  goawaypls = "comepls",
  comepls = "goawaypls",
  haetskye = "haetflor",
  haetflor = "haetskye",
  diag = "ortho",
  ortho = "diag",
  turncornr = "folowal",
  folowal = "turncornr",
  rotatbl = "noturn",
  noturn = "rotatbl",
  right = "left",
  downright = "upleft",
  down = "up",
  downleft = "upright",
  left = "right",
  upleft = "downright",
  up = "down",
  upright = "downleft",
  thicc = "babby",
  [":)"] = "un:)",
  ["un:)"] = ":)",
  nedkee = "fordor",
  fordor = "nedkee",
  hotte = "fridgd",
  fridgd = "hotte",
  cool = "hotte",
  thingify = "txtify",
  txtify = "thingify",
  notranform = "tranz",
  noundo = "undo",
  undo = "noundo",
  brite = "tranparnt",
  tranparnt = "brite",
  gone = "zomb",
  reed = "cyeann",
  orang = "bleu",
  yello = "purp",
  grun = "pinc",
  cyeann = "reed",
  bleu = "orang",
  purp = "yello",
  pinc = "grun",
  whit = "blacc",
  graey = "graey",
  blacc = "whit",
  brwn = "cyeann",
  creat = "snacc",
  snacc = "creat",
  liek = "haet",
  haet = "liek",
  lookat = "lookaway",
  lookaway = "lookat",
  corekt = "rong",
  rong = "corekt",
  seenby = "behind",
  behind = "seenby",
}

anti_word_reverses = {
  wont = true,
  oob = true,
  frenles = true,
  timles = true,
  lit = true,
  alt = true,
  past = true,
  wun = true,
  an = true,
  mayb = true,
  ["wait..."] = true,
  ["w/fren"] = true,
  arond = true,
  sans = true,
  meow = true,
}

anti_verb_mirrors = {
  be = true,
  got = true,
  paint = true,
  rp = true,
}

--in palettes: (3,4) is main title buttons, (4,4) is level buttons, (5,4) is extras
menu_palettes = {
  "autumn",
  "cauliflower",
  "default",
  "edge",
  "factory",
  "garden",
  "greenfault",
  "mountain",
  "ocean",
  "redfault",
  "ruins",
  "space",
  "variant",
  "volcano",
}

custom_letter_quads = {
  {}, -- single letters will always use actual letter units, not custom letter units
  {
    {love.graphics.newQuad(0, 0, 16, 32, 64, 64), 0, 0},
    {love.graphics.newQuad(16, 0, 16, 32, 64, 64), 16, 0},
  },
  {
    {love.graphics.newQuad(32, 0, 16, 16, 64, 64), 0, 0},
    {love.graphics.newQuad(48, 0, 16, 16, 64, 64), 16, 0},
    {love.graphics.newQuad(0, 48, 32, 16, 64, 64), 0, 16},
  },
  {
    {love.graphics.newQuad(32, 0, 16, 16, 64, 64), 0, 0},
    {love.graphics.newQuad(48, 0, 16, 16, 64, 64), 16, 0},
    {love.graphics.newQuad(32, 16, 16, 16, 64, 64), 0, 16},
    {love.graphics.newQuad(48, 16, 16, 16, 64, 64), 16, 16},
  },
  {
    {love.graphics.newQuad(0, 32, 16, 16, 64, 64), 0, 0},
    {love.graphics.newQuad(16, 32, 16, 16, 64, 64), 16, 0},
    {love.graphics.newQuad(32, 48, 11, 16, 64, 64), 0, 16},
    {love.graphics.newQuad(43, 48, 10, 16, 64, 64), 11, 16},
    {love.graphics.newQuad(53, 48, 11, 16, 64, 64), 21, 16},
  },
  {
    {love.graphics.newQuad(32, 32, 11, 16, 64, 64), 0, 0},
    {love.graphics.newQuad(43, 32, 10, 16, 64, 64), 11, 0},
    {love.graphics.newQuad(53, 32, 11, 16, 64, 64), 21, 0},
    {love.graphics.newQuad(32, 48, 11, 16, 64, 64), 0, 16},
    {love.graphics.newQuad(43, 48, 10, 16, 64, 64), 11, 16},
    {love.graphics.newQuad(53, 48, 11, 16, 64, 64), 21, 16},
  },
}

selector_grid_contents = {
  -- page 1: default
  {
    0, "txt_be", "txt_&", "txt_got", "txt_nt", "txt_every1", "txt_no1", "txt_txt", "txt_wurd", "txt_txtify", 0, "txt_wait...", "txt_mous", "txt_clikt", "txt_nxt", "txt_stayther", "lvl", "txt_lvl",
    "bab", "txt_bab", "txt_u", "kee", "txt_kee", "txt_fordor", "txt_goooo", "txt_icy", "txt_icyyyy", "txt_behinu", "txt_moar", "txt_sans", "txt_liek", "txt_infloop", "lin", "txt_lin", "selctr", "txt_selctr",
    "keek", "txt_keek", "txt_walk", "dor", "txt_dor", "txt_nedkee", "txt_frens", "txt_gang", "txt_utoo", "txt_utres", "txt_delet", "txt_an", "txt_haet", "txt_mayb", "txt_that", "txt_ignor", "txt_curse", "txt_...",
    "flog", "txt_flog", "txt_:)", "colld", "txt_colld", "txt_fridgd", "txt_direction", "txt_ouch", "txt_slep", "txt_protecc", "txt_sidekik", "txt_brite", "txt_lit", "txt_tranparnt", "txt_torc", "txt_vs", "txt_nuek", "txt_''",
    "roc", "txt_roc", "txt_goawaypls", "laav", "txt_laav", "txt_hotte","txt_visitfren", "txt_w/fren", "txt_arond", "txt_frenles", "txt_copkat", "txt_zawarudo", "txt_timles", "txt_behind", "txt_beside", "txt_lookaway", "txt_notranform", "this",
    "wal", "txt_wal", "txt_nogo", "l..uv", "txt_l..uv", "gras", "txt_gras", "txt_creat", "txt_lookat", "txt_spoop", "txt_yeet", "txt_turncornr", "txt_corekt", "txt_goarnd", "txt_mirrarnd", "txt_past", 0, "txt_sing",
    "watr", "txt_watr", "txt_noswim", "meem", "txt_meem", "dayzy", "txt_dayzy", "txt_snacc", "txt_seenby" , "txt_stalk", "txt_moov", "txt_folowal", "txt_rong", "txt_her", "txt_thr", "txt_rithere", "txt_the", 0,
    "skul", "txt_skul", "txt_:(", "til", "txt_til", "hurcane", "txt_hurcane", "gunne", "txt_gunne", "wog", "txt_wog", 0, "txt_shy...", "txt_munwalk", "txt_sidestep", "txt_diagstep", "txt_hopovr", "txt_knightstep",
    "boux", "txt_boux", "txt_comepls", "os", "txt_os", "bup", "txt_bup", "han", "txt_han", "fenss", "txt_fenss", 0, 0, "hol", "txt_hol", "txt_poortoll", "txt_blacc", "txt_reed",
    "bellt", "txt_bellt", "txt_go", "tre", "txt_tre", "piler", "txt_piler", "hatt", "txt_hatt", "hedg", "txt_hedg", 0, 0, "rif", "txt_rif", "txt_glued", "txt_whit", "txt_orang",
    "boll", "txt_boll", "txt_:o", "frut", "txt_frut", "kirb", "txt_kirb", "katany", "txt_katany", "metl", "txt_metl", 0, 0, 0, 0, "txt_enby", "txt_colrful", "txt_yello",
    "clok", "txt_clok", "txt_tryagain", "txt_noundo", "txt_undo", "slippers", "txt_slippers", "firbolt", "txt_firbolt", "jail", "txt_jail", 0, 0, 0, 0, "txt_tranz", "txt_rave", "txt_grun",
    "splittr", "txt_splittr", "txt_split", "steev", "txt_steev", "boy", "txt_boy", "icbolt", "txt_icbolt", "platfor", "txt_platfor", "chain", "txt_chain", 0, 0, "txt_gay", "txt_stelth", "txt_cyeann",
    "chekr", "txt_chekr", "txt_diag", "txt_ortho", "txt_haetflor", "arro", "txt_arro", "txt_gomyway", "txt_spin", "txt_noturn", "txt_stubbn", "txt_rotatbl", 0, 0, "txt_pinc", "txt_qt", "txt_paint", "txt_bleu",
    "clowd", "txt_clowd", "txt_flye", "txt_tall", "txt_haetskye", "ghostfren", "txt_ghostfren", "robobot", "txt_robobot", "sparkl", "txt_sparkl", "spik", "txt_spik", "spiky", "txt_spiky", "bordr", "txt_bordr", "txt_purp",
    nil
  },
  -- page 2: letters
  {
    "letter_a","letter_b","letter_c","letter_d","letter_e","letter_f","letter_g","letter_h","letter_i","letter_j","letter_k","letter_l","letter_m","letter_n","letter_o","letter_p","letter_q","letter_r",
    "letter_s","letter_t","letter_u","letter_v","letter_w","letter_x","letter_y","letter_z","letter_.","letter_colon","letter_parenthesis","letter_'","letter_/","letter_1","letter_2","letter_3","letter_4","letter_5",
    0,0,0,0,0,0,0,"letter_π","letter_$","letter_;","letter_>",0,0,"letter_6","letter_7","letter_8","letter_9","letter_o",
	"letter_go","letter_come","letter_pls","letter_away","letter_my","letter_no","letter_way","letter_ee","letter_fren","letter_ll","letter_bolt","letter_ol",0,0,0,"letter_*","txt_numa","txt_lethers",
	"txt_c_sharp","txt_d_sharp","txt_f_sharp","txt_g_sharp","txt_a_sharp","txt_sharp","txt_flat",0,0,0,0,0,0,0,0,0,0,0,
  },
  -- page 3: ui / instructions
  {
    "ui_esc",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "ui_tab","ui_q","ui_w","ui_e","ui_r","ui_t","ui_y","ui_u","ui_i","ui_o","ui_p","ui_[","ui_-","ui_=","ui_`","ui_7","ui_8","ui_9",
    "ui_cap","ui_a","ui_s","ui_d","ui_f","ui_g","ui_h","ui_j","ui_k","ui_l","ui_;","ui_'","ui_return",0,0,"ui_4","ui_5","ui_6",
    "ui_shift",0,"ui_z","ui_x","ui_c","ui_v","ui_b","ui_n","ui_m","ui_,","ui_.","ui_/",0,0,0,"ui_1","ui_2","ui_3",
    "ui_ctrl","ui_gui","ui_alt",0,"ui_space",0,0,0,0,0,0,0,0,0,0,"ui_arrow","ui_0","ui_del",
    "txt_press","txt_f1","txt_2pley","txt_f2","txt_2edit","ui_leftclick","ui_rightclick",0,0,0,0,0,0,0,0,0,"txt_yuiy","ui_box",
    0,"ui_walk",0,0,"ui_reset",0,0,"ui_undo",0,0,"ui_wait",0,0,"ui_activat",0,0,"ui_clik",0,0,0,0,
  },
  -- page 4: characters and special objects
  {
    "bab","txt_bab","kat","txt_kat","flof","txt_flof","babby","txt_babby","bad","txt_bad",0,0,0,0,"lila","txt_lila","larry","txt_larry",
    "keek","txt_keek","creb","txt_creb","shrim","txt_shrim","moo","txt_moo","toby","txt_toby",0,0,0,0,"pata","txt_pata","jill","txt_jill",
    "meem","txt_meem","statoo","txt_statoo","flamgo","txt_flamgo","migri","txt_migri","temmi","txt_temmi",0,0,0,0,"slab","txt_slab","zsoob","txt_zsoob",
    "skul","txt_skul","beeee","txt_beeee","gul","txt_gul","kva","txt_kva","bunmy","txt_bunmy",0,0,0,0,"notnat","txt_notnat","oat","txt_oat",
    "ghostfren","txt_ghostfren","fishe","txt_fishe","starrfishe","txt_starrfishe","pidgin","txt_pidgin",0,0,0,0,0,0,0,0,"butcher","txt_butcher",
    "robobot","txt_robobot","snek","txt_snek","sneel","txt_sneel","swan","txt_swan",0,0,0,0,0,0,0,0,0,0,
    "wog","txt_wog","bog","txt_bog","enbybog","txt_enbybog","spoder","txt_spoder","niko","txt_niko",0,0,0,0,0,0,0,0,
    "kirb","txt_kirb","ripof","txt_ripof","cavebab","txt_cavebab","detox","txt_detox","nyowo","txt_nyowo",0,0,0,0,0,0,0,0,
    "bup","txt_bup","butflye","txt_butflye","boooo","txt_boooo","prime","txt_prime","grimkid","txt_grimkid",0,0,0,0,0,0,0,0,
    "boy","txt_boy","wurm","txt_wurm","madi","txt_madi","angle","txt_angle","boogie","txt_boogie",0,0,0,0,0,0,0,0,
    "steev","txt_steev","ratt","txt_ratt","badi","txt_badi","dvl","txt_dvl","assh","txt_assh",0,0,0,0,0,0,0,0,
    "han","txt_han","iy","txt_iy","lisp","txt_lisp","paw","txt_paw","humuhumunukunukuapua'a","txt_humuhumunukunukuapua'a",0,0,0,0,0,0,0,0,
    "snoman","txt_snoman","pingu","txt_pingu","der","txt_der","ginn","txt_ginn","snom","txt_snom",0,0,0,0,0,0,0,0,
    "kapa","txt_kapa","urei","txt_urei","ryugon","txt_ryugon","viruse","txt_viruse",0,0,0,0,0,0,0,0,0,0,
    "os","txt_os","hors","txt_hors","mimi","txt_mimi","err","txt_err",0,0,0,0,0,0,0,0,0,0,
  },
  -- page 5: inanimate objects
  {
    "wal","txt_wal","bellt","txt_bellt","hurcane","txt_hurcane","buble","txt_buble","katany","txt_katany","petnygrame","txt_petnygrame","firbolt","txt_firbolt","hol","txt_hol","golf","txt_golf",
    "til","txt_til","arro","txt_arro","clowd","txt_clowd","snoflak","txt_snoflak","gunne","txt_gunne","scarr","txt_scarr","litbolt","txt_litbolt","rif","txt_rif","paint","txt_paint",
    "watr","txt_watr","colld","txt_colld","rein","txt_rein","icecub","txt_icecub","slippers","txt_slippers","pudll","txt_pudll","icbolt","txt_icbolt","win","txt_win","press","txt_press",
    "laav","txt_laav","dor","txt_dor","kee","txt_kee","roc","txt_roc","hatt","txt_hatt","extre","txt_extre","poisbolt","txt_poisbolt","smol","txt_smol","pumkin","txt_pumkin",
    "gras","txt_gras","algay","txt_algay","flog","txt_flog","boux","txt_boux","knif","txt_knif","heg","txt_heg","timbolt","txt_timbolt","tor","txt_tor","grav","txt_grav",
    "hedg","txt_hedg","banboo","txt_banboo","boll","txt_boll","l..uv","txt_l..uv","wips","txt_wips","pepis","txt_pepis","pixbolt","txt_pixbolt","dling","txt_dling","pen","txt_pen",
    "metl","txt_metl","vien","txt_vien","leef","txt_leef","karot","txt_karot","fir","txt_fir","eeg","txt_eeg","foreeg","txt_foreeg","forbeeee","txt_forbeeee","cil","txt_cil",
    "jail","txt_jail","ladr","txt_ladr","pallm","txt_pallm","coco","txt_coco","rouz","txt_rouz","noet","txt_noet","lili","txt_lili","weeb","txt_weeb","3den","txt_3den",
    "fenss","txt_fenss","platfor","txt_platfor","tre","txt_tre","stum","txt_stum","dayzy","txt_dayzy","lie","txt_lie","reffil","txt_reffil","ofin","txt_ofin","ches","txt_ches",
    "cobll","txt_cobll","spik","txt_spik","frut","txt_frut","fungye","txt_fungye","red","txt_red","lie/8","txt_lie/8","vlc","txt_vlc","foru","txt_foru","rod","txt_rod",
    "wuud","txt_wuud","spiky","txt_spiky","parsol","txt_parsol","clok","txt_clok","ufu","txt_ufu","rockit","txt_rockit","swim","txt_swim","yanying","txt_yanying","casete","txt_casete",
    "brik","txt_brik","sparkl","txt_sparkl","sanglas","txt_sanglas","bullb","txt_bullb","son","txt_son","muun","txt_muun","bac","txt_bac","warn","txt_warn","piep","txt_piep",
    "san","txt_san","piler","txt_piler","sancastl","txt_sancastl","shel","txt_shel","starr","txt_starr","cor","txt_cor","byc","txt_byc","gorder","txt_gorder","tuba","txt_tuba",
    "glas","txt_glas","bom","txt_bom","sine","txt_sine","kar","txt_kar","can","txt_can","ger","txt_ger","sirn","txt_sirn","chain","txt_chain","sloop","txt_sloop",
    0,0,"wut","txt_wut","wat","txt_wat","splittr","txt_splittr","toggl","txt_toggl","bon","txt_bon","battry","txt_battry","chekr","txt_chekr","do$h","txt_do$h",
  },
  -- page 6: more inanimate objects
  {
    "fube","txt_fube","tronk","txt_tronk","cart","txt_cart","drop","txt_drop","woosh","txt_woosh","tanc","txt_tanc","gato","txt_gato",0,0,0,0,
    "colect","txt_colect","zig","txt_zig","pixl","txt_pixl","prop","txt_prop","qb","txt_qb","panlie","txt_panlie",0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "whee","txt_whee","joycon","txt_joycon",0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,"wan","txt_wan","mug","txt_mug","die","txt_die",0,0,0,0,0,0,0,0,0,0,
    "sno","txt_sno","bel","txt_bel","wres","txt_wres","bowie","txt_bowie","sant","txt_sant","canedy","txt_canedy","bolble","txt_bolble","now","txt_now","cooky","txt_cooky",
    0,0,"pot","txt_pot","sweep","txt_sweep","candl","txt_candl","which","txt_which","corndy","txt_corndy","maglit","txt_maglit","cracc","txt_cracc",0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  },
  -- page 7: properties, verbs and conditions
  {
    "txt_be","txt_&","txt_got","txt_creat","txt_snacc","txt_spoop","txt_copkat","txt_moov","txt_yeet","txt_liek","txt_haet","txt_stalk","txt_ignor","txt_paint","txt_vs","txt_sing","txt_soko","txt_lookat",
    "txt_u","txt_utoo","txt_utres","txt_y'all","txt_w","txt_:)","txt_noswim","txt_ouch","txt_protecc",0,"txt_nxt","txt_stayther","txt_wont","txt_giv",0,"txt_rp",0,"txt_lookaway",
    "txt_go","txt_goooo","txt_icy","txt_icyyyy","txt_stubbn","txt_:(","txt_nedkee","txt_fordor","txt_wurd",0,0,"txt_infloop","txt_oob","txt_frenles","txt_timles","txt_lit","txt_corekt","txt_rong",
    "txt_nogo","txt_goawaypls","txt_comepls","txt_sidekik","txt_diagkik","txt_delet","txt_hotte","txt_fridgd","txt_thingify",0,"txt_dragbl","txt_nodrag","txt_alt","txt_clikt","txt_past","txt_wun","txt_an","txt_mayb",
    "txt_visitfren","txt_slep","txt_shy...","txt_behinu","txt_walk","txt_:o","txt_moar","txt_split","txt_txtify",0,"txt_rythm","txt_curse",0,"txt_wait...","txt_samefloat","txt_samepaint","txt_sameface",0,
    "txt_flye","txt_tall","txt_haetskye","txt_haetflor","txt_zomb","txt_un:)","txt_gone","txt_nuek","txt_notranform",0,0,0,0,"txt_w/fren","txt_arond","txt_sans","txt_seenby","txt_behind",
    "txt_diag","txt_ortho","txt_gomyway",0,0,0,0,0,0,0,0,0,0,"txt_that","txt_thatbe","txt_thatgot","txt_meow","txt_beside",
    "txt_turncornr","txt_folowal","txt_hopovr","txt_reflecc",0,0,0,0,0,0,0,0,0,"txt_reed","txt_orang","txt_yello","txt_grun","txt_cyeann",
    "txt_munwalk","txt_sidestep","txt_diagstep","txt_knightstep",0,"txt_tryagain","txt_noundo","txt_undo","txt_zawarudo","txt_brite","txt_torc","txt_tranparnt",0,"txt_bleu","txt_purp","txt_pinc","txt_whit","txt_graey",
    "txt_spin","txt_rotatbl","txt_noturn","txt_stukc",0,"txt_poortoll","txt_goarnd","txt_mirrarnd","txt_glued",0,0,0,0,0,"txt_rave","txt_colrful","txt_blacc","txt_brwn",
    "txt_upleft","txt_up","txt_upright","txt_thicc",0,"txt_her","txt_thr","txt_rithere","txt_the","txt_deez",0,0,0,0,"txt_stelth","txt_qt","txt_thonk","txt_cool",
    "txt_left","txt_direction","txt_right",0,0,0,0,0,0,0,0,0,0,"txt_gay","txt_lesbab","txt_tranz","txt_ace","txt_aro",
    "txt_downleft","txt_down","txt_downright",0,0,"selctr","txt_selctr","txt_frens","txt_groop","txt_gang","txt_themself",0,0,"txt_pan","txt_bi","txt_enby","txt_fluid","txt_πoly",
    0,0,0,0,0,"lvl","txt_lvl","txt_txt","txt_no1","txt_every1","txt_every2","this","txt_mous",0,0,0,0,0,
    "txt_...","txt_''","txt_nt","txt_anti",0,"bordr","txt_bordr","lin","txt_lin","txt_lethers","txt_numa","txt_toen","txt_yuiy",0,0,0,0,0,
  },
}
tile_grid_width = 18
tile_grid_height = 15

if settings["baba"] then
  table.insert(selector_grid_contents, {
    0,"txt_is",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "baba","txt_baba","txt_you",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    "txt_lesbad",0,0,0,0,0,0,0,0,0,0,0,0,0,0,"aaaaaa","therealqt","zawarudo",
    "txt_every3",0,0,0,0,0,0,0,0,0,0,0,0,"&","&n't","sans","copkat","ditto",
  })
end

special_objects = {"mous", "lvl", "bordr", "no1", "this"}