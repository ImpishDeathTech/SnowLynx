
--
-- nclassic.lua
--
-- Modified by ImpishDeathTech, July 26, 2022
-- 
-- based on https://github.com/rxi/classic
-- 
-- Copyright (c) 2022, ImpishDeathTech
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license.
--

local Object = {}

Object.__index = Object
Object.__name  = "class"


function Object:new()
end

function Object:delete()
end

function Object:extend(type_str)
  local cls = {}

  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end

  cls.__index = cls
  cls.__name  = type_str or "object"
  cls.super   = self

  setmetatable(cls, self)
  return cls
end

function Object:fields(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if type(v) ~= "function" then
        self[k] = v
      end
    end
  end
end

function Object:implement(...)
  self.interfaces = {}
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function"  then
        self[k] = v
      end
    end
  end
end

function Object:override(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do 
      if (self[k] ~= nil) and (type[k] == "function") and (type(v) == "function") then
        self[k] = v
      end
    end
  end
end

function Object:metatable(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      getmetatable(self)[k] = v
    end
  end
  return getmetatable(self)
end

function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

function Object:equals(cls) 
  local retVal = true

  for k, v in pairs(cls) do
    if (self[k] == nil) or (self[k] ~= v) then
      retVal = false
      break
    end
  end
  return retVal
end

function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end

function Object:__gc()
  self:delete()
end

function Object:__len()
  local c = 0
  for k, v in pairs(self) do
    c = c + 1
  end
  return c
end

return Object