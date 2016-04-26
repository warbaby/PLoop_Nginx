import "System"

class "master" {
	PageTitle = { Type = String, Default = "MASTER" }
}

function master:OnLoad()
	self.PageTitle = "My web site"
end

