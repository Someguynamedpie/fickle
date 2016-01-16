local baseeffect = class( "BaseAudioEffect" )
baseeffect.stopOnComplete = false
baseeffect.neverending = false
function baseeffect:update( source )
	if self.delay then
		if sdl.GetTicks() > self.delay then
			self.delay = nil
			self.startTime = sdl.GetTicks()
			self.finishTime = self.startTime + self.duration
		else return end
	end
	if self.finishTime < sdl.GetTicks() and not self.neverending then
		
		self:onfinish( source )
		if self.callback then self.callback() end
		if self.stopOnComplete then
			source:setGain(0)
			source:removeEffect( self )
		else
			source:removeEffect( self )
		end
	elseif not self.firstRan then
		self.firstRan = true
		self:firstRun( source )
	else self:run( source ) end
end
function baseeffect:onfinish( source ) end
function baseeffect:run( source ) end
function baseeffect:firstRun( source ) end
function baseeffect:getFraction()
	return 1 - (self.finishTime - sdl.GetTicks()) / self.duration
end
function baseeffect:initialize( duration, callback, delay )
	self.delay = sdl.GetTicks() + (delay or 0)*1000
	self.duration = duration * 1000
	self.callback = callback
end

FadeOutAudioEffect = class( "FadeOutAudioEffect", baseeffect )

FadeOutAudioEffect.stopOnComplete = true
function FadeOutAudioEffect:run( source )
	source:setGain( self.startGain * (1 - self:getFraction()) )
end
function FadeOutAudioEffect:onfinish( source )
	source:setGain( self.startGain )
end
function FadeOutAudioEffect:firstRun( source )
	self.startGain = 1--source:getGain()
end

FadeInAudioEffect = class( "FadeInAudioEffect", baseeffect )

FadeInAudioEffect.stopOnComplete = false
function FadeInAudioEffect:run( source )
	source:setGain( self.startGain * (self:getFraction()) )
end
function FadeInAudioEffect:firstRun( source )
	self.startGain = 1--source:getGain()
end

