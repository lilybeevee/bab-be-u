-- get if the terminal even SUPPORTS colors

-- 1 - force colors on, 2 - force colors off, nil - autodetect
local force_color

if os.getenv('FORCE_COLOR') then
    local envval = os.getenv('FORCE_COLOR')
    if envval == 'true' or envval == '1' then
        force_color = 1
    elseif envval == 'false' or envval == '0' then
        force_color = 0
    end
end

local user_os = package.config:sub(1,1) == '\\' and 'Windows' or 'Unix'

-- 0 - supports none
-- 1 - basic
-- 2 - 256 colors
-- 3 - 16m ("true color")
function getcolorsupport()
    if force_color == 0 then
        return 0
    end
    
    -- i couldn't get it to work in lua. so i just always return 1

    return force_color or 1
end

local supportscolor = getcolorsupport()

function colorstr(str, style)
    if supportscolor < 1 then
        return str..''
    end

    local open = '\x1b[' .. style[1] .. 'm';
    local close = '\x1b[' .. style[2] .. 'm';

    return open..str..close
end

local codes = {
    reset = {0, 0},
  
    bold = {1, 22},
    dim = {2, 22},
    italic = {3, 23},
    underline = {4, 24},
    inverse = {7, 27},
    hidden = {8, 28},
    strikethrough = {9, 29},
  
    black = {30, 39},
    red = {31, 39},
    green = {32, 39},
    yellow = {33, 39},
    blue = {34, 39},
    magenta = {35, 39},
    cyan = {36, 39},
    white = {37, 39},
    gray = {90, 39},
    grey = {90, 39},
  
    brightRed = {91, 39},
    brightGreen = {92, 39},
    brightYellow = {93, 39},
    brightBlue = {94, 39},
    brightMagenta = {95, 39},
    brightCyan = {96, 39},
    brightWhite = {97, 39},

    bgBlack = {40, 49},
    bgRed = {41, 49},
    bgGreen = {42, 49},
    bgYellow = {43, 49},
    bgBlue = {44, 49},
    bgMagenta = {45, 49},
    bgCyan = {46, 49},
    bgWhite = {47, 49},
    bgGray = {100, 49},
    bgGrey = {100, 49},

    bgBrightRed = {101, 49},
    bgBrightGreen = {102, 49},
    bgBrightYellow = {103, 49},
    bgBrightBlue = {104, 49},
    bgBrightMagenta = {105, 49},
    bgBrightCyan = {106, 49},
    bgBrightWhite = {107, 49},
};

function        red(str) return colorstr(str, codes.red) end
function     yellow(str) return colorstr(str, codes.yellow) end
function      green(str) return colorstr(str, codes.green) end
function       blue(str) return colorstr(str, codes.blue) end
function       cyan(str) return colorstr(str, codes.cyan) end
function    magenta(str) return colorstr(str, codes.magenta) end
function      white(str) return colorstr(str, codes.white) end
function      black(str) return colorstr(str, codes.black) end

function      bgred(str) return colorstr(str, codes.bgRed) end
function   bgyellow(str) return colorstr(str, codes.bgYellow) end
function    bggreen(str) return colorstr(str, codes.bgGreen) end
function     bgcyan(str) return colorstr(str, codes.bgCyan) end
function     bgblue(str) return colorstr(str, codes.bgBlue) end
function  bgmagenta(str) return colorstr(str, codes.bgMagenta) end
function    bgwhite(str) return colorstr(str, codes.bgWhite) end
function    bgblack(str) return colorstr(str, codes.bgBlack) end

function        bright(str) return colorstr(str, codes.bold) end
function        italic(str) return colorstr(str, codes.italic) end
function           dim(str) return colorstr(str, codes.dim) end
function    underscore(str) return colorstr(str, codes.underline) end
function       reverse(str) return colorstr(str, codes.inverse) end
function        hidden(str) return colorstr(str, codes.hidden) end
function strikethrough(str) return colorstr(str, codes.strikethrough) end

return {
    red           =           red,
    yellow        =        yellow,
    green         =         green,
    cyan          =          cyan,
    blue          =          blue,
    magenta       =       magenta,
    white         =         white,
    black         =         black,

    bgred         =         bgred,
    bgyellow      =      bgyellow,
    bggreen       =       bggreen,
    bgcyan        =        bgcyan,
    bgblue        =        bgblue,
    bgmagenta     =     bgmagenta,
    bgwhite       =       bgwhite,
    bgblack       =       bgblack,

    bright        =        bright,
    italic        =        italic,
    bold          =        bright,
    dim           =           dim,
    underscore    =    underscore,
    reverse       =       reverse,
    hidden        =        hidden,
    strikethrough = strikethrough,
}