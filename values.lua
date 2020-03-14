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
  game_scale = "auto",
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
    0, "txt_be", "txt_&", "txt_got", "txt_n't", "txt_every1", "txt_no1", "txt_text", "txt_wurd", "txt_txtify", "txt_sublvl", "txt_wait...", "txt_mous", "txt_clikt", "txt_nxt", "txt_stayther", "lvl", "txt_lvl",
    "bab", "txt_bab", "txt_u", "kee", "txt_kee", "txt_fordor", "txt_goooo", "txt_icy", "txt_icyyyy", "txt_behinu", "txt_moar", "txt_sans", "txt_liek", "txt_loop", "lin", "txt_lin", "selctr", "txt_selctr",
    "keek", "txt_keek", "txt_walk", "dor", "txt_dor", "txt_nedkee", "txt_frens", "txt_groop", "txt_utoo", "txt_utres", "txt_delet", "txt_an", "txt_haet", "txt_mayb", "txt_that", "txt_ignor", "txt_curse", "txt_...",
    "flog", "txt_flog", "txt_:)", "colld", "txt_colld", "txt_fridgd", "txt_direction", "txt_ouch", "txt_slep", "txt_protecc", "txt_sidekik", "txt_brite", "txt_lit", "txt_tranparnt", "txt_torc", "txt_vs", "txt_nuek", "txt_''",
    "roc", "txt_roc", "txt_goawaypls", "laav", "txt_laav", "txt_hotte","txt_visitfren", "txt_w/fren", "txt_arond", "txt_frenles", "txt_copkat", "txt_zawarudo", "txt_timles", "txt_behind", "txt_beside", "txt_lookaway", "txt_notranform", "this",
    "wal", "txt_wal", "txt_nogo", "l..uv", "txt_l..uv", "gras", "txt_gras", "txt_creat", "txt_lookat", "txt_spoop", "txt_yeet", "txt_turncornr", "txt_corekt", "txt_goarnd", "txt_mirrarnd", "txt_past", 0, "txt_sing",
    "watr", "txt_watr", "txt_noswim", "meem", "txt_meem", "dayzy", "txt_dayzy", "txt_snacc", "txt_seenby" , "txt_stalk", "txt_moov", "txt_folowal", "txt_rong", "txt_her", "txt_thr", "txt_rithere", "txt_the", 0,
    "skul", "txt_skul", "txt_:(", "til", "txt_til", "hurcane", "txt_hurcane", "gunne", "txt_gunne", "wog", "txt_wog", "txt_zip", "txt_shy...", "txt_munwalk", "txt_sidestep", "txt_diagstep", "txt_hopovr", "txt_knightstep",
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
    0,0,0,0,0,0,0,0,0,"letter_;","letter_>",0,0,"letter_6","letter_7","letter_8","letter_9","letter_o",
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
    "bab","txt_bab","kat","txt_kat","flof","txt_flof","babby","txt_babby","bunmy","txt_bunmy",0,0,0,0,"selctr","txt_selctr","lvl","txt_lvl",
    "keek","txt_keek","creb","txt_creb","shrim","txt_shrim","moo","txt_moo","toby","txt_toby",0,0,0,0,"this","txt_mous","lin","txt_lin",
    "meem","txt_meem","statoo","txt_statoo","flamgo","txt_flamgo","migri","txt_migri","temmi","txt_temmi",0,0,0,0,0,"txt_frens","txt_groop","txt_gang",
    "skul","txt_skul","beeee","txt_beeee","gul","txt_gul","kva","txt_kva",0,0,0,0,0,0,"txt_no1","txt_every1","txt_every2","txt_every3",
    "ghostfren","txt_ghostfren","fishe","txt_fishe","starrfishe","txt_starrfishe","pidgin","txt_pidgin",0,0,0,0,0,0,"txt_text","txt_lethers","txt_numa","txt_toen",
    "robobot","txt_robobot","snek","txt_snek","sneel","txt_sneel","swan","txt_swan",0,0,0,0,0,0,0,"txt_themself","txt_yuiy","txt_xplod",
    "wog","txt_wog","bog","txt_bog","enbybog","txt_enbybog","spoder","txt_spoder",0,0,0,0,0,0,0,0,0,0,
    "kirb","txt_kirb","ripof","txt_ripof","cavebab","txt_cavebab","detox","txt_detox","nyowo","txt_nyowo",0,0,0,0,0,0,0,0,
    "bup","txt_bup","butflye","txt_butflye","boooo","txt_boooo","prime","txt_prime","grimkid","txt_grimkid",0,0,0,0,0,0,0,0,
    "boy","txt_boy","wurm","txt_wurm","madi","txt_madi","angle","txt_angle","boogie","txt_boogie",0,0,0,0,"lila","txt_lila","larry","txt_larry",
    "steev","txt_steev","ratt","txt_ratt","badi","txt_badi","dvl","txt_dvl","assh","txt_assh",0,0,0,0,"pata","txt_pata","jill","txt_jill",
    "han","txt_han","iy","txt_iy","lisp","txt_lisp","paw","txt_paw",0,0,0,0,0,0,"slab","txt_slab","zsoob","txt_zsoob",
    "snoman","txt_snoman","pingu","txt_pingu","der","txt_der","ginn","txt_ginn","snom","txt_snom",0,0,0,0,"notnat","txt_notnat","oat","txt_oat",
    "kapa","txt_kapa","urei","txt_urei","ryugon","txt_ryugon","viruse","txt_viruse",0,0,0,0,0,0,0,0,"butcher","txt_butcher",
    "os","txt_os","hors","txt_hors","mimi","txt_mimi","err","txt_err",0,0,0,0,0,0,0,0,0,0,
  },
  -- page 5: inanimate objects
  {
    "wal","txt_wal","bellt","txt_bellt","hurcane","txt_hurcane","buble","txt_buble","katany","txt_katany","petnygrame","txt_petnygrame","firbolt","txt_firbolt","hol","txt_hol","golf","txt_golf",
    "til","txt_til","arro","txt_arro","clowd","txt_clowd","snoflak","txt_snoflak","gunne","txt_gunne","scarr","txt_scarr","litbolt","txt_litbolt","rif","txt_rif","paint","txt_paint",
    "watr","txt_watr","colld","txt_colld","rein","txt_rein","icecub","txt_icecub","slippers","txt_slippers","pudll","txt_pudll","icbolt","txt_icbolt","win","txt_win","press","txt_press",
    "laav","txt_laav","dor","txt_dor","kee","txt_kee","roc","txt_roc","hatt","txt_hatt","extre","txt_extre","poisbolt","txt_poisbolt","smol","txt_smol","pumkin","txt_pumkin",
    "gras","txt_gras","algay","txt_algay","flog","txt_flog","boux","txt_boux","knif","txt_knif","heg","txt_heg","timbolt","txt_timbolt","tor","txt_tor","grav","txt_grav",
    "hedg","txt_hedg","banboo","txt_banboo","boll","txt_boll","l..uv","txt_l..uv","wips","txt_wips","pepis","txt_pepis","do$h","txt_do$h","dling","txt_dling","pen","txt_pen",
    "metl","txt_metl","vien","txt_vien","leef","txt_leef","karot","txt_karot","fir","txt_fir","eeg","txt_eeg","foreeg","txt_foreeg","forbeeee","txt_forbeeee","cil","txt_cil",
    "jail","txt_jail","ladr","txt_ladr","pallm","txt_pallm","coco","txt_coco","rouz","txt_rouz","noet","txt_noet","lili","txt_lili","weeb","txt_weeb","3den","txt_3den",
    "fenss","txt_fenss","platfor","txt_platfor","tre","txt_tre","stum","txt_stum","dayzy","txt_dayzy","lie","txt_lie","reffil","txt_reffil","ofin","txt_ofin","ches","txt_ches",
    "cobll","txt_cobll","spik","txt_spik","frut","txt_frut","fungye","txt_fungye","red","txt_red","lie/8","txt_lie/8","vlc","txt_vlc","foru","txt_foru","rod","txt_rod",
    "wuud","txt_wuud","spiky","txt_spiky","parsol","txt_parsol","clok","txt_clok","ufu","txt_ufu","rockit","txt_rockit","swim","txt_swim","yanying","txt_yanying","casete","txt_casete",
    "brik","txt_brik","sparkl","txt_sparkl","sanglas","txt_sanglas","bullb","txt_bullb","son","txt_son","muun","txt_muun","bac","txt_bac","warn","txt_warn","piep","txt_piep",
    "san","txt_san","piler","txt_piler","sancastl","txt_sancastl","shel","txt_shel","starr","txt_starr","cor","txt_cor","byc","txt_byc","gorder","txt_gorder","tuba","txt_tuba",
    "glas","txt_glas","bom","txt_bom","sine","txt_sine","kar","txt_kar","can","txt_can","ger","txt_ger","sirn","txt_sirn","chain","txt_chain","reflecr","txt_reflecr",
    "bordr","txt_bordr","wut","txt_wut","wat","txt_wat","splittr","txt_splittr","toggl","txt_toggl","bon","txt_bon","battry","txt_battry","chekr","txt_chekr","sloop","txt_sloop",
  },
  -- page 6: more inanimate objects
  {
    "gato","txt_gato","fube","txt_fube","tronk","txt_tronk","cart","txt_cart","drop","txt_drop","woosh","txt_woosh",0,0,0,0,0,0,
    "colect","txt_colect","zig","txt_zig","pixl","txt_pixl",0,0,0,0,0,0,0,0,0,0,0,0,
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
    "txt_u","txt_utoo","txt_utres","txt_y'all","txt_walk","txt_:)","txt_noswim","txt_ouch","txt_protecc",0,"txt_nxt","txt_stayther","txt_wont","txt_giv",0,"txt_rp",0,"txt_lookaway",
    "txt_go","txt_goooo","txt_icy","txt_icyyyy","txt_stubbn","txt_:(","txt_nedkee","txt_fordor","txt_wurd",0,"txt_sublvl","txt_loop","txt_oob","txt_frenles","txt_timles","txt_lit","txt_corekt","txt_rong",
    "txt_nogo","txt_goawaypls","txt_comepls","txt_sidekik","txt_diagkik","txt_delet","txt_hotte","txt_fridgd","txt_thingify",0,"txt_dragbl","txt_nodrag","txt_alt","txt_clikt","txt_past","txt_wun","txt_an","txt_mayb",
    "txt_visitfren","txt_slep","txt_shy...","txt_behinu",0,"txt_:o","txt_moar","txt_split","txt_txtify",0,"txt_rythm","txt_curse",0,"txt_wait...","txt_samefloat","txt_samepaint","txt_sameface",0,
    "txt_flye","txt_tall","txt_haetskye","txt_haetflor",0,"txt_un:)","txt_gone","txt_nuek","txt_notranform",0,0,0,0,"txt_w/fren","txt_arond","txt_sans","txt_seenby","txt_behind",
    "txt_diag","txt_ortho","txt_gomyway","txt_zip",0,"txt_B)","txt_cool",0,0,0,0,0,0,"txt_that","txt_thatbe","txt_thatgot","txt_meow","txt_beside",
    "txt_turncornr","txt_folowal","txt_hopovr","txt_reflecc",0,0,0,0,0,0,0,0,0,0,0,0,0,"txt_n't",
    "txt_munwalk","txt_sidestep","txt_diagstep","txt_knightstep",0,0,0,0,0,0,0,0,0,0,0,0,0,"txt_reed",
    "txt_spin","txt_rotatbl","txt_noturn","txt_stukc",0,0,0,0,0,0,0,0,0,0,0,0,"txt_enby","txt_orang",
    "txt_upleft","txt_up","txt_upright","txt_thicc",0,0,0,0,0,0,0,0,0,0,0,"txt_brwn","txt_tranz","txt_yello",
    "txt_left","txt_direction","txt_right",0,0,0,0,0,0,0,0,0,0,0,0,"txt_blacc","txt_gay","txt_grun",
    "txt_downleft","txt_down","txt_downright",0,0,"txt_tryagain","txt_noundo","txt_undo","txt_zawarudo","txt_brite","txt_torc","txt_tranparnt",0,0,0,"txt_graey","txt_qt","txt_cyeann",
    0,0,0,0,0,"txt_poortoll","txt_goarnd","txt_mirrarnd","txt_glued",0,0,0,0,0,"txt_thonk","txt_whit","txt_pinc","txt_bleu",
    "txt_...","txt_''","prop","txt_prop",0,"txt_her","txt_thr","txt_rithere","txt_the","txt_deez",0,0,0,0,"txt_stelth","txt_colrful","txt_rave","txt_purp",
  },
}
tile_grid_width = 18
tile_grid_height = 15

--[[
layer list:
1: bordr, and nothing else
2: full tile things (wal, watr, laav)
3: other "low" objects (gras, chekr, selctr)
4: bg objects (extre, pudll)
5: bg particles (sparkl, rein)
6: collectables (flog, boll)
7: objects that take a lot of area (boux, luv)
8: rest of objects
9: bg characters (skul)
10: characters that take a lot of area (boooo, lila)
11: rest of characters
19: fake text (prop)
20: text
21: text that is slightly bigger than other text (thicc, rithere)
22: fg objects (jail)
23: lins
24: lvls
100: the real bab dictator
]]

