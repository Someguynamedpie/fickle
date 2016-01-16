local enet = require'lib.enet'
require( 'net' )
local fs = require( 'filesystem' )

local M = {}

-- uses regex
M.whitelist = {
    -- Matches maps/giddyup.dmm maps/blah/reallycoolmap.dmm
    -- Also matchs maps/asdf.dll[200 spaces].dmm which is a biiiig FIXME
    "^maps/.-%.dmm$",
    -- Matches sound/honk.ogg sound/sound/effects/gib.ogg
    -- Only allows ogg files, or at least only allows files named like ogg.
    "^sound/.-%.ogg$",
    -- Matches any of the following obvious image types
    "^textures/.-%.(jpg|bmp|png|jpeg|dmi)$",
}

-- in bytes
M.fragmentsize = 512
-- in megabytes
M.uploadLimit = .5
-- 0 is unlimited
M.downloadLimit = 0

M.currentFile = nil

M.queue = {}

M.processQueue = function( self )
    for i,v in pairs( self.queue ) do
        -- Ask the server to start uploading the file to us.
        self.currentFile = v
        net.sendToServer( C2S_filehandshake, {path = v.path} )
        -- Wait until we're done downloading..
        while( v.downloaded < v.size ) do
            print( "Downloading ", v.path, "...", ( v.downloaded/v.size ) * 100, "%" )
            sleep( 1 )
        end
        -- Write file to disk
        -- ???
        -- and we're done!
        self.currentFile = nil
    end
end

filetransfer = M

net.definePacket( "S2C_filehandshake", {{'path', NET_STRING}, {'size', NET_INT}}, function( data, buffer )
    if M.queue[path] ~= nil then
        error( "Duplicate file handshake" )
    end
    local file = { path = data.path, size = data.size, downloaded = 0, data = nil }
    -- check if the file is within whitelist.
    local allowed = false
    for i,v in pairs( filetransfer.whitelist ) do
        if string.match( file.path, v ) ~= nil then
            allowed = true
        end
    end
    if not allowed then return end
    -- If we already have the file don't do anything..
    if fs.exists( path ) then return end
    -- Slap the file onto the queue to be downloaded later
    filetransfer.queue[path] = file
end, nil, true )

net.definePacket( "C2S_filehandshake", {{'path', NET_STRING}}, function( data, buffer )
    -- begin asyncronous file upload to whichever client
end, nil, true )

net.definePacket( "S2C_filedata", {{'data', NET_STRING}}, function( data, buffer )
    -- FIXME: This can be exploited to crash clients easily
    if not filetransfer.currentFile then error( "Got filedata without handshake!" ) end
    -- Enet ensures we get all the packets, and that we
    -- get them in the correct order.
    -- buffer:WriteBytes( filetransfer.currentFile.data ) ????
    -- filetransfer.currentFile.downloaded += buffer:CountBytes()
end, nil, true )
