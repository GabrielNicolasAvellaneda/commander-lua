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

function Program:option(option, description)
 table.insert(self._options, { short = option, description = description } )

 return self
end

function Program:_findShortOption(option)
  for _, o in ipairs(self._options) do
      if option == o.short then
        return true
      end
  end 
  return false
end

function Program:_isShortFlag(flag)
  assert(flag, '_isShortFlag expect non-nil value')
  return string.match(flag, '^(%-[^%-]+)$')
end

function Program:_expandShortFlag(flag)
  assert(flag, '_expandShortFlag expect non-nil flag')
  local t = {}
  local i = 2 
  while true do
    local f = string.sub(flag, i, i) 
    if f == '' then break end
    
    table.insert(t, '-' .. f)
    i = i + 1
  end
  return t
end

function Program:parse(args)
  table.foreach(args, function (_, v)

    if self:_isShortFlag(v) then
      local flags = self:_expandShortFlag(v)
      for _, o in ipairs(flags) do
        if self:_findShortOption(o) then
          local field = string.match(o, '%-([a-zA-Z])')
          if field then
           self[field] = true
          end
        else
          table.insert(self.args, o)
        end
      end
    else
      table.insert(self.args, v)
    end

  end)
end

function Program:options()
  return self._options
end

local commander = {}
commander.Program = Program

return commander