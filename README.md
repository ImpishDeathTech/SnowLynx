# SnowLynx
A lua-based build system (akin to make/cmake/scons)

I work with lua a lot, so I figured why not write a build system scripted in it?

for now, it is written completely in lua, but may be rewritten in c++ depending on how efficient that is

in comparison

## .snowrc and .snowtab
### A .snowrc looks something like [this](https://github.com/ImpishDeathTech/SnowLynx/blob/master/.snowrc)

use it to create new global variables, commands and modes like so
```lua
-- command example
function snow.commandname(snowtab)
  -- code
end

-- mode example
function snow.Tab:modename()
  -- code
end
```

### A .snowtab looks something like [this](https://github.com/ImpishDeathTech/SnowLynx/blob/master/example/.snowtab)
It is where we define our build table

Several options are available by default:
```lua
function snow.Tab:new(tab, ...)
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
```
## Commands 
snow is used from command line like so

`snow [command] [optionals]`

the optional values can be used to choose a specific .snowrc and .snowtab

`snow build @ data/.snowtab $ data/.snowrc`

`@` for .snowtab

`$` for .snowrc

### Default Command List
```sh
snow build
snow install
snow remove
snow help [option]
snow (same as snow build)
```

### Default Mode List
```lua
snow.exe
snow.cmp
snow.pic
snow.shared
snow.multi
```
### [An example can be found here to show usage](https://github.com/ImpishDeathTech/SnowLynx/tree/master/example)
