local Reset = "\x1b[0m"
local Bright = "\x1b[1m"
local Dim = "\x1b[2m"
local Underscore = "\x1b[4m"
local Blink = "\x1b[5m"
local Reverse = "\x1b[7m"
local Hidden = "\x1b[8m"

local FgBlack = "\x1b[30m"
local FgRed = "\x1b[31m"
local FgGreen = "\x1b[32m"
local FgYellow = "\x1b[33m"
local FgBlue = "\x1b[34m"
local FgMagenta = "\x1b[35m"
local FgCyan = "\x1b[36m"
local FgWhite = "\x1b[37m"

local BgBlack = "\x1b[40m"
local BgRed = "\x1b[41m"
local BgGreen = "\x1b[42m"
local BgYellow = "\x1b[43m"
local BgBlue = "\x1b[44m"
local BgMagenta = "\x1b[45m"
local BgCyan = "\x1b[46m"
local BgWhite = "\x1b[47m"

function        red(str) return FgRed      ..str..Reset end
function     yellow(str) return FgYellow   ..str..Reset end
function      green(str) return FgGreen    ..str..Reset end
function       blue(str) return FgBlue     ..str..Reset end
function       cyan(str) return FgCyan     ..str..Reset end
function    magenta(str) return FgMagenta  ..str..Reset end
function      white(str) return FgWhite    ..str..Reset end
function      black(str) return FgBlack    ..str..Reset end

function      bgred(str) return BgRed      ..str..Reset end
function   bgyellow(str) return BgYellow   ..str..Reset end
function    bggreen(str) return BgGreen    ..str..Reset end
function     bgcyan(str) return BgCyan     ..str..Reset end
function     bgblue(str) return BgBlue     ..str..Reset end
function  bgmagenta(str) return BgMagenta  ..str..Reset end
function    bgwhite(str) return BgWhite    ..str..Reset end
function    bgblack(str) return BgBlack    ..str..Reset end

function     bright(str) return Bright     ..str..Reset end
function        dim(str) return Dim        ..str..Reset end
function underscore(str) return Underscore ..str..Reset end
function      blink(str) return Blink      ..str..Reset end
function    reverse(str) return Reverse    ..str..Reset end
function     hidden(str) return Hidden     ..str..Reset end

return {
    red        =        red,
    yellow     =     yellow,
    green      =      green,
    cyan       =       cyan,
    blue       =       blue,
    magenta    =    magenta,
    white      =      white,
    black      =      black,

    bgred      =      bgred,
    bgyellow   =   bgyellow,
    bggreen    =    bggreen,
    bgcyan     =     bgcyan,
    bgblue     =     bgblue,
    bgmagenta  =  bgmagenta,
    bgwhite    =    bgwhite,
    bgblack    =    bgblack,

    bright     =     bright,
    dim        =        dim,
    underscore = underscore,
    blink      =      blink,
    reverse    =    reverse,
    hidden     =     hidden,
}