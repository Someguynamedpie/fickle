local class = require( "middleclass" )

BaseEntity = class( "BaseEntity" )
local ENT = BaseEntity

ENT_NETWORKED = 1--sent to clients based on PVS
ENT_UNNETWORKED = 2--not sent to clients
ENT_BROADCAST = 3--networked regardless of PVS

ENT.Type = ""--Accepted: POINT for entities without icons or anything, ANIM for entities that can move and are visible

function ENT:tick()
	self:SetNextThink( CurTime() + 0.1 )
	self:Think()
end

function ENT:Think() end
function ENT:SetPos( x, y )
	self:dtSet( "x", x )
	self:dtSet( "y", y )
end
function ENT:SetVelocity( vX, vY )
	self:dtSet( "velX", vX )
	self:dtSet( "velY", vY )
end

ENT.nettype = ENT_NETWORKED