tiles_list = {
  -- 1
  {
    name = "bab",
    sprite = "bab",
    type = "object",
    color = {0, 3},
    layer = 11,
    rotate = true,
    sing = "s_doo",
    features = { sans = {x=22, y=10, w=2, h=2} },
    tags = {"chars", "baba"},
    desc = "its bab bruh",
    pronouns = {"she","her"},
  },
  -- 2
  {
    name = "txt_bab",
    sprite = "text/bab",
    metasprite = "text/bab meta",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"chars", "baba"},
    desc = "\"BAB\". thats what it says"
  },
  -- 3
  {
    name = "txt_be",
    sprite = "text/be",
    type = "text",
    texttype = {verb = true, verb_class = true, verb_property = true},
    color = {0, 3},
    layer = 20,
    tags = {"is"},
    desc = "BE (Verb): Causes the subject to become an object or have a property.",
  },
  -- 4
  {
    name = "txt_u",
    sprite = "text/u",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"you","p1", "player"},
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
    desc = "ston briks",
    pronouns = {"it"},
  },
  -- 6
  {
    name = "txt_wal",
    sprite = "text/wal",
    metasprite = "text/wal meta",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"wall"},
    desc = "uigi isn't gonna be in smash"
  },
  -- 7
  {
    name = "txt_nogo",
    sprite = "text/nogo",
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
    layer = 7,
    sing = "s_bdrum",
    tags = {"rock"},
    desc = "roc: not a bord"
  },
  -- 9
  {
    name = "txt_roc",
    sprite = "text/roc",
    metasprite = "text/roc meta",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"rock"},
  },
  -- 10
  {
    name = "txt_goawaypls",
    sprite = "text/goaway",
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
    desc = "for door",
  },
  -- 12
  {
    name = "txt_dor",
    sprite = "text/dor",
    metasprite = "text/dor meta",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"door"}
  },
  -- 13
  {
    name = "txt_nedkee",
    sprite = "text/nedkee",
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
    layer = 8,
    rotate = true,
    sing = "s_hiclose",
    tags = {"key"},
    desc = "needs key",
  },
  -- 15
  {
    name = "txt_kee",
    sprite = "text/kee",
    metasprite = "text/kee meta",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"key"},
  },
  -- 16
  {
    name = "txt_fordor",
    sprite = "text/fordor",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    tags = {"open"},
    desc = "FOR DOR: When a NED KEE and FOR DOR unit move into each other or are on each other, they are both destroyed.",
  },
  -- 17
  {
    name = "txt_&",
    sprite = "text/and",
    type = "text",
    texttype = {["and"] = true}, -- and is a reserved word
    color = {0, 3},
    layer = 20,
    alias = {"ampersand"},
    tags = {"and"},
    desc = "&: Joins multiple conditions, subjects or objects together in a rule. Can also be spelled as ampersand with letters. Rules with stacked text and &s don't work like in baba, be sure to experiment!\nTry thingifying an &n't text, since no one would ever think to try that considering &n'ts are useless.",
  },
  -- 18
  {
    name = "flog",
    sprite = "flog",
    type = "object",
    color = {2, 4},
    layer = 6,
    sing = "s_marim",
    tags = {"flag"},
    desc = "i want 1!!!",
  },
  -- 19
  {
    name = "txt_flog",
    sprite = "text/flog",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"flag"},
  },
  -- 20
  {
    name = "txt_:)",
    sprite = "text/good",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    features = { sans = {x=21, y=6, w=3, h=4} },
    tags = {"win", "smiley", "face", "happy", "yay"},
    desc = ":): At end of turn, if U is on :) and survives, U R WIN!",
  },
  -- 21
  {
    name = "til",
    sprite = "til",
    type = "object",
    color = {1, 0},
    layer = 3,
    tags = {"tile"},
    desc = "it goes under your feet"
  },
  -- 22
  {
    name = "watr",
    sprite = "watr",
    type = "object",
    color = {1, 3},
    layer = 2,
    desc = "splish sploosh",
    tags = {"water"},
  },
  -- 23
  {
    name = "txt_watr",
    sprite = "text/watr",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"water"},
  },
  -- 24
  {
    name = "txt_noswim",
    sprite = "text/noswim",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"sink"},
    desc = "NO SWIM: At end of turn, if a NO SWIM unit is touching another object, all objects on the tile are destroyed.",
  },

  -- 25
  {
    name = "txt_got",
    sprite = "text/got",
    type = "text",
    texttype = {verb = true, verb_class = true},
    color = {0, 3},
    layer = 20,
    tags = {"has"},
    desc = "GOT (Verb): Causes the subject to drop the object when destroyed.",
  },
  -- 26
  {
    name = "txt_colrful",
    sprite = "text/colrful",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    desc = "COLRFUL: Causes the unit to appear a variety of colours.",
  },
  -- 27
  {
    name = "txt_reed",
    sprite = "text/reed_cond",
    sprite_transforms = {
      property = "txt_reed"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {2, 2},
    layer = 20,
    tags = {"colors", "colours", "red"},
    desc = "REED: Causes the unit to appear red. Persistent and can be used as a prefix condition.",
  },
  -- 28
  {
    name = "txt_bleu",
    sprite = "text/bleu_cond",
    sprite_transforms = {
      property = "txt_bleu"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {1, 3},
    layer = 20,
    tags = {"colors", "colours", "blue"},
    desc = "BLEU: Causes the unit to appear blue. Persistent and can be used as a prefix condition.",
  },
  -- 29
  {
    name = "txt_tranz",
    sprite = "text/tranz-colored",
    type = "text",
    texttype = {property = true},
    color = {255, 255, 255},
    layer = 20,
    tags = {"trans"},
    desc = "TRANZ: Causes the unit to appear pink, white and baby blue. TRANZ objects are pinc, whit, and cyeann, and not any other colors.",
  },
  -- 30
  {
    name = "txt_gay",
    sprite = "text/gay-colored",
    type = "text",
    texttype = {property = true},
    color = {255, 255, 255},
    layer = 20,
    desc = "GAY: Causes the unit to appear rainbow coloured. GAY objects are reed, orang, yello, grun, bleu, and purp, and not any other colors.",
  },
  -- 31
  {
    name = "txt_mous",
    sprite = "text/mous",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"mouse","cursor"},
    desc = "MOUS: Refers to the mouse cursor. You can create, destroy and apply properties to mouse cursors!",
  },
  -- 32
  {
    name = "txt_boux",
    sprite = "text/boux",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"box"},
  },
  -- 33
  {
    name = "boux",
    sprite = "boux",
    type = "object",
    color = {6, 2},
    layer = 7,
    sing = "s_sdrum",
    desc = "ce n'est pas une boîte, c'est quelque chose DE MIEUX",
    tags = {"box"},
  },
  -- 34
  {
    name = "txt_skul",
    sprite = "text/skul",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"skull"},
  },
  -- 35
  {
    name = "skul",
    sprite = "skul",
    type = "object",
    color = {2, 1},
    layer = 9,
    rotate = true,
    sing = "s_saw",
    features = { sans = {x=21, y=8, w=4, h=4} },
    tags = {"skull"},
    desc = "evillllll",
  },
  -- 36
  {
    name = "txt_laav",
    sprite = "text/laav",
    type = "text",
    texttype = {object = true},
    color = {2, 3},
    layer = 20,
    tags = {"lava"},
  },
  -- 37
  {
    name = "laav",
    sprite = "watr",
    type = "object",
    color = {2, 3},
    layer = 2,
    tags = {"lava"},
    desc = "very hot. not hotte tho unless u make it",
  },
  -- 38
  {
    name = "txt_keek",
    sprite = "text/keek",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"keke", "chars"},
  },
  -- 39
  {
    name = "keek",
    sprite = "keek",
    type = "object",
    color = {2, 2},
    layer = 11,
    rotate = true,
    sing = "s_saw",
    features = { sans = {x=19, y=7, w=2, h=2} },
    tags = {"keke", "chars"},
    desc = "babs bff",
    pronouns = {"they","them"}, --i hope i'm remembering properly
  },
  -- 40
  {
    name = "txt_meem",
    sprite = "text/meem",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"chars"},
  },
  -- 41
  {
    name = "meem",
    sprite = "meem",
    type = "object",
    color = {3, 1},
    layer = 11,
    rotate = true,
    sing = "s_organ",
    features = { sans = {x=18, y=3, w=2, h=2} },
    tags = {"chars"},
    desc = "meem is the true philosopher of our time. babs 3ff",
    pronouns = {"he","him"},
  },
  -- 42
  {
    name = "txt_til",
    sprite = "text/til",
    metasprite = "text/til meta",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"tile"},
  },
  -- 43
  {
    name = "txt_text",
    sprite = "text/txt",
    metasprite = "text/txt meta",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"txt"},
    desc = "TXT: An object class referring to all text objects, or just a specific one if you write e.g. BAB TXT BE GAY.",
  },
  -- 44
  {
    name = "txt_os",
    sprite = "text/os",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"apple", "android", "windows", "linux", "operating system"},
  },
  -- 45
  {
    name = "os",
    sprite = "os",
    type = "object",
    color = {0, 3},
    layer = 10,
    rotate = "true",
    sing = "bit2",
    features = { sans = {x=14, y=8, w=2, h=2} },
    tags = {"apple", "android", "windows", "linux", "operating system"},
    desc = "OS: Its sprites changes with the user's Operating System!",
  },
  -- 46
  {
    name = "txt_slep",
    sprite = "text/slep",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"sleep"},
    desc = "SLEP: SLEP units can't move due to being U, WALK, COPKAT or SPOOPed.",
  },
  -- 47
  {
    name = "l..uv",
    sprite = "luv",
    type = "object",
    color = {4, 2},
    layer = 7,
    tags = {"love"},
    desc = "makes up the very fabric of reality of bab be u"
  },
  -- 48
  {
    name = "txt_l..uv",
    sprite = "text/luv",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    alias = {"l*v"},
    tags = {"love"},
    desc = "LÜV: To use with letters, you need an umlaut!",
  },
  -- 49
  {
    name = "frut",
    sprite = "frut",
    type = "object",
    color = {2, 2},
    layer = 6,
    rotate = "true",
    tags = {"fruit", "apple", "plants", "food"},
    desc = "babs favorite snacc. not to be confused with OS appl",
  },
  -- 50
  {
    name = "txt_frut",
    sprite = "text/frut",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"fruit", "apple", "plants", "food"},
  },
  -- 51
  {
    name = "tre",
    sprite = "tre",
    type = "object",
    color = {5, 2},
    layer = 4,
    rotate = "true",
    tags = {"tree", "plants"},
    desc = "tre is the creator of all plant life in bab"
  },
  -- 52
  {
    name = "txt_tre",
    sprite = "text/tre",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"tree", "plants"},
  },
  -- 53
  {
    name = "wog",
    sprite = "wog",
    type = "object",
    color = {2, 4},
    layer = 10,
    rotate = "true",
    sing = "s_strum",
    features = { sans = {x=16, y=9, w=3, h=3} },
    desc = "smol frens who own pointy tridents, play with explosives, and bake good cake. nobody knows how to describe more than one of them",
    tags = {"wug", "chars", "bird"},
  },
  -- 54
  {
    name = "txt_wog",
    sprite = "text/wog",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    desc = "wogs dream is to be a mad scientist and go evil with power using nothing but sheer linguistics. linguists' evil career options may be limited but that wont stop wog from trying their best",
    tags = {"wug", "chars", "bird"},
  },
  --tutorial sprites
  -- 55
  {
    name = "txt_press",
    sprite = "tutorial_press",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    desc = "PRESS: Make PRESS F2 <property> to do something upon pressing F. Only some properties, like :(, will work!"
  },
  -- 56
  {
    name = "txt_f2",
    sprite = "tutorial_f2",
    type = "text",
    texttype = {verb = true, verb_property = true},
    color = {0, 3},
    layer = 20,
    desc = "F2: Used with PRESS.",
  },
  -- 57
  {
    name = "txt_2edit",
    sprite = "tutorial_edit",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    desc = "EDIT: Make PRESS F2 EDIT to unlock the level editor!",
  },
  -- 58
  {
    name = "txt_2pley",
    sprite = "tutorial_play",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"txt_2pley"},
  },
  -- 59
  {
    name = "txt_f1",
    sprite = "tutorial_f1",
    type = "text",
    texttype = {verb = true, verb_property = true},
    color = {0, 3},
    layer = 20,
  },
  -- 60
  {
    name = "txt_:(",
    sprite = "text/bad",
    type = "text",
    texttype = {property = true},
    color = {2, 1},
    layer = 20,
    features = { sans = {x=20, y=6, w=4, h=4} },
    tags = {"defeat", "sad", "face", "aw"},
    desc = ":(: At end of turn, destroys any U objects on it.",
  },
  -- 61
  {
    name = "txt_walk",
    sprite = "text/walk",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"move"},
    desc = "WALK: Moves in a straight line each turn, bouncing off walls.",
  },
  -- 62
  {
    name = "txt_bup",
    sprite = "text/bup",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"toad", "simpleflips", "chars"},
  },
  -- 63
  {
    name = "bup",
    sprite = {"bup","no1","no1","no1"},
    color = {{6, 2},{2,4},{0,2},{0,3}},
    colored = {true,false,false,false},
    type = "object",
    layer = 11,
    rotate = true,
    sing = "s_steel",
    features = { sans = {x=23, y=19, w=3, h=3} },
    tags = {"toad", "simpleflips", "chars"},
    desc = "BUP: HELLO\nBUP DOES NOT WANT, BUP DOES NOT DREAM\nPLEASE HELP HIM\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  },
  -- 64
  {
    name = "txt_boll",
    sprite = "text/boll",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"orb", "ball"},
  },
  -- 65
  {
    name = "boll",
    sprite = "orrb",
    type = "object",
    color = {4, 1},
    layer = 6,
    tags = {"orb", "ball"},
    desc = "hnmm... roun. colecc",
  },
  -- 66
  {
    name = "txt_bellt",
    sprite = "text/bellt",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"belt"},
  },
  -- 67
  {
    name = "bellt",
    sprite = "bellt",
    type = "object",
    color = {1, 1},
    layer = 3,
    rotate = true,
    desc = "bells and bellts are both metal so theyre basically the same thing right? dont tell anyone",
    tags = {"belt"},
  },
  -- 68
  {
    name = "txt_:o",
    sprite = "text/whoa",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    features = { sans = {x=19, y=10, w=3, h=5} },
    tags = {"bonus", "woah", "whoa", "face"},
    desc = ":o: If U is on :o, the :o is collected. Bonus!",
  },
  -- 69
  {
    name = "txt_up",
    sprite = "text/up",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    nice = true,
    desc = "UP: A GO ->, but facing up.",
  },
  -- 70
  {
    name = "txt_direction",
    sprite = "text/direction",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    rotate = true,
    tags = {"go arrow", "up", "down", "left", "right","go ->","go^"},
    desc = "GO ->: The unit is forced to face the indicated direction. LOOKAT GO -> makes a unit look in that direction or is true if it is facing that direction. BEN'T GO -> prevents an object from facing that direction.",
  },
  -- 71
  {
    name = "txt_left",
    sprite = "text/left",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    nice = false,
    desc = "LEFT: A GO ->, but facing left.",
  },
  -- 72
  {
    name = "txt_down",
    sprite = "text/down",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    desc = "DOWN: A GO ->, but facing down.",
  },
  -- 73
  {
    name = "txt_behinu",
    sprite = "text/behinu",
    type = "text",
    texttype = {property = true},
    color = {3, 1},
    layer = 20,
    tags = {"swap", "edgy"},
    desc = "BEHIN U: BEHIN U units swap with everything on tiles they move into, and swap with units that move onto their tile, then face their swapee. Nothing personnel, kid.",
  },
  -- 74
  {
    name = "txt_w/fren",
    sprite = "text/wfren",
    metasprite = "text/wfren meta",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"on", "wfren"},
    desc = "W/ FREN (Infix Condition): True if the unit shares a tile with this object.\nDespite what it might look like, w/fren't doesn't work with letters.",
  },
  -- 75
  {
    name = "txt_lookat",
    sprite = "text/lookat",
    type = "text",
    texttype = {cond_infix = true, cond_infix_dir = true, verb = true, verb_unit = true},
    color = {0, 3},
    layer = 20,
    tags = {"follow", "facing", "lookat"},
    desc = "LOOK AT: As an infix condition, true if this object is on the tile in front of the unit. As a verb, makes the unit face this object at end of turn.",
  },
  -- 76
  {
    name = "txt_frenles",
    sprite = "text/frenles",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2, 2},
    layer = 20,
    tags = {"lonely", "friendless"},
    desc = "FRENLES (Prefix Condition): True if the unit is alone on its tile.",
  },
  -- 77
  {
    name = "txt_creat",
    sprite = "text/creat",
    type = "text",
    texttype = {verb = true, verb_class = true},
    color = {0, 3},
    layer = 20,
    tags = {"make", "create"},
    desc = "CREAT (Verb): At end of turn, the unit makes this object.",
  },
  -- 78
  {
    name = "txt_snacc",
    sprite = "text/snacc",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    allowconds = true,
    color = {2, 2},
    layer = 20,
    tags = {"eat", "consume"},
    desc = "SNACC (Verb): Units destroy any other unit that they SNACC on contact, like a conditional OUCH.",
  },
  -- 79
  {
    name = "kirb",
    sprite = "kirb",
    type = "object",
    color = {4, 2},
    layer = 10,
    rotate = true,
    sing = "s_spian",
    features = { sans = {x=21, y=9, w=2, h=2} },
    tags = {"kirby", "chars"},
    desc = "1, 2 oatmeal kirb be be a pincc guy"
  },
  -- 80
  {
    name = "txt_kirb",
    sprite = "text/kirb",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"kirby", "chars"},
  },
  -- 81
  {
    name = "gunne",
    sprite = "gunne",
    type = "object",
    color = {0, 3},
    layer = 8,
    rotate = true,
    tags = {"weapon"},
    desc = "all i wanna do is *bang* *bang* *bang* *bang*"
  },
  -- 82
  {
    name = "txt_gunne",
    sprite = "text/gunne",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"weapon"},
    desc = "GUNNE: Any object with GOT GUNNE will wield a GUNNE."
  },
  -- 83
  {
    name = "txt_ouch",
    sprite = "text/ouch",
    type = "text",
    texttype = {property = true},
    color = {1, 2},
    layer = 20,
    tags = {"weak"},
    desc = "OUCH: This unit is destroyed if it shares a tile with another object, or if it tries to move/be moved into and can't.",
  },
  -- 84
  {
    name = "tot",
    sprite = "tot",
    type = "object",
    color = {4, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=18, y=8, w=2, h=2} },
    tags = {"anni", "chars", "devs"},
    desc = "the bab equivalent of anni",
    pronouns = {"she","her"},
  },
  -- 85
  {
    name = "txt_tot",
    sprite = "text/tot",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"anni", "chars", "devs"},
  },
  -- 86
  {
    name = "txt_qt",
    sprite = "text/qt",
    type = "text",
    texttype = {property = true},
    color = {4, 2},
    layer = 20,
    demeta = "therealqt",
    tags = {"cute","lily"},
    desc = "QT: Makes the unit emit love hearts.",
  },
  -- 87
  {
    name = "oat",
    sprite = "o",
    type = "object",
    texttype = {object = true, letter = true},
    color = {2, 4},
    layer = 11,
    sing = "pipipi",
    features = { sans = {x=19, y=7, w=2, h=2} },
    tags = {"devs", "chars", "oatmealine", "puyopuyo tetris"},
    desc = "pi pi piiii!!!",
  },
  -- 88
  {
    name = "txt_oat",
    sprite = "text/oat",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"devs", "chars", "oatmealine", "puyopuyo tetris"},
  },
  -- 89
  {
    name = "han",
    sprite = "han",
    type = "object",
    color = {0, 3},
    layer = 9,
    rotate = true,
    tags = {"hand", "body part"},
    desc = "grab, then yeet"
  },
  -- 90
  {
    name = "txt_han",
    sprite = "text/han",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"hand", "body part"},
  },
  -- 91
  {
    name = "gras",
    sprite = "gras",
    type = "object",
    color = {5, 1},
    layer = 3,
    desc = "don step on it. or do step on it. ur choice",
    tags = {"grass", "plants"},
  },
  -- 92
  {
    name = "txt_gras",
    sprite = "text/gras",
    type = "text",
    texttype = {object = true},
    color = {5, 3},
    layer = 20,
    tags = {"grass", "plants"},
  },
  -- 93
  {
    name = "dayzy",
    sprite = "dayzy",
    type = "object",
    color = {3, 3},
    layer = 4,
    features = { sans = {x=10, y=7, w=3, h=3} },
    tags = {"violet", "daisy", "flower", "plants"},
    desc = "dayzy me rollin, they haetin",
  },
  -- 94
  {
    name = "txt_dayzy",
    sprite = "text/dayzy",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"violet", "daisy", "flower", "plants"},
  },
  -- 95
  {
    name = "hurcane",
    sprite = "hurcane",
    type = "object",
    color = {3, 1},
    layer = 4,
    tags = {"hurricane","tornado"},
    desc = "woosh swoosh vwoosh aaaa",
    features = { sans = {x=15, y=15, w=3, h=3} },
  },
  -- 96
  {
    name = "txt_hurcane",
    sprite = "text/hurcane",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"hurricane","tornado"},
  },
  -- 97
  {
    name = "hatt",
    sprite = "hat",
    type = "object",
    color = {3, 1},
    layer = 7,
    tags = {"clothing"},
    desc = "a hatt n tim"
  },
  -- 98
  {
    name = "txt_hatt",
    sprite = "text/hatt",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"clothing"},
    desc = "HATT: Any object with GOT HATT will wear a HATT. (Aesthetic)"
  },
  -- 99
  {
    name = "press",
    sprite = "press",
    type = "object",
    color = {0, 3},
    layer = 20,
    desc = "it presses buttons"
  },
  -- 100
  {
    name = "txt_yeet",
    sprite = "text/yeet",
    type = "text",
    texttype = {verb = true, verb_unit = true, verb_direction = true},
    allowconds = true,
    color = {0, 3},
    layer = 20,
    tags = {"throw"},
    desc = "YEET (Verb): This unit will force things it yeets in its tile to hurtle across the level in its facing direction (until it hits an object that stops it). YEET GO^ makes the object fall in that direction.",
  },
  -- 101
  {
    name = "txt_go",
    sprite = "text/go",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"shift"},
    desc = "GO: This unit will force all other objects in its tile to move in its facing direction.",
  },
  -- 102
  {
    name = "txt_icy",
    sprite = "text/icy",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"slip", "patashu"},
    desc = "ICY: Objects on something ICY are forced to move in their facing direction until they either leave the ice or can't move any further.",
  },
  -- 103
  {
    name = "txt_delet",
    sprite = "text/delet",
    type = "text",
    texttype = {property = true},
    color = {2, 2},
    layer = 20,
    features = { sans = {x=19, y=5, w=4, h=5} },
    tags = {"crash", "oops", "fucky wucky", "xwx", "delete"},
    desc = "DELET: At end of turn, if U is on DELET, you get booted out of the level and erases all progress in the level (win, bonus, transformation).",
  },
  -- 104
  {
    name = "txt_sublvl",
    sprite = "text/sublvl",
    type = "text",
    texttype = {property = true},
    color = {4,1},
    layer = 20,
    tags = {"lvl", "level", "sublevel"},
    desc = "SUBLVL: An object that is sublvl will become enterable. Currently unimplemented.",
  },
  -- 105
  {
    name = "txt_comepls",
    sprite = "text/comepls",
    type = "text",
    texttype = {property = true},
    color = {6, 2},
    layer = 20,
    tags = {"pull"},
    desc = "COME PLS: Pulled by movement on adjacent tiles facing away from this unit.",
  },
  -- 106
  {
    name = "txt_sidekik",
    sprite = "text/sidekik",
    type = "text",
    texttype = {property = true},
    color ={6, 1},
    layer = 20,
    tags = {"sidekick"},
    desc = "SIDEKIK: If a unit moves perpendicularly away from a SIDEKIK, the SIDEKIK copies that movement.",
  },
  -- 107
  {
    name = "txt_arond",
    sprite = "text/arond",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"near", "around"},
    desc = "AROND (Infix Condition): True if the indicated object is on any of the tiles surrounding the unit. (The unit's own tile is not checked.) ORTHO/DIAG AROND will only check the tiles orthogonally or diagonally. GO^ AROND will only check the tile in that direction.",
  },
  -- 108
  {
    name = "chekr",
    sprite = "chekr",
    type = "object",
    color ={3, 2},
    layer = 3,
    tags = {"checker","diamond"},
    desc = "ya wannna ploy checkrz?"
  },
  -- 109
  {
    name = "txt_chekr",
    sprite = "text/chekr",
    type = "text",
    texttype = {object = true},
    color ={3, 2},
    layer = 20,
    tags = {"checker","diamond"},
  },
  -- 110
  {
    name = "txt_diag",
    sprite = "text/diag",
    type = "text",
    texttype = {property = true, direction = true},
    color = {3, 2},
    layer = 20,
    tags = {"direction","diagonal"},
    desc = "DIAG: Prevents the unit from moving orthogonally, unless it is also ORTHO. Also affects rule parsing.",
  },
  -- 111
  {
    name = "txt_gomyway",
    sprite = "text/gomywey",
    type = "text",
    texttype = {property = true},
    color ={1, 3},
    layer = 20,
    tags = {"oneway", "go my wey"},
    desc = "GO MY WAY: Prevents movement onto its tile from the tile in front of it and the two tiles 45 degrees to either side.",
  },
  -- 112
  {
    name = "txt_ortho",
    sprite = "text/ortho",
    type = "text",
    texttype = {property = true, direction = true},
    color ={3, 2},
    layer = 20,
    tags = {"direction","orthogonal"},
    desc = "ORTHO: Prevents the unit from moving diagonally, unless it is also DIAG. Also affects rule parsing.",
  },
  -- 113
  {
    name = "arro",
    sprite = "arro",
    type = "object",
    color ={0, 3},
    layer = 3,
    rotate = true,
    tags = {"arrow"},
    desc = "ARRO: Is supposed to act like a letter, but that's not implemented yet.",
  },
  -- 114
  {
    name = "txt_arro",
    sprite = "text/arro",
    type = "text",
    texttype = {object = true},
    color ={0, 3},
    layer = 20,
    tags = {"arrow"},
  },
  -- 115
  {
    name = "txt_hotte",
    sprite = "text/hotte",
    type = "text",
    texttype = {property = true},
    color = {2, 3},
    layer = 20,
    tags = {"hot"},
    desc = "HOTTE: At end of turn, HOTTE units destroys all units that are FRIDGD on their tile.",
  },
  -- 116
  {
    name = "txt_fridgd",
    sprite = "text/fridgd",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"melt"},
    desc = "FRIDGD: At end of turn, HOTTE units destroys all units that are FRIDGD on their tile.",
  },
  -- 117
  {
    name = "txt_colld",
    sprite = "text/colld",
    type = "text",
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    tags = {"ice"},
  },
  -- 118
  {
    name = "colld",
    sprite = "colld",
    type = "object",
    color = {1, 4},
    layer = 3,
    desc = "nothin says colld like diagonal lines",
    tags = {"ice"},
  },
  -- 119
  {
    name = "txt_goooo",
    sprite = "text/goooo",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"shift"},
    desc = "GOOOO: The instant an object steps on a GOOOO unit, it is forced to move in the GOOOO unit's direction.",
  },
  -- 120
  {
    name = "txt_icyyyy",
    sprite = "text/icyyyy",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"slip", "slide", "patashu"},
    desc = "ICYYYY: The instant an object steps on an ICYYYY unit, it is forced to move again.",
  },
  -- 121
  {
    name = "txt_protecc",
    sprite = "text/protecc",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"safe", "protect"},
    desc = "PROTECC: Cannot be destroyed (but can be converted).",
  },
  -- 122
  {
    name = "txt_flye",
    sprite = "text/flye",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"float"},
    desc = "FLYE: A FLYE unit doesn't interact with other objects on its tile, and can ignore the collision of other objects, unless that other object has the same amount of FLYE as the unit. FLYE stacks with itself! Also pushing can occur regardless of flye.",
  },
  -- 123
  {
    name = "txt_piler",
    sprite = "text/piler",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"pillar"},
  },
  -- 124
  {
    name = "piler",
    sprite = "piler",
    type = "object",
    color = {0, 1},
    layer = 3,
    desc = "secretly made from several pairs of pliers sacrificed to keepin babs out (or in)",
    tags = {"pillar"},
  },
  -- 125
  {
    name = "txt_n't",
    sprite = "text/nt",
    type = "text",
    texttype = {["not"] = true}, -- not is a reserved word
    color = {2, 2},
    layer = 20,
    tags = {"not", "nt"},
    desc = "N'T: A suffix that negates the meaning of a verb, condition or object class. X txtn't will refer to all txt except that one.",
  },
  -- 126
  {
    name = "txt_haetskye",
    sprite = "text/haetskye",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"fall", "gravity"},
    desc = "HAET SKYE: After movement, this unit falls DOWN as far as it can.",
  },
  -- 127
  {
    name = "clowd",
    sprite = "clowd",
    type = "object",
    color = {0, 3},
    rotate = true,
    layer = 6,
    tags = {"cloud"},
    desc = "clowd and rein are good frens. not bffs though, clowd's bff is tifa"
  },
  -- 128
  {
    name = "txt_clowd",
    sprite = "text/clowd",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"cloud"},
  },
  -- 129
  {
    name = "txt_moar",
    sprite = "text/moar",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"more"},
    desc = "MOAR: At end of turn, this unit replicates to all free tiles that are orthogonally adjacent. MOAR stacks with itself; note that at 3+ you can go through walls!",
  },
  -- 130
  {
    name = "txt_visitfren",
    sprite = "text/visitfren",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"warp", "teleport", "portal"},
    desc = "VISIT FREN: At end of turn, all other objects are sent to the next VISIT FREN unit with the same name in reading order (left to right, line by line, wrapping around). Higher levels of VISIT FREN will cause the target to be 1 backward, 2 forward, 2 backward, etc.",
  },
  -- 131
  {
    name = "infloop",
    sprite = "text/infloop",
    type = "object",
    color = {0, 3},
    layer = 21,
    tags = {"infinity", "infinite", "loop"},
  },
  -- 132
  {
    name = "txt_wait...",
    sprite = "text/wait",
    metasprite = "text/wait meta",
    type = "text",
    texttype = {cond_prefix = true},
    color = {0, 3},
    layer = 20,
    tags = {"idle"},
    desc = "WAIT... (Prefix Condition): True if the player waited last input. (This does not include clicks.)",
  },
  -- 133
  {
    name = "txt_sans",
    sprite = "text/sans",
    metasprite = "text/sans meta",
    sprite_transforms = {
      property = "txt_sans_property"
    },
    type = "text",
    texttype = {cond_infix = true, property = true},
    color = {1, 4},
    layer = 20,
    tags = {"without", "w/o"},
    desc = "SANS (Infix Condition): True if none of the indicated object exist in the level. Does not include itself (so BAB SANS BAB is true if there is only one bab in the level).",
  },
  -- 134
  {
    name = "txt_spoop",
    sprite = "text/spoop",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {2, 2},
    layer = 20,
    tags = {"fear", "spook"},
    desc = "SPOOP (Verb): A SPOOPY unit forces all objects it SPOOPS on adjacent tiles to move away!",
  },
  -- 135
  {
    name = "txt_stalk",
    sprite = "text/stalk",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {5, 2},
    layer = 20,
    tags = {"follow", "find", "cg5"},
    desc = "STALK (Verb): If X stalks Y, X becomes an intelligent AI determined to get to Y. If it's also STUBBN, it'll try to track through walls if it can't reach its target. (actually that's not implemented yet)"
  },
  -- 136
  {
    name = "txt_stelth",
    sprite = "text/stelth",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"stealth", "hide"},
    desc = "STELTH: A STELTHy unit doesn't draw. STELTHy text won't appear in the rules list... kinda",
  },
  -- 137
  {
    name = "pata",
    sprite = "pata",
    type = "object",
    color = {3, 3},
    layer = 11,
    rotate = true,
    sing = "pata1",
    features = { sans = {x=17, y=4, w=1, h=2} },
    tags = {"devs", "chars", "patashu"},
    desc = "pat a shoe"
  },
  -- 138
  {
    name = "txt_pata",
    sprite = "text/pata",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"devs", "chars", "patashu"},
  },
  -- 139
  {
    name = "larry",
    sprite = "larry",
    type = "object",
    color = {2, 4},
    layer = 11,
    rotate = true,
    sing = "s_vitellary",
    features = {
      sans = {x=18, y=4, w=2, h=2},
      
      which = {x=-3, y=-5},
      hatt = {x=-2, y=-6},
      sant = {x=-6,y=-3},
      bowie = {x=-2,y=-6},
      cool = {x=-4, y=-7},
      
      katany = {x=4,y=-4},
      knif = {x=9,y=-2},
      gunne = {x=5,y=-1}
    },
    tags = {"devs", "chars", "vitellary", "vvvvvv"},
    desc = "larry be haetflor",
  },
  -- 140
  {
    name = "txt_larry",
    sprite = "text/larry",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"devs", "chars", "vitellary", "vvvvvv"},
  },
  -- 141
  {
    name = "lila",
    sprite = "lila",
    color = {4, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=19, y=8, w=2, h=2} },
    tags = {"devs", "chars", "lily", "lili"},
    desc = "lila, represents the creator of bab be u herself! all hail lila",
    pronouns = {"she","her"},
  },
  -- 142
  {
    name = "txt_lila",
    sprite = "text/lila",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"devs", "chars", "lily", "lili"},
  },
  -- 143
  {
    name = "txt_every1",
    sprite = "text/every1",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"all", "everyone", "every1"},
    desc = "EVERY1: Every object type in the level, aside from special objects like TXT, NO1, LVL, BORDR, and MOUS.",
  },
  -- 144
  {
    name = "txt_tall",
    sprite = "text/tall",
    type = "text",
    texttype = {property = true},
    color = {0, 1},
    layer = 20,
    desc = "TALL: Considered to be every FLYE amount at once.",
  },
  -- 145
  {
    name = "txt_liek",
    sprite = "text/liek",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    allowconds = true,
    color = {5, 3},
    layer = 20,
    tags = {"bounded", "likes"},
    desc = "LIEK (Verb): If a unit LIEKs objects, it is picky, and cannot step onto a tile unless it has at least one object it LIEKs. If an object LIEKs zero objects, it is not bounded.",
  },
  -- 146
  {
    name = "txt_zip",
    sprite = "text/zip",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    desc = "ZIP: At end of turn, if it is on a tile it couldn't enter or shares a tile with another object of its name, it finds the nearest free tile (preferring backwards directions) and ejects to it.",
  },
  -- 147
  {
    name = "txt_shy...",
    sprite = "text/shy",
    type = "text",
    texttype = {property = true},
    color = {6, 2},
    layer = 20,
    tags = {"patashu"},
    desc = "SHY...: Can't initiate or continue a goawaypls, comepls, sidekik, or diagkik movement, and can look away from those objects, sometimes."
  },
  -- 148
  {
    name = "txt_folowal",
    sprite = "text/folo_wal",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"follow wall"},
    desc = "FOLO WAL: At end of turn, faces the first direction that it could enter and that doesn't have another unit of its name: right, forward, left, backward. When combined with WALK, causes the unit to follow the right wall.",
  },
  -- 149
  {
    name = "txt_turncornr",
    sprite = "text/turn_cornr",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"turn corner"},
    desc = "TURN CORNR: At end of turn, faces the first direction that it could enter and that doesn't have another unit of its name: forward, right, left, backward. When combined with WALK, causes the unit to bounce off walls at 90 degree angles.",
  },
  -- 150
  {
    name = "petnygrame",
    sprite = "petnygrame",
    color = {2, 1},
    layer = 4,
    tags = {"pentagram", "edgy"},
    desc = "perform the ritual to summon the real bab dictator"
  },
  -- 151
  {
    name = "txt_petnygrame",
    sprite = "text/petnygrame",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"pentagram", "edgy"},
  },
  -- 152
  {
    name = "katany",
    sprite = "katany",
    color = {0, 1},
    layer = 8,
    rotate = true,
    tags = {"weapon", "japan", "asia", "edgy"},
    desc = "very very weeb. make steev got katany and you will know"
  },
  -- 153
  {
    name = "txt_katany",
    sprite = "text/katany",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    alias = {"katanya"},
    tags = {"weapon", "japan", "asia", "edgy"},
    desc = "KATANY: Any object with GOT KATANY will have a KATANY."
  },
  -- 154
  {
    name = "scarr",
    sprite = "scarr",
    color = {2, 1},
    layer = 4,
    tags = {"scar", "edgy"},
    desc = "it's not blood it's just cranberry juice. no violence in my bab"
  },
  -- 155
  {
    name = "txt_scarr",
    sprite = "text/scarr",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"scar", "edgy"},
  },
  -- 156
  {
    name = "txt_no1",
    sprite = "text/no1",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"none","empty", "no one"},
    desc = "NO1: Refers to tiles with nothing in them. Rotation status is kept on the tile. Cannot be colored."
  },
  -- 157
  {
    name = "no1",
    sprite = "no1",
    type = "object",
    color = {0, 4},
    layer = 20,
    rotate = true,
  },
  -- 158
  {
    name = "txt_lvl",
    sprite = "text/lvl",
    metasprite = "text/lvl meta",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"level"},
    desc = "LVL: Refers to the level you're in, as well as any enterable levels in this level. \nMiddle or SHIFT right-click it to edit.)\nCreating levels will be a samepaint lvl.\nlvl be pathz by default.\nlvl got X will trigger even if the level infloops."
  },
  -- 159
  {
    name = "txt_nxt",
    sprite = "text/nxt",
    type = "text",
    texttype = {property = true},
    color = {0,3},
    layer = 20,
    --alias = {"nxt"},
    features = { sans = {x=19, y=5, w=3, h=4} },
    tags = {"next", "nxt", ":>", ";."},
    desc = "nxt: If U is on nxt, go to the next level (specified in object settings)."
  },
  -- 160
  {
    name = "pepis",
    sprite = {"pepis","pepis_red","pepis_blue"},
    color = {{0,3},{2,2},{1,2}},
    colored = {false,true,true},
    layer = 7,
    tags = {"bepis", "pepsi"},
    desc = "pepis: tastes like tar and mud",
  },
  -- 161
  {
    name = "txt_pepis",
    sprite = "text/pepis",
    type = "text",
    texttype = {object = true},
    color = {3, 2},
    layer = 20,
    tags = {"bepis", "pepsi"},
  },
  -- 162
  {
    name = "txt_copkat",
    sprite = "text/copkat",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {0, 3},
    layer = 20,
    tags = {"copycat", "lily"},
    desc = "COPKAT (Verb): COPKAT units copy the successful movements of the indicated object, no matter how far away."
  },
  -- 163
  {
    name = "clok",
    sprite = "clok",
    type = "object",
    color = {3, 3},
    layer = 8,
    rotate = true,
    sing = "tick",
    features = { sans = {x=14, y=14, w=3, h=3} },
    tags = {"clock", "time"},
    desc = "keek look at'd the clok. 'oh no! im late for school!' keek shouted and raced out of bed."
  },
  -- 164
  {
    name = "txt_clok",
    sprite = "text/clok",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"clock", "time"},
  },
  -- 165
  {
    name = "txt_tryagain",
    sprite = "text/try again",
    type = "text",
    texttype = {property = true},
    color = {3, 3},
    layer = 20,
    --alias = {"try again"},
    features = { sans = {x=21, y=6, w=3, h=4} },
    tags = {"retry", "time", "reset", "lily", ":/", ";/"},
    desc = "TRY AGAIN: When U is on TRY AGAIN, the level is undone back to the starting state, except for NO UNDO objects. TRY AGAIN can be undone!"
  },
  -- 166
  {
    name = "txt_noundo",
    sprite = "text/noundo",
    type = "text",
    texttype = {property = true},
    color = {5, 3},
    layer = 20,
    tags = {"persist", "time", "lily"},
    desc = "NO UNDO: NO UNDO units aren't affected by undoing manually. LVL BE NO UNDO prevents undo inputs entirely.",
  },
  -- 167
  {
    name = "zsoob",
    sprite = "zsoob",
    type = "object",
    color = {4,1},
    layer = 11,
    rotate = true,
    features = { sans = {x=17, y=9, w=2, h=2} },
    tags = {"devs","chars","szoob"},
    desc = "pinc keke",
  },
  -- 168
  {
    name = "txt_zsoob",
    sprite = "text/zsoob",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"devs","chars","szoob"},
  },
  -- 169
  {
    name = "txt_mayb",
    sprite = "text/mayb",
    type = "text",
    texttype = {cond_prefix = true},
    color = {0, 3},
    layer = 20,
    rotate = true,
    tags = {"/", "maybe", "random", "rng", "patashu"},
    desc = "? (MAYBE) (Prefix Condition): Has a chance of being true, independent for each MAYBE, affected unit and turn. The number on top indicates the % chance of being true. Compatible with N'T.",
  },
  -- 170
  {
    name = "txt_stubbn",
    sprite = "text/stubbn",
    type = "text",
    texttype = {property = true},
    color = {6, 1},
    layer = 20,
    tags = {"stubborn","patashu"},
    desc = "STUBBN: STUBBN units ignore the special properties of WALK movers (bouncing off of walls, and declining to move if it would die due to being OUCH) and also makes attempted diagonal movement slide along walls. Stacks with itself - the more STUBBN, the more additional angles it will try, up to 180 degrees at 5 stacks! (2 stacks allows for 45 degree movement orthogonally.)",
  },
  -- 171
  {
    name = "txt_seenby",
    sprite = "text/seenby",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"seenby", "looked at", "in front"},
    desc = "SEEN BY (Infix Condition): True if an indicated object is looking at this unit from an adjacent tile.",
  },
  -- 172
  {
    name = "steev",
    sprite = "steev",
    type = "object",
    color = {2,3},
    layer = 11,
    rotate = true,
    sing = "dog",
    features = { 
      sans = {x=20, y=13, w=2, h=2},
      katany = {nya = true},
    },
    tags = {"chars", "5 step steve", "cat"},
    desc = "can only moov 5 steps b4 dyin nya",
  },
  -- 173
  {
    name = "txt_steev",
    sprite = "text/steev",
    type = "text",
    texttype = {object = true},
    color = {2,3},
    layer = 20,
    tags = {"chars", "5 step steve", "cat"},
  },
  -- 174
  {
    name = "txt_goarnd",
    sprite = "text/goarnd",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"wrap around", "go around", "cg5"},
    desc = "GO ARND: GO ARND units wrap around the level, as though it were a torus. BORDR objects are used as the level border, and the wraparound doesn't go through BORDRs. Diagonal GO ARNDs on corners of non-square levels might not work as expected, as it simply traces backward until hitting a BORDR.",
  },
  -- 175
  {
    name = "txt_poortoll",
    sprite = "text/poortoll",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"portal","cg5"},
    desc = "POOR TOLL: If a unit would enter a POOR TOLL unit, it instead leaves the next POOR TOLL unit of the same name in reading order (left to right, line by line, wrapping around) out the corresponding same side. Does not stack.",
  },
  -- 176
  {
    name = "splittr",
    sprite = "splittr",
    type = "object",
    color = {0, 3},
    layer = 4,
    rotate = true,
    tags = {"splitter", "5 step"},
    features = { sans = {x=22,y=12,w=3,h=5} },
    desc = "specifically made to be used with SPLIT because it looks horrible otherwise (but other tiles like CHAIN can also work)."
  },
  -- 177
  {
    name = "txt_splittr",
    sprite = "text/splittr",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"splitter", "5 step"},
  },
  -- 178
  {
    name = "txt_split",
    sprite = "text/split",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"splitter", "5 step"},
    desc = "SPLIT: Objects on a SPLITer are split into two copies on adjacent tiles.",
  },
  -- 179
  {
    name = "txt_cilindr",
    sprite = "text/cilindr",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    rotate = true,
    tags = {"cyllinder","space", "wrap"},
    desc = "CILINDR: CILINDR units wrap around the level, as though it were a cylinder with the indicated orientation.",
  },
  -- 180
  {
    name = "txt_mobyus",
    sprite = "text/mobyus",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    rotate = true,
    tags = {"mobius","space", "wrap"},
    desc = "MOBYUS: MOBYUS units wrap around the level, as though it were a mobius strip with the indicated orientation.",
  },
  -- 181
  {
    name = "txt_munwalk",
    sprite = "text/munwalk",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"moonwalk","patashu"},
    desc = "MUNWALK: MUNWALK units move 180 degrees opposite of their facing direction. Stacks will cancel each other out.",
  },
  -- 182
  {
    name = "txt_mirrarnd",
    sprite = "text/mirrarnd",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"mirror around","cg5", "space", "wrap"},
    desc = "MIRR ARND: MIRR ARND units wrap around the level, as though it were a projective plane.",
  },
  -- 183
  {
    name = "txt_sidestep",
    sprite = "text/sidestep",
    type = "text",
    texttype = {property = true},
    color = {1, 3},
    layer = 20,
    tags = {"patashu", "drunk"},
    desc = "SIDESTEP: SIDESTEP units move 90 degrees clockwise off of their facing direction. Stacks!",
  },
  -- 184
  {
    name = "txt_diagstep",
    sprite = "text/diagstep",
    type = "text",
    texttype = {property = true},
    color = {3, 2},
    layer = 20,
    tags = {"patashu", "drunker"},
    desc = "DIAGSTEP: DIAGSTEP units move 45 degrees clockwise off of their facing direction. Stacks!",
  },
  -- 185
  {
    name = "txt_hopovr",
    sprite = "text/hopovr",
    type = "text",
    texttype = {property = true},
    color = {5, 2},
    layer = 20,
    tags = {"patashu", "skip"},
    desc = "HOPOVR: HOPOVR units move two tiles ahead, skipping the intermediate tile. Stacks!",
  },
  -- 186
  {
    name = "txt_undo",
    sprite = "text/undo",
    type = "text",
    texttype = {property = true},
    color = {6, 1},
    layer = 20,
    tags = {"time", "back"},
    desc = "UNDO: UNDO units, at end of turn, rewind a turn earlier, cumulatively. Stacks!",
  },
  -- 187
  {
    name = "boy",
    sprite = "boy",
    type = "object",
    color = {0, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=14, y=15, w=2, h=5} },
    tags = {"chars"},
    desc = "he's upsidedown b/c he lives on a Boy's surface"
  },
  -- 188
  {
    name = "txt_boy",
    sprite = "text/boy",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"chars"},
  },
  -- 189
  {
    name = "txt_spin",
    sprite = "text/spin",
    type = "text",
    texttype = {property = true, direction=true},
    color = {4, 1},
    layer = 20,
    rotate = true,
    tags = {"rotate","lily"},
    desc = "SPIN: A GO^ facing the same direction as the unit is facing, rotated clockwise the number of times on top of the property.",
  },
  -- 190
  {
    name = "lvl",
    sprite = "lvl",
    type = "object",
    color = {0,3},
    layer = 2,
  },
  -- 191
  {
    name = "txt_slippers",
    sprite = "text/slippers",
    type = "text",
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    desc = "SLIPPERS: An object that GOT SLIPPERS will ignore ICY and ICYYYYY objects (and wear SLIPPERS)."
  },
  -- 192
  {
    name = "slippers",
    sprite = "slippers",
    type = "object",
    color = {1, 3},
    layer = 8,
    desc = "the goomba that lived in this shoe is now homeless. how do you feel"
  },
  -- 193
  {
    name = "ghostfren",
    sprite = "ghost",
    type = "object",
    color = {4, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=26, y=10, w=2, h=4} },
    sing = "s_sine",
    desc = "its not spooky, its a fren.",
    tags = {"chars"},
  },
  -- 194
  {
    name = "txt_ghostfren",
    sprite = "text/ghostfren",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    desc = "this text is very spooky tho",
    tags = {"chars"},
  },
  -- 195
  {
    name = "robobot",
    sprite = "robobot",
    type = "object",
    color = {6, 1},
    layer = 11,
    rotate = true,
    sing = "bit2",
    features = { sans = {x=17, y=7, w=2, h=4} },
    desc = "the super scan mouth lazers that copy abilities are missing because they forgot to design a mouth",
    tags = {"robot", "chars"},
  },
  -- 196
  {
    name = "txt_robobot",
    sprite = "text/robobot",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"robot", "chars"},
  },
  -- 197
  {
    name = "lvl",
    sprite = "lvl",
    type = "object",
    color = {0, 3},
    layer = 24,
    rotate = true,
    tags = {"level", "path"},
    desc = "its a lavel, working like baba. LVL BE NOGO by default."
  },
  -- 198
  {
    name = "selctr",
    sprite = "selctr",
    type = "object",
    color = {3, 3},
    layer = 3,
    tags = {"cursor", "selector"},
    desc = "used to select levis"
  },
  -- 199
  {
    name = "txt_selctr",
    sprite = "text/selctr",
    type = "text",
    texttype = {object = true},
    color = {2, 3},
    layer = 20,
    tags = {"cursor", "selector"},
  },
  -- 200
  {
    name = "lin",
    sprite = "lin",
    type = "object",
    color = {0, 3},
    layer = 23,
    tags = {"line", "path"},
    desc = "used to connect lovils"
  },
  -- 201
  {
    name = "txt_lin",
    sprite = "text/lin",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"line", "path"},
    desc = "LIN BE PATHZ by default. Also lin is used in floodfilling and can have a puff/blossom door attached to it."
  },
  -- 202
  {
    name = "txt_moov",
    sprite = "text/moov",
    type = "text",
    texttype = {verb = true, verb_unit = true, verb_direction = true},
    color = {1,3},
    layer = 20,
    tags = {"shift"},
    desc = "MOOV (Verb): A verbified GO AWAY PLS/GO. x MOOV y means that x can push and shift y. y is not treated as solid if unable to be pushed. MOOV GO^ will make the unit move one unit in that direction per turn.",
  },
  --- 203
  {
    name = "txt_haet",
    sprite = "text/haet",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    allowconds = true,
    color = {2, 3},
    layer = 20,
    tags = {"patashu", "hate", "hates", "collide"},
    desc = "HAET (Verb): A unit cannot stop onto a tile that has something it HAETs (treating it like NOGO). (x HAET LVL makes x unable to move.)",
  },
  -- 204
  {
    name = "txt_brite",
    sprite = "text/brite",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    tags = {"bright", "power"},
    desc = "BRITE: A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing TRANPARN'T is in the way.",
  },
  -- 205
  {
    name = "txt_lit",
    sprite = "text/lit",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2, 4},
    layer = 20,
    tags = {"powered"},
    desc = "LIT (Prefix Condition): A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing TRANPARN'T is in the way.",
  },
  -- 206
  {
    name = "txt_tranparnt",
    sprite = "text/tranparnt",
    type = "text",
    texttype = {property = true},
    color = {0, 1},
    layer = 20,
    alias = {"tranparn't"},
    desc = "TRANPARN'T: A BRITE object emits light in all directions. LIT will be true for objects on the same FLYE level if nothing TRANPARN'T is in the way.",
  },
  -- 207
  {
    name = "txt_noturn",
    sprite = "text/noturn",
    type = "text",
    texttype = {property = true},
    color = {2, 3},
    layer = 20,
    tags = {"strafe"},
    desc = "NO TURN: A NO TURN unit's direction can't change (unless re-oriented by non-euclidean level geometry, i.e. POOR TOLL).",
  },
  -- 208
  {
    name = "txt_an",
    sprite = "text/an",
    type = "text",
    texttype = {cond_prefix = true},
    color = {0, 3},
    layer = 20,
    tags = {"rng", "random"},
    desc = "AN (Prefix Condition): True for a single arbitrary unit per turn and condition. To get multiple results in one tile, rotate the ANs in different directions.",
  },
  -- 209
  {
    name = "txt_wurd",
    sprite = "text/wurd",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"word"},
    desc = "WURD: A WURD unit forms rules as though it was its respective text. TXT BEN'T WURD makes that text not parse.",
  },
  -- 210
  {
    name = "firbolt",
    sprite = "firbolt",
    type = "object",
    color = {6, 2},
    layer = 8,
    rotate = true,
    tags = {"firebolt"},
    desc = "i cast FIRBOLT at the NO1!",
  },
  -- 211
  {
    name = "txt_firbolt",
    sprite = "text/firbolt",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"firebolt"},
  },
  -- 212
  {
    name = "icbolt",
    sprite = "icbolt",
    type = "object",
    color = {1, 4},
    layer = 8,
    rotate = true,
    desc = "its time for u to CHILL out. stay FROSTY.",
    tags = {"icebolt"},
  },
  -- 213
  {
    name = "txt_icbolt",
    sprite = "text/icbolt",
    type = "text",
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    tags = {"icebolt"},
  },
  -- 214
  {
    name = "hedg",
    sprite = "hedg",
    type = "object",
    color = {5, 1},
    layer = 3,
    tags = {"hedge", "plants"},
    desc = "im hedg the hedg heg",
  },
  -- 215
  {
    name = "txt_hedg",
    sprite = "text/hedg",
    type = "text",
    texttype = {object = true},
    color = {5, 1},
    layer = 20,
    tags = {"hedge", "plants"},
  },
  -- 216
  {
    name = "fenss",
    sprite = "fenss",
    type = "object",
    color = {6, 2},
    layer = 3,
    tags = {"fence"},
    desc = "keeps babs out!!",
  },
  -- 217
  {
    name = "txt_fenss",
    sprite = "text/fenss",
    type = "text",
    color = {6, 2},
    layer = 20,
    tags = {"fence"},
  },
  -- 218
  {
    name = "metl",
    sprite = "metl",
    type = "object",
    color = {0, 2},
    layer = 2,
    tags = {"metal"},
    desc = "impervious metl...",
  },
  -- 219
  {
    name = "txt_metl",
    sprite = "text/metl",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"metal"},
  },
  -- 220
  {
    name = "sparkl",
    sprite = "sparkl",
    type = "object",
    color = {2, 4},
    layer = 5,
    tags = {"sparkle", "dust"},
    desc = "as brite as a star... but also as hotte as one!!",
  },
  -- 221
  {
    name = "txt_sparkl",
    sprite = "text/sparkl",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"sparkle", "dust"},
  },
  -- 222
  {
    name = "spik",
    sprite = "spik",
    type = "object",
    color = {0, 2},
    layer = 5,
    rotate = true,
    tags = {"spike"},
    desc = "finally, i can make my i wanna be the bab fangame in bab be u",
  },
  -- 223
  {
    name = "txt_spik",
    sprite = "text/spik",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"spike"},
  },
  -- 224
  {
    name = "spiky",
    sprite = "spiky",
    type = "object",
    color = {0, 2},
    layer = 6,
    rotate = true,
    tags = {"spike"},
    desc = "ouch!! many spik at once.",
  },
  -- 225
  {
    name = "txt_spiky",
    sprite = "text/spiky",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"spike"},
  },
  -- 226
  {
    name = "bordr",
    sprite = "bordr",
    type = "object",
    color = {1, 0},
    layer = 1,
    tags = {"border"},
    desc = "BORDR: OOB you can place manually. NOGO, TALL and BORDR by default."
  },
  -- 227
  {
    name = "txt_bordr",
    sprite = "text/bordr",
    type = "text",
    texttype = {object = true},
    color = {2, 0},
    layer = 20,
    tags = {"border"},
  },
  -- 228
  {
    name = "txt_loop",
    sprite = "text/infloop",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    alias = {"infloop"},
    tags = {"infloop", "infinity", "infinite loop"},
    desc = "INFLOOP: A special word that describes the infinite loop state."
  },
  -- 229
  {
    name = "platfor",
    sprite = "platfor",
    type = "object",
    color = {6, 2},
    layer = 3,
    desc = "good for use with go my way",
    rotate = true,
    tags = {"platform"},
  },
  -- 230
  {
    name = "txt_platfor",
    sprite = "text/platfor",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"platform"},
  },
  -- 231
  {
    name = "jail",
    sprite = "jail",
    type = "object",
    color = {0, 2},
    layer = 22,
    desc = "BAB W/FREN JAIL BE STUKC. now bab's in jail :(",
  },
  -- 232
  {
    name = "txt_jail",
    sprite = "text/jail",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
  },
  -- 233
  {
    name = "txt_haetflor",
    sprite = "text/haetflor",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"vall", "gravity"},
    desc = "HAET FLOR: After movement, this unit falls UP as far as it can.",
  },
  -- 234
  {
    name = "this",
    sprite = "this",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "THIS: Text that refers to itself. Each THIS is independant. THIS TXT refers to all THISs."
  },
  -- 235
  {
    name = "txt_grun",
    sprite = "text/grun_cond",
    sprite_transforms = {
      property = "txt_grun"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {5, 2},
    layer = 20,
    tags = {"colors", "colours", "green"},
    desc = "GRUN: Causes the unit to appear green. Persistent and can be used as a prefix condition."
  },
  -- 236
  {
    name = "txt_yello",
    sprite = "text/yello_cond",
    sprite_transforms = {
      property = "txt_yello"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {2, 4},
    layer = 20,
    tags = {"colors", "colours", "yellow"},
    desc = "YELLO: Causes the unit to appear yellow. Persistent and can be used as a prefix condition. Reed + Grun."
  },
  -- 237
  {
    name = "txt_purp",
    sprite = "text/purp_cond",
    sprite_transforms = {
      property = "txt_purp"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {3, 1},
    layer = 20,
    tags = {"colors", "colours", "purple"},
    desc = "PURP: Causes the unit to appear purple. Persistent and can be used as a prefix condition."
  },
  -- 238
  {
    name = "txt_orang",
    sprite = "text/orang_cond",
    sprite_transforms = {
      property = "txt_orang"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {2, 3},
    layer = 20,
    tags = {"colors", "colours", "orange"},
    desc = "ORANG: Causes the unit to appear orange. Persistent and can be used as a prefix condition."
  },
  -- 239
  {
    name = "txt_cyeann",
    sprite = "text/cyeann_cond",
    sprite_transforms = {
      property = "txt_cyeann"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {1, 4},
    layer = 20,
    tags = {"colors", "colours", "cyan"},
    desc = "CYEANN: Causes the unit to appear cyan. Persistent and can be used as a prefix condition."
  },
  -- 240
  {
    name = "txt_whit",
    sprite = "text/whit_cond",
    sprite_transforms = {
      property = "txt_whit"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {0, 3},
    layer = 20,
    tags = {"colors", "colours", "white"},
    desc = "WHIT: Causes the unit to appear white. Persistent and can be used as a prefix condition. Bleu + Yello, Reed + Cyeann, Grun + Purp."
  },
  -- 241
  {
    name = "txt_blacc",
    sprite = "text/blacc_cond",
    sprite_transforms = {
      property = "txt_blacc"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {0, 0},
    layer = 20,
    tags = {"colors", "colours", "black"},
    desc = "BLACC: Causes the unit to appear black. Persistent and can be used as a prefix condition."
  },
  -- 242
  {
    name = "txt_rave",
    sprite = "text/rave",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    desc = "RAVE: Causes the unit to flash through the rainbow extremely quickly."
  },
  -- 243
  {
    name = "hol",
    sprite = "hol",
    type = "object",
    color = {3, 3},
    layer = 22,
    rotate = true,
    portal = true,
    tags = {"portal"},
    desc = "the real poor toll"
  },
  -- 244
  {
    name = "txt_hol",
    sprite = "text/hol",
    type = "text",
    texttype = {object = true},
    color = {3, 2},
    layer = 20,
    tags = {"portal"},
  },
  -- 245
  {
    name = "txt_corekt",
    sprite = "text/corekt",
    type = "text",
    texttype = {cond_prefix = true},
    color = {5,2},
    layer = 20,
    tags = {"correct", "cg5"},
    desc = "COREKT (Prefix Condition): True if the unit is in an active rule.",
  },
  -- 246
  {
    name = "txt_rong",
    sprite = "text/rong",
    sprite_transforms = {
      property = "txt_rong_prop"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true},
    color = {2,2},
    layer = 20,
    tags = {"wrong", "false", "cg5"},
    desc = "RONG: As a prefix, true if the unit is in a negated rule (via rong, n't, or notranform). As a property, if a rule has a rong unit in it it'll be negated.",
  },
  -- 247
  {
    name = "txt_...",
    sprite = "text/...",
    type = "text",
    texttype = {ellipsis = true},
    color = {0, 3},
    layer = 20,
    tags = {"ellipsis", "dotdotdot", "period"},
    desc = "... (ELLIPSIS): Extends rules. BAB ... BE ... ... U is the same as BAB BE U.",
  },
  -- 248
  {
	name = "txt_utoo",
	sprite = "text/utoo",
	type = "text",
	texttype = {property = true},
	color = {4,1},
  layer = 20,
  alias = {"u2"},
  tags = {"you2", "p2", "player"},
	desc = "player 2 has joined the game (dpad). Can also be spelled 'u2'.",
  },
  -- 249
  {
	name = "txt_utres",
	sprite = "text/utres",
	type = "text",
	texttype = {property = true},
	color = {4,1},
  layer = 20,
  alias = {"u3"},
  tags = {"you3", "p3", "player"},
	desc = "and player 3 (ijkl or numpad).\nIf there are objects of two control schemes but not a third, the third control scheme can be used to move both of the first two at once.\nCan also be spelled 'u3'.",
  },
  -- 250
  {
    name = "txt_zawarudo",
    sprite = "text/zawarudo",
    type = "text",
    texttype = {property = true},
    color = {2,4},
    layer = 20,
    tags = {"timeless", "the world", "dio", "lily"},
    desc = "ZA WARUDO: Can stop time and move without anything else moving. Faster than rule parsing itself! After forming the rule, press E (hourglass on mobile) to toggle. While stopped, a non-zawarudo object that would move at infinite speed will move one space per turn.",
  },
	-- 251
  {
    name = "txt_babn't",
    sprite = {"text/bab meta", "n't"},
    color = {{4, 1}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {object = true},
    layer = 20,
		desc = "BAB N'T: The same as having these two text tiles in a row."
  },
	-- 252
  {
    name = "txt_ben't",
    sprite = {"text/be n't", "n't (be)"},
    color = {{0, 3}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {verb = true, verb_class = true, verb_property = true},
    layer = 20,
    tags = {"isn't", "is not", "verb"},
		desc = "BE N'T (Verb): The same as having these two text tiles in a row."
  },
	-- 253
   {
    name = "txt_rocn't",
    sprite = {"text/roc meta", "n't"},
    color = {{6, 1}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {object = true},
    layer = 20,
		desc = "ROC N'T: The same as having these two text tiles in a row."
  },
	-- 254
   {
    name = "txt_waln't",
    sprite = {"text/wal meta", "n't"},
    color = {{0, 1}, {2, 2}},
    colored = {true, false},
    type = "text",
    texttype = {object = true},
    layer = 20,
		desc = "WAL N'T: The same as having these two text tiles in a row."
  },
  -- 255
  {
    name = "letter_a",
    sprite = "letter_a",
    type = "text",
    texttype = {letter = true, note = true},
    color = {0,3},
    layer = 20,
    desc = "try thingifying a custom AAAAAA letter!"
  },
  -- 256
  {
    name = "letter_b",
    sprite = "letter_b",
    type = "text",
    texttype = {letter = true, note = true},
    color = {0,3},
    layer = 20,
  },
  -- 257
  {
    name = "letter_c",
    sprite = "letter_c",
    type = "text",
    texttype = {letter = true, note = true},
    color = {0,3},
    layer = 20,
  },
  -- 258
  {
    name = "letter_d",
    sprite = "letter_d",
    type = "text",
    texttype = {letter = true, note = true},
    color = {0,3},
    layer = 20,
  },
  -- 259
  {
    name = "letter_e",
    sprite = "letter_e",
    type = "text",
    texttype = {letter = true, note = true},
    color = {0,3},
    layer = 20,
  },
  -- 260
  {
    name = "letter_f",
    sprite = "letter_f",
    type = "text",
    texttype = {letter = true, note = true},
    color = {0,3},
    layer = 20,
    desc = "press F to pay respects",
  },
  -- 261
  {
    name = "letter_g",
    sprite = "letter_g",
    type = "text",
    texttype = {letter = true, note = true},
    color = {0,3},
    layer = 20,
  },
  -- 262
  {
    name = "letter_h",
    sprite = "letter_h",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 263
  {
    name = "letter_j",
    sprite = "letter_j",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "This is used in JAIL and JILL. Discrimination against J!"
  },
  -- 264
  {
    name = "letter_k",
    sprite = "letter_k",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 265
  {
    name = "letter_l",
    sprite = "letter_l",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 266
  {
    name = "letter_m",
    sprite = "letter_m",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 267
  {
    name = "letter_n",
    sprite = "letter_n",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 268
  {
    name = "letter_p",
    sprite = "letter_p",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 269
  {
    name = "letter_q",
    sprite = "letter_q",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 270
  {
    name = "letter_r",
    sprite = "letter_r",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 271
  {
    name = "letter_s",
    sprite = "letter_s",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "ome body once told me..."
  },
  -- 272
  {
    name = "letter_t",
    sprite = "letter_t",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "he world is gonna roll me."
  },
  -- 273
  {
    name = "letter_u",
    sprite = "letter_u",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 274
  {
    name = "letter_v",
    sprite = "letter_v",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 275
  {
    name = "letter_w",
    sprite = "letter_w",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 276
  {
    name = "letter_x",
    sprite = "letter_x",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 277
  {
    name = "letter_y",
    sprite = "letter_y",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 278
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
  -- 279
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
  -- 280
  {
    name = "letter_parenthesis",
    sprite = "letter_paranthesis",
    type = "text",
    texttype = {letter = true, parenthesis = true},
    rotate = true,
    color = {0,3},
    layer = 20,
    tags = {"9", "0", "brackets"},
    desc = "Can also be used in rules, sometimes. bab arond flog w/fren ( roc arond keek ) be :) will parse, for example."
  },
  -- 281
  {
    name = "letter_'",
    sprite = "letter_apostrophe",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for n't, y'all, and ''."
  },
  -- 282
  {
    name = "letter_go",
    sprite = "letter_go",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "used in a whole lot of words",
  },
  -- 283
  {
    name = "letter_come",
    sprite = "letter_come",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used exclusively for COME PLS.",
  },
  -- 284
  {
    name = "letter_pls",
    sprite = "letter_pls",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for GO AWAY PLS and COME PLS.",
  },
  -- 285
  {
    name = "letter_away",
    sprite = "letter_away",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for GO AWAY PLS and LOOK AWAY.",
  },
  -- 286
  {
    name = "letter_my",
    sprite = "letter_my",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used exclusively for GO MY WAY.",
  },
  -- 287
  {
    name = "letter_no",
    sprite = "letter_no",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for NO GO and NO1.",
  },
  -- 288
  {
    name = "letter_way",
    sprite = "letter_way",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"wey"},
  },
  -- 289
  {
    name = "txt_''",
    sprite = "text/ditto",
    type = "text",
    texttype = {ditto = true},
    color = {0,3},
    layer = 20,
    demeta = "ditto",
    tags = {"ditto", "quotation marks", "\""},
    desc = "DITTO: Acts like the text above it. \" TXT will refer to the ditto itself, not the text above it.",
  },
  -- 290
  {
    name = "txt_txtify",
    sprite = "text/txtify",
    type = "text",
    texttype = {property = true},
    color = {4, 1},
    layer = 20,
    tags = {"meta", "notnat"},
    desc = "TXTIFY: BE TXTIFY causes that object to be turned into its corresponding metatext.",
  },
  -- 291
  {
    name = "ui_1",
    sprite = "ui_1",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down left.",
  },
  -- 292
  {
    name = "ui_2",
    sprite = "ui_2",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down.",
  },
  -- 293
  {
    name = "ui_3",
    sprite = "ui_3",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down right.",
  },
  -- 294
  {
    name = "ui_4",
    sprite = "ui_4",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Left.",
  },
  -- 295
  {
    name = "ui_6",
    sprite = "ui_6",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Right.",
  },
  -- 296
  {
    name = "ui_7",
    sprite = "ui_7",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up left.",
  },
  -- 297
  {
    name = "ui_8",
    sprite = "ui_8",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up.",
  },
  -- 298
  {
    name = "ui_9",
    sprite = "ui_9",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up right.",
  },
  -- 299
  {
    name = "ui_w",
    sprite = "ui_w",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Up.",
  },
  -- 300
  {
    name = "ui_a",
    sprite = "ui_a",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Left.",
  },
  -- 301
  {
    name = "ui_s",
    sprite = "ui_s",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Down.",
  },
  -- 302
  {
    name = "ui_d",
    sprite = "ui_d",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U controls. Right.",
  },
  -- 303
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
  -- 304
  {
    name = "ui_i",
    sprite = "ui_i",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Up.",
  },
  -- 305
  {
    name = "ui_j",
    sprite = "ui_j",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Left.",
  },
  -- 306
  {
    name = "ui_k",
    sprite = "ui_k",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Down.",
  },
  -- 307
  {
    name = "ui_l",
    sprite = "ui_l",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "U TRES controls. Right.",
  },
  -- 308
  {
    name = "ui_e",
    sprite = "ui_e",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The ZA WARUDO button.",
  },
  -- 309
  {
    name = "ui_walk",
    sprite = "ui_walk",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 310
  {
    name = "ui_activat",
    sprite = "ui_activat",
    type = "object",
    color = {0,3},
    layer = 20,
  },
	-- 311
  {
    name = "txt_frens",
    sprite = "text/frens",
    type = "text",
    texttype = {object = true, group = true},
    color = {3, 3},
    layer = 20,
    tags = {"group", "friends"},
    desc = "FRENS: A group you can be a member of. 'x BE FRENS' adds you to the FRENS group. 'FRENS BE x' applies the property to all FRENS.",
  },
	-- 312
  {
    name = "txt_curse",
    sprite = "text/curse",
    type = "text",
    texttype = {property = true},
    color = {3, 3},
    layer = 20,
    tags = {"select"},
    desc = "CURSE: Makes object move like U on lins/lvls and able to enter lvls (also goes through walls)",
  },
	-- 313
  {
    name = "txt_groop",
    sprite = "text/groop",
    type = "text",
    texttype = {object = true, group = true},
    color = {3, 3},
    layer = 20,
    tags = {"group"},
    desc = "GROOP: A variant of FRENS.",
  },
  -- 314
  {
    name = "txt_her",
    sprite = "text/her",
    type = "text",
    texttype = {property = true},
    rotate = true,
    color = {1,3},
    layer = 20,
    tags = {"here","cg5", "her^", "her ->"},
    desc = "HER ->: Sends objects to where the text indicates. N'T HER makes objects HAET that tile.",
  },
  -- 315
  {
    name = "txt_thr",
    sprite = "text/thr",
    type = "text",
    texttype = {property = true},
    rotate = true,
    color = {3,2},
    layer = 20,
    tags = {"there","cg5", "thr^", "thr ->"},
    desc = "THR ->: Sends objects as far away from it as possible (until hitting a wall) in the indicated direction. N'T THR makes objects HAET a line from the text.",
  },
  -- 316
  {
    name = "txt_the",
    sprite = "text/the",
    type = "text",
    texttype = {object = true, cond_prefix = true},
    rotate = true,
    color = {0,3},
    layer = 20,
    tags = {"that","those","cg5", "the^", "the ->"},
    desc = "THE: Refers to the object it's pointing at.",
  },
  -- 317
  {
    name = "txt_knightstep",
    sprite = "text/knightstep",
    type = "text",
    texttype = {property = true},
    color = {0, 2},
    layer = 20,
    tags = {"chess"},
    desc = "KNIGHTSTEP: KNIGHTSTEP units move like the Knight chess piece, rotated 22.5 degrees clockwise. Stacks add additional 1, 1 hops.",
  },
  -- 318
  {
    name = "txt_that",
    sprite = "text/that",
    type = "text",
    texttype = {cond_infix = true, cond_infix_verb = true},
    color = {0, 3},
    layer = 20,
    tags = {"lily", "with", "w/"},
    desc = "THAT (Infix Condition): x THAT BE y is true if x BE y. x THAT GOT Y is true if x GOT y. And so on.",
  },
  -- 319
  {
    name = "txt_thatbe",
    sprite = "text/that be",
    type = "text",
    --this is because while it's technically cond_infix, listing it as one makes it double count any n'ts after it because it saves the n'ts accumulated from the two different paths it can try it as? I think?? anyway this fixes it because it's special cased in parser.lua
    texttype = {cond_infix = true, cond_infix_verb = true, cond_infix_verb_plus = true},
    color = {0, 3},
    layer = 20,
    tags = {"lily", "with", "w/"},
    desc = "THAT BE (Infix Condition): x THAT BE y is true if x BE y.",
  },
  -- 320
  {
    name = "txt_timles",
    sprite = "text/timles",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2,4},
    layer = 20,
    tags = {"timeless"},
    desc = "TIMLES (Prefix Condition): True if ZA WARUDO is active.",
  },
  -- 321
  {
    name = "letter_i",
    sprite = "letter_i",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 322
  {
    name = "letter_z",
    sprite = "letter_z",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Z: it's just a rotated N"
  },
  -- 323
  {
    name = "rif",
    sprite = "riff",
    type = "object",
    rotate = true,
    portal = true,
    color = {2,4},
    layer = 22,
    tags = {"portal", "rift"},
    desc = "the fake poor toll"
  },
  -- 324
  {
    name = "txt_rif",
    sprite = "text/rif",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"portal", "rift"},
  },
  -- 325
  {
    name = "txt_stayther",
    sprite = "text/stay ther",
    type = "text",
    texttype = {property = true},
    color = {0, 3},
    layer = 20,
    tags = {"persist"},
    desc = "STAY THER: Objects with this property will be taken with you when you transition between levels.",
  },
  -- 326
  {
    name = "lie",
    sprite = "caek",
    type = "object",
    color = {4,1},
    layer = 6,
    tags = {"portal", "cake", "food"},
    desc = "caek be lie",
  },
  -- 327
  {
    name = "txt_lie",
    sprite = "text/caek",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"portal", "cake", "food"},
    desc = "LIE: If LIE BE SPLIT, LIE becomes LIE/8 on all open adjacent tiles.",
  },
  -- 328
  {
    name = "lie/8",
    sprite = "slis",
    type = "object",
    color = {4,2},
    rotate = true,
    layer = 6,
    tags = {"portal", "cake", "food", "slice"},
    desc = "idc if it's a lie, it tastes good",
  },
  -- 329
  {
    name = "txt_lie/8",
    sprite = "text/slis",
    type = "text",
    texttype = {object = true},
    color = {4,2},
    layer = 20,
    tags = {"portal", "cake", "food", "slice"},
    desc = "LIE/8: If LIE/8 BE MOAR, LIE/8 becomes LIE.",
  },
  -- 330
  {
    name = "ui_leftclick",
    sprite = "ui_left_click",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "Trigger CLIKT.",
  },
  -- 331
  {
    name = "ui_rightclick",
    sprite = "ui_right_click",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "See what's on the tile you clicked!",
  },
  -- 332
  {
    name = "ui_clik",
    sprite = "ui_clik",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 333
  {
    name = "txt_clikt",
    sprite = "text/clikt",
    metasprite = "text/clikt meta",
    type = "text",
    texttype = {cond_prefix = true},
    color = {3, 3},
    layer = 20,
    tags = {"clicked", "mouse"},
    desc = "CLIKT (Prefix Condition): CLIKT objects will be true when left-clicked. Clicks will pass a turn if this text exists.",
  },
  -- 334
  {
    name = "sine",
    sprite = "sine",
    type = "object",
    color = {6,2},
    layer = 4,
    tags = {"sign"},
    desc = 'the sine says "shoutouts to simpleflips"',
  },
  -- 335
  {
    name = "txt_sine",
    sprite = "text/sine",
    type = "text",
    texttype = {object = true},
    color = {6,2},
    layer = 20,
    tags = {"sign"},
  },
  -- 336
  {
    name = "buble",
    sprite = "buble",
    type = "object",
    color = {1,3},
    layer = 5,
    sing = "kkb2",
    tags = {"bubble"},
    desc = "bibble bobubble bub bab. blup"
  },
  -- 337
  {
    name = "txt_buble",
    sprite = "text/buble",
    type = "text",
    texttype = {object = true},
    color = {1,3},
    layer = 20,
    tags = {"bubble"},
  },
  -- 338
  {
    name = "creb",
    sprite = "creb",
    type = "object",
    color = {2,2},
    layer = 11,
    sing = "crab rave",
    features = { sans = {x=20, y=4, w=4, h=5} },
    tags = {"crab"},
    desc = "loves to party and dance! woo! yeah!"
  },
  -- 339
  {
    name = "txt_creb",
    sprite = "text/creb",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"crab"},
  },
  -- 340
  {
    name = "icecub",
    sprite = "icecub",
    type = "object",
    color = {1,4},
    layer = 6,
    tags = {"icecube"},
    desc = "icecub ben't melltt. classic baba reference"
  },
  -- 341
  {
    name = "txt_icecub",
    sprite = "text/icecub",
    type = "text",
    texttype = {object = true},
    color = {1,4},
    layer = 20,
    tags = {"icecube"},
  },
  -- 342
  {
    name = "jill",
    sprite = "jill",
    type = "object",
    color = {1,3},
    layer = 11,
    rotate = true,
    sing = "s_jill",
    features = { 
      sans = {x=17, y=8, w=2, h=3},
      cool = {x=-2, y=-3},
      
      which = {x=-2, y=-1},
      hatt = {x=-1, y=-1},
      sant = {x=-5},
      
      knif = {x=3,y=-3},
      bowie = {x=-1,y=-5},
    },
    tags = {"devs", "chars", "valhalla", "cynthia"},
    desc = "it time 2 mix drincc & chaeng life"
  },
  -- 343
  {
    name = "txt_jill",
    sprite = "text/jill",
    type = "text",
    texttype = {object = true},
    color = {1,3},
    layer = 20,
    tags = {"devs", "chars", "va11 hall-a", "cynthia"},
  },
  -- 344
  {
    name = "txt_paint",
    sprite = "text/paint",
    type = "text",
    texttype = {verb = true, verb_unit = true, property = true, object = true},
    color = {4,2},
    layer = 20,
    tags = {"colors", "colours"},
    desc = "PAINT (Verb): changes the second object's color to match the first if the objects are on each other. Supports color mixing."
  },
  -- 345
  {
    name = "paint",
    sprite = {"paint","paint_color"},
    type = "object",
    color = {{0,3},{0,3}},
    colored = {false,true},
    layer = 8,
    tags = {"colors", "colours"},
    desc = "Creating a PAINT will always be a samecolor paint."
  },
  -- 346
  {
    name = "txt_glued",
    sprite = "text/glued",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    tags = {"sticky","lily"},
    desc = "GLUED: Stuck to adjacent units sharing its colour, and can't move unless the entire block can simultaneously move.",
  },
  --- 347
  {
    name = "ger",
    sprite = "ger",
    type = "object",
    color = {6,1},
    layer = 7,
    rotate = true,
    tags = {"gear", "time", "cog"},
    desc = "it spins! spin spin spin weeee"
  },
  -- 348
  {
    name = "txt_ger",
    sprite = "text/ger",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"gear", "time", "cog"},
  },
  -- 349
  {
    name = "txt_rithere",
    sprite = "text/rithere",
    type = "text",
    texttype = {property = true},
    color = {4,0},
    layer = 21,
    tags = {"right here"},
    desc = "RIT HERE: Sends objects to where the text is.",
  },
  -- 350
  {
    name = "txt_torc",
    sprite = "text/torc",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"torchlight", "flashlight"},
    desc = "TORC: A TORC object emits light in the direction they're facing. The angle of the light determined by the number of TORC stacks. (WIP)",
  },
  -- 351
  {
    name = "txt_ignor",
    sprite = "text/ignor",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {0,1},
    layer = 20,
    tags = {"ignore"},
    desc = "IGNOR (Verb): x IGNOR y causes x to not be able to interact with or move y in any way."
  },
  -- 352
  {
    name = "txt_rotatbl",
    sprite = "text/rotatbl",
    type = "text",
    texttype = {property = true},
    color = {6,2},
    layer = 20,
    tags = {"rotatable"},
    desc = "ROTATBL: Makes any object able to be rotated."
  },
  -- 353
  {
    name = "txt_vs",
    sprite = "text/vs",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {2,1},
    layer = 20,
    tags = {"versus"},
    desc = "VS (Verb): The two objects enter a 1 on 1 battle: whoever steps on the other wins.",
  },
  -- 354
  {
    name = "hors",
    sprite = "hors",
    type = "object",
    color = {6,1},
    layer = 11,
    features = { sans = {x=17,y=6,w=3,h=3} },
    tags = {"chess", "knight", "horse"},
    desc = "it's a knoble knight"
  },
  -- 355
  {
    name = "txt_hors",
    sprite = "text/hors",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"chess", "knight", "horse"},
  },
  -- 356
  {
    name = "can",
    sprite = "can",
    type = "object",
    color = {2,1},
    layer = 8,
    rotate = true,
    tags = {"valhalla"},
    desc = "crack fordor a colld one"
  },
  -- 357
  {
    name = "txt_can",
    sprite = "text/can",
    type = "text",
    texttype = {object = true},
    color = {2,1},
    layer = 20,
    tags = {"valhalla"},
  },
  -- 358
  {
    name = "toggl",
    sprite = "toggl",
    type = "object",
    color = {0,3},
    layer = 4,
    rotate = true,
    tags = {"toggle","lightswitch"},
    desc = "flip flop"
  },
  -- 359
  {
    name = "txt_toggl",
    sprite = "text/toggl",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"toggle","lightswitch"},
  },
  -- 360
  {
    name = "txt_pinc",
    sprite = "text/pinc_cond",
    sprite_transforms = {
      property = "txt_pinc"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {4, 1},
    layer = 20,
    tags = {"colors", "colours", "pink"},
    desc = "PINC: Causes the unit to become pink!"
  },
  -- 361
  {
    name = "txt_nuek",
    sprite = "text/nuek",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"nuke", "bomb"},
    desc = "NUEK: A NUEK will begin destroying everything around it, its radius growing once per turn. Currently very laggy, for some reason."
  },
  -- 362
  {
    name = "letter_o",
    sprite = "letter_o",
    type = "text",
    texttype = {letter = true, object = true},
    color = {0,3},
    layer = 20,
    desc = "the most op letter",
  },
  -- 363
  {
    name = "txt_samefloat",
    sprite = "text/samefloat",
    type = "text",
    texttype = {cond_compare = true},
    color = {1,4},
    layer = 20,
    tags = {"sameflye"},
    desc = "SAMEFLOAT( (Compare Condition): True if the condition unit has the same amount of FLYE as the target.",
  },
  -- 364
  {
    name = "bom",
    sprite = "bom",
    type = "object",
    color = {0,1},
    layer = 6,
    tags = {"bomb", "boom"},
    desc = "it go boom",
  },
  -- 365
  {
    name = "txt_bom",
    sprite = "text/bom",
    type = "text",
    texttype = {object = true},
    color = {0,1},
    layer = 20,
    tags = {"bomb", "boom"},
  },
  -- 366
  {
    name = "xplod",
    sprite = "sparkl",
    type = "object",
    color = {2,2},
    layer = 22,
  },
  -- 367
  {
    name = "txt_behind",
    sprite = "text/behind",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"back", "look"},
    desc = "BEHIND (Infix Condition): True if an indicated object is looking away from the unit on an adjacent tile.",
  },
  -- 368
  {
    name = "txt_beside",
    sprite = "text/beside",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"look", "left", "right"},
    desc = "BESIDE (Infix Condition): True if an indicated object is at the side of the unit on an adjacent tile.",
  },
  -- 369
  {
    name = "txt_lookaway",
    sprite = "text/lookaway",
    type = "text",
    texttype = {cond_infix = true, cond_infix_dir = true, verb = true, verb_unit = true},
    color = {0, 3},
    layer = 20,
    tags = {"unfollow", "facing away", "lookaway", "behind"},
    desc = "LOOK AWAY: As an infix condition, true if this object is on the tile behind the unit As a verb, makes the unit face away from this object at end of turn.",
  },
  -- 370
  {
    name = "square",
    sprite = "square",
    type = "object",
    color = {2, 4},
    layer = 11,
    sing = "pipipi",
    features = { sans = {x=19, y=7, w=2, h=2} },
    tags = {"chars", "oatmealine", "puyopuyo tetris"},
    desc = "oh no am square????"
  },
  -- 371
  {
    name = "triangle",
    sprite = "triangle",
    type = "object",
    color = {2, 4},
    layer = 11,
    sing = "pipipi",
    features = { sans = {x=17, y=7, w=2, h=2} },
    tags = {"chars", "oatmealine", "puyopuyo tetris"},
    desc = "TRIASNGLE?????? this is ridicouuolus",
  },
  -- 372
  {
    name = "txt_square",
    sprite = "text/square",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    features = { sans = {x=19, y=7, w=2, h=2} },
    tags = {"chars", "oatmealine", "puyopuyo tetris"},
  },
  -- 373
  {
    name = "txt_triangle",
    sprite = "text/triangle",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    features = { sans = {x=19, y=7, w=2, h=2} },
    tags = {"chars", "oatmealine", "puyopuyo tetris"},
  },
  -- 374
  {
    name = "txt_right",
    sprite = "text/goup",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    tags = {"direction"},
    desc = "RIGHT: A GO ->, but facing right.",
  },
  -- 375
  {
    name = "txt_upleft",
    sprite = "text/upleft",
    type = "text",
    texttype = {property = true, direction = true},
    alias = {"leftup"},
    color = {1, 4},
    layer = 20,
    tags = {"direction"},
    desc = "UPLEFT: A GO ->, but facing upleft. Can also be spelled leftup.",
  },
  -- 376
  {
    name = "txt_upright",
    sprite = "text/upright",
    type = "text",
    texttype = {property = true, direction = true},
    alias = {"rightup"},
    color = {1, 4},
    layer = 20,
    tags = {"direction"},
    desc = "UPRIGHT: A GO ->, but facing upright. Can also be spelled rightup.",
  },
  -- 377
  {
    name = "txt_downleft",
    sprite = "text/downleft",
    type = "text",
    texttype = {property = true, direction = true},
    alias = {"leftdown"},
    color = {1, 4},
    layer = 20,
    tags = {"direction"},
    desc = "DOWNLEFT: A GO ->, but facing downleft. Can also be spelled leftdown.",
  },
  -- 378
  {
    name = "txt_downright",
    sprite = "text/downright",
    type = "text",
    texttype = {property = true, direction = true},
    alias = {"rightdown"},
    color = {1, 4},
    layer = 20,
    tags = {"direction"},
    desc = "DOWNRIGHT: A GO ->, but facing downright. Can also be spelled rightdown.",
  },
  -- 379
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
  -- 380
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
  -- 381
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
  -- 382
  {
    name = "snoman",
    sprite = "snoman",
    type = "object",
    color = {0, 3},
    layer = 10,
    features = { sans = {x=17, y=8, w=3, h=3} },
    tags = {"chars", "snowman", "christmas"},
    desc = "do u wanna creat a snoman??",
  },
  -- 383
  {
    name = "txt_snoman",
    sprite = "text/snoman",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"chars", "snowman", "christmas"},
  },
  -- 384
  {
    name = "snoflak",
    sprite = "snoflak",
    type = "object",
    color = {0,3},
    layer = 4,
    tags = {"snowflake", "ice", "hail", "christmas"},
    desc = "no 2 r the same...\nor is it?",
  },
  -- 385
  {
    name = "txt_snoflak",
    sprite = "text/snoflak",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"snowflake", "ice", "hail", "christmas"},
  },
  -- 386
  {
    name = "fir",
    sprite = "fir",
    type = "object",
    color = {2,2},
    layer = 7,
    tags = {"hot", "fire", "flame"},
    desc = "CAUTION HOTTE!!!",
  },
  -- 387
  {
    name = "txt_fir",
    sprite = "text/fir",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"hot", "fire", "flame"},
  },
  -- 388
  {
    name = "sanglas",
    sprite = "sanglas",
    type = "object",
    color = {2,4},
    layer = 6,
    rotate = true,
    tags = {"time", "hourglass"},
    desc = "tim got broken",
  },
  -- 389
  {
    name = "txt_sanglas",
    sprite = "text/sanglas",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"time", "hourglass"},
  },
  -- 390
  {
    name = "ui_5",
    sprite = "ui_5",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The other wait key.",
  },
  -- 391
  {
    name = "ui_space",
    sprite = "ui_space",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The wait key.",
  },
  -- 392
  {
    name = "ui_z",
    sprite = "ui_z",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The undo key.",
  },
  -- 393
  {
    name = "ui_r",
    sprite = "ui_r",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The restart key.",
  },
  -- 394
  {
    name = "letter_ee",
    sprite = "letter_ee",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 395
  {
    name = "letter_fren",
    sprite = "letter_fren",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "its a fren",
  },
  -- 396
  {
    name = "letter_ll",
    sprite = "letter_ll",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "welcome <3 he11",
  },
  -- 397
  {
    name = "letter_2",
    sprite = "letter_2",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "used for every2, what a surprise (can also spell u2)",
  },
  -- 398
  {
    name = "letter_3",
    sprite = "letter_3",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "and an every3 here (can also spell u3)",
  },
  -- 399
  {
    name = "letter_4",
    sprite = "letter_4",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 400
  {
    name = "letter_5",
    sprite = "letter_5",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 401
  {
    name = "letter_6",
    sprite = "letter_6",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 402
  {
    name = "letter_7",
    sprite = "letter_7",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 403
  {
    name = "letter_9",
    sprite = "letter_9",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 404
  {
    name = "ladr",
    sprite = "ladr",
    type = "object",
    color = {6,0},
    layer = 4,
    rotate = true,
    tags = {"ladder", "stairs", "climb"},
    desc = "jumpman be u",
  },
  -- 405
  {
    name = "txt_ladr",
    sprite = "text/ladr",
    type = "text",
    texttype = {object = true},
    color = {6,0},
    layer = 20,
    tags = {"ladder", "stairs", "climb"},
  },
  -- 406
  {
    name = "txt_gravy",
    sprite = "text/gravy",
    type = "text",
    texttype = {object = true},
    color = {6,2},
    layer = 20,
    tags = {"gravity", "fall", "lily"},
    desc = "GRAVY: Changes the direction of HAET SKYE and HAET FLOR. (Unimplemented)"
  },
  -- 407
  {
    name = "txt_w/neighbor",
    sprite = "text/wneighbor",
    type = "text",
    texttype = {cond_infix = true},
    color = {0, 3},
    layer = 20,
    tags = {"near", "around", "infix condition", "touching", "adjacent"},
    desc = "W/ NEIGHBOR (Infix Condition): True if the indicated object is on any of orthogonal tiles surrounding the unit. (The unit's own tile is not checked.)",
  },
  -- 408
  {
    name = "cobll",
    sprite = "cobll",
    type = "object",
    color = {0, 1},
    layer = 2,
    sing = "s_bdrum",
    tags = {"cobblestone"},
    desc = "so we back in the mine"
  },
  -- 409
  {
    name = "txt_cobll",
    sprite = "text/cobll",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"cobblestone"},
  },
  -- 410
  {
    name = "wuud",
    sprite = "wuud",
    type = "object",
    color = {6, 2},
    layer = 2,
    sing = "s_spian",
    tags = {"wood", "planks"},
    desc = "wuud u cuud u"
  },
  -- 411
  {
    name = "txt_wuud",
    sprite = "text/wuud",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"wood", "planks"},
  },
  -- 412
  {
    name = "ui_reset",
    sprite = "ui_reset",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 413
  {
    name = "ui_undo",
    sprite = "ui_undo",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 414
  {
    name = "ui_wait",
    sprite = "ui_wait",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 415
  {
    name = "wut",
    sprite = "wut",
    type = "object",
    color = {0,3},
    layer = 11,
    tags = {"what"},
    desc = "im confuse",
  },
  -- 416
  {
    name = "txt_wut",
    sprite = "text/wut",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"what"},
  },
  -- 417
  {
    name = "wat",
    type = "object",
    color = {0,3},
    layer = 11,
    tags = {"what", "error"},
    desc = "whoops error"
  },
  -- 418
  {
    name = "txt_wat",
    sprite = "text/wat",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"what", "error"},
  },
  -- 419
  {
    name = "brik",
    sprite = "brik",
    type = "object",
    color = {2, 1},
    layer = 2,
    tags = {"bricks", "wall"},
    desc = "just another brik in the wal",
  },
  -- 420
  {
    name = "txt_brik",
    sprite = "text/brik",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"bricks", "wall"},
    nice = true,
    desc = "reverse kirb",
  },
  -- 421
  {
    name = "litbolt",
    sprite = "litbolt",
    type = "object",
    color = {2, 4},
    layer = 8,
    rotate = true,
    desc = "made with lightning. REAL LIGHTNING.",
  },
  -- 422
  {
    name = "txt_litbolt",
    sprite = "text/litbolt",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
  },
  -- 423
  {
    name = "txt_un:)",
    sprite = "text/ungood",
    type = "text",
    texttype = {property = true},
    color = {1,2},
    layer = 20,
    features = { sans = {x=23, y=8, w=3, h=4} },
    tags = {"unwin", "ungood", "face", "unyay", "patashu", ";d"},
    desc = "UN:): When U touches UN:), the current level will no longer be considered won, without exiting the level. Imagine a win score equal to the number of Us on :) minus the Us on UN:). If positive, you win. If negative, you lose your win. If equal, nothing happens.",
  },
  -- 424
  {
    name = "txt_enby",
    sprite = "text/enby-colored",
    type = "text",
    texttype = {property = true},
    color = {255, 255, 255},
    layer = 20,
    desc = "ENBY: Causes the unit to appear yellow, white, purple and black. ENBY objects are yello, whit, purp, and blacc, and not any other colors.",
  },
  -- 425
  {
    name = "beeee",
    sprite = {"beeee","no1"},
    type = "object",
    color = {{2, 4},{0,0}},
    colored = {true,false},
    layer = 10,
    rotate = true,
    features = { sans = {x=25, y=14, w=2, h=2} },
    tags = {"honeybee", "chars", "insect"},
    desc = "the bab beeee be tranz",
  },
  -- 426
  {
    name = "txt_beeee",
    sprite = "text/beeee",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"honeybee", "chars", "insect"},
    desc = "bab beeeeeeeee u",
  },
  -- 427
  {
    name = "rouz",
    sprite = "rouz",
    type = "object",
    color = {4, 1},
    layer = 4,
    features = { sans = {x=8, y=6, w=3, h=3} },
    tags = {"rose", "flower", "plants"},
    desc = "every rouz got poke, ow"
  },
  -- 428
  {
    name = "txt_rouz",
    sprite = "text/rouz",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"rose", "flower", "plants"},
  },
  -- 429
  {
    name = "san",
    sprite = "san",
    type = "object",
    color = {2, 4},
    layer = 2,
    sing = "s_sdrum",
    tags = {"sand", "beach", "desert"},
    desc = "san undertales",
  },
  -- 430
  {
    name = "txt_san",
    sprite = "text/san",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"sand", "beach", "desert"},
  },
  -- 431
  {
    name = "letter_;",
    sprite = "letter_semicolon",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {"semicolon", "wink"},
    desc = "Formerly used in ;D, until we changed that to be UN:). Now it's useless, very sad.",
  },
  -- 432
  {
    name = "fungye",
    sprite = "fungye",
    type = "object",
    color = {6, 2},
    layer = 4,
    tags = {"fungus", "fungi", "mushroom"},
    desc = "super fungye"
  },
  -- 433
  {
    name = "txt_fungye",
    sprite = "text/fungye",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"fungus", "fungi", "mushroom"},
    desc = "not a very fun guy",
  },
  -- 434
  {
    name = "kar",
    sprite = "kar",
    type = "object",
    color = {5, 2},
    layer = 10,
    rotate = true,
    features = { sans = {x=20,y=11,w=2,h=4} },
    tags = {"car", "vehicle"},
    desc = "awaken my masters",
  },
  -- 435
  {
    name = "txt_kar",
    sprite = "text/kar",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"car", "vehicle"},
  },
  -- 436
  {
    name = "tor",
    sprite = "tor",
    type = "object",
    color = {2, 1},
    layer = 22,
    portal = true,
    tags = {"portal", "japan", "torii", "asia"},
    desc = "the east poor toll",
  },
  -- 437
  {
    name = "txt_tor",
    sprite = "text/tor",
    type = "text",
    texttype = {object = true},
    color = {2, 1},
    layer = 20,
    tags = {"portal", "japan", "torii", "asia"},
  },
  -- 438
  {
    name = "son",
    sprite = "son",
    type = "object",
    color = {2,4},
    layer = 6,
    tags = {"hot", "sunny", "day"},
    desc = "the son be a :( lazor",
  },
  -- 439
  {
    name = "txt_son",
    sprite = "text/son",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"hot", "sunny", "day"},
  },
  -- 440
  {
    name = "muun",
    sprite = "muun",
    type = "object",
    color = {1,2},
    layer = 6,
    tags = {"moon", "night", "mun", "crescent"},
    desc = "unaffiliated with munwalk",
  },
  -- 441
  {
    name = "txt_muun",
    sprite = "text/muun",
    type = "text",
    texttype = {object = true},
    color = {1,2},
    layer = 20,
    tags = {"moon", "night", "mun", "crescent"},
  },
  -- 442
  {
    name = "leef",
    sprite = "leef",
    type = "object",
    color = {5,2},
    layer = 7,
    rotate = true,
    tags = {"leaf", "weed lmao", "plants"},
    desc = "leef meem alone",
  },
  -- 443
  {
    name = "txt_leef",
    sprite = "text/leef",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"leaf", "weed lmao", "plants"},
    desc = "its the 420th object lmao",
    nice = false,
  },
  -- 444
  {
    name = "starr",
    sprite = "starr",
    type = "object",
    color = {2,4},
    layer = 6,
    tags = {"star", "night"},
    desc = "starr starr nite",
  },
  -- 445
  {
    name = "txt_starr",
    sprite = "text/starr",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"star", "night"},
  },
  -- 446
  {
    name = "shel",
    sprite = "shel",
    type = "object",
    color = {4,2},
    layer = 7,
    tags = {"shell", "scallop", "beach"},
    desc = "gas gas gas",
  },
  -- 447
  {
    name = "txt_shel",
    sprite = "text/shel",
    type = "text",
    texttype = {object = true},
    color = {4,2},
    layer = 20,
    tags = {"shell", "scallop", "beach"},
  },
  -- 448
  {
    name = "sancastl",
    sprite = "sancastl",
    type = "object",
    color = {2,4},
    layer = 7,
    tags = {"sandcastle", "beach"},
    desc = "lets creat a sancastl",
  },
  -- 449
  {
    name = "txt_sancastl",
    sprite = "text/sancastl",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"sandcastle", "beach"},
  },
  -- 450
  {
    name = "parsol",
    sprite = "parsol",
    type = "object",
    color = {2, 2},
    layer = 9,
    rotate = true,
    tags = {"parasol", "umbrella", "beach"},
    desc = "protecc from son thatbe :(",
  },
  -- 451
  {
    name = "txt_parsol",
    sprite = "text/parsol",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"parasol", "umbrella", "beach"},
  },
  -- 452
  {
    name = "pallm",
    sprite = "pallm",
    type = "object",
    color = {5, 2},
    layer = 4,
    sing = "s_steel",
    tags = {"palm tree", "coconut tree", "beach", "plants"},
    desc = "visit the tropical bab beach, it's a fun time for the bab family!!"
  },
  -- 453
  {
    name = "txt_pallm",
    sprite = "text/pallm",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"palm tree", "coconut tree", "beach", "plants"},
  },
  -- 454
  {
    name = "coco",
    sprite = "coco",
    type = "object",
    color = {6, 1},
    layer = 7,
    rotate = "true",
    sing = "s_steel",
    features = { sans = {x=20,y=12,w=2,h=3} },
    tags = {"fruit", "coconut", "plants"},
    desc = "its a bigg bigg nutt",
  },
  -- 455
  {
    name = "txt_coco",
    sprite = "text/coco",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"fruit", "coconut", "plants"},
  },
  -- 456
  {
    name = "glas",
    sprite = "glas",
    type = "object",
    color = {0,3},
    layer = 22,
    sing = "s_organ",
    tags = {"glass"},
    desc = "a tranzlucent block?!",
  },
  -- 457
  {
    name = "txt_glas",
    sprite = "text/glas",
    type = "text",
    texttype = {object = true},
    color = {0,2},
    layer = 20,
    tags = {"glass"},
  },
  -- 458
  {
    name = "fishe",
    sprite = "fishe",
    type = "object",
    color = {0, 3},
    layer = 10,
    rotate = "true",
    features = { sans = {x=24, y=11, w=2, h=2} },
    tags = {"angelfish", "chars"},
    desc = "fishe be walk?? kinda quirky doe",
  },
  -- 459
  {
    name = "txt_fishe",
    sprite = "text/fishe",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"angelfish", "chars"},
  },
  -- 460
  {
    name = "vien",
    sprite = "vien",
    type = "object",
    color = {5,1},
    layer = 4,
    rotate = true,
    tags = {"vines", "plants", "climb"},
    desc = "vinny viensauce",
  },
  -- 461
  {
    name = "txt_vien",
    sprite = "text/vien",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"vines", "plants", "climb"},
    desc = "so she uploads a VIEN",
  },
  -- 462
  {
    name = "pudll",
    sprite = "pudll",
    type = "object",
    color = {1, 3},
    layer = 4,
    tags = {"water", "puddle"},
    desc = "its just a single watr",
  },
  -- 463
  {
    name = "txt_pudll",
    sprite = "text/pudll",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"water", "puddle"},
  },
  -- 464
  {
    name = "red",
    sprite = "red",
    type = "object",
    color = {6,2},
    layer = 4,
    tags = {"reeds", "plants", "cattail", "swamp"},
    desc = "it's not orange, that's just a trick"
  },
  -- 465
  {
    name = "txt_red",
    sprite = "text/red",
    type = "text",
    texttype = {object = true},
    color = {6,2},
    layer = 20,
    tags = {"reeds", "plants", "cattail", "swamp"},
    desc = "wait what",
  },
  -- 466
  {
    name = "stum",
    sprite = "stum",
    type = "object",
    color = {6,1},
    layer = 4,
    tags = {"plants", "tree stump"},
    desc = "im stumped",
  },
  -- 467
  {
    name = "txt_stum",
    sprite = "text/stum",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"plants", "tree stump"},
    unlucky = true,
  },
  -- 468
  {
    name = "bullb",
    sprite = "bullb",
    type = "object",
    color = {2, 4},
    layer = 6,
    tags = {"lightbulb", "power"},
    desc = "lit bullb meow"
  },
  -- 469
  {
    name = "txt_bullb",
    sprite = "text/bullb",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"lightbulb", "power"},
    desc = "go play lightbulbmeow's baba pack it's super good",
  },
  -- 470
  {
    name = "battry",
    sprite = "battry",
    type = "object",
    color = {4, 1},
    layer = 4,
    rotate = "true",
    features = { sans = {x=23,y=14,w=2,h=4} },
    tags = {"battery", "power"},
    desc = "not responsible for hidden states",
  },
  -- 471
  {
    name = "txt_battry",
    sprite = "text/battry",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"battery", "power"},
  },
  -- 472
  {
    name = "smol",
    sprite = "smol",
    type = object,
    color = {5,2},
    layer = 22,
    rotate = true,
    portal = true,
    tags = {"portal"},
    desc = "the tini poor toll",
  },
  -- 473
  {
    name = "txt_smol",
    sprite = "text/smol",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"portal"},
  },
  -- 474
  {
    name = "win",
    sprite = "win",
    type = object,
    color = {1,4},
    layer = 22,
    rotate = true,
    portal = true,
    tags = {"portal", "window", "doorway"},
    desc = "the skware poor toll",
  },
  -- 475
  {
    name = "txt_win",
    sprite = "text/win",
    type = "text",
    texttype = {object = true},
    color = {1,4},
    layer = 20,
    tags = {"portal", "window", "doorway"},
    desc = "not to be confused with :)",
  },
  -- 476
  {
    name = "statoo",
    sprite = "statoo",
    type = "object",
    color = {0, 1},
    layer = 11,
    features = { sans = {x=16, y=6, w=2, h=2} },
    tags = {"statue", "chars", "janitor"},
    desc = "their occupation is a janitor",
  },
  -- 477
  {
    name = "txt_statoo",
    sprite = "text/statoo",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"statue", "chars", "janitor"},
  },
  -- 478
  {
    name = "bon",
    sprite = "bon",
    type = "object",
    color = {0, 3},
    layer = 4,
    rotate = true,
    sing = "overdriven guitar",
    tags = {"bone"},
    desc = "bonles pizza",
  },
  -- 479
  {
    name = "txt_bon",
    sprite = "text/bon",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"bone"},
  },
  -- 480
  {
    name = "rockit",
    sprite = "rockit",
    type = "object",
    color = {1, 3},
    layer = 10,
    rotate = true,
    features = { sans = {x=18,y=13,w=3,h=4} },
    tags = {"rocket", "spaceship"},
    desc = "goes to spce",
  },
  -- 481
  {
    name = "txt_rockit",
    sprite = "text/rockit",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"rocket", "spaceship"},
  },
  -- 482
  {
    name = "ufu",
    sprite = "ufu",
    type = "object",
    color = {3, 3},
    layer = 10,
    features = { sans = {x=15,y=10,w=4,h=5} },
    tags = {"ufo", "spaceship"},
    desc = "comes from spce",
  },
  -- 483
  {
    name = "txt_ufu",
    sprite = "text/ufu",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"ufo", "spaceship"},
  },
  -- 484
  {
    name = "rein",
    sprite = "rein",
    type = "object",
    color = {1, 3},
    layer = 5,
    tags = {"rain"},
    desc = "it pours",
  },
  -- 485
  {
    name = "txt_rein",
    sprite = "text/rein",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"rain"},
  },
  -- 486
  {
    name = "algay",
    sprite = "algay",
    type = "object",
    color = {5,1},
    layer = 3,
    tags = {"algae", "plants"},
  },
  -- 487
  {
    name = "txt_algay",
    sprite = "text/algay",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"algae", "plants"},
    desc = "very gay",
  },
  -- 488
  {
    name = "noet",
    sprite = "noet",
    type = "object",
    color = {4,1},
    layer = 9,
    tags = {"music note", "quarter note"},
    desc = "muzique to my ears"
  },
  -- 489
  {
    name = "txt_noet",
    sprite = "text/noet",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"music note", "quarter note"},
  },
  -- 490
  {
    name = "banboo",
    sprite = "banboo",
    type = "object",
    color = {5,1},
    layer = 4,
    tags = {"bamboo", "plants"},
    desc = "thin tre, tall tre, crunchy tre"
  },
  -- 491
  {
    name = "txt_banboo",
    sprite = "text/banboo",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"bamboo", "plants"},
  },
  -- 492
  {
    name = "bunmy",
    sprite = "bunmy",
    type = "object",
    color = {0, 3},
    layer = 11,
    rotate = true,
    features = { sans = {x=23, y=12, w=2, h=2} },
    tags = {"chars", "bunny rabbit"},
    desc = "looks kinda like bab???",
    nice = true,
  },
  -- 493
  {
    name = "txt_bunmy",
    sprite = "text/bunmy",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "bunny rabbit"},
  },
  -- 494
  {
    name = "karot",
    sprite = "karot",
    type = "object",
    color = {2,3},
    layer = 8,
    rotate = true,
    tags = {"carrot", "plants", "fruit", "food", "vegetable"},
    desc = "bunmy lüv this",
  },
  -- 495
  {
    name = "txt_karot",
    sprite = "text/karot",
    type = "text",
    texttype = {object = true},
    color = {2,3},
    layer = 20,
    tags = {"carrot", "plants", "fruit", "food", "vegetable"},
    desc = "is it a frut? is it a vege? i dont karot all!!!",
  },
  -- 496
  {
    name = "poisbolt",
    sprite = "poisbolt",
    type = "object",
    color = {5, 3},
    layer = 8,
    rotate = true,
    tags = {"poison"},
    desc = "how kids learn the triangular number series",
  },
  -- 497
  {
    name = "txt_poisbolt",
    sprite = "text/poisbolt",
    type = "text",
    texttype = {object = true},
    color = {5, 3},
    layer = 20,
    tags = {"poison"},
  },
  -- 498
  {
    name = "knif",
    sprite = "knif",
    color = {0, 3},
    layer = 8,
    rotate = true,
    tags = {"weapon", "edgy"},
    desc = "doesn't like hurting people"
  },
  -- 499
  {
    name = "txt_knif",
    sprite = "text/knif",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"weapon", "kitchen knife"},
    desc = "KNIF: Any object with GOT KNIF will wield a KNIF."
  },
  -- 500
  {
    name = "timbolt",
    sprite = "timbolt",
    type = "object",
    color = {3, 3},
    layer = 8,
    rotate = true,
    desc = "tim heals all wounds... unless its a bolt",
  },
  -- 501
  {
    name = "txt_timbolt",
    sprite = "text/timbolt",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
  },
  -- 502
  {
    name = "bog",
    sprite = "bog",
    type = "object",
    color = {6, 1},
    layer = 10,
    rotate = true,
    sing = "s_scat",
    features = { sans = {x=24, y=16, w=2, h=2} },
    tags = {"chars", "bug", "insect", "cockroach"},
    desc = "icky",
  },
  -- 503
  {
    name = "txt_bog",
    sprite = "text/bog",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"chars", "bug", "insect", "cockroach"},
  },
  -- 504
  {
    name = "pingu",
    sprite = "pingu",
    type = "object",
    color = {1, 3},
    layer = 11,
    rotate = true,
    features = { sans = {x=12, y=11, w=2, h=2} },
    tags = {"chars", "penguin", "bird"},
    desc = "noot noot",
  },
  -- 505
  {
    name = "txt_pingu",
    sprite = "text/pingu",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"chars", "penguin", "bird"},
  },
  -- 506
  {
    name = "snek",
    sprite = "snek",
    type = "object",
    color = {5, 3},
    layer = 11,
    rotate = true,
    features = { sans = {x=20, y=7, w=2, h=2} },
    tags = {"chars", "snake"},
    desc = "sssssssssssssss",
  },
  -- 507
  {
    name = "txt_snek",
    sprite = "text/snek",
    type = "text",
    texttype = {object = true},
    color = {5, 3},
    layer = 20,
    tags = {"chars", "snake"},
  },
  -- 508
  {
    name = "ripof",
    sprite = "ripof",
    type = "object",
    color = {1, 3},
    layer = 10,
    rotate = true,
    features = { sans = {x=25, y=17, w=3, h=3} },
    tags = {"chars", "dev", "slime", "blob", "rip off"},
    desc = "from the hit game DEV IS YOU",
  },
  -- 509
  {
    name = "txt_ripof",
    sprite = "text/ripof",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"chars", "dev", "slime", "blob", "rip off"},
    desc = "it needs to have the tag dev but i don't want it to be with the other devs",
  },
  -- 510
  {
    name = "butflye",
    sprite = "butflye",
    type = "object",
    color = {1, 4},
    layer = 10,
    rotate = true,
    features = { sans = {x=19, y=11, w=2, h=2} },
    tags = {"butterfly", "chars", "insect"},
    desc = "of the bleu morpho variety",
  },
  -- 511
  {
    name = "txt_butflye",
    sprite = "text/butflye",
    type = "text",
    texttype = {object = true},
    color = {1, 4},
    layer = 20,
    tags = {"butterfly", "chars", "insect"},
    desc = "but, flye??",
  },
  -- 512
  {
    name = "wurm",
    sprite = "wurm",
    type = "object",
    color = {3, 3},
    layer = 11,
    rotate = true,
    features = { sans = {x=20, y=4, w=2, h=2} },
    tags = {"worm", "caterpillar", "bug", "chars", "insect"},
    desc = "slithers\nbut a wormy slither not a snaky slither"
  },
  -- 513
  {
    name = "txt_wurm",
    sprite = "text/wurm",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"worm", "caterpillar", "bug", "chars", "insect"},
  },
  -- 514
  {
    name = "letter_bolt",
    sprite = "letter_bolt",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "Used for all of the bolt words; firbolt, icbolt, litbolt, etc.",
  },
  -- 515
  {
    name = "letter_ol",
    sprite = "letter_ol",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 516
  {
    name = "cor",
    sprite = "cor",
    type = "object",
    color = {4,0},
    layer = 4,
    tags = {"coral", "beach"},
    desc = "they look very pretty irl"
  },
  -- 517
  {
    name = "txt_cor",
    sprite = "text/cor",
    type = "text",
    texttype = {object = true},
    color = {4,0},
    layer = 20,
    tags = {"coral", "beach"},
    desc = "ROC backwards",
  },
  -- 518
  {
    name = "sirn",
    sprite = "sirn",
    type = "object",
    color = {2,2},
    layer = 6,
    rotate = true,
    tags = {"siren", "alarm"},
    desc = "will steal ur tim machine,"
  },
  -- 519
  {
    name = "txt_sirn",
    sprite = "text/sirn",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"siren", "alarm"},
  },
  -- 520
  {
    name = "ratt",
    sprite = "ratt",
    type = "object",
    color = {0, 1},
    layer = 10,
    rotate = true,
    features = { sans = {x=27, y=14, w=2, h=2} },
    tags = {"chars", "rat", "mouse"},
    desc = "the real MOUS, they STALK at night and SNACC at night, they're the RATTs",
  },
  -- 521
  {
    name = "txt_ratt",
    sprite = "text/ratt",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"chars", "rat", "mouse"},
    desc = "the stand of BOG-SNACCEN",
  },
  -- 522
  {
    name = "moo",
    sprite = "moo",
    type = "object",
    color = {0, 3},
    layer = 11,
    rotate = true,
    features = { sans = {x=27, y=7, w=2, h=2} },
    tags = {"chars", "cow"},
    desc = "you found bertie, the unfindable moo! noe lvl be infloop",
  },
  -- 523
  {
    name = "txt_moo",
    sprite = "text/moo",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "cow"},
    desc = "moooooo",
  },
  -- 524
  {
    name = "enbybog",
    sprite = "enbybog",
    type = "object",
    color = {2, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=23, y=17, w=2, h=2} },
    tags = {"chars", "ladybug", "insect", "cockroach"},
    desc = "goes by they/them",
    pronouns = {"they","them"},
  },
  -- 525
  {
    name = "txt_enbybog",
    sprite = "text/enbybog",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"chars", "ladybug", "insect", "cockroach"},
  },
  -- 526
  {
    name = "shrim",
    sprite = "shrim",
    type = "object",
    color = {2, 2},
    layer = 11,
    rotate = true,
    sing = "kkb",
    features = { sans = {x=20, y=9, w=2, h=2} },
    tags = {"chars", "shrimp", "prawn"},
    desc = "shouldnt it be PINC",
  },
  -- 527
  {
    name = "txt_shrim",
    sprite = "text/shrim",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"chars", "shrimp", "prawn"},
    desc = "shrims are pretty rich",
  },
  -- 528
  {
    name = "flamgo",
    sprite = "flamgo",
    type = "object",
    color = {4, 1},
    layer = 11,
    sing = "kkb",
    features = { sans = {x=23, y=3, w=2, h=2} },
    tags = {"chars", "flamingo", "bird"},
    desc = "if ur COLRFUL thats cool too!!",
  },
  -- 529
  {
    name = "txt_flamgo",
    sprite = "text/flamgo",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"chars", "flamingo", "bird"},
    desc = "mr. flame go"
  },
  -- 530
  {
    name = "gul",
    sprite = "gul",
    type = "object",
    color = {0, 3},
    layer = 11,
    features = { sans = {x=21, y=11, w=2, h=2} },
    tags = {"chars", "seagull", "bird", "beach", "7"},
    desc = "7",
  },
  -- 531
  {
    name = "txt_gul",
    sprite = "text/gul",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "seagull", "bird", "beach"},
  },
  -- 532
  {
    name = "starrfishe",
    sprite = "starrfishe",
    type = "object",
    color = {4, 2},
    layer = 10,
    rotate = true,
    features = { sans = {x=16, y=12, w=2, h=2} },
    tags = {"chars", "starfish", "beach"},
    desc = "she's alive, and has 4 eyes",
  },
  -- 533
  {
    name = "txt_starrfishe",
    sprite = "text/starrfishe",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"chars", "starfish", "beach"},
    desc = "what a long name",
  },
  -- 534
  {
    name = "sneel",
    sprite = "sneel",
    type = "object",
    color = {4, 2},
    layer = 10,
    rotate = true,
    features = { sans = {x=21, y=28, w=2, h=2} },
    tags = {"chars", "snail"},
    desc = "winner of the undertale snail race gets into BAB",
  },
  -- 535
  {
    name = "txt_sneel",
    sprite = "text/sneel",
    type = "text",
    texttype = {object = true},
    color = {4, 2},
    layer = 20,
    tags = {"chars", "snail"},
    desc = "its kinda slow to load in tho."
  },
  -- 536
  {
    name = "kapa",
    sprite = "kapa",
    type = "object",
    color = {5, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=24, y=14, w=2, h=2} },
    tags = {"chars", "japan", "youkai", "kappa"},
    desc = "now we need a CUMBER object",
  },
  -- 537
  {
    name = "txt_kapa",
    sprite = "text/kapa",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"chars", "japan", "youkai", "kappa"},
    desc = ":V"
  },
  -- 538
  {
    name = "urei",
    sprite = "urei",
    type = "object",
    color = {0, 3},
    layer = 11,
    features = { sans = {x=20, y=19, w=2, h=2} },
    tags = {"chars", "japan", "youkai", "yuurei", "ghost"},
    desc = "GHOST FREN of the eastern variety",
  },
  -- 539
  {
    name = "txt_urei",
    sprite = "text/urei",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "japan", "youkai", "yuurei", "ghost"},
  },
  -- 540
  {
    name = "wips",
    sprite = "wips",
    type = "object",
    color = {0, 3},
    layer = 9,
    tags = {"will o wisp", "japan", "ghost", "spirit"},
    desc = "WILL o WIPS?",
  },
  -- 541
  {
    name = "txt_wips",
    sprite = "text/wips",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"will o wisp", "japan", "ghost", "spirit"},
    desc = "work in progress",
  },
  -- 542
  {
    name = "ryugon",
    sprite = "ryugon",
    type = "object",
    color = {5, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=21, y=7, w=3, h=2} },
    tags = {"chars", "japan", "youkai", "dragon"},
    desc = "ryugon no ken wo kurae",
  },
  -- 543
  {
    name = "txt_ryugon",
    sprite = "text/ryugon",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"chars", "japan", "youkai", "dragon"},
  },
  -- 544
  {
    name = "iy",
    sprite = "iy",
    type = "object",
    color = {0, 3},
    layer = 10,
    rotate = true,
    features = { sans = {x=17, y=12, w=7, h=8} },
    tags = {"eye", "body part"},
    desc = "IY SEES ALL",
  },
  -- 545
  {
    name = "txt_iy",
    sprite = "text/iy",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"eye", "body part"},
  },
  -- 546
  {
    name = "lisp",
    sprite = "lisp",
    type = "object",
    color = {2, 2},
    layer = 10,
    rotate = true,
    sing = "kkb2",
    tags = {"mouth", "lips", "body part"},
    desc = "it speaks",
  },
  -- 547
  {
    name = "txt_lisp",
    sprite = "text/lisp",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"mouth", "lips", "body part"},
    desc = "it altho hath a lithp",
  },
  -- 548
  {
    name = "eeg",
    sprite = "eeg",
    type = "object",
    color = {6, 2},
    layer = 8,
    rotate = true,
    tags = {"egg", "food"},
    desc = "no one knows what's inside. it's impenetrable"
  },
  -- 549
  {
    name = "txt_eeg",
    sprite = "text/eeg",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"egg", "food"},
  },
  -- 550
  {
    name = "foreeg",
    sprite = "foreeg",
    type = "object",
    color = {6, 1},
    layer = 4,
    rotate = true,
    tags = {"nest"},
    desc = "no one knows what's inside. the eeg proteccs it"
  },
  -- 551
  {
    name = "txt_foreeg",
    sprite = "text/foreeg",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"nest"},
  },
  -- 552
  {
    name = "paw",
    sprite = "paw",
    type = "object",
    color = {0, 3},
    layer = 10,
    rotate = true,
    tags = {"paw print"},
    desc = "dogg in bab when?",
  },
  -- 553
  {
    name = "txt_paw",
    sprite = "text/paw",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"paw print"},
    desc = "ok well idk when it happened but we have toby now"
  },
  -- 554
  {
    name = "cavebab",
    sprite = "cavebab",
    type = "object",
    color = {3,3},
    layer = 11,
    features = { sans = {x=18, y=10, w=2, h=2} },
    tags = {"chars", "bat"},
    desc = "slep upside down",
  },
  -- 555
  {
    name = "txt_cavebab",
    sprite = "text/cavebab",
    type = "text",
    texttype = {object = true},
    color = {3,3},
    layer = 20,
    tags = {"chars", "bat"},
  },
  -- 556
  {
    name = "extre",
    sprite = "extre",
    type = "object",
    color = {6, 1},
    layer = 4,
    rotate = "true",
    tags = {"tree", "plants", "husk"},
    desc = "a ded tre. rip",
  },
  -- 557
  {
    name = "txt_extre",
    sprite = "text/extre",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"tree", "plants", "husk"},
  },
  -- 558
  {
    name = "heg",
    sprite = "heg",
    type = "object",
    color = {5, 2},
    layer = 4,
    tags = {"plant", "cactus"},
    desc = "ouch",
  },
  -- 559
  {
    name = "txt_heg",
    sprite = "text/heg",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"plant", "cactus"},
    dec = "the text ben't as ouch"
  },
  -- 560
  {
    name = "byc",
    sprite = {"byc", "byc_editor"},
    type = "object",
    color = {{0, 3}, {2, 2}, {2, 2}},
    colored = {{0, 0}, true, true},
    rotate = true,
    layer = 8,
    tags = {"playing card", "bicycle", "ace", "card"},
    desc = "haha get it, it's because bicycle is a specific brand of playing card",
  },
  -- 561
  {
    name = "txt_byc",
    sprite = "text/byc",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"playing card", "bicycle", "ace", "card"},
    desc = "BYC: has a random image every time it's loaded!",
  },
  -- 562
  {
    name = "bac",
    sprite = {"byc", "bac"},
    type = "object",
    color = {{0, 3}, {2, 2}},
    colored = {{0, 0}, true},
    rotate = true,
    layer = 8,
    tags = {"playing card back", "bicycle", "card"},
    desc = "cards have 2 sides",
  },
  -- 563
  {
    name = "txt_bac",
    sprite = "text/bac",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"playing card back", "bicycle", "card"},
  },
  -- 564
  {
    name = "txt_wun",
    sprite = "text/wun",
    type = "text",
    texttype = {cond_prefix = true},
    color = {2,4},
    layer = 20,
    tags = {"won","patashu"},
    desc = "WUN: A prefix condition that's true if the unit is a won level. If the unit isn't a level, then true if the current level is won.",
  },
  -- 565
  {
    name = "txt_notranform",
    sprite = "text/notranform",
    type = "text",
    texttype = {property = true},
    color = {2,2},
    layer = 20,
    tags = {"no transform"},
    desc = "NO TRANFORM: A property that prevents the object from transforming. LVL BE NO TRANFORM reverts any transformations it had. X BEN'T NOTRANFORM negates X BE X. Also negates TRANZ.",
  },
  -- 566
  {
    name = "golf",
    sprite = "golf",
    type = "object",
    color = {1, 2},
    layer = 6,
    tags = {"flag", "unwin"},
    desc = "i want 0!!!",
  },
  -- 567
  {
    name = "txt_golf",
    sprite = "text/golf",
    type = "text",
    texttype = {object = true},
    color = {1, 2},
    layer = 20,
    tags = {"flag", "unwin"},
    desc = "you see, in golf, a LOWER score is better",
  },
  -- 568
  {
    name = "txt_sing",
    sprite = "text/sing",
    type = "text",
    texttype = {verb = true, verb_sing = true},
    color = {4, 1},
    layer = 20,
    tags = {"play", "music", "say"},
    desc = "SING (Verb): SING A-G with letters!",
  },
  --- 569
  {
    name = "txt_diagkik",
    sprite = "text/diagkik",
    type = "text",
    texttype = {property = true},
    color ={6, 1},
    layer = 20,
    tags = {"sidekick", "diagkick"},
    desc = "DIAGKIK: If a unit moves 45 degrees away from a DIAGKIK, the DIAGKIK copies that movement. With two stacks, also copies 135 degree movement.",
  },
  -- 570
  {
    name = "migri",
    sprite = "migri",
    type = "object",
    color = {3, 0},
    layer = 11,
    rotate = true,
    features = { sans = {x=12,y=14,w=2,h=3} },
    tags = {"chars"},
    desc = "i don't actually know what this is, someone tell me",
  },
  -- 571
  {
    name = "txt_migri",
    sprite = "text/migri",
    type = "text",
    texttype = {object = true},
    color = {3, 0},
    layer = 20,
    tags = {"chars"},
  },
  -- 572
  {
    name = "sloop",
    sprite = "sloop",
    type = "object",
    color = {0, 3},
    layer = 3,
    rotate = true,
    tags = {"triangle", "half", "slope"},
    desc = "really cool that bab be u 2 introduced slopes, GOTY",
  },
  -- 573
  {
    name = "txt_sloop",
    sprite = "text/sloop",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"triangle", "half", "slope"},
    desc = "ideal for reflecc + go my way",
  },
  -- 574
  {
    name = "txt_reflecc",
    sprite = "text/reflecc",
    type = "text",
    texttype = {property = true},
    color = {5, 2},
    layer = 20,
    tags = {"reflect", "slope", "bounce", "mirror"},
    desc = "REFLECC: When a unit moves onto a REFLECC unit from in front or behind, it will bounce back at 180 degrees. At a 45/135 angle, 90 degrees. At a 90 angle, it will be unable to enter.",
  },
  -- 575
  {
    name = "reflecr",
    sprite = "reflecr",
    type = "object",
    color = {0, 3},
    layer = 3,
    rotate = true,
    tags = {"mirror", "diagonal", "line", "slope"},
    desc = "imported directly from Deflektor",
  },
  -- 576
  {
    name = "txt_reflecr",
    sprite = "text/reflecr",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"mirror", "diagonal", "line", "slope"},
    desc = "ideal for reflecc",
  },
  -- 577
  {
    name = "txt_graey",
    sprite = "text/graey_cond",
    sprite_transforms = {
      property = "txt_graey"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {0, 1},
    layer = 20,
    tags = {"colors", "colours", "gray", "grey"},
    desc = "GRAEY: Causes the unit to become gray/grey.\nColor or colour?"
  },
  -- 578
  {
    name = "txt_brwn",
    sprite = "text/brwn_cond",
    sprite_transforms = {
      property = "txt_brwn"
    },
    type = "text",
    texttype = {cond_prefix = true, property = true, class_prefix = true},
    color = {6, 0},
    layer = 20,
    tags = {"colors", "colours", "brown"},
    desc = "BRWN: Causes the unit to become brown."
  },
  -- 579
  {
    name = "txt_sharp",
    sprite = "letter_sharp",
    type = "text",
    texttype = {note_modifier = true},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 580
  {
    name = "txt_flat",
    sprite = "letter_flat",
    type = "text",
    texttype = {note_modifier = true},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 581
  {
    name = "chain",
    sprite = "chain",
    type = "object",
    color = {0, 2},
    layer = 22,
    rotate = "true",
    desc = "EVERY1 W/FREN CHAIN STALK JAIL. now bab's going to jail :(",
  },
  -- 582
  {
    name = "txt_chain",
    sprite = "text/chain",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
  },
  -- 583
  {
    name = "lili",
    sprite = "lili",
    type = "object",
    color = {5,1},
    layer = 4,
    rotate = "true",
    tags = {"lilypad", "plants"},
    desc = "water type evolution of platfor"
  },
  -- 584
  {
    name = "txt_lili",
    sprite = "text/lili",
    type = "text",
    texttype = {object = true},
    color = {5,1},
    layer = 20,
    tags = {"lilypad", "plants"},
    desc = "not to be confused with LILA",
  },
  -- 585
  {
    name = "swim",
    sprite = "swim",
    type = "object",
    color = {6,1},
    layer = 8,
    tags = {"boat", "ship"},
    desc = "no no swim n't n't"
  },
  -- 586
  {
    name = "txt_swim",
    sprite = "text/swim",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"boat", "ship"},
  },
  -- 587
  {
    name = "boooo",
    sprite = {"boooo","boooo_mouth"},
    type = "object",
    color = {{0,3},{2,2},{4,2}},
    colored = {true,false,false},
    layer = 10,
    rotate = true,
    features = { sans = {x=23,y=9,w=4,h=5} },
    tags = {"boo","mario","ghost"},
    desc = "very shy, don't lookat",
  },
  -- 588
  {
    name = "txt_boooo",
    sprite = "text/boooo",
    type = "text",
    texttype = {object = true},
    color = {4,2},
    layer = 20,
    tags = {"boo","mario","ghost"},
    desc = "AAA u scar mee!",
  },
  -- 589
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
  -- 590
  {
    name = "txt_gorder",
    sprite = "text/gorder",
    type = "text",
    texttype = {object = true},
    color = {0,2},
    layer = 20,
    tags = {"girder","city"},
  },
  -- 591
  {
    name = "piep",
    sprite = "piep",
    type = "object",
    color = {5,2},
    rotate = true,
    portal = true,
    layer = 3,
    tags = {"pipe","tube","mario"},
    desc = "enter the piep to skip world",
  },
  -- 592
  {
    name = "txt_piep",
    sprite = "text/piep",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"pipe","tube","mario"},
  },
  -- 593
  {
    name = "tuba",
    sprite = "tuba",
    type = "object",
    color = {5,2},
    rotate = true,
    layer = 3,
    tags = {"pipe","tube","mario"},
    desc = "piep's bff",
  },
  -- 594
  {
    name = "txt_tuba",
    sprite = "text/tuba",
    type = "text",
    texttype = {object = true},
    color = {5,2},
    layer = 20,
    tags = {"pipe","tube","mario"},
    desc = "pieps are musical instruments",
  },
  -- 595
  {
    name = "txt_every2",
    sprite = "text/every2",
    type = "text",
    texttype = {object = true},
    color = {3, 3},
    layer = 20,
    tags = {"all", "everyone", "every2"},
    desc = "EVERY2: EVERY1 + TXT. (Doesn't include innerlvls atm because lazy + hard to code + unlikely to come up. Sorry.)",
  },
  -- 596
  {
    name = "txt_every3",
    sprite = "text/every3",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"all", "everyone", "every3"},
    desc = "EVERY3: Absolutely everything conceivable. The pinnacle of everything technology. (Infloop is not an object.)",
  },
  -- 597
  {
    name = "txt_every3",
    sprite = "text/every3",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"all", "everyone", "every3"},
    desc = "EVERY3: Absolutely everything conceivable. The pinnacle of everything technology.",
  },
  -- 598
  {
    name = "madi",
    sprite = {"madi_hair","madi_skin","madi_shirt","madi_pants"},
    type = "object",
    color = {{2,2},{2,4},{1,3},{2,2}},
    colored = {true,false,false,false},
    rotate = true,
    features = { sans = {x=21,y=9,w=1,h=2} },
    layer = 11,
    tags = {"madeline","celeste","chars"},
    desc = "she clim mountain in very good game",
  },
  -- 599
  {
    name = "txt_madi",
    sprite = "text/madi",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    tags = {"madeline","celeste","chars"},
  },
  -- 600
  {
    name = "badi",
    sprite = {"madi_hair","madi_skin","madi_eyes","madi_shirt","madi_pants"},
    type = "object",
    color = {{3,1},{3,3},{2,2},{3,2},{3,0}},
    colored = {true,false,false,false,false},
    rotate = true,
    features = { sans = {x=21,y=9,w=1,h=2} },
    layer = 11,
    tags = {"badeline","celeste","chars"},
    desc = "emag doog yrev ni niatnuom milc ehs",
  },
  -- 601
  {
    name = "txt_badi",
    sprite = "text/badi",
    type = "text",
    texttype = {object = true},
    color = {3,3},
    layer = 20,
    tags = {"badeline","celeste","chars"},
  },
  -- 602
  {
    name = "txt_lethers",
    sprite = "text/lethers",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"letters"},
    desc = "LETHERS: Refers to all letters that exist in the level.",
  },
  -- 603
  {
    name = "txt_thatgot",
    sprite = "text/that got",
    type = "text",
    texttype = {cond_infix = true, cond_infix_verb = true, cond_infix_verb_plus = true},
    color = {0, 3},
    layer = 20,
    tags = {"lily", "with", "w/", "infix condition"},
    desc = "THAT GOT (Infix Condition): x THAT GOT y is true if x GOT y.",
  },
  -- 604
  {
    name = "forbeeee",
    sprite = "forbeeee",
    type = "object",
    color = {6, 2},
    layer = 4,
    tags = {"beehive", "beecomb", "honeycomb"},
    desc = "trans rights",
  },
  -- 605
  {
    name = "txt_forbeeee",
    sprite = "text/forbeeee",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"beehive", "beecomb", "honeycomb"},
  },
  -- 606
  {
    name = "do$h",
    sprite = "do$h",
    type = "object",
    color = {5, 2},
    layer = 6,
    tags = {"dosh", "cash money","money"},
    desc = "DO$H DO$H DO$H!"
  },
  -- 607
  {
    name = "txt_do$h",
    sprite = "text/do$h",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"dosh", "cash money","money"},
    desc = "dollas",
  },
  -- 608
  {
    name = "dling",
    sprite = "dling",
    type = "object",
    color = {2, 4},
    layer = 6,
    rotate = "true",
    tags = {"coin","mario"},
    desc = "dling dling dling!"
  },
  -- 609
  {
    name = "txt_dling",
    sprite = "text/dling",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"coin","mario"},
    desc = "the sound a coin makes",
  },
  -- 610
  {
    name = "warn",
    sprite = {"warn", "no1"},
    type = "object",
    color = {{2, 4}, {0,0}},
    colored = {true, false},
    layer = 3,
    tags = {"warning", "stripes"},
    desc = "cauntion",
  },
  -- 611
  {
    name = "txt_warn",
    sprite = "text/warn",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"warning", "stripes"},
  },
  -- 612
  {
    name = "reffil",
    sprite = "reffil",
    type = "object",
    color = {5,3},
    layer = 6,
    tags = {"refill","celeste"},
    desc = "gives u dash bacc",
  },
  -- 613
  {
    name = "txt_reffil",
    sprite = "text/reffil",
    type = "text",
    texttype = {object = true},
    color = {5,3},
    layer = 20,
    tags = {"refill","celeste"},
  },
  -- 614
  {
    name = "txt_soko",
    sprite = "text/soko",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {6,2},
    layer = 20,
    tags = {"sokoban"},
    desc = "SOKO (Verb): If X SOKO Y, then X wins when all Y are not frenles.",
  },
  -- 615
  {
    name = "yanying",
    sprite = {"yan", "ying"},
    type = "object",
    color = {{0,3}, {2,2}},
    colored = {false, true},
    layer = 6,
    tags = {"yin yang orb", "taoism"},
    desc = "good vs bad, they balanced"
  },
  -- 616
  {
    name = "txt_yanying",
    sprite = "text/yanying",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"yin yang orb", "taoism"},
  },
  -- 617
  {
    name = "vlc",
    sprite = "vlc",
    type = "object",
    color = {2,3},
    layer = 6,
    tags = {"traffic cone"},
    desc = "VLC media player is a free and open-source portable cross-platform media player software and streaming media server developed by the VideoLAN project. VLC is available for desktop operating systems and mobile platforms, such as Android, iOS, iPadOS, Tizen, Windows 10 Mobile and Windows Phone."
  },
  -- 618
  {
    name = "txt_vlc",
    sprite = "text/vlc",
    type = "text",
    texttype = {object = true},
    color = {2,3},
    layer = 20,
    tags = {"traffic cone"},
  },
  -- 619
  {
    name = "pidgin",
    sprite = "pidgin",
    type = "object",
    color = {0, 2},
    layer = 11,
    rotate = true,
    features = { sans = {x=21, y=6, w=2, h=2} },
    tags = {"chars", "bird", "city", "pigeon"},
    desc = "not a creole",
  },
  -- 620
  {
    name = "txt_pidgin",
    sprite = "text/pidgin",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"chars", "bird", "city", "pigeon"},
    desc = "also not a creole",
  },
  -- 621
  {
    name = "foru",
    sprite = "foru",
    type = "object",
    color = {0,1},
    layer = 4,
    tags = {"trash can", "rubbish bin", "garbage", "delete", "city"},
    desc = "tresh",
  },
  -- 622
  {
    name = "txt_foru",
    sprite = "text/foru",
    type = "text",
    texttype = {object = true},
    color = {0,1},
    layer = 20,
    tags = {"trash can", "rubbish bin", "garbage", "delete", "city"},
    desc = "ha ! goteeM",
  },
  -- 623
  {
    name = "rod",
    sprite = "rod",
    type = "object",
    color = {0,3},
    layer = 3,
    rotate = true,
    tags = {"city", "street", "road"},
    desc = "forkar",
  },
  -- 624
  {
    name = "txt_rod",
    sprite = "text/rod",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"city", "street", "road"},
  },
  -- 625
  {
    name = "letter_custom",
    sprite = "letter_custom",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    tags = {},
    desc = "Custom Letters: Type up to 6 letters into the search box and hit ctrl+enter to get a tile with those letters in it. This text shouldn't show ingame anywhere."
  },
  -- 626
  {
    name = "txt_past",
    sprite = "text/past",
    type = "text",
    texttype = {cond_prefix = true},
    color = {3, 3},
    layer = 20,
    desc = "PAST (Prefix Condition): Applies the rule to turns that have already happened. (It's about as great as it sounds.)",
  },
  -- 627
  {
    name = "sans",
    sprite = {"sans_base","sans_jacket"},
    color = {{0,3},{1,3}},
    colored = {false,true},
    layer = 11,
    rotate = true,
    sing = "overdriven guitar",
    convertible = false,
    features = { sans = {x=19, y=5, w=2, h=2} },
    tags = {"chars", "sans", "undertale", "skeleton"},
    desc = "sans",
  },
  -- 628
  {
    name = "ditto",
    sprite = "ditto",
    color = {3,3},
    layer = 11,
    rotate = true,
    sing = "ditto",
    tometa = "txt_''",
    features = {
      sans = {x=10, y=16, w=5, h=5},
      which = {x=1, y=6, sprite = {"no1", "which_ditto"}},
      sant = {y=4},
      gunne = {sprite = "gunne_ditto"},
    },
    tags = {"chars", "ditto", "pokemon"},
  },
  -- 629
  {
    name = "kva",
    sprite = "kva",
    type = "object",
    color = {5,3},
    layer = 11,
    rotate = true,
    features = { sans = {x=25, y=7, w=3, h=3} },
    tags = {"chars", "frog", "toad"},
    desc = "hippity hoppity kva loves u"
  },
  -- 630
  {
    name = "txt_kva",
    sprite = "text/kva",
    type = "text",
    texttype = {object = true},
    color = {5,3},
    layer = 20,
    tags = {"chars", "frog", "toad"},
  },
  -- 631
  {
    name = "ofin",
    sprite = "ofin",
    type = "object",
    color = {2,3},
    layer = 7,
    tags = {"oven", "microwave", "future gadget", "of out"},
    desc = "why do they call it oven when you of in the cold food of out hot eat the food",
  },
  -- 632
  {
    name = "txt_ofin",
    sprite = "text/ofin",
    type = "text",
    texttype = {object = true},
    color = {2,3},
    layer = 20,
    tags = {"oven", "microwave", "future gadget", "of out"},
    desc = "of out",
  },
  -- 633
  {
    name = "txt_stukc",
    sprite = "text/stukc",
    type = "text",
    texttype = {property = true},
    color = {1,1},
    layer = 20,
    tags = {"stuck", "still"},
    desc = "STUKC: Anything with this property can't move."
  },
  -- 634
  {
    name = "casete",
    sprite = "casete",
    type = "object",
    color = {0,2},
    layer = 2,
    tags = {"cassette","bside","b-side","celeste"},
    desc = "chiptune bloc",
  },
  -- 635
  {
    name = "txt_casete",
    sprite = "text/casete",
    type = "text",
    texttype = {object = true},
    color = {0,2},
    layer = 20,
    tags = {"cassette","bside","b-side","celeste"},
    desc = "The sprite changes if you change its color. Try it out!",
  },
  -- 636
  {
    name = "txt_giv",
    sprite = "text/giv",
    type = "text",
    texttype = {verb = true, verb_property = true},
    color = {2,4},
    layer = 20,
    tags = {"give"},
    desc = "GIV (Verb): If X giv Y, any other units in the same space and flye will get the Y property.",
  },
  -- 637
  {
    name = "copkat",
    sprite = {"copkat_base", "copkat_stuff", "copkat_badge"},
    color = {{0,3}, {1,3}, {2,4}},
    colored = {true, false, false},
    layer = 11,
    rotate = true,
    sing = "cat",
    convertible = false,
    features = { sans = {x=27, y=14, w=2, h=2} },
    tags = {"chars", "cop", "police", "cat"},
    desc = "u hav da wight to wemain siwent!!",
  },
  -- 638
  {
    name = "kat",
    sprite = "kat",
    color = {0, 3},
    layer = 11,
    rotate = true,
    sing = "cat",
    features = { 
      sans = {x=26, y=11, w=3, h=3},
      cool = {x=5, y=-1},
      which = {x = 7},
      sant = {y = 1},
      knif = {x = 6, y = 2},
      bowie = {x = 5, y = -3},
      hatt = {x = 7},
      gunne = {x = 2, y = 4},
      katany = {nya = true},
    },
    tags = {"chars", "cat", "sis", "sister"},
    desc = "bab's sister",
    pronouns = {"she","her"}
  },
  -- 639
  {
    name = "txt_kat",
    sprite = "text/kat",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"chars", "cat", "sis", "sister"},
    desc = "meow?"
  },
  -- 640
  {
    name = "txt_gone",
    sprite = "text/gone",
    type = "text",
    texttype = {property = true},
    color = {0,3},
    layer = 20,
    tags = {"done"},
    desc = "GONE: If something is GONE, it floats away into nothingness."
  },
  -- 641
  {
    name = "swan",
    sprite = "swan",
    color = {0, 3},
    layer = 11,
    rotate = true,
    features = {
      sans = {x=20, y=5, w=2, h=2},
      which = {x = 2, y = -3},
      sant = {x = 2, y = 2},
      katany = {x = 10, y = -14},
      knif = {x = 13, y = -12},
      bowie = {x = 3, y = -6},
      hatt = {x = 4, y = -3},
      gunne = {x = 11, y = -10},
      slippers = {x = 3}
    },
    tags = {"chars", "bird", "untitled goose game"},
    desc = "a goos is a female swan",
  },
  -- 642
  {
    name = "txt_swan",
    sprite = "text/swan",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"chars", "bird", "untitled goose game"},
    desc = "unnamed swan thing: swan can GOT any object!!!",
  },
  -- 643
  {
    name = "spoder",
    sprite = "spoder",
    color = {3, 1},
    layer = 11,
    rotate = true,
    features = { sans = {x=12, y=12, w=3, h=3} },
    tags = {"chars", "spider", "bug", "spoods"},
    desc = "i think purp is a goode look on u!",
  },
  -- 644
  {
    name = "txt_spoder",
    sprite = "text/spoder",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"chars", "spider", "bug", "spoods"},
    desc = "sppood",
  },
  -- 645
  {
    name = "weeb",
    sprite = "weeb",
    color = {0, 3},
    layer = 4,
    rotate = true,
    tags = {"spiderweb", "cobweb", "for spoder"},
    desc = "very glued",
  },
  -- 646
  {
    name = "txt_weeb",
    sprite = "text/weeb",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"spiderweb", "cobweb", "for spoder"},
    desc = "weebs dont interact",
  },
  -- 647
  {
    name = "flof",
    sprite = "flof",
    color = {0, 3},
    layer = 11,
    rotate = true,
    features = { 
      sans = {x=23, y=17, w=3, h=3},
      hatt = {y = 4},
      which = {y = 4},
    },
    tags = {"fluff", "floof", "brother", "dog"},
    desc = "bab's bro, ver soft, pls pet",
    pronouns = {"he","him"},
  },
  -- 648
  {
    name = "txt_flof",
    sprite = "text/flof",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"fluff", "floof", "brother", "dog"},
    desc = "not a flog",
  },
  -- 649
  {
    name = "err",
    sprite = "err",
    color = {0, 3},
    layer = 11,
    rotate = true,
    features = { sans = {x=23, y=9, w=4, h=4} },
    tags = {"chars", "error"},
    desc = "kinda spooky in bab tbh",
  },
  -- 650
  {
    name = "txt_err",
    sprite = "text/err",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"chars", "error"},
  },
  -- 651
  {
    name = "ches",
    sprite = "chest_close",
    color = {2, 2},
    layer = 7,
    tags = {"chest", "treasure chest", "mimic"},
    desc = "closes when NED KEE",
  },
  -- 652
  {
    name = "txt_ches",
    sprite = "text/ches",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"chest", "treasure chest", "mimic"},
  },
  -- 653
  {
    name = "mimi",
    sprite = "mimic_close",
    color = {2, 2},
    layer = 9,
    features = { sans = {x=14, y=17, w=2, h=4} },
    tags = {"chars", "chest", "treasure chest", "mimic"},
    desc = "closes when NED KEE",
  },
  -- 654
  {
    name = "txt_mimi",
    sprite = "text/mimi",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"chars", "chest", "treasure chest", "mimic"},
  },
  -- 655
  {
    name = "3den",
    sprite = "3den",
    color = {1, 2},
    layer = 8,
    rotate = true,
    tags = {"trident"},
    desc = "dont throw it away",
  },
  -- 656
  {
    name = "txt_3den",
    sprite = "text/3den",
    type = "text",
    texttype = {object = true},
    color = {1, 2},
    layer = 20,
    tags = {"trident"},
  },
  -- 657
  {
    name = "pen",
    sprite = "pen",
    color = {2, 4},
    layer = 7,
    rotate = true,
    tags = {"pencil"},
    desc = "the creating one",
  },
  -- 658
  {
    name = "txt_pen",
    sprite = "text/pen",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"pencil"},
  },
  -- 659
  {
    name = "cil",
    sprite = "cil",
    color = {2, 4},
    layer = 7,
    rotate = true,
    tags = {"pencil", "eraser"},
    desc = "the deleting one",
  },
  -- 660
  {
    name = "txt_cil",
    sprite = "text/cil",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"pencil", "eraser"},
  },
  -- 661
  {
    name = "grav",
    sprite = "grav",
    color = {0, 1},
    layer = 4,
    tags = {"gravestone", "tombstone", "spooky"},
    desc = "what do you call a serious person with a shovel?\na grave digger\nhahahahaha"
  },
  -- 662
  {
    name = "txt_grav",
    sprite = "text/grav",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"gravestone", "tombstone", "spooky"},
    desc = "not to be confused with the removed GRAVY",
  },
  -- 663
  {
    name = "pumkin",
    sprite = "pumkin",
    color = {2, 3},
    layer = 6,
    features = { sans = {x=21, y=15, w=5, h=3} },
    tags = {"pumpkin", "plant", "spooky"},
    desc = "turns spooky with the correct properties",
  },
  -- 664
  {
    name = "txt_pumkin",
    sprite = "text/pumkin",
    type = "text",
    texttype = {object = true},
    color = {2, 3},
    layer = 20,
    tags = {"pumpkin", "plant", "spooky"},
  },
  -- 665
  {
    name = "txt_thingify",
    sprite = "text/thingify",
    type = "text",
    texttype = {property = true},
    color = {3, 1},
    layer = 20,
    tags = {"demeta", "notnat"},
    desc = "THINGIFY: BE THINGIFY causes that text to turn into the object it represents (or text it represents if metatext). Some texts become objects that can only be formed through thingify!",
  },
  -- 666
  {
    name = "txt_right",
    sprite = "text/right",
    type = "text",
    texttype = {property = true, direction = true},
    color = {1, 4},
    layer = 20,
    edgy = true,
    desc = "RIGHT: A GO ->, but facing right.",
  },
  -- 667
  {
    name = "txt_samepaint",
    sprite = "text/samepaint",
    type = "text",
    texttype = {cond_compare = true, class_prefix = true},
    color = {4,2},
    layer = 20,
    tags = {"samecolor"},
    desc = "SAMEPAINT (Compare Condition): True if the condition unit is the same color as the target. Also, BAB BE SAMEPAINT KEEK will turn bab into a keek of the same color that bab was.",
  },
  -- 668
  {
    name = "txt_sameface",
    sprite = "text/sameface",
    type = "text",
    texttype = {cond_compare = true},
    color = {2,4},
    layer = 20,
    tags = {"samedirection","samefacing"},
    desc = "SAMEFACE (Compare Condition): True if the condition unit is facing the same direction as the target.",
  },
  -- 669
  {
    name = "zawarudo",
    sprite = "zawarudo",
    color = {2,4},
    layer = 11,
    rotate = true,
    sing = "muda",
    convertible = false,
    features = { sans = {x=19, y=10, w=2, h=2} },
    tags = {"chars", "the world", "jojo", "DIO"},
    desc = "WRYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
  },
  -- 670
  {
    name = "thingify",
    sprite = "thingify",
    color = {5,2},
    layer = 7,
    convertible = false,
    tags = {"thing"},
    desc = "its a thing.",
  },
  -- 671
  {
    name = "&",
    sprite = "and",
    color = {0,3},
    layer = 7,
    rotate = true,
    convertible = false,
    tags = {"and gate", "logic gate"},
    desc = "only if all are true",
  },
  -- 672
  {
    name = "&n't",
    sprite = "andn't",
    color = {0,3},
    layer = 7,
    rotate = true,
    convertible = false,
    tags = {"nand gate", "logic gate"},
    desc = "only if not all are true",
  },
  -- 673
  {
    name = "txt_dragbl",
    sprite = "text/dragbl",
    type = "text",
    texttype = {property = true},
    color = {3,3},
    layer = 20,
    tags = {"draggable","mouse"},
    desc = "DRAGBL: Units that are DRAGBL can be picked up and moved around.",
  },
  -- 674
  {
    name = "txt_nodrag",
    sprite = "text/nodrag",
    type = "text",
    texttype = {property = true},
    color = {3,0},
    layer = 20,
    tags = {"mouse"},
    desc = "NO DRAG: Units that are DRAGBL can't be placed on NO DRAG objects.",
  },
  -- 675
  {
    name = "txt_cann't",
    sprite = "text/can't",
    type = "text",
    texttype = {object = true},
    color = {2,1},
    layer = 20,
    tags = {"valhalla"},
  },
  -- 676
  {
    name = "bel",
    sprite = "bel",
    color = {2, 4},
    layer = 6,
    rotate = true,
    tags = {"bell", "christmas"},
    desc = "tis the season"
  },
  -- 677
  {
    name = "txt_bel",
    sprite = "text/bel",
    type = "text",
    texttype = {object = true},
    color = {2, 4},
    layer = 20,
    tags = {"bell", "christmas"},
  },
  -- 678
  {
    name = "wres",
    sprite = "wres",
    color = {5, 2},
    layer = 4,
    tags = {"wreathe", "plant", "christmas"},
    desc = "tis the wreson"
  },
  -- 679
  {
    name = "txt_wres",
    sprite = "text/wres",
    type = "text",
    texttype = {object = true},
    color = {5, 2},
    layer = 20,
    tags = {"wreathe", "plant", "christmas"},
  },
  -- 680
  {
    name = "bowie",
    sprite = "bowie",
    color = {2, 2},
    layer = 9,
    rotate = true,
    tags = {"ribbon", "bow", "christmas"},
    desc = "we could be heroes",
  },
  -- 681
  {
    name = "txt_bowie",
    sprite = "text/bowie",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"ribbon", "bow", "christmas"},
    desc = "just for one day",
  },
  -- 682
  {
    name = "der",
    sprite = "der",
    type = "object",
    color = {6,1},
    layer = 11,
    rotate = true,
    features = { sans = {x=24, y=11, w=2, h=2} },
    tags = {"chars", "reindeer", "moose", "christmas"},
    desc = "rudolf w/ ur nos be BRITE, wont u guid my slay?",
  },
  -- 683
  {
    name = "txt_der",
    sprite = "text/der",
    type = "text",
    texttype = {object = true},
    color = {6,1},
    layer = 20,
    tags = {"chars", "reindeer", "moose", "christmas"},
    desc = "stay away from kappa and ryugon!!",
  },
  -- 684
  {
    name = "sant",
    sprite = {"sant_base", "sant_flof"},
    type = "object",
    color = {{2,2}, {0,3}},
    colored = {true, false},
    layer = 8,
    tags = {"santa hat", "christmas"},
    desc = "ho ho ho",
  },
  -- 685
  {
    name = "txt_sant",
    sprite = "text/sant",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"santa hat", "christmas"},
  },
  -- 686
  {
    name = "gato",
    sprite = "gato",
    type = "object",
    color = {0,2},
    rotate = true,
    layer = 3,
    tags = {"oneway","mario","gate"},
    desc = "shakes if you can't walk into it",
  },
  -- 687
  {
    name = "txt_gato",
    sprite = "text/gato",
    type = "text",
    texttype = {object = true},
    color = {0,2},
    layer = 20,
    tags = {"oneway","mario","gate"},
    desc = "el gato negro, michi michi",
  },
  -- 688
  {
    name = "canedy",
    sprite = {"canedy_stripes", "canedy_base"},
    type = "object",
    color = {{2,2}, {0,3}},
    colored = {true, false},
    rotate = true,
    layer = 8,
    tags = {"candy cane", "christmas", "food", "sweets"},
    desc = "no pun in canedied",
  },
  -- 689
  {
    name = "txt_canedy",
    sprite = "text/canedy",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"candy cane", "christmas", "food", "sweets"},
  },
  -- 690
  {
    name = "now",
    sprite = {"now_box", "now_bow"},
    type = "object",
    color = {{2,2}, {2,4}},
    colored = {true, false},
    layer = 8,
    tags = {"present", "gift", "box", "christmas"},
    nice = true,
    desc = "a gift for every bab supporteres!",
  },
  -- 691
  {
    name = "txt_now",
    sprite = "text/now",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"present", "gift", "box", "christmas"},
    alias = {"futr"},
    desc = "its now, or latr, no srsly",
  },
  -- 692
  {
    name = "bolble",
    sprite = "bolble",
    type = "object",
    color = {2,2},
    rotate = true,
    layer = 8,
    tags = {"bauble", "ball", "christmas"},
    desc = "wil chang patern w/ colr",
  },
  -- 693
  {
    name = "txt_bolble",
    sprite = "text/bolble",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"bauble", "ball", "christmas"},
  },
  -- 694
  {
    name = "sno",
    sprite = "sno",
    type = "object",
    color = {0, 3},
    layer = 2,
    tags = {"snow", "christmas"},
    desc = "snodin",
  },
  -- 695
  {
    name = "txt_sno",
    sprite = "text/sno",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"snow", "christmas"},
    desc = "sno easy bein grun",
    edgy = false,
  },
  -- 696
  {
    name = "cooky",
    sprite = "cooky",
    type = "object",
    color = {6, 2},
    layer = 8,
    tags = {"cookie", "biscuit", "chocolate chip", "christmas", "food", "sweets"},
    desc = "clik clik clik",
  },
  -- 697
  {
    name = "txt_cooky",
    sprite = "text/cooky",
    type = "text",
    texttype = {object = true},
    color = {6, 2},
    layer = 20,
    tags = {"cookie", "biscuit", "chocolate chip", "christmas", "food", "sweets"},
    desc = "very cooky"
  },
  -- 698
  {
    name = "ginn",
    sprite = "ginn",
    type = "object",
    color = {6,2},
    layer = 11,
    rotate = true,
    features = { sans = {x=18, y=6, w=2, h=2} },
    tags = {"chars", "gingerbread man", "christmas", "cookie", "food"},
    desc = "shes a girl!",
    pronouns = {"she","her"},
  },
  -- 699
  {
    name = "txt_ginn",
    sprite = "text/ginn",
    type = "text",
    texttype = {object = true},
    color = {6,2},
    layer = 20,
    tags = {"chars", "gingerbread man", "christmas", "cookie", "food"},
  },
  -- 700
  {
    name = "pot",
    sprite = {"pot_drink", "pot_bottle"},
    type = "object",
    color = {{3,1}, {0,3}},
    colored = {true, false},
    layer = 7,
    rotate = true,
    tags = {"potion", "bottle", "halloween"},
    desc = "+1 ATK"
  },
  -- 701
  {
    name = "txt_pot",
    sprite = "text/pot",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"potion", "bottle", "halloween"},
  },
  -- 702
  {
    name = "sweep",
    sprite = "sweep",
    type = "object",
    color = {6, 1},
    layer = 8,
    rotate = true,
    tags = {"broomstick", "halloween", "witch"},
    desc = "for the master sparkl users",
  },
  -- 703
  {
    name = "txt_sweep",
    sprite = "text/sweep",
    type = "text",
    texttype = {object = true},
    color = {6, 1},
    layer = 20,
    tags = {"broomstick", "halloween", "witch"},
  },
  -- 704
  {
    name = "which",
    sprite = {"which_that", "which_base"},
    type = "object",
    color = {{3,1}, {0,0}},
    colored = {true, false},
    layer = 8,
    tags = {"witch hat", "halloween"},
    desc = "mors tak the precious thing",
  },
  -- 705
  {
    name = "txt_which",
    sprite = "text/which",
    type = "text",
    texttype = {object = true},
    color = {3,1},
    layer = 20,
    tags = {"witch hat", "halloween"},
    desc = "which one? THAT one!",
  },
  -- 706
  {
    name = "txt_rp",
    sprite = "text/rp",
    type = "text",
    texttype = {verb = true, verb_unit = true},
    color = {3,3},
    layer = 20,
    tags = {"mimic","roleplay"},
    desc = "RP: X RP Y gives X all of the properties of Y. Only an object that actually exists can be RP'd."
  },
  -- 707
  {
    name = "toby",
    sprite = "toby",
    color = {0, 3},
    layer = 11,
    rotate = true,
    sing = "dog",
    features = {
      sans = {x=24, y=9, w=2, h=2},
      sant = {x=1},
      hatt = {x=5},
      which = {x=5},
      gunne = {x=5},
      knif = {x=5},
      katany = {x=5},
    },
    tags = {"chars", "toby fox", "annoying dog", "undertale"},
    desc = "absorps ur artefac",
  },
  -- 708
  {
    name = "txt_toby",
    sprite = "text/toby",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "toby fox", "annoying dog", "undertale"},
    desc = "The highly respectable Toby Fox himself,\nCreator of UNDERTALE and deltarune."
  },
  -- 709
  {
    name = "angle",
    sprite = "angle",
    color = {0, 3},
    layer = 11,
    rotate = true,
    sing = "choir",
    features = {
      sans = {x=19, y=9, w=2, h=2},
    },
    tags = {"chars", "angel"},
    desc = "i can be your angle...",
    nice = true,
  },
  -- 710
  {
    name = "txt_angle",
    sprite = "text/angle",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "angel"},
    desc = "she's 90 gradians... acute angle",
    nice = false,
  },
  -- 711
  {
    name = "dvl",
    sprite = "debil",
    color = {2, 2},
    layer = 11,
    rotate = true,
    features = {
      sans = {x=14, y=18, w=2, h=2},
    },
    tags = {"chars", "devil", "demon", "debil"},
    desc = "or yuor dvl...",
    nice = true,
  },
  -- 712
  {
    name = "txt_dvl",
    sprite = "text/dvl",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"chars", "devil", "demon", "debil"},
    desc = "used to be called \"debil\" until we found out that's a bad word in a different language",
  },
  -- 713
  {
    name = "txt_y'all",
    sprite = "text/y'all",
    type = "text",
    texttype = {property = true},
    color = {4,2},
    layer = 20,
    tags = {"you all", "players"},
    desc = "all players control y'all",
  },
  -- 714
  {
    name = "txt_thicc",
    sprite = "text/thicc",
    type = "text",
    texttype = {property = true},
    color = {1,3},
    layer = 20,
    desc = "THICC: Thicc things take up a 2x2 space. Expands to the lower left.",
  },
  -- 715
  {
    name = "txt_rythm",
    sprite = "text/rythm",
    type = "text",
    texttype = {property = true},
    color = {4,1},
    layer = 20,
    tags = {"auto","necrodancer","lily", "rhythm", "rythm", "dancr"},
	  desc = "RYTHM (property): Turns pass for these units based on time, separate from normal turns passing.",
  },
  -- 716
  {
    name = "wan",
    sprite = {"wan_center", "wan_end"},
    type = "object",
    color = {{0,0}, {0,3}},
    colored = {true, false},
    rotate = true,
    layer = 8,
    tags = {"magician wand", "staff"},
    desc = "wan and han gos han in han",
    nicest = false,
  },
  -- 717
  {
    name = "txt_wan",
    sprite = "text/wan",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"magician wand", "staff",},
  },
  -- 718
  {
    name = "mug",
    sprite = "mug",
    color = {0, 3},
    layer = 8,
    rotate = true,
    features = {
        sans = {x=20, y=15, w=2, h=2},
    },
    tags = {"cup", "mug", "magician"},
    desc = "mugman",
  },
  -- 719
  {
    name = "txt_mug",
    sprite = "text/mug",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"cup", "mug", "magician"},
    nice = true,
  },
  -- 720
  {
    name = "corndy",
    sprite = {"corndy_top", "corndy_center", "corndy_bottom"},
    type = "object",
    color = {{0,3}, {2,2}, {2,4}},
    colored = {false, true, false},
    rotate = true,
    layer = 8,
    tags = {"candy corn", "food", "sweets", "halloween"},
    desc = "corndy and han gos han in han",
  },
  -- 721
  {
    name = "txt_corndy",
    sprite = "text/corndy",
    type = "text",
    texttype = {object = true},
    color = {0, 1},
    layer = 20,
    tags = {"candy corn", "food", "sweets", "halloween"},
  },
  -- 722
  {
    name = "die",
    sprite = {"die_cube","die_nil"},
    color = {{0, 3},{2,2}},
    colored = {true, false},
    type = "object",
    rotate = true,
    layer = 8,
    tags = {"dice", "cube", "random"},
    desc = "rerolls every turn unless its NO TURN",
  },
  -- 723
  {
    name = "txt_die",
    sprite = "text/die",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"dice", "cube", "random"},
    desc = "ur turn to DIE",
  },
  -- 724
  {
    name = "txt_oob",
    sprite = "text/oob",
    type = "text",
    texttype = {cond_prefix = true},
    color = {1, 2},
    layer = 20,
    tags = {"out of bounds"},
    desc = "OOB (Prefix Condition): True if the unit is on a border.",
  },
  -- 725
  {
    name = "temmi",
    sprite = {"temmi","temmi but just her face"},
    color = {{0, 3},{0,3}},
    colored = {true, false},
    layer = 11,
    rotate = true,
    sing = "temmie",
    features = {
      sans = {x=23, y=12, w=2, h=2},
      cool = {x=2, y=2},
      sant = {x=1},
      hatt = {x=5},
      which = {x=5},
      gunne = {x=5},
      knif = {x=5},
      katany = {x=5},
    },
    tags = {"chars", "temmie chang", "undertale"},
    desc = "hOI!!! i'm tEMMi!!",
  },
  -- 726
  {
    name = "txt_temmi",
    sprite = "text/temmi",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    alias = {"temmi!", "temmi!!", "temmi!!!", "bob."},
    tags = {"chars", "temmie chang", "undertale"},
    desc = "Temmie Chang: Main artist of UNDERTALE and deltarune."
  },
	-- 727
  {
    name = "txt_gang",
    sprite = "text/gang",
    type = "text",
    texttype = {object = true, group = true},
    color = {0, 1},
    layer = 20,
    tags = {"group"},
    desc = "GANG: A variant of FRENS but members wear an exclusive hat.",
  },
  -- 728
  {
    name = "ui_0",
    sprite = "ui_0",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "The other undo key.",
  },
  -- 729
  {
    name = "txt_b)",
    sprite = "text/B)",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    features = { sans = {x=20, y=8, w=5, h=4} },
    tags = {"cool", "smiley"},
    desc = "B): At end of turn, if U is on B) and survives, U R COOL! (This currently does nothing.)",
  },
  -- 730
  {
    name = "txt_cool",
    sprite = "text/cool",
    type = "text",
    texttype = {property = true},
    color = {1, 4},
    layer = 20,
    tags = {"cool"},
    desc = "COOL: COOL units wear a pair of sunglasses, and don't shake.",
  },
  -- 731
  {
    name = "therealqt",
    sprite = "therealqt",
    color = {4, 2},
    layer = 22,
    tometa = "txt_qt",
  },
  -- 732
  {
    name = "tronk",
    sprite = "tronk",
    type = "object",
    color = {1,4},
    layer = 6,
    tags = {"trinket","vvvvvv"},
    desc = "upside down boll",
  },
  -- 733
  {
    name = "txt_tronk",
    sprite = "text/tronk",
    type = "text",
    texttype = {object = true},
    color = {1,4},
    layer = 20,
    tags = {"trinket","vvvvvv"},
  },
  -- 734
  {
    name = "aaaaaa",
    sprite = "aaaaaa",
    color = {0, 3},
    layer = 100
  },
  -- 735
  {
    name = "therealbabdictator",
    sprite = "therealbabdictator",
    color = {0, 3},
    layer = 100,
    sing = "miku",
    tags = {"hatsune miku"},
    desc = "yes",
    pronouns = {"she","her","miku"},
  },
  -- 736
  {
    name = "fube",
    sprite = {"fube_arrow","fube_cube"},
    color = {{2, 2},{0, 3}},
    colored = {true,false},
    type = "object",
    rotate = true,
    layer = 8,
    tags = {"manifold garden", "arrow", "gravity"},
    desc = "the cube thingy from many folds garden",
  },
  -- 737
  {
    name = "txt_fube",
    sprite = "text/fube",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"manifold garden", "arrow", "gravity"},
    desc = "don't be fooled by the sprite it's just fube",
  },
  -- 738
  {
    name = "detox",
    sprite = "detox",
    type = "object",
    color = {2,4},
    rotate = true,
    layer = 11,
    sing = "s_vitellary",
    features = {sans = {x=21,y=8,w=2,h=3}},
    tags = {"vvvvvv","allison"},
    desc = "u've been lookin @ too much Good Art",
  },
  -- 739
  {
    name = "txt_detox",
    sprite = "text/detox",
    type = "text",
    texttype = {object = true},
    color = {3,1},
    layer = 20,
    tags = {"vvvvvv","allison"},
    desc = "detox be a custom vvvvvv level by allison, very good",
  },
  -- 740
  {
    name = "txt_c_sharp",
    sprite = "text/c_sharp",
    type = "text",
    texttype = {note = true},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 741
  {
    name = "txt_d_sharp",
    sprite = "text/d_sharp",
    type = "text",
    texttype = {note = true},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 742
  {
    name = "txt_f_sharp",
    sprite = "text/f_sharp",
    type = "text",
    texttype = {note = true},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 743
  {
    name = "txt_g_sharp",
    sprite = "text/g_sharp",
    type = "text",
    texttype = {note = true},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 744
  {
    name = "txt_a_sharp",
    sprite = "text/a_sharp",
    type = "text",
    texttype = {note = true},
    color = {0,3},
    layer = 20,
    desc = "For use with SING.";
  },
  -- 745
  {
    name = "viruse",
    type = "object",
    rotate = true,
    layer = 11,
    sprite = "virus",
    color = {2, 4},
    desc = "gon infect u",
    sing = "sham_gatsample",
    --[[features = {
        sans = {x=19,y=16,w=1,h=3},
        cool = {x=-4, y=3},
        sant = {x=-1},
        hatt = {x=0},
        which = {x=-1},
        gunne = {x=5},
        knif = {x=5},
        katany = {x=5},
        bowie = {x=0,y=19},
        slippers = {x=0, y=5},
    },]]
    tags = {"dr mario", "mario", "virus"},
  },
  -- 746
  {
    name = "txt_viruse",
    sprite = "text/viruse",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"dr mario", "mario", "virus"},
    desc = "virus",
  },
  -- 747
  {
    name = "nyowo",
    sprite = {"nyowo","nyowo_face"},
    type = "object",
    color = {{2,4},{0,3}},
    colored = {true,false},
    features = {
      sans = {x=23,y=13,w=3,h=6},
    },
    layer = 10,
    tags = {"nya","jill"},
    desc = "crying",
  },
  -- 748
  {
    name = "txt_nyowo",
    sprite = "text/nyowo",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"nya","jill"},
  },
  -- 749
  {
    name = "prop",
    sprite = "prop",
    type = "text",
    texttype = {property = true},
    color = {0,3},
    layer = 19,
    tags = {"property","square","box"},
    desc = "it's an empty property object",
  },
  -- 750
  {
    name = "txt_prop",
    sprite = "text/prop",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"property","square","box"},
    desc = "it refers to the empty property object",
  },
  -- 751
  {
    name = "ui_box",
    sprite = "ui_box",
    type = "object",
    color = {0,3},
    layer = 20,
    tags = {"square"},
    desc = "Empty.",
  },
  -- 752
  {
    name = "slab",
    sprite = "slab",
    type = "object",
    color = {{1,4},{0,3}},
    colored = {true,false},
    features = {
      sans = {x=17,y=13,w=1,h=2},
    },
    layer = 20,
    tags = {"devs", "chars"},
    desc = "omg its a beautiful buttered fly",
  },
  -- 753
  {
    name = "txt_slab",
    sprite = "text/slab",
    type = "text",
    texttype = {object = true},
    color = {1,4},
    layer = 20,
    tags = {"devs", "chars"},
    desc = "i need to make this multicolor why am i so lazy",
  },
  -- 754
  {
    name = "butcher",
    sprite = "butcher",
    type = "object",
    color = {{1,2},{0,3}},
    colored = {true,false},
    features = {
      sans = {x=23,y=13,w=3,h=3},
    },
    rotate = true,
    layer = 20,
    tags = {"devs", "chars"},
    desc = "slice slice make a fruit salad",
  },
  -- 755
  {
    name = "txt_butcher",
    sprite = "text/butcher",
    type = "text",
    texttype = {object = true},
    color = {1,2},
    layer = 20,
    tags = {"devs", "chars"},
  },
  -- 756
  {
    name = "notnat",
    sprite = "notnat",
    type = "object",
    color = {1,4},
    features = {
      sans = {x=26,y=10,w=2,h=2},
    },
    rotate = true,
    layer = 20,
    tags = {"devs", "chars"},
    desc = "this is just another pokemon??? what a ripoff",
  },
  -- 757
  {
    name = "txt_notnat",
    sprite = "text/notnat",
    type = "text",
    texttype = {object = true},
    color = {1,4},
    layer = 20,
    tags = {"devs", "chars"},
  },
  -- lots of UI time im not counting
  -- lazy jill >:(
  -- 758
  {
    name = "ui_q",
    sprite = "ui_q",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 759
  {
    name = "ui_t",
    sprite = "ui_t",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 760
  {
    name = "ui_y",
    sprite = "ui_y",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 761
  {
    name = "ui_u",
    sprite = "ui_u",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 762
  {
    name = "ui_o",
    sprite = "ui_o",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 763
  {
    name = "ui_p",
    sprite = "ui_p",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 764
  {
    name = "ui_f",
    sprite = "ui_f",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "Triggers PRESS F2.",
  },
  -- 765
  {
    name = "ui_g",
    sprite = "ui_g",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 766
  {
    name = "ui_h",
    sprite = "ui_h",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 767
  {
    name = "ui_;",
    sprite = "ui_;",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 768
  {
    name = "ui_'",
    sprite = "ui_'",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 769
  {
    name = "ui_return",
    sprite = "ui_return",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "in the editor, obtain object matching your search term if it exists (by code name, not letter aliases)",
  },
  -- 770
  {
    name = "ui_x",
    sprite = "ui_x",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 771
  {
    name = "ui_c",
    sprite = "ui_c",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 772
  {
    name = "ui_v",
    sprite = "ui_v",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 773
  {
    name = "ui_b",
    sprite = "ui_b",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 774
  {
    name = "ui_n",
    sprite = "ui_n",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 775
  {
    name = "ui_m",
    sprite = "ui_m",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 776
  {
    name = "ui_,",
    sprite = "ui_,",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 777
  {
    name = "ui_.",
    sprite = "ui_.",
    type = "object",
    color = {0,3},
    layer = 20,
    lucky = true,
  },
  -- 778
  {
    name = "ui_/",
    sprite = "ui_slash",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 779
  {
    name = "ui_-",
    sprite = "ui_-",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 780
  {
    name = "ui_=",
    sprite = "ui_=",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 781
  {
    name = "ui_`",
    sprite = "ui_`",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 782
  {
    name = "letter_>",
    sprite = "letter_angle",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
  },
  -- 783
  {
    name = "grimkid",
    sprite = {"grimkid_body","grimkid"},
    colored = {true,false},
    color = {{2,1},{0,3}},
    features = {
      sans = {x=21,y=13,w=2,h=2},
    },
    type = "object",
    layer = 11,
    desc = "complet rituel pls",
  },
  -- 784
  {
    name = "txt_grimkid",
    sprite = "text/grimkid",
    color = {2,2},
    type = "text",
    texttype = {object = true},
    layer = 20,
  },
  -- 785
  {
    name = "colect",
    sprite = "colect",
    color = {0,2},
    type = "object",
    layer = 22,
    desc = "to hold bugs",
  },
  -- 786
  {
    name = "txt_colect",
    sprite = "text/colect",
    color = {0,3},
    type = "text",
    texttype = {object = true},
    layer = 20,
  },
  -- 787
  {
    name = "prime",
    sprite = "prime",
    color = {2,3},
    features = {
      sans = {x=11,y=17,w=2,h=2},
    },
    type = "object",
    layer = 10,
    desc = "prime numbers SUCK",
  },
  -- 788
  {
    name = "txt_prime",
    sprite = "text/prime",
    color = {2,3},
    type = "text",
    texttype = {object = true},
    layer = 20,
  },
  -- 789
  {
    name = "whee",
    sprite = "whee",
    rotate = true,
    color = {0,3},
    type = "object",
    layer = 8,
    desc = "the nostalgia console",
  },
  -- 790
  {
    name = "txt_whee",
    sprite = "text/whee",
    color = {0,3},
    type = "text",
    texttype = {object = true},
    layer = 20,
  },
  -- 791
  {
    name = "joycon",
    sprite = "joycon",
    rotate = true,
    color = {2,2},
    type = "object",
    layer = 7,
    desc = "where's its partner? you gotta find it!",
  },
  -- 792
  {
    name = "txt_joycon",
    sprite = {"text/joycon_l","text/joycon_r"},
    color = {{1,3},{2,2}},
    colored = {true,false},
    type = "text",
    texttype = {object = true},
    layer = 20,
    desc = "multicolor text?!?!?",
  },
  -- 793
  {
    name = "ui_ctrl",
    sprite = "ui_ctrl",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "hold when placing an object to stack objects, including multiple of the same one\nctrl+enter with 1-6 chars in selector search bar to get a custom letter",
  },
  -- 794
  {
    name = "ui_alt",
    sprite = "ui_alt",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 795
  {
    name = "ui_shift",
    sprite = "ui_shift",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "hold when placing an object to stack objects (unless its the same object)\nshift + wasd in editor to shift the whole level around",
  },
  -- 796
  {
    name = "ui_del",
    sprite = "ui_del",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 797
  {
    name = "ui_[",
    sprite = "ui_[",
    type = "object",
    color = {0,3},
    layer = 20,
  },
  -- 798
  {
    name = "ui_gui",
    sprite = "ui_gui",
    type = "object",
    color = {0,3},
    layer = 20,
    tags = {"windows","command","cmd"},
    desc = "Changes sprites depending on user's Operating System.",
  },
  -- 799
  {
    name = "ui_tab",
    sprite = "ui_tab",
    type = "object",
    color = {0,3},
    layer = 20,
    desc = "Used to open the tile selector in the menu. Though I think you already know that.",
  },
  -- 800
  {
    name = "ui_cap",
    sprite = "ui_cap_on",
    type = "object",
    color = {0,3},
    layer = 20,
    tags = {"caps lock"},
  },
  -- 801
  {
    name = "ui_esc",
    sprite = "ui_esc",
    type = "object",
    color = {0,3},
    layer = 20,
    tags = {"caps lock"},
    desc = "There is no ESC\nOpen the menu. Useful for returning to map.",
  },
  -- 802
  {
    name = "cart",
    sprite = "cart",
    type = "object",
    color = {0,2},
    layer = 20,
    tags = {"cart"},
    desc = "like casette but from an objectively better game",
  },
  -- 803
  {
    name = "txt_cart",
    sprite = "text/cart",
    type = "text",
    texttype = {object = true},
    color = {0,2},
    layer = 20,
    tags = {"cart"},
  },
  -- 804
  {
    name = "assh",
    sprite = "assh",
    type = "object",
    color = {0,3},
    layer = 11,
    rotate = true,
    tags = {"ash"},
    desc = "he can grab on ledges",
  },
  -- 805
  {
    name = "txt_assh",
    sprite = "text/assh",
    type = "text",
    texttype = {object = true},
    color = {0,1},
    layer = 20,
    tags = {"ash"},
    desc = "no bad words here mister vitellary",
  },
  -- 806
  {
    name = "txt_thonk",
    sprite = "text/thonk",
    type = "text",
    texttype = {property = true},
    color = {2, 4},
    layer = 20,
    tags = {"thinking", "wonder"},
    desc = "THONK: THONK units question their own FRAGIL existence.",
  },
  -- 807
  {
    name = "drop",
    sprite = "drop",
    color = {1, 3},
    type = "object",
    layer = 6,
    tags = {"tear", "droplet", "water", "blood"},
    desc = "when they crai",
  },
  -- 808
  {
    name = "txt_drop",
    sprite = "text/drop",
    type = "text",
    texttype = {object = true},
    color = {1, 3},
    layer = 20,
    tags = {"tear", "droplet", "water", "blood"},
  },
  -- 809
  {
    name = "woosh",
    sprite = "woosh",
    color = {0, 3},
    type = "object",
    rotate = true,
    layer = 6,
    tags = {"wind", "blow", "whoosh"},
    desc = "dont make a shitty reddit joke no one likes them",
  },
  -- 810
  {
    name = "txt_woosh",
    sprite = "text/woosh",
    type = "text",
    texttype = {object = true},
    color = {5, 3},
    layer = 20,
    tags = {"wind", "blow", "whoosh"},
  },
  -- 811
  {
    name = "candl",
    sprite = "candl",
    color = {2, 2},
    type = "object",
    layer = 6,
    tags = {"candle", "fire", "light"},
    desc = "BURNNNNNNNNN",
  },
  -- 812
  {
    name = "txt_candl",
    sprite = "text/candl",
    type = "text",
    texttype = {object = true},
    color = {2, 2},
    layer = 20,
    tags = {"candle", "fire", "light"},
  },
  -- 813
  {
    name = "maglit",
    sprite = {"maglit","no1"},
    color = {{0, 2},{0,3}},
    colored = {true, false},
    type = "object",
    rotate = true,
    layer = 6,
    tags = {"maglight", "torchlight", "flashlight"},
    desc = "turns on when its TORC",
  },
  -- 814
  {
    name = "txt_maglit",
    sprite = "text/maglit",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"maglight", "torchlight", "flashlight"},
  },
  -- 815
  {
    name = "txt_xplod",
    sprite = "text/xplod",
    type = "text",
    texttype = {object = true},
    color = {2,2},
    layer = 20,
    desc = "The object created by nuek",
  },
  -- 816
  {
    name = "zig",
    sprite = "zig",
    type = "object",
    color = {0,3},
    layer = 5,
    rotate = true,
    tags = {"zigzag"},
    desc = "v^v^v^, that's my textual representation of zigzag"
  },
  -- 817
  -- one day someone should count how many there actually are
  -- vitellary: ...i just did that though, you guys are just bad >:(
  -- did u not see my big commit where i fixed all of the numbers
  {
    name = "txt_zig",
    sprite = "text/zig",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"zigzag"},
    desc = "zag",
  },
  -- 818
  {
    name = "boogie",
    sprite = "boogie",
    type = "object",
    color = {1,3},
    layer = 11,
    features = { sans = {x=22, y=16, w=3, h=3} },
    rotate = true,
    tags = {"slime", "crypt of the necrodancer"},
    desc = "cant hurt u unless u walk into it somehow",
  },
  -- 819
  {
    name = "txt_boogie",
    sprite = "text/boogie",
    type = "text",
    texttype = {object = true},
    color = {1,3},
    layer = 20,
    tags = {"slime", "crypt of the necrodancer"},
  },
  -- 820
  {
    name = "txt_alt",
    sprite = "text/alt",
    type = "text",
    texttype = {cond_prefix = true},
    color = {1,3},
    layer = 20,
    tags = {"correct", "cg5"},
    desc = "ALT (Prefix Condition): True every other turn.",
  },
  -- 821
  {
    name = "cracc",
    sprite = "cracc",
    type = "object",
    color = {0,0},
    layer = 5,
    tags = {"crack"},
    desc = "just a cracc in the wals",
  },
  -- 822
  {
    name = "txt_cracc",
    sprite = "text/cracc",
    type = "text",
    texttype = {object = true},
    color = {0,1},
    layer = 20,
    tags = {"crack"},
  },
  -- 823
  {
    name = "pixl",
    sprite = "pixl",
    type = "object",
    color = {0,3},
    layer = 5,
    tags = {"pixel", "square", "block"},
    desc = "a lil square half the size of a til",
  },
  -- 824
  {
    name = "txt_pixl",
    sprite = "text/pixl",
    type = "text",
    texttype = {object = true},
    color = {0,3},
    layer = 20,
    tags = {"pixel", "square", "block"},
  },
  -- 825
  {
    name = "txt_deez",
    sprite = "text/deez",
    type = "text",
    texttype = {object = true, cond_prefix = true},
    rotate = true,
    color = {0,3},
    layer = 20,
    tags = {"that","those","cg5", "the^", "the ->", "these"},
    desc = "DEEZ: Refers to the objects in the direction it's pointing at.",
  },
  -- 826
  {
    name = "babby",
    sprite = "babby",
    sing = "babby",
    rotate = true,
    color = {0,3},
    layer = 11,
    tags = {"baby", "bapy", "babey", "babbey", "smol"},
    desc = "bab be babbe ba"
  },
  -- 827
  {
    name = "txt_babby",
    sprite = "text/babby",
    type = "text",
    texttype = {object = true},
    color = {4,1},
    layer = 20,
    tags = {"baby", "bapy", "babey", "babbey", "smol"},
    desc = "not to be confused with bab be"
  },
  -- 828
  {
    name = "txt_yuiy",
    sprite = "text/yuiy",
    type = "text",
    texttype = {object = true},
    color = {0, 2},
    layer = 20,
    tags = {"ui"},
    desc = "YUIY: Refers to all UIs that exist in the level.",
  },
  -- 829
  {
    name = "txt_wont",
    sprite = "text/wont",
    type = "text",
    texttype = {verb = true, verb_property = true},
    color = {2,2},
    layer = 20,
    tags = {"won't","can't"},
    desc = "WON'T: X WON'T PROPERTY makes X not be affected by that property."
  },
  -- 830
  {
    name = "voom",
    sprite = {"voom_handle", "voom_blade"},
    sing = "s_voom",
    rotate = true,
    color = {{0,2}, {1, 3}},
    colored = {false, true},
    layer = 11,
    tags = {"lightsaber", "starwars", "jedi", "laser", "sword"},
    desc = "britesaber",
  },
  -- 831
  {
    name = "txt_voom",
    sprite = "text/voom",
    type = "text",
    texttype = {object = true},
    color = {2,4},
    layer = 20,
    tags = {"lightsaber", "starwars", "jedi", "laser", "sword"},
    desc = "a long time ago in a galaxy far, far away...",
  },
  --832
  {
    name = "letter_*",
    sprite = "letter_asterisk",
    type = "text",
    texttype = {letter = true},
    color = {0,3},
    layer = 20,
    desc = "wildcard.",
  },
  -- 834
  {
    name = "txt_numa",
    sprite = "text/numa",
    type = "text",
    texttype = {object = true},
    color = {3, 1},
    layer = 20,
    tags = {"number","digit"},
    desc = "NUMA: Refers to all numbers that exist in the level.\n\nNUMA n't refers to all non-number letters.",
  },
  -- 835
  {
    name = "txt_toen",
    sprite = "text/toen",
    type = "text",
    texttype = {object = true},
    color = {4, 1},
    layer = 20,
    tags = {"tone","pitch","music notes"},
    desc = "TOEN: Refers to all music note letters that exist in the level.",
  },
  -- 836
  {
    name = "snom",
    sprite = "snom",
    type = "object",
    color = {0, 3},
    layer = 11,
    rotate = true,
    features = { sans = {x=20, y=25, w=2, h=2} },
    tags = {"chars", "snom", "pokemon"},
    desc = "its snom bruh",
    pronouns = {"any", "all"},
    desc = "It snaccs SNO that piles up on the ground. The more SNO it snaccs, the THICCer and MOAR impressive the spikes on its back grow.",
  },
  -- 837
  {
    name = "txt_snom",
    sprite = "text/snom",
    type = "text",
    texttype = {object = true},
    color = {0, 3},
    layer = 20,
    tags = {"chars", "snom", "pokemon"},
    desc = "yea its the same spelling what else would it be, SNOWM??",
  },
  -- 838
  {
    name = "txt_themself",
    sprite = "text/themself",
    type = "text",
    texttype = {object = true},
    color = {2, 3},
    layer = 20,
    tags = {"itself"},
    desc = "ITSELF: Refers to the subject of the rule in conditions.",
  },
  --839? though the numbers are off anyway lol
  {
    name = "txt_meow",
    sprite = "text/meow",
    type = "text",
    texttype = {cond_infix = true},
    color = {2, 4},
    layer = 20,
    tags = {"infix","stare at"},
    desc = "Like AROND, but instead of only checking one tile it goes until it hits a TRANPARN'T object, following spatial warping/etc.\nCurrently has a range cap of 100 because it's laggy.",
  },
}

--other_alias = {["wontn't"]: "wo"}

--add every unicode flag (256 total)
--sprite is just the overlay, referenced like "flogus" for us flag, "floggb-eng" for english flag, etc.
unicode_flag_list = {}
items = love.filesystem.getDirectoryItems("assets/sprites/overlay/flog")
for _,item in ipairs(items) do
  if (string.sub(item, -4) == ".png") then
    local flag_code = string.sub(item, 1, -5) --flag_code is usually 2 letters, i.e. "us", can be 6 chars, i.e. "gb-eng"
	  table.insert(tiles_list, {
		name = "txt_flog" .. flag_code,
		sprite = "overlay/flog/" .. flag_code,
		type = "text",
		texttype = {property = true},
		color = {255, 255, 255},
		layer = 20,
      })
	  local prop_name = "flog" .. flag_code
	  table.insert(unicode_flag_list, prop_name)
  end
end

tiles_by_name = {}
group_names = {}
group_names_nt = {}
group_names_set = {}
group_names_set_nt = {}
for i,v in ipairs(tiles_list) do
  tiles_by_name[v.name] = i
  tiles_by_name[v.name:gsub(" ","")] = i
  if v.texttype and v.texttype.group then
		table.insert(group_names, v.name:sub(5, -1));
    table.insert(group_names_nt, v.name:sub(5, -1).."n't");
    group_names_set[v.name:sub(5, -1)] = true;
    group_names_set_nt[v.name:sub(5, -1).."n't"] = true;
	end
end

special_objects = {"mous", "lvl", "bordr", "no1", "this"}

--[[local new_lists = {}

new_lists["Objects"] = {}
new_lists["Characters"] = {}
new_lists["Dev Characters"] = {}
new_lists["Thingify"] = {}
new_lists["Special Objects"] = {}
new_lists["UI"] = {}

new_lists["Text"] = {}
new_lists["Letters"] = {}
new_lists["Verbs"] = {}
new_lists["Properties"] = {}
new_lists["Conditions"] = {}
new_lists["Tutorial"] = {}

for _,tile in ipairs(tiles_list) do
  local name = tile.name:gsub(" ", "")
  local textname = name:starts("txt_") and name:sub(5) or ""
  
  local category = "Objects"
  if tile.sprite and type(tile.sprite) == "string" and tile.sprite:starts("tutorial_") then
    category = "Tutorial"
  elseif table.has_value(special_objects, name) or table.has_value(special_objects, textname) or name == "text" then
    category = "Special Objects"
  elseif name:starts("letter_") then
    category = "Letters"
  elseif name:starts("ui_") then
    category = "UI"
  elseif tile.texttype and (tile.texttype.cond_infix or tile.texttype.cond_prefix) then
    category = "Conditions"
  elseif tile.texttype and tile.texttype.property then
    category = "Properties"
  elseif tile.texttype and tile.texttype.verb then
    category = "Verbs"
  elseif tile.tometa or tile.convertible == false then
    category = "Thingify"
  elseif tile.tags and table.has_value(tile.tags, "devs") then
    category = "Dev Characters"
  elseif table.has_value(selector_grid_contents[4], tile.name) then
    category = "Characters"
  elseif tile.type == "text" and not tiles_by_name[textname] then
    category = "Text"
  end

  local types
  if tile.texttype then
    types = {}
    for k, v in pairs(tile.texttype) do
      table.insert(types, k)
    end
  end

  local layer
  if not (tile.type == "text" and tile.layer == 20) then
    layer = tile.layer
  end

  local features
  if tile.features then
    features = deepCopy(tile.features)
    for k, v in pairs(features) do
      v.__jsonfields = {"x", "y", "w", "h"}
    end
    features.__jsonfields = {
      "hatt",
      "which",
      "sant",
      "bowie",
      "gang",
      "sans",
      "cool",
      "katany",
      "knif",
      "gunne",
      "slippers"
    }
    features.__jsoncompact = features.__jsonfields
  end

  local new_tile = {
    name = name:gsub("txt_", "txt_"),
    sprite = tile.sprite and (type(tile.sprite) == "table" and tile.sprite or {tile.sprite}) or nil,
    sprite_transforms = tile.sprite_transforms and copyTable(tile.sprite_transforms) or nil,
    metasprite = tile.metasprite and (type(tile.metasprite) == "table" and tile.metasprite or {tile.metasprite}) or nil,
    types = types,
    layer = layer,
    color = tile.color and (type(tile.color[1]) == "table" and tile.color or {tile.color}) or {{0, 3}},
    painted = tile.colored,
    txtify = tile.tometa,
    thingify = tile.demeta,
    rotate = tile.rotate,
    features = features,
    voice = tile.sing,
    desc = tile.desc,
    tags = tile.tags,
    pronouns = tile.pronouns,

    __jsonfields = {
      "name",
      "sprite",
      "sprite_transforms",
      "metasprite",
      "types",
      "layer",
      "color",
      "painted",
      "txtify",
      "thingify",
      "rotate",
      "features",
      "voice",
      "desc",
      "tags",
      "pronouns"
    },
    __jsoncompact = {
      "sprite",
      "metasprite",
      "types",
      "color",
      "painted",
      "tags",
      "pronouns"
    }
  }

  table.insert(new_lists[category], new_tile)
end

local clipboard_str = ""
for category, tiles in pairs(new_lists) do
  clipboard_str = clipboard_str .. "--==[ [ " .. category .. " ] ]==--\n\n" .. json.encode(tiles, true) .. "\n\n"
end
love.system.setClipboardText(clipboard_str)]]