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

function snow.major()
    return 1
end

function snow.minor()
    return 4
end

function snow.patch()
    return 5
end

function snow.isrelease()
    return false
end

function snow.name()
    return 'SnowLynx'
end

function snow.version(fmt)
    fmt = fmt or 'table'

    if fmt == 'string' then 
        return string.format("%d.%d.%d", snow.major(), snow.minor(), snow.patch())
    elseif fmt == 'table' then
        local o = {
            major     = snow.major(),
            minor     = snow.minor(),
            patch     = snow.patch(),
            isrelease = snow.isrelease()
        }
        
        local mt = {}

        mt.__name = string.format("%s %s", snow.name(), 'Version')

        function mt:__eq(value) 
            return (self.major == value.major and self.minor == value.minor and self.patch == value.patch and self.isrelease == value.isrelease)
        end

        function mt:__lt(value)
            return (self.major < value.major or self.minor < value.minor or self.patch < value.pach)
        end

        function mt:__le(value)
            return (self.major <= value.major or self.minor <= value.minor or self.patch <= value.patch)
        end

        return setmetatable(o, mt)
    end
end

function snow.watermark()
    return string.format("SnowLynx Build System ver%s, Copyright (c) Christopher Stephen Rafuse 2022, BSD 3-Clause All rights reserved", snow.version('string'))
end

snow.errfmt  = 'SnowLynx: !ERROR! %s x,..,X\n'
snow.errfmt2 = 'SnowLynx: %s: !ERROR! %s x,..,X\n'
snow.badarg  = "badargument #%d to '%s' (%s expected, got %s)\n"
snow.badarg2 = "badargument #%d to '%s' (%s expected)\n"
snow.newline = '\n'
snow.tabchar = '\t'

function snow.errorf(fmt, ...)
    io.stderr:write(string.format(fmt, ...))
end

function snow.error(e, exit, code)
    exit = exit or false
    code = code or 1
    snow.errorf(snow.errfmt, e)
    if exit then
        os.exit(code)
    end
end

snow.HelpTab = Object:extend("HelpTab")

function snow.HelpTab:build()
    print("\tsnow build: builds a project based on the local snowtab, or a given .snowtab")
end

function snow.HelpTab:install()
    print("\tsnow install: installs a project to the standard directories")
end

function snow.HelpTab:remove()
    print("\tsnow remove: removes a project from the standard directories")
end

function snow.HelpTab:help()
    print("\tsnow help [option]: prints a standard help message, or the description of the given command")
end

-- help output
function snow.help(opt)
    if not opt then
        snow.printf("SnowLynx-%s Help", snow.version())
        snow.printf("snow [command] [@ .snowtab] [$ .snowrc]")
        
        for k, _ in pairs(snow.HelpTab) do
            snow.printf('\tsnow %s', k)
        end
    else
        local flag     = false
        local e        = false
        local snowexec = snow.HelpTab[opt]

        if snowexec and type(snowexec) == 'function' then
            flag, e = pcall(snowexec, snow.HelpTab)
            
            if not flag then
                snow.error(e, true)
            end
        else
            snow.error(string.format('%s not in snow.HelpTab', opt), true)
        end
    end
end

-- copy given target to given destination
function snow.cp(target, destination, recursive)
    recursive = recursive or false

    if recursive then 
        return os.execute(string.format('sudo cp -r %s %s', target, destination))
    else
        return os.execute(string.format('sudo cp %s %s', target, destination))
    end
end

-- move given target to given destination
function snow.mv(target, destination, recursive)
    recursive = recursive or false

    if recursive then
        return os.execute(string.format('sudo mv -r %s %s', target, destination))
    else 
        return os.execute(string.format('sudo mv %s %s', target, destination))
    end
end

-- remove given target
function snow.rm(target, recursive)
    recursive = recursive or false
    
    if recursive then
        return os.execute(string.format('sudo rm -r %s', target))
    else
        return os.execute(string.format('sudo rm %s', target))
    end
end

-- change the current directory
function snow.cd(directory)
    directory = directory or ''
    
    if directory == '' then
        return os.execute('cd')
    else
        return os.execute("cd "..directory)
    end
end

-- make a new directory
function snow.mkdir(directory)
    return os.execute('sudo mkdir '..directory)
end

-- print with a given format
function snow.printf(fmt, ...)
    io.stdout:write(string.format(fmt, ...))
    collectgarbage()
