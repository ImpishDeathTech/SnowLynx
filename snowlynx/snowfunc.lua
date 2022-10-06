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

-- SnowLynx version
function snow.major()
    return 1
end

function snow.minor()
    return 5
end

function snow.patch()
    return 0
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

-- watermark printed at beginning of snow program
function snow.watermark()
    local testing = ' (TESTING)'

    if snow.isrelease() then
        testing = ''
    end

    return string.format("SnowLynx Build System ver%s%s, Copyright (c) Christopher Stephen Rafuse 2022, BSD 3-Clause All rights reserved", snow.version('string'), testing)
end

-- some format strings
snow.errfmt  = 'SnowLynx: !ERROR! %s x,..,X\n'
snow.errfmt2 = 'SnowLynx: %s: !ERROR! %s x,..,X\n'
snow.badarg  = "badargument #%d to '%s' (%s expected, got %s)\n"
snow.badarg2 = "badargument #%d to '%s' (%s expected)\n"

-- some characters
snow.newline = '\n'
snow.tabchar = '\t'

-- error format function that prints to stderr
-- @param fmt should be a format string
-- used by snow.error
function snow.errorf(fmt, ...)
    if type(fmt) == 'string' then
        io.stderr:write(string.format(fmt, ...))
    else
        error(string.format(snow.badarg, 1, "errorf", 'string', type(fmt)), 2)
    end
end

-- error function used by snow program
-- @param e should be an error object
-- @param exit should be a boolean or no value
-- @param code should be a number or no value
function snow.error(e, exit, code)
    exit = exit or false
    code = code or 1
    snow.errorf(snow.errfmt, e)
    if exit then
        os.exit(code)
    end
end

function snow.badargument(num, proc, expected, got)
    return string.format(snow.badarg, num, proc, expected, got)
end

-- a table contaning the functions that print the 
-- descriptions of different commands
-- these can be added in .snowrc along side 
-- their respective command functions to
-- snow table
snow.HelpTab = {}

function snow.HelpTab:build()
    print("\tsnow build: builds a project based on the local .snowtab, or a given .snowtab")
end

function snow.HelpTab:install()
    print("\tsnow install: installs a project to the standard directories")
end

function snow.HelpTab:remove()
    print("\tsnow remove: removes a project from the standard directories")
end

function snow.HelpTab:multiple()
    print("\tsnow multiple: builds a project based on the local multitab .snowtab, or a given multitab .snowtab")
end

function snow.HelpTab:help()
    print("\tsnow help [option]: prints a standard help message, or the description of the given command")
end

-- entry object for adding command entries
-- to snow from .snowrc
snow.Entry   = Object:extend("SnowEntry")

function snow.Entry:new(name, proc, command)
    if type(name) == 'string' then
        self.name = name
    else
        error(snow.badargument(1, 'new', 'string', type(name)), 2)
    end

    if type(proc) == 'function' then
        self.proc = proc
    else
        error(snow.badargument(2, 'new', 'function', type(proc)), 2)
    end

    if type(command) == 'function' then
        self.command = command
    else
        error(snow.badargument(3, 'new', 'function', type(command)), 2)
    end
end

-- function for adding help entries
-- @param entry should be of type Entry, found in snow.Entry
function snow.add(entry)
    if Object.is(entry, snow.Entry) then
        snow.HelpTab[entry.name] = entry.proc
        snow[entry.name]         = entry.command
    else
        error(snow.badargument(1, 'add', 'Entry', tostring(entry)), 2)
    end
end

-- help output
-- @param opt should be a string contained as a key within the HelpTab
function snow.help(opt)
    if not opt then
        snow.printf("SnowLynx-%s Help\n", snow.version())
        snow.printf("snow [command] [@ .snowtab] [$ .snowrc]\n")
        
        for k, _ in pairs(snow.HelpTab) do
            snow.printf('\tsnow %s\n', k)    
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
            error(string.format('%s not a snow.HelpTab option', opt), 2)
        end
    end
end

-- copy given target to given destination
-- @param target should be the path of the target
-- @param destination should be the path of the destination of the copy
-- @param recusive should be a boolean indicating wether or not to use -r
function snow.cp(target, destination, recursive)
    recursive = recursive or false
    
    if type(target) ~= 'string' then
        error(snow.badargument(1, 'cp', 'string', type(target)), 2)
    elseif type(destination) ~= 'string' then
        error(snow.badargument(2, 'cp', 'string', type(destination)), 2)
    elseif type(recursive) ~= 'boolean' then
        error(snow.badargument(3, 'cp', 'boolean or no value', type(destination)), 2)
    end

    if recursive then 
        return os.execute(string.format('sudo cp -r %s %s', target, destination))
    else
        return os.execute(string.format('sudo cp %s %s', target, destination))
    end
end

-- move given target to given destination
-- @param target should be the path of the target
-- @param destination should be the path of the destination of the copy
-- @param recusive should be a boolean indicating wether or not to use -r
--        can be no value
function snow.mv(target, destination, recursive)
    recursive = recursive or false

    if type(target) ~= 'string' then
        error(snow.badargument(1, 'cp', 'string', type(target)), 2)
    elseif type(destination) ~= 'string' then
        error(snow.badargument(2, 'cp', 'string', type(destination)), 2)
    elseif type(recursive) ~= 'boolean' then
        error(snow.badargument(3, 'cp', 'boolean or novalue', type(recursive)), 2)
    end

    if recursive then
        return os.execute(string.format('sudo mv -r %s %s', target, destination))
    else 
        return os.execute(string.format('sudo mv %s %s', target, destination))
    end
end

-- remove given target
-- @param target should be the path of the target
-- @param recusive should be a boolean indicating wether or not to use -r
--        can be no value
function snow.rm(target, recursive)
    recursive = recursive or false
    
    if type(target) ~= 'string' then
        error(snow.badargument(1, 'cp', 'string', type(target)), 2)
    elseif type(recursive) ~= 'boolean' then
        error(snow.badargument(2, 'cp', 'boolean or no value', type(recursive)), 2)
    end

    if recursive then
        return os.execute(string.format('sudo rm -r %s', target))
    else
        return os.execute(string.format('sudo rm %s', target))
    end
end

-- change the current directory
-- @param directory should be the path of the directory to change or novalue
function snow.cd(directory)
    directory = directory or ''
    
    if directory == '' then
        return os.execute('cd')
    else
        return os.execute("cd "..directory)
    end
end

-- make a new directory
-- @param directory should be the path of the directory to make
function snow.mkdir(directory)
    if type(directory) == 'string' then
        return os.execute('sudo mkdir '..directory)
    else
        error(snow.badargument(1, 'mkdir', 'string', type(directory)), 2)
    end
end

-- print with a given format
-- @param fmt should be a format string, writes to stdout
function snow.printf(fmt, ...)
    if type(fmt) ~= 'string' then
        error(snow.badargument(1, 'printf', 'string', type(fmt)), 2)
    else
        io.stdout:write(string.format(fmt, ...))
    end

    collectgarbage()
end

-- join a table and it's subtables into a string
-- @param tab should be a table of strings and tables of strings to join
-- @param sep should be a separator string or no value
function snow.join(tab, sep)
    local output = {}
    sep = sep or ' '

    for _, v in pairs(tab) do
        if type(v) == 'string' then
            table.insert(output, v)
        elseif type(v) == 'table' then
            for _, v2 in pairs(v) do
                table.insert(output, v2)
            end
        else
            error(v..' is not a table or string', 2)
        end
    end

    return table.concat(output, sep)
end

-- execute default c compiler with arguments
function snow.cc(...)
    return os.execute(string.format("cc %s", snow.join({...})))
end

-- execute default c++ compiler with arguments
function snow.cxx(...)
    return os.execute(string.format("c++ %s", snow.join({...})))
end

-- execute gcc compiler with argumens

function snow.gcc(...)
    return os.execute(string.format("gcc %s", snow.join({...})))
end

-- execute g++ compiler with arguments 
function snow.gxx(...) 
    return os.execute(string.format("g++ %s", snow.join({...})))
end

snow['g++'] = snow.gxx

function snow.clang(...)
    return os.execute(string.format("clang %s", snow.join({...})))
end

-- execute fpc compiler with arguments
function snow.fpc(...)
    return os.execute(string.format("fpc %s", snow.join({...})))
end

-- execute default assembler with arguments
function snow.as(...)
    return os.execute(string.format("as %s", snow.join({...})))
end

-- execute dynamic linker with arguments
function snow.ld(...)
    return os.execute(string.format("ld %s", snaw.join({...})))
end

-- execute chmod
function snow.chmod(mod, file)
    return os.execute(string.format('chmod %s %s', mod, file))
end

snow.compilers = {
    'cc',
    'cxx',
    'gcc',
    'g++',
    'clang',
    'fpc'
}

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

    if snowtab.build and type(snowtab.build) == 'function' then
        return snowtab:build()
    
    elseif snowtab.mode == 'multiple' then
        local out = snow.Tab({ mode = 'multiple' })

        for _, v in pairs(snowtab.subtabs) do
            if v.mode == 'build' then
                table.insert(out.subtabs, v)
            end
        end

        return snow.multiple(out)

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

    local path     = snowtab.manifest or '.snowman'
    local manifest = io.open(path, 'a+')
    local ret      = 0

    if snowtab.install and (type(snowtab.install) == 'function') then
        ret = snowtab:install(manifest)
        manifest:close()
    
    elseif snowtab.mode == 'multiple' then
        manifest:close()
        local out = snow.Tab({ mode = 'multiple '})

        for _, v in pairs(snowtab.subtabs) do
            if v.mode == 'install' then
                table.insert(out.subtabs, v)
            end
        end

        return snow.multiple(out)

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
    elseif snowtab.mode == 'multiple' then
        manifest:close()
        local out = snow.Tab({ mode = 'multiple' })

        for _, v in pairs(snowtab.subtabs) do
            if v.mode == 'remove' then
                table.insert(out.subtabs, v)
            end
        end

        return snow.multiple(out)
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

function snow.multiple(snowtab)
    for _, v in pairs(snowtab.subtabs) do
        local snowexec = snow[v.mode]

        v.mode = v.submode

        if type(snowexec) == 'function' then
            flag, e = pcall(snowexec, v)
            
            if not flag then
                error(e, 2)
            elseif tonumber(e) and e ~= 0 then
                return e
            end
        else
            error(v.mode..' is not a valid command', 2)
        end
    end
end

-- iterate through command line arguments
-- to get desired information
function snow.loadargs()
    local i = 1

    while i <= #arg do

        if i == 1 then
            SNOW_MODE = arg[i]

        elseif arg[i] == '@' then
            i = i + 1
            SNOW_TAB = arg[i]
        elseif arg[i] == '$' then
            i = i + 1
            SNOW_RC = arg[i]
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
