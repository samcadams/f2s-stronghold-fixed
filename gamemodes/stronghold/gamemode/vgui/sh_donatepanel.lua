--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self.Donate = vgui.Create( "HTML", self )
	--self.Donate:OpenURL( "http://www.roaringcow.com/Donate.php" )
end

function PANEL:PerformLayout( w, h )
	self.Donate:SetSize( w, h )
	self.Donate:SetPos( 0, 0 )
end

vgui.Register( "sh_donatepanel", PANEL, "Panel" )