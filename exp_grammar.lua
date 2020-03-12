local lpeg = require "lpeglabel"
lpeg.locale(lpeg)

local space = lpeg.space^0
local var = lpeg.C(lpeg.alpha * lpeg.alnum^0) * space
local num = lpeg.C( lpeg.digit^1 * ("." * lpeg.digit^1)^-1 ) * space / tonumber
local openPar = "(" * space
local closePar = ")" * space
local termOp = lpeg.C(lpeg.S("+-")) * space
local factorOp = lpeg.C(lpeg.S("*/")) * space
local assignSign = "=" * space

local symTable = {}

local operation = {
    ["+"] = function (a, b) return a + (b or 0) end,
    ["-"] = function (a, b) return a - (b or 0) end,
    ["*"] = function (a, b) return a * (b or 1) end,
    ["/"] = function (a, b) return a / (b or 1) end,
}

local function getVal (id)
    return type(id) == "string" and 
            (symTable[id] or error("Variable not in scope")) or id
end

local function evalOp (a, op, b)
    a, b = getVal(a), getVal(b)
    return operation[op](a, b)
end

local function assign (lVal, rVal)
    rVal = getVal(rVal)
    symTable[lVal] = rVal
end

local function show(ouF)
    return function (a)
        ouF (getVal(a))
    end
end

parser = function (ouF) -- `ouF` describes what to do with showing expressions.
    ouF = ouF or print
    return lpeg.P{
        "Program";
        Program     =   space * (lpeg.V("Cmd") + lpeg.V("Exp") / show(ouF))^0,
        Cmd         =   (var * assignSign * lpeg.V("Exp") * space) / assign,
        Exp         =   lpeg.Cf(lpeg.V("Term") * lpeg.Cg(termOp * lpeg.V("Term"))^0, evalOp),
        Term        =   lpeg.Cf(lpeg.V("Factor") * lpeg.Cg(factorOp * lpeg.V("Factor"))^0, evalOp),
        Factor      =   var + num + openPar * lpeg.V("Exp") * closePar,
    } * -1
end
return parser