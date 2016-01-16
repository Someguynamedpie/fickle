local decoder = class( "OggVorbisDecoder", AudioDecoder )

--decode next chunk
function decoder:decode() return -1 end

--return the buffer, size decoded; assume changes after each call to decode
function decoder:getBuffer() return nil, -1 end
--seek to position in secs
function decoder:seek(seconds) return false end
--return false if cant seek to start
function decoder:rewind() return false end
--true if can seek
function decoder:isSeekable() return false end
--whether or not theres more data
function decoder:isDone() return false end
--channel count, 0 for errors, 1 for mono, 2 for stereo
function decoder:getChannels() return 0 end
--bit depth, 8/16 supported
function decoder:getBits() return 0 end
--samples/s
function decoder:getSampleRate() return 0 end