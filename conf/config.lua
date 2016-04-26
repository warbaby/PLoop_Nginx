require "PLoop_NgxLua"

import "System.Web"

--=============================
-- NameSpace
--=============================
namespace "MyWeb"

--=============================
-- Web Settings
--=============================
System.Web.DebugMode = true

System.Web.IOutputLoader.DefaultRenderConfig.noindent = false
System.Web.IOutputLoader.DefaultRenderConfig.nolinebreak = false

System.Logger.DefaultLogger.LogLevel = System.LogLevel.Debug

--=============================
-- Session Settings
--=============================
-- Storage
TableSessionStorageProvider()

-- Session ID Manager
GuidSessionIDManager { CookieName = "MyWebSessionID", TimeOutMinutes = 10 }

--=============================
-- Route
--=============================
--- Bind a context handler to an url
Route("/testhandler",
	IContextHandler(function(self, context, phase)
		if phase == ContextProcessPhase.GenerateHead then
			context.Response.ContentType = "text/plain"
		else
			context.Response.Write("This is only a test for binding handler to an url")
		end
	end)
)

--- MVC route
Route("/mvc/{Controller?}/{Action?}/{Id?}",
	function (request, controller, action, id)
		controller = controller ~= "" and controller or "home"
		action = action ~= "" and action or "index"
		return ('/controller/%scontroller.lua'):format(controller), {Action = action, Id = id}
	end
)

--- Direct map
Route(".*.lsp", "r=>r.Url")
