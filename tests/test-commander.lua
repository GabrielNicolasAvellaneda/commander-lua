--[[

Copyright 2015 Gabriel Nicolas Avellaneda <avellaneda.gabriel@gmail.com>. All Rights Reserved.

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

  test('Program:_splitFlags should split flags in short and log parts', function ()
    local program = Program:new()
    local a, all = program:_splitFlags('-a, --all')
    assert('-a', a)
    assert('--all', all)
  end)

  test('Program:_snakecase should return snake case of long type flags', function () 
    local program = Program:new()
    local allow_all = program:_snakecase('allow-all')
    assert('allow_all' == allow_all)
  end)

  test('Program:option sets new option and return the same instance', function ()
   local program = Program:new()
   local inst = program:option('-s, --silent', 'Silent mode')

   assert(program == inst)
   assert(#program:options() == 1)
   assert(deepEqual(program:options(), { { short = '-s', long = '--silent', description = 'Silent mode'} }))
   program:option('-x, --extract', 'Another option')
   assert(#program:options() == 2)
   assert(deepEqual(program:options(), { { short = '-s', long = '--silent', description = 'Silent mode' }, { short = '-x', long = '--extract', description = 'Another option' } }))
  end)

  --[[test('Program:option using simple bolean defaulting to false', function () 
    local program = Program:new()
    program:option('

  end)]]

  test('Program:parse should set fields only for parsed and configured options', function ()
    local program = Program:new()
    program:option('-f, --force', 'Force update')
    program:option('-i, --interactive', 'Interactive mode')
    program:parse({'-i'})
    assert(program.i)
    assert(program.interactive)
    assert(not program.f)
    assert(not program.force)
  end)

  test('Program:parse should parse options into short and long fields', function ()
    local program = Program:new()
    program:option('-s, --silent', 'Silent mode')
    program:option('-x, --extract', 'Extract')

    program:parse({'-s', '--extract'})
    assert(program.s, 'short flag s should be set')
    assert(program.silent, 'long flag silent sholud be set')
    assert(program.x, 'short flag x should be set')
    assert(program.extract, 'long flag extract should be set')
  end)


  test('Program:parse should leave not parsed options into args field', function () 
    local program = Program:new()
    program:option('-t, --test', 'Test option')
    program:parse({ '-t', '-s', 'arg2', 'arg3' })
    assert(deepEqual({'-s', 'arg2', 'arg3'}, program.args))
  end)

  test('Program:parse should parse collapsed short option into fields', function ()
    local program = Program:new()
    program:option('-s, --silent', 'Silent mode')
    program:option('-x, --extract', 'Extract')
    
    program:parse({'-sx', '-t'})

    assert(program.s)
    assert(program.x)
    assert(deepEqual({'-t'}, program.args))
  end)

end)
