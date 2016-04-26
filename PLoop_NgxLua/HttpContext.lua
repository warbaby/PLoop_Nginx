--=============================
-- NgxLua.HttpContext
--
-- Author : Kurapica
-- Create Date : 2015/10/22
--=============================

_ENV = Module "NgxLua.HttpContext" "1.0.0"

class "HttpContext" (function (_ENV)
	inherit (System.Web.HttpContext)

	property "Request" { Set = false, Default = function () return HttpRequest() end }

	property "Response" { Set = false, Default = function () return HttpResponse() end }
end)