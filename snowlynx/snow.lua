--
-- snow.lua
--
-- BSD 3-Clause License
--
-- Copyright (c) 2022, Christopher Stephen Rafuse
-- All rights reserved.
--
-- See LICENSE for details
--

require 'snowlynx'

function snow.run()
    -- set defaults:
    --      1. look for a local snowtab file
    --      2. set base mode to build
    --      3. set default snowrc to local directory
    --      4. for unix, default snowrc is also in /usr/share/snowlynx
    SNOW_TAB   = './.snowtab'
    SNOW_MODE  = 'build'
    SNOW_RC    = './.snowrc'
    SNOW_DEFRC = '/usr/share/snowlynx/.snowrc'

    -- load cli arguments and run configuration
    -- if it can't find the specified rc or a local rc
    -- it will load the default rc in /usr/share/snowlynx
    -- fuck off at any errors
    snow.loadargs()

    -- get HOME variable
    HOME   = snow.home()
    snowrc = false
    flag   = false
    e      = false

    -- load the rc, fuck off with an error if it fails
    flag, e = snow.loadrc()

    if flag then
        snowrc = e
    else
        snow.error(e, true)
    end


    flag, e = pcall(snowrc)

    if not flag then
        snow.error(e, true)
    end

    -- once the run configuration is loaded, print the watermark, and load the given snowtab
    -- the program will fuck off on an error if it fails to load this table
    print(snow.watermark())

    if SNOW_MODE == 'help' then
        if #arg == 2 then
            snow.help(arg[2])
        else
            snow.help()
        end
        
        os.exit(0)
    end

    input, e = loadfile(SNOW_TAB)

    if type(input) ~= 'function' then
        snow.error(e, true)
    else
        flag = false
        e    = false

        flag, e = pcall(input)

        if flag then
            local snowtab = e
            local snowexec = snow[SNOW_MODE]

            if type(snowexec) ~= 'function' then
                snow.error(SNOW_MODE..' is not a valid mode', true)
            else
                flag, e = pcall(snowexec, snowtab)

                if not flag then
                    snow.error(e, true)

                elseif tonumber(e) and e ~= 0 then
                    snow.errorf("SnowLynx: !ERROR! code %d", e)
                        os.exit(e)
                end
            end
        -- if the snowtab load does fail, the snow tab will be an error object
        -- so report that error
        else
            snow.error(e, true)
        end
    end

    print "Done ^,..,^"
end

function snow.repl()
    local args = {}

    for i = 2, #arg, 1 do
        table.insert(args, arg[i])
    end
    
    return os.execute(string.format('lua -i /usr/bin/snow %s'), table.concat(args, ' '))
end

