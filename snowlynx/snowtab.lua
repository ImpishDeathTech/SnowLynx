--
-- snowtab.lua
--
-- BSD 3-Clause License
--
-- Copyright (c) 2022, Christopher Stephen Rafuse
-- All rights reserved.
--
-- See LICENSE for details
--
local Object = require('snowlynx.nclassic')

local SnowTab = Object:extend('SnowTab')

function SnowTab:new(tab, ...)
    self.mode          = 'build'
    self.libname       = ''
    self.submode       = ''
    self.bin           = 'bin'
    self.object        = 'snow.out'
    self.platform      = 'unix'
    self.subplatform   = 'linux'
    self.architechture = 'x86_64'
    self.compiler      = 'g++'
    self.stdlib        = 'c++20'
    self.lib           = 'lib'
    self.include       = 'include'
    self.link          = {}
    self.src           = {}
    self.obj           = {}
    self.cflags        = '-c'
    self.lflags        = '-o'
    self['@']          = ''
    self['$']          = ''
    self.subtabs       = {...}
    self.order         = {}
    self:fields(tab)
end

function SnowTab:printfields()
    for k, v in pairs(self) do
        print(string.format('key   : %s\nvalue : %s\n', k, v))
    end
end

function SnowTab:order()
    return { 
        string.format("-std=%s", self.stdlib), 
        string.format("-I%s", self.include),
        string.format('-L%s', self.lib),
        self.cflags,
        self.src
    }
end

function SnowTab:cmp()
    local output = ''
    for k, _ in pairs(snow.compilers) do
        if self.compiler == k then
            local flag = false 
            local e    = false

            flag, e = pcall(snow[k], self:order())

            if not flag then
                error(e, 2)
            end

            return e
        end
    end

    error(self.compiler..' not supported', 2)
end

function SnowTab:exe()
    local output = ''
    
    if string.lower(self.platform) == 'unix' then
        output = string.format("-std=%s -I%s -L%s %s %s ", self.stdlib, self.inculde, self.lib, self.lflags, self.object)
    
    elseif string.lower(self.platform) == 'win32' then
        output = string.format("-std=%s -I%s %s %s.exe ", self.stdlib, self.include, self.lflags, self.object)
    else
        error("platform '"..self.platform.."' is unrecognized")
    end

    return snow[self.compiler](output, self.src, self.link)
end

SnowTab.bin = SnowTab.exe

function SnowTab:pic()

    print(string.format('SnowLynx: Building project independant code for %s-%s', string.upper(self.platform), self.architechture))

    local output = ''

    if string.lower(self.platform) == 'unix' then       
        output = string.format("%s -std=%s -fpic -I%s %s ", self.compiler, self.stdlib, self.include, self.cflags)
    
    elseif string.lower(self.platform) == 'win32' then
        output = string.format("%s -std=% -fpic -I%s %s ", self.compiler, self.stdlib, self.include, self.cflags)
    else 
        error("platform '"..self.platform.." is unrecognized")
    end

    if type(self.src) == 'string' then
        output = output..self.src..' '

    elseif type(self.src) == 'table' then
        for _, v in pairs(self.src) do
            output = output..v..' '
        end
    else
        error(type(self.src)..' invalid type for tab.src (string or table expected)')
    end

    return os.execute(output)
end

function SnowTab:shared()
    local output = ''
    
    if string.lower(self.platform) == 'unix'then
        output = string.format("%s -std=%s -shared -I%s %s %s/lib%s.so ", self.compiler, self.stdlib, self.include, self.lflags, self.lib, self.object)
    elseif string.lower(self.platform) == 'win32' then
        output = string.format("%s.exe -std=%s -shared -I%s %s %s/lib%s.dll", self.compiler, self.stdlib, self.include, self.lflags, self.lib, self.object)
    else
        error("platform '"..self.platform.."' is unrecognized")
    end

    if type(self.obj) == 'string' then
        output = output..self.obj..' '
    elseif type(self.obj) == 'table' then
        for _, v in pairs(self.obj) do
            output = output..v..' '
        end
    else
        error(type(self.obj)..' invalid type for tab.obj (string or table expected)')
    end

    for _, v in pairs(self.link) do
        output = output..'-l'..v..' '
    end

    return os.execute(output)
end

function SnowTab:__add(value)
    if self.is(value, SnowTab) then
        table.insert(self.subtabs, value)
    else
        error("bad argument #1 to __add (SnowTab expected, got "..tostring(value)..")", 2)
    end
end

return SnowTab