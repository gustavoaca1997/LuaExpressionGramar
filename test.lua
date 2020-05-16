local function contains_error(state, arguments)
    local expMsg, toCall = table.unpack(arguments)

    local ok, errMsg = pcall(toCall, table.unpack(arguments, 3))
    if ok then
        return false
    else
        local pos = string.find( errMsg, expMsg )
        return pos
    end
end

assert:register("assertion", "evals_to", evals_to)
assert:register("assertion", "contains_error", contains_error)

describe("Arithmetic expression", function ( )
    local output, expGrammarMod, genParser, terrorMsgs, parser
    local evals_to

    setup(function()
        expGrammarMod = require "exp_grammar"
        genParser = expGrammarMod.genParser
        terrorMsgs = expGrammarMod.terrorMsgs
        
        parser = genParser(function (val)
            table.insert(output, val)
        end)

        evals_to = function (expected, input)
            local result = parser(input)
            assert.is_truthy(result)
            assert.are.same(output, expected)
        end
    end)

    describe("parser", function()
        setup(function (  )
            output = {}
        end)

        it("throws statement syntax error", function()
            local input = [[
                a = 1/2
                b = a * 32
                (a)
                )b)
            ]]
            local errfn = function ()
                parser(input)
            end
            assert.contains_error(terrorMsgs.ErrStmt, parser, input)
        end)

        it("throws expression syntax error", function()
            local input = [[
                a = 1/2
                b = .5
            ]]
            assert.contains_error(terrorMsgs.ErrExp, parser, input)
        end)

        it("throws term syntax error", function()
            local input = [[
                a = 1/2
                b = 1 - (+)
            ]]
            assert.contains_error(terrorMsgs.ErrTerm, parser, input)
        end)

        it("throws factor syntax error", function()
            local input = [[
                a = 1/2
                b = 1 - (a * ( + 32)
            ]]
            assert.contains_error(terrorMsgs.ErrFactor, parser, input)
        end)
    end)

    describe("interpreter", function()
        before_each(function()
            output = {}
        end)

        it("shows one number", function()
            evals_to({3}, "3")
        end)

        it("evals addition", function()
            evals_to({5}, "3 +  2")
        end)

        it("evals substraction", function()
            evals_to({2.25}, "3  - 0.75")
        end)

        it("evals multiplication", function()
            evals_to({2.0}, "0.5*4")
        end)

        it("evals division", function()
            evals_to({2.0}, "4/2")
        end)

        it("gives more precedence to multiplication than addition", function ()
            evals_to({7}, "1 + 2 * 3")
        end)

        it("evals negative numbers", function()
            evals_to({-0.5}, "a = 2  a/-4")
        end)

        it("evals double negative operator", function()
            evals_to({12}, "10 - -2")
        end)

        it("executes sequence of statements", function()
            input = [[
                3 
                3.1416 - 1 
                1 / 2 * 4
            ]]
            evals_to({3, 2.1416, 2}, input)
        end)

        it("assigns an expression to a variable", function()
            input = [[
                a = 1/2
                a*5
            ]]
            evals_to({ 2.5 }, input)
        end)

        it("operates two variables", function()
            input = [[
                a = 1/2
                b = a * 32
                b - a
            ]]
            evals_to({ 15.5 }, input)
        end)

        it("throws error if an undefined variable is operated", function()
            input = [[
                a = 1/2
                b = a0 * 32
                c = 2
            ]]
            assert.contains_error("not defined", parser, input)
        end)

        it("throws error if an undefined variable is shown", function()
            input = [[
                a = 1/2
                b = a * 32
                c
                c = 2
            ]]
            assert.contains_error("not defined", parser, input)
        end)
    end)
end)