end

-- scan data with a given format
function snow.scanf(fmt)
    local input = io.stdin:read('l')

    if not tonumber(input) then
        return string.format(fmt, input)
    else
        return string.format(fmt, tonumber(input))
    end
end

-- join a table and it's subtables into a string
function snow.join(tab, sep)
    local output = ''
    sep = sep or ' '

    for _, v in pairs(tab) do
        if type(v) == 'string' then
            output = output..v..sep
        elseif type(v) == 'table' then
            for _, v2 in pairs(v) do
                output = string.format("%s %s ", output, snow.join(v2, sep))
            end
        end
    end

    return output
end

-- execute default c compiler with arguments
function snow.cc(...)
    return os.execute(string.format("cc ", snow.join({...})))
end

-- execute default c++ compiler with arguments
function snow.cxx(...)
    return os.execute(string.format("c++ ", snow.join({...})))
end

-- execute default assembler with arguments
function snow.as(...)
    return os.execute(string.format("as ", snow.join({...})))
end

-- execute dynamic linker with arguments
function snow.ld(...)
    return os.execute(string.format("ld ", snaw.join({...})))
end

-- execute ldconfig
function snow.ldconfig()
    return os.execute('ldconfig')
end

snow.buildfmt = "SnowLynx: Building %s for %s-%s e,..,e\n"

-- builds a project based on a snowtab
function snow.build(snowtab)
    platform    = string.upper(snowtab.platform)
    subplatform = string.upper(snowtab.subplatform)

    if platform == 'UNIX' then
        if subplatform == 'LINUX' or subplatform == 'FREEBSD' then
        snow.printf(snow.buildfmt, snowtab.object, snowtab.subplatform, snowtab.architechture)
        else
            snow.printf(snow.buildfmt, snowtab.object, snowtab.platform, snowtab.architechture)
        end
    else
        snow.printf(snow.buildfmt, snowtab.object, snowtab.platform, snowtab.architechture)
    end

    if snowtab.mode == snow.multi or snowtab.submode == snow.multi then
        for _, v in pairs(snowtab.subtabs) do
            local ret = snow.build(v)

            if tonumber(ret) and ret ~= 0 then
                return ret
            end
        end
    end

    if snowtab.build and type(snowtab.build) == 'function' then
        snowtab:build()

    elseif snowtab.compiler == 'lua' then 
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
            local flag = false
            local e    = false
            
            flag, e = pcall(snowexec, snowtab)
            
            if not flag then 
                error(e)
            else
                return e
            end
        else
            error(snowtab.mode.." not a valid mode")
        end
    end
end

snow.installfmt = "SnowLynx: Installing %s to %s >,..,>\n"

-- installs a snowtab and writes the installed
-- locations to a manifest file called .snowman
function snow.install(snowtab)
    if snowtab.mode == snow.multi or snowtab.submode == snow.multi then
        for _, v in pairs(snowtab.subtabs) do
            local ret = snow.install(v)

            if tonumber(ret) and ret ~= 0 then
                return ret
            end
        end
    end

    local path     = snowtab.manifest or '.snowman'
    local manifest = io.open(path, 'a+')
    local ret      = 0

    if snowtab.install and (type(snowtab.install) == 'function') then
        ret = snowtab:install(manifest)
        manifest:close()

    elseif snowtab.mode == 'bin' then
        manifest:write(snowtab.destination..'\n')
        ret = snow.cp(snowtab.target, snowtab.destination)

        if ret ~= 0 then
            manifest:close()
            return ret
        end

        manifest:write(string.format('executable: %s\n', snowtab.target))
        manifest:write(snowtab.destination..'\n')
        manifest:close()

    elseif snowtab.mode == 'inc' then    
        ret = snow.mkdir(snowtab.include)

        if tonumber(ret) and ret ~= 0 then
            manifest:close()
            return ret
        else
            
            manifest:write(string.format('include: %s\n', snowtab.include))
            if type(snowtab.target) == 'string' then
                snow.printf(snow.installfmt, snowtab.target, snowtab.include)
                ret = snow.cp(snowtab.target, snowtab.include)

                if ret ~= 0 then
                    manifest:close()
                    return ret
                end

            elseif type(snowtab.target) == 'table' then  
                for i = 1, #snowtab.target, 1 do
                    snow.printf(snow.installfmt, snowtab.target[i], snowtab.include)
                    ret = snow.cp(snowtab.target[i], string.format("%s/%s", snowtab.include, snowtab.destination[i]), true)
                
                    if ret ~= 0 then
                        manifest:close()
                        return ret
                    end

                    manifest:write(string.format("%s/s\n", snowtab.include, snowtab.destination[i]))
                end
            end
        end

        manifest:close()
        snow.ldconfig()
    elseif snowtab.mode == 'lib' then
        manifest:write(string.format('library: %s\n', snowtab.lib))
            if type(snowtab.target) == 'string' then
                snow.printf(snow.installfmt, snowtab.target, snowtab.lib)
                ret = snow.cp(snowtab.target, snowtab.lib)

                if ret ~= 0 then
                    manifest:close()
                    return ret
                end

            elseif type(snowtab.target) == 'table' then  
                for i = 1, #snowtab.target, 1 do
                    snow.printf(snow.installfmt, snowtab.target[i], snowtab.lib)
                    ret = snow.cp(snowtab.target[i], string.format("%s/%s", snowtab.lib, snowtab.destination[i]), true)
                
                    if ret ~= 0 then
                        manifest:close()
                        return ret
                    end

                    manifest:write(string.format("%s/s\n", snowtab.lib, snowtab.destination[i]))
                end
            end
    else
        error('unrecognized install mode: '..snowtab.mode)
    end

    return ret 
