--
-- snowfunc.lua
--
-- BSD 3-Clause License
--
-- Copyright (c) 2022, Christopher Stephen Rafuse
-- All rights reserved.
--
-- See LICENSE for details
--

local Object = require('snowlynx.nclassic')
local snow = Object:extend()

function snow.version()
    return '1.3'
end

function snow.cp(target, destination, recursive)
    recursive = recursive or false

    if recursive then 
        return os.execute(string.format('sudo cp -r %s %s', target, destination))
    else
        return os.execute(string.format('sudo cp %s %s', target, destination))
    end
end

function snow.mv(target, destination, recursive)
    recursive = recursive or false

    if recursive then
        return os.execute(string.format('sudo mv -r %s %s', target, destination))
    else 
        return os.execute(string.format('sudo mv %s %s', target, destination))
    end
end

function snow.rm(target, recursive)
    recursive = recursive or false
    
    if recursive then
        return os.execute(string.format('sudo rm -r %s', target))
    else
        return os.execute(stirng.format('sudo rm %s', target))
    end
end

function snow.cd(directory)
    directory = directory or ''
    
    if directory == '' then
        return os.execute('cd')
    else
        return os.execute("cd "..directory)
    end
end

function snow.mkdir(directory)
    return os.execute('sudo mkdir '..directory)
end

function snow.printf(fmt, ...)
    print(string.format(fmt, ...))
end

function snow.build(snowtab)
    if snowtab.compiler == 'lua' then 
        local out = loadfile(snowtab['$'])

        if type(out) == 'function' then
            local flag = false
            local obj  = true

            flag, obj = pcall(out)
            if flag then
                output = io.open(snowtab['@'], 'w+b')
                output:write(string.dump(out))
                output:close()
            else
                error(obj)
            end
        else
            error("could not open script "..snowtab['$'], 2)
        end
    else
        local snowexec = snowtab[snowtab.mode]

        if type(snowexec) == 'function' then
            return snowexec(snowtab)
        else
            error(snowtab.mode.." not a valid submode")
        end
    end
end

function snow.install(snowtab)
    if (snowtab.install ~= nil) and (type(snowtab.install) == 'function') then
        snowtab:install()

    elseif snowtab.mode == 'exe' then
        snow.printf("SnowLynx: Installing %s to %s", snowtab.object, snowtab.bin)
        snow.cp(snowtab.object, snowtab.bin)

    elseif snowtab.mode == 'lib' then
        local target      = snowtab.lib..'/*'
        local destination = '/usr/lib/'..snowtab.libname
        
        snow.printf("SnowLynx: Installing %s to %s", target, destination)
        snow.mkdir(destination)
        snow.cp(target, destination, true)
        
        target = snowtab.inculde..'/*'
        destination = '/usr/include/'..snowtab.libname 
        
        snow.printf("SnowLynx: Installing %s to %s", target, destination)
        snow.mkdir(destination)
        snow.cp(target, destination, true)
    else
        error('unrecognized install option'..snowtab.mode)
    end
end

function snow.remove(snowtab)
    if (snowtab.remove ~= nil) and (type(snowtab.install) == 'function') then
        return snowtab:remove()

    elseif snowtab.submode == 'exe' then
        snow.printf("SnowLynx: Removing %s", snowtab.object)
        return snow.rm(snowtab.bin..'/'..snowtab.object)

    elseif snowtab.submode == 'lib' then
        snow.printf("Removing %s", snowtab.libname)
        snow.rm('/usr/lib/'..snowtab.libname, true)
        snow.rm('/usr/include/'..snowtab.libname, true)
    end
end

return snow
