--=============================
-- NgxLua
--
-- Author : Kurapica
-- Create Date : 2015/10/22
--=============================
require "PLoop_Web"

_ENV = Module "NgxLua" "1.0.0"

namespace "NgxLua"

import "System"
import "System.Web"

-- Loading modules
require "PLoop_NgxLua.HttpRequest"
require "PLoop_NgxLua.HttpResponse"
require "PLoop_NgxLua.HttpContext"

-- Log
System.Logger.DefaultLogger:AddHandler("t=>ngx.log(ngx.CRIT,t)", System.LogLevel.Fatal)
System.Logger.DefaultLogger:AddHandler("t=>ngx.log(ngx.ERR,t)", System.LogLevel.Error)
System.Logger.DefaultLogger:AddHandler("t=>ngx.log(ngx.WARN,t)", System.LogLevel.Warn)
System.Logger.DefaultLogger:AddHandler("t=>ngx.log(ngx.NOTICE,t)", System.LogLevel.Info)
System.Logger.DefaultLogger:AddHandler("t=>ngx.log(ngx.INFO,t)", System.LogLevel.Debug)
System.Logger.DefaultLogger:AddHandler("t=>ngx.log(ngx.DEBUG,t)", System.LogLevel.Trace)

-- Useful handlers
IContextHandler { ProcessPhase = ContextProcessPhase.HeadGenerated,
	Process = function(self, context)
		local cookies = context.Response.Cookies
		if next(cookies) then
			local cache = {}
			local cnt = 1
			for name, cookie in pairs(cookies) do
				cache[cnt] = tostring(cookie)
				cnt = cnt + 1
			end
			ngx.header['Set-Cookie'] = cache
		end
	end,
}