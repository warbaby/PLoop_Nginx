import "System"

struct "Person" { Name = String, Age = Number}
struct "Persons" { Person }

class "index" (function (_ENV)
	property "Data" { Type = Persons }

	function OnLoad(self)
		Super.OnLoad(self)

		self.Data = {
			Person("Ann", 12),
			Person("King", 32),
			Person("July", 22),
			Person("Sam", 30),
		}
	end
end)
