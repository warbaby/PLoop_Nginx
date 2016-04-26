--=============================
-- NgxLua.HttpResponse
--
-- Author : Kurapica
-- Create Date : 2015/10/22
--=============================

_ENV = Module "NgxLua.HttpResponse" "1.0.0"

import "System.Text"

class "HttpResponse" (function (_ENV)
	inherit (System.Web.HttpResponse)

	local BUFF_SIZE = 4096

	property "ContentType" { Type = String, Handler = function (self, value) ngx.header.content_type = value end }

	property "RedirectLocation" { Handler = function (self, value) ngx.header.location = value end }

	property "Write" { Set = false , Default = function (self)
		local cache = {}
		local index = 1
		local length = 0

		-- Register for finish
		self._Cache = cache

		return function (text)
			if text then
				cache[index] = text
				length = length + #text
				if length >= BUFF_SIZE then
					-- Send out the buff
					ngx.print(cache)
					ngx.flush()

					-- Use a new buff
					cache = {}
					index = 1
					length = 0
					self._Cache = cache
				else
					index = index + 1
				end
			end
		end
	end }

	property "StatusCode" { Type = HTTP_STATUS, Handler = function (self, value) ngx.status = value end }

	function Close(self)
		if self._Cache and self._Cache[1] then ngx.print(self._Cache) ngx.flush() end
		return ngx.eof()
	end
end)