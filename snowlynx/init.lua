--
-- snowlynx/init.lua
--
-- BSD 3-Clause License
--
-- Copyright (c) 2022, Christopher Stephen Rafuse
-- All rights reserved.
--
-- See LICENSE for details
--

snow        = require('snowlynx.snowfunc')
snow.Tab    = require('snowlynx.snowtab')
snow.Object = require('snowlynx.nclassic')

snow.Multi   = snow.Tab:extend('MultiTab')
snow.Install = snow.Tab:extend('InstallTab')
snow.Remove  = snow.Tab:extend('RemoveTab')

function snow.Multi:new(...)
    self:fields(self.super({ mode = 'multiple' }, ...))
end

function snow.Install:new(manifest, ...)
    local inp = {...}

    if type(manifest) == 'table' then 
        self.manifest = '.snowman'
        table.insert(inp, 1, manifest)
        self:fields(self.super({ mode = 'install', submode = 'multiple' }, inp))

    elseif type(manifest) == 'string' then
        self.manifest = manifest
        self:fields(self.super({ mode = 'install', submode = 'multiple' }, inp))
    end
end

function snow.Remove:new(manifest)
    self:fields(self.super({}))
    self.mode      = 'remove'
    self.manifest  = manifest or '.snowman'
end

snow.exe    = 'exe'
snow.pic    = 'pic'
snow.shared = 'shared'
snow.cmp    = 'cmp'
snow.multi  = 'multiple'
snow.bin    = 'bin'
snow.lib    = 'lib'
snow.inc    = 'inc'
snow.cmd    = {
    install = 'install',
    remove  = 'remove',
    build   = 'build',
    multi   = 'multiple'
}
