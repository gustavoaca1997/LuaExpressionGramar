parser = dofile "exp_grammar.lua"

lu = require "luaunit"

TestClass = {
    -- All output of the program would be
    -- stored in an array.
    output = {}, 
}

    function TestClass:setUp()
        self.output = {}
        self.ouF = function (val) 
            table.insert(self.output, val) 
        end
    end

    function TestClass:testOneNumber()
        input = "3"
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, {3})
    end

    function TestClass:testAddition()
        input = "3+2"
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, {5})
    end

    function TestClass:testSubstraction()
        input = "3-0.75"
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, {2.25})
    end

    function TestClass:testMultiplication()
        input = "0.5*4"
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, {2.0})
    end

    function TestClass:testDivision()
        input = "4/2"
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, {2.0})
    end
    
    function TestClass:testSequence()
        input = [[
            3 
            3.1416 - 1 
            1 / 2 * 4
        ]]
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, { 3, 2.1416, 2 })
    end

    function TestClass:testAssignment()
        input = [[
            a = 1/2
            a*5
        ]]
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, { 2.5 })
    end

    function TestClass:testOperateTwoVariables()
        input = [[
            a = 1/2
            b = a * 32
            b - a
        ]]
        result = parser(self.ouF):match(input)
        assert(result)
        lu.assertEquals(self.output, { 15.5 })
    end

    os.exit( lu.LuaUnit.run() )