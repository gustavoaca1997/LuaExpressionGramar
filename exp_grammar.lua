local lp = require "lpeglabel"
local re = require "relabel"
lp.locale(lp)

local M = {} -- Module

local space = lp.space^0
local var = space * lp.C(lp.alpha * lp.alnum^0) * space
local num = space * lp.C( lp.P("-")^-1 * lp.digit^1 * ("." * lp.digit^1)^-1 ) * space / tonumber
local openPar = space * "(" * space
local closePar = space * ")" * space
local termOp = space * lp.C(lp.S("+-")) * space
local factorOp = space * lp.C(lp.S("*/")) * space
local assignSign = space * "=" * space

local symTable, ouF = {}

local operation = {
    ["+"] = function (a, b) return a + (b or 0) end,
    ["-"] = function (a, b) return a - (b or 0) end,
    ["*"] = function (a, b) return a * (b or 1) end,
    ["/"] = function (a, b) return a / (b or 1) end,
}

M.terrorMsgs = {
    ErrStmt     = "expecting a command or an expression",
    ErrExp      = "expecting a valid expression",
    ErrTerm     = "expecting a valid term",
    ErrFactor   = "expecting a valid factor",
}

local function getVal (id)
    return type(id) == "string" and 
            (symTable[id] or error("Variable '" .. id .. "' not defined")) or id
end

local function evalOp (a, op, b)
    a, b = getVal(a), getVal(b)
    return operation[op](a, b)
end

local function assign (lVal, rVal)
    rVal = getVal(rVal)
    symTable[lVal] = rVal
end

local function show(a)
    ouF (getVal(a))
end

function M.genParser (ouFunction) -- `ouF` describes what to do with showing expressions.
    ouF = ouFunction or print
    local parser = lp.P{
        "Program";
        Program     =   (lp.V("Cmd") + lp.V("Exp") / show + #lp.P(1) * lp.T("ErrStmt"))^0,
        Cmd         =   (var * assignSign * ( lp.V("Exp") + lp.T("ErrExp") ) * space) / assign,
        Exp         =   lp.Cf( lp.V("Term") * lp.Cg( termOp * (lp.V("Term") + lp.T("ErrTerm")) )^0, evalOp ),
        Term        =   lp.Cf( lp.V("Factor") * lp.Cg( factorOp * (lp.V("Factor") + lp.T("ErrFactor")) )^0, evalOp ),
        Factor      =   var + num + openPar * lp.V("Exp") * closePar,
    } * -1

    return function(subject)
        symTable = {}
        local r, errLabel, pos = parser:match(subject)
        if not r then
            local line, col = re.calcline(subject, pos)
            local errMsg = "Error at line " .. line .. ", column " .. col .. ": " .. 
                M.terrorMsgs[errLabel] .. "."
            error(errMsg)
        end
        return r
    end
end

return M