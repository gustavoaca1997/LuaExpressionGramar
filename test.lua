genParser, terrorMsgs = dofile "exp_grammar.lua"

lu = require "luaunit"

TestParser = {
    -- All output of the program would be
    -- stored in an array.
    output = {}, 
    parser = genParser(function (val) 
        table.insert(TestParser.output, val) 
    end),
}
    function TestParser:setUp()
        self.output = {}
    end

    function TestParser:testSyntaxErrorAtProgramProduction()
        input = [[
            a = 1/2
            b = a * 32
            (a)
            )b)
        ]]
        lu.assertErrorMsgContains(terrorMsgs.ErrStmt, self.parser, input)
    end

    function TestParser:testSyntaxErrorOfRValue()
        input = [[
            a = 1/2
            b = .5
        ]]
        lu.assertErrorMsgContains(terrorMsgs.ErrExp, self.parser, input)
    end

    function TestParser:testSyntaxErrorOfTerm()
        input = [[
            a = 1/2
            b = 1 - (a( * 32
        ]]
        lu.assertErrorMsgContains(terrorMsgs.ErrTerm, self.parser, input)
    end
    
    function TestParser:testSyntaxErrorOfFactor()
        input = [[
            a = 1/2
            b = 1 - (a * ( + 32)
        ]]
        lu.assertErrorMsgContains(terrorMsgs.ErrFactor, self.parser, input)
    end

TestInterpreter = {
    -- All output of the program would be
    -- stored in an array.
    output = {}, 
    parser = genParser(function (val) 
        table.insert(TestInterpreter.output, val) 
    end),
}

    function TestInterpreter:setUp()
        self.output = {}
    end

    function TestInterpreter:testOneNumber()
        input = "3"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {3})
    end

    function TestInterpreter:testAddition()
        input = "3+2"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {5})
    end

    function TestInterpreter:testSubstraction()
        input = "3-0.75"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {2.25})
    end

    function TestInterpreter:testMultiplication()
        input = "0.5*4"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {2.0})
    end

    function TestInterpreter:testDivision()
        input = "4/2"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {2.0})
    end

    function TestInterpreter:testPrecedence()
        input = "1 + 2*3"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {7})
    end

    function TestInterpreter:testNegative()
        input = "a = 2     a/-4"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {-0.5})
    end

    function TestInterpreter:testDoubleNegative()
        input = "10 - -2"
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, {12})
    end
    
    function TestInterpreter:testSequence()
        input = [[
            3 
            3.1416 - 1 
            1 / 2 * 4
        ]]
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, { 3, 2.1416, 2 })
    end

    function TestInterpreter:testAssignment()
        input = [[
            a = 1/2
            a*5
        ]]
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, { 2.5 })
    end

    function TestInterpreter:testOperateTwoVariables()
        input = [[
            a = 1/2
            b = a * 32
            b - a
        ]]
        result = self.parser(input)
        lu.assertEvalToTrue(result)
        lu.assertEquals(self.output, { 15.5 })
    end

    function TestInterpreter:testUseNotDefinedVariable()
        input = [[
            a = 1/2
            b = a0 * 32
            c = 2
        ]]
        lu.assertErrorMsgContains("not defined", self.parser, input)
    end

    function TestInterpreter:testShowNotDefinedVariable()
        input = [[
            a = 1/2
            b = a * 32
            c
            c = 2
        ]]
        lu.assertErrorMsgContains("not defined", self.parser, input)
    end

os.exit( lu.LuaUnit.run() )