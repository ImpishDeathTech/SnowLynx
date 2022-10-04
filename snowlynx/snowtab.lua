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

local SnowTab = Object:extend('snowtab')

function SnowTab:new(tab, ...)
    self.mode          = 'executable'
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

function SnowTab:cmp()
    local output = ''

    if string.lower(self.platform) == 'unix' then
        if string.lower(self.subplatform) == 'linux' or string.lower(self.subplatform) == 'freebsd' then 
            snow.printf("SnowLynx: Compiling %s for %s-%s", self.object, string.upper(self.subplatform), self.architechture)
        else
            snow.printf("SnowLynx: Compiling %s for %s-%s", self.object, string.upper(self.platform), self.architechture)
        end

        output = string.format("%s -std=%s -I%s %s ", self.compiler, self.stdlib, self.include, self.cflags)
    
    elseif string.lower(self.platform) == 'win32' then
        snow.printf("SnowLynx: Compiling %s for %s-%s", self.object, string.upper(self.platform), self.architechture)
        output = string.format("%s -std=% -I%s %s ", self.compiler, self.stdlib, self.include, self.cflags)
    
    else 
        error("platform '"..self.platform.." is unrecognized")
    end

    if type(self.src) == 'string' then 
        output = output..self.src..' '

    elseif type(self.src) == 'table' then 
        for _, o in pairs(self.src) do 
            output = output..o..' '
        end
    end

    return os.execute(output)
end

function SnowTab:exe()
    local output = ''
    
    if string.lower(self.platform) == 'unix' then
        if string.lower(self.subplatform) == 'linux' or string.lower(self.subplatform) == 'freebsd' then
            snow.printf("SnowLynx: Building %s for %s-%s", self.object, string.upper(self.subplatform), self.architechture)
        else
            snow.printf("SnowLynx: Building %s for %s-%s", self.object, string.upper(self.platform), self.architechture)
        end

        output = string.format("%s -std=%s -I%s -L%s %s %s ", self.compiler, self.stdlib, self.inculde, self.lib, self.lflags, self.object)
    
    elseif string.lower(self.platform) == 'win32' then
        snow.printf("SnowLynx: Building %s for %s-%s", self.object, string.upper(self.platform), self.architechture)
        output = string.format("%s.exe -std=%s -I%s %s %s.exe ", self.compiler, self.stdlib, self.include, self.lflags, self.object)
    else
        error("platform '"..self.platform.."' is unrecognized")
    end

    if type(self.src) == 'string' then 
        output = output..self.src..' '

    elseif type(self.src) == 'table' then 
        for _, o in pairs(self.src) do 
            output = output..o..' '
        end
    end

    for _, o in pairs(self.link) do
        output = output..'-l'..o..' '
    end

    return os.execute(output)
end


function SnowTab:pic()

    print(string.format('SnowLynx: Building project independant code for %s-%s', string.upper(self.platform), self.architechture))

    local output = ''

    if string.lower(self.platform) == 'unix' then
        if string.lower(self.subplatform) == 'linux' or string.lower(self.subplatform) == 'freebsd' then
            snow.printf("SnowLynx: Building project independant code for %s-%s", string.upper(self.subplatform), self.architechture)
        else
            snow.printf("SnowLynx: Building project independant code for %s-%s", string.upper(self.platform), self.architechture)
        end
        
        output = string.format("%s -std=%s -fpic -I%s %s ", self.compiler, self.stdlib, self.include, self.cflags)
    
    elseif self.platform == 'win32' then
        snow.printf("SnowLynx: Building project independant code for %s-%S", string.upper(self.platform), self.architechture)
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
    
    if self.platform == 'unix'then
        subplatform = string.lower(self.subplatform)

        if subplatform == 'linux' or string.lower(self.platform) == 'freebsd' then
            print(string.format('SnowLynx: Building lib%s.so for %s-%s', self.object, string.upper(self.subplatform), self.architechture))
            output = string.format("%s -std=%s -shared -I%s %s %s/lib%s.so ", self.compiler, self.stdlib, self.include, self.lflags, self.lib, self.object)
        
        elseif not subplatform then
            print(string.format('SnowLynx: Building lib%s.so for %s-%s', self.object, string.upper(self.platform), self.architechture))
            output = string.format("%s -std=%s -shared -I%s %s %s/lib%s.so ", self.compiler, self.stdlib, self.include, self.lflags, self.lib, self.object)
        
        else
            error(string.format("UNIX platform "..string.upper(subplatform).." is unrecognized"))
        end
    elseif string.lower(self.platform) == 'win32' then
        print(string.format('SnowLynx: Building lib%s.dll for %s-%s', self.object, string.upper(self.platform), self.architechture))
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
    if self.is(value, Object) and value:is(SnowTab) then
        table.insert(self.subtabs, value)
    else
        error(string.badargument(1, '__add', 'SnowTab', tostring(value)), 2)
    end
end


return SnowTab