end

-- remove all files contained within the
-- install manifest
function snow.remove(snowtab)
    local path = snowtab.manifest or '.snowman'
    local manifest = io.open(path, 'r')

    if not manifest then
        error('manifest '..path..' could not be found')
    end

    if snowtab.remove and type(snowtab.remove) == 'function' then
        snowtab:remove(manifest)
        manifest:close()
    else
        local input = manifest:read('l')

        while input do
            if (input:find('executable:', 1, true) == 1) or (input:find('library:', 1, true) == 1) then
                local inp = {}

                for s in string.gmatch(input, "([^%s]+)") do
                    table.insert(inp, s)
                end

                local ret = snow.rm(inp[2])

                if tonumber(ret) and ret ~= 0 then
                    manifest:close()
                    return ret
                end
            elseif input:find('include:', 1, true) == 1 then
                local inp = {}

                for s in string.gmatch(input, "([^%s]+)") do
                    table.insert(inp, s)
                end

                local ret = snow.rm(inp[2], true)

                if tonumber(ret) and ret ~= 0 then
                    manifest:close()
                    return ret
                end
            else
                local ret = snow.rm(input)

                if tonumber(ret) and ret ~= 0 then
                    manifest:close()
                    return ret
                end
            end

            input = manifest:read('l')
        end

        manifest:close()
        snow.ldconfig()
    end
end

-- iterate through command line arguments
-- to get desired information
function snow.loadargs()
    local i = 1

    if #arg >= 1 then
        if arg[1] == 'help' then
            if #arg == 2 then
                snow.help(arg[2])
            else
                snow.help()
            end
            
            os.exit(0)
        else
            SNOW_MODE = arg[1]
        end
    end

    i = i + 1

    while i <= #arg do
        if arg[i] == '@' then
            i = i + 1
            SNOW_TAB = arg[i]
        elseif arg[i] == '$' then
            i = i + 1
            SNOW_RC = arg[i]
        else
            SNOW_MODE = arg[i]
        end
        i = i + 1
    end
end

function snow.checkpath(path)
    local rc = io.open(path, 'r')
    if rc then
        rc:close()
        return true
    else
        return false
    end
end

function snow.loadrc()
    local snowrc = false
    local e      = 'could not find a .snowrc'

    if snow.checkpath(SNOW_RC) then
        snowrc, e = loadfile(SNOW_RC)

    elseif snow.checkpath(HOME..'/.config/snowrc') then
        SNOW_RC = HOME..'/.config/snowrc'
        snowrc, e = loadfile(SNOW_RC)

    elseif snow.checkpath(SNOW_DEFRC) then
        SNOW_RC = SNOW_DEFRC
        snowrc, e = loadfile(SNOW_RC)
    end

    if type(snowrc) ~= 'function' then
        return false, e
    else
        return true, snowrc
    end
end 

-- get the home path
function snow.home()
    os.execute('echo $HOME > snow.home')
    local f = io.open('snow.home', 'r')
    local o = f:read('a')
    f:close()
    snow.rm('snow.home')
    return o
end

return snow
