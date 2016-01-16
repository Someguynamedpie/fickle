local panel = class( 'gui.MenuItem', 'gui.Button' )
function panel:onmouseup()
	gui.onnonmenuclick()
	if self.callback then self.callback() end
end
return panel