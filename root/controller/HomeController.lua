import "System"
import "System.Web"

struct "Person" { Name = String, Age = Number}
struct "Persons" { Person }

class "HomeController" { Controller }

__HttpMethod__()
function HomeController:Index()
	local Data = {
		Person("Ann", 12),
		Person("King", 32),
		Person("July", 22),
		Person("Sam", 30),
	}

	return self:View("/view/homepage.view", { Data = Data })
end

__HttpMethod__ "Get" "Json"
function HomeController:GetJson()
	local data = {
		Person("Ann", 12),
		Person("King", 32),
		Person("July", 22),
		Person("Sam", 30),
	}

	return self:Json(data)
end

__HttpMethod__()
function HomeController:Url()
	return self:Text(self.Context.Request.Url)
end