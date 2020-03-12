genParser = dofile "exp_grammar.lua"

lu = require "luaunit"

TestSuite = {
    -- All output of the program would be
    -- stored in an array.
    output = {}, 
}
    parser = genParser(function (val) 
        table.insert(TestSuite.output, val) 
    end)

    function TestSuite:setUp()
        self.output = {}
    end

    function TestSuite:testOneNumber()
        input = "3"
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {3})
    end

    function TestSuite:testAddition()
        input = "3+2"
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {5})
    end

    function TestSuite:testSubstraction()
        input = "3-0.75"
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {2.25})
    end

    function TestSuite:testMultiplication()
        input = "0.5*4"
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {2.0})
    end

    function TestSuite:testDivision()
        input = "4/2"
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {2.0})
    end
    
    function TestSuite:testSequence()
        input = [[
            3 
            3.1416 - 1 
            1 / 2 * 4
        ]]
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, { 3, 2.1416, 2 })
    end

    function TestSuite:testAssignment()
        input = [[
            a = 1/2
            a*5
        ]]
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, { 2.5 })
    end

    function TestSuite:testOperateTwoVariables()
        input = [[
            a = 1/2
            b = a * 32
            b - a
        ]]
        result = parser:match(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, { 15.5 })
    end

    function TestSuite:testNotDefinedVariable()
        input = [[
            a = 1/2
            b = a0 * 32
        ]]
        lu.assertErrorMsgContains("Variable not defined", parser.match, parser, input)
    end

    os.exit( lu.LuaUnit.run() )