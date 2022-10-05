local Object = require('snowlynx.nclassic')
local snow = Object:extend()

function snow.version()
    return '1.4'
end

function snow.isrelease()
    return false
end

snow.HelpTab = Object:extend("HelpTab")

function snow.HelpTab:add(name, proc) 
    self[name] = proc; 
end

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

snow.HelpTab['snow.exe'] = function (self) print(self.descreption['snow.exe']); end

snow.HelpTab['snow.cmp'] = function (self) print(self.description['snow.cmp']); end

snow.HelpTab['snow.pic'] = function (self) print(self.description['snow.pic']); end

snow.HelpTab['snow.shared'] = function (self) print(self.description['snow.shared']); end

snow.HelpTab['snow.multi'] = function (self) print(self.description['snow.multi']); end

function snow.help(opt)
    opt = opt or false
    if not opt then
        snow.printf("SnowLynx-%s Help", snow.version())
        snow.printf("snow [command] [@ .snowtab] [$ .snowrc]")
        snow.printf("\tsnow build\n\tsnow install\n\tsnow remove\n\tsnow help [option] snow (same as snow build)")
    else
        snowexec = snow.HelpTab[opt]

        if snowexec ~= nil and type(snowexec) == 'function' then
            snowexec(HelpTab)
        else
            error(string.format('%s not in helptab'))
        end
    end
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
        return os.execute(string.format('sudo rm %s', target))
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
