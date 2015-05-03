if exports then
  exports.name = 'gna/commander'
  exports.version = '0.0.1'
  exports.private = true
  exports.dependencies = {
    "luvit/require",
    "luvit/pretty-print"
  }
end

local Object = require('core').Object
local table = require('table')
local strign = require('string')

local Program = Object:extend()

function Program:initialize()
 self._options = {} 
 self.args = {}
end

function Program:version(version)
  if not version then
    return self._version
  end

  self._version = version
  
  return self
end

function Program:_splitFlags(flags)

  return string.match(flags, '(%-%w+)%s*,%s*(%-%-%w+)')
end

function Program:_snakecase(str)
  return string.gsub(str, '%-', '_') 
end

function Program:option(flags, description, fn, default)
  local short, long = self:_splitFlags(flags)
  table.insert(self._options, { short = short, long = long, description = description } )
  return self
end

function Program:_findShortOption(option)
  return self:_findOption(option, 'short')
end

function Program:_findLongOption(option)
  return self:_findOption(option, 'long')
end

function Program:_findOption(option, type)
  for _, o in ipairs(self._options) do
    if option == o[type] then
      return o 
    end
  end
  return nil
end

function Program:_isShortFlag(flag)
  assert(flag, '_isShortFlag expect non-nil value')
  return string.match(flag, '^(%-[^%-]+)$')
end

function Program:_isLongFlag(flag)
  assert(flag, '_isLongFlag exepct non-nil value')
  return string.match(flag, '^(%-%-[^%-]+)$')
end

function Program:_extractShortFlag(flag)
  return string.match(flag, '^-(%w+)$')
end

function Program:_extractLongFlag(flag)
  return string.match(flag, '^%-%-(%w+)$')
end

function Program:charAt(str, i)
  return string.sub(str, i, i)
end

function Program:_expandShortFlag(flag)
  assert(flag, '_expandShortFlag expect non-nil flag')
  local t = {}
  local i = 2 
  while true do
    local f = self:charAt(flag, i) 
    if f == '' then break end
    
    table.insert(t, '-' .. f)
    i = i + 1
  end
  return t
end

function Program:_addIgnoredArg(arg)
  table.insert(self.args, arg)
end

function Program:_setField(option)
  local shortField = self:_extractShortFlag(option.short)
  local longField = self:_extractLongFlag(option.long)
  self[shortField] = true
  self[longField] = true
end

function Program:_setFieldOrIgnore(flag, type)
  local option
  if type == 'long' then
    option = self:_findLongOption(flag)
  elseif type == 'short' then
    option = self:_findShortOption(flag) 
  end

  if option then
    self:_setField(option)
  else
    self:_addIgnoredArg(flag)
  end
end

function Program:parse(args)
  table.foreach(args, function (_, v)
    if self:_isShortFlag(v) then
      local flags = self:_expandShortFlag(v)
      for _, o in ipairs(flags) do
        self:_setFieldOrIgnore(o, 'short')
      end
    elseif self:_isLongFlag(v) then
       self:_setFieldOrIgnore(v, 'long')
    else
      self:_addIgnoredArg(v)
    end
  end)
end

function Program:options()
  return self._options
end

local commander = {}
commander.Program = Program

return commander
