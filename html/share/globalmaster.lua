import "System"

class "globalmaster" {
	PageTitle = { Type = String, Default = "MASTER" }
}

function globalmaster:OnLoad()
	self.PageTitle = "My web site"
end

