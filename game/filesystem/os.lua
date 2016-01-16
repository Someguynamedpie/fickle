if( jit.os == "Windows" ) then return require'filesystem.windows' end
if( jit.os == "Linux" ) then return require'filesystem.linux' end