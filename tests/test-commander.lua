--[[

Copyright 2012-2014 The Luvit Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]

local Program = require('../commander').Program
local deepEqual = require('deep-equal.lua')

require("tap")(function (test)
  test("Program:version sets version and return the same instance", function ()
   
    local program = Program:new()
    local inst = program:version('0.0.1')

    assert(program == inst)
    assert(program:version() == '0.0.1') 
  end)

  test('Program:option sets new option and return the same instance', function ()
   local program = Program:new()
   local inst = program:option('-s', 'Silent mode')

   assert(program == inst)
   assert(#program:options() == 1)
   assert(deepEqual(program:options(), { { short = '-s', description = 'Silent mode'} }))
   program:option('-o', 'Another option')
   assert(#program:options() == 2)
   assert(deepEqual(program:options(), { { short = '-s', description = 'Silent mode' }, { short = '-o', description = 'Another option' } }))
  end)

  test('Program:parse should parse short options into fields', function ()
    local program = Program:new()
    program:option('-s', 'Silent mode')
    program:option('-x', 'Extract')

    program:parse({'-s'})
    assert(program.s)
    assert(not program.x)
  end)

  test('Program:parse should leave not parsed option into args field', function () 
    local program = Program:new()
    program:option('-t', 'Test option')

    program:parse({ '-t', '-s', 'arg2', 'arg3' })
    assert(deepEqual({'-s', 'arg2', 'arg3'}, program.args))
  end)

  test('Program:parse should parse collapsed short option into fields', function ()
    local program = Program:new()
    program:option('-s', 'Silent mode')
    program:option('-x', 'Extract')
    
    program:parse({'-sx', '-t'})

    assert(program.s)
    assert(program.x)
    assert(deepEqual({'-t'}, program.args))
  end)


end)
