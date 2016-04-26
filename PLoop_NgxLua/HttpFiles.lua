--=============================
-- NgxLua.HttpFiles
--
-- Author : Kurapica
-- Create Date : 2016/04/24
--=============================

_ENV = Module "NgxLua.HttpFiles" "1.0.0"

import "System.Collections"

class "HttpFiles" (function (_ENV)
	extend "Iterable" "ICountable"

	-- The timeout of the cosocket in milliseconds
	property "Timeout" { Default = 1000, Type = Number,
		Handler = function(self, value)
			if self._HttpFiles_Sock then self._HttpFiles_Sock:settimeout(value) end
		end
	}

	property "Count" { Type = Number, Set = false, Field = "_HttpFiles_Count", Default = 0 }

	function HttpFiles(self)
		local header = ngx.var.content_type

		if not header then return end

		if type(header) == "table" then header = header[1] end

		local boundary = header:match(";%s*boundary=\"([^\"]+)\"") or
						header:match(";%s*boundary=([^\",;]+)")

		if not boundary then return end

		local sock = ngx.req.socket()
		if not sock then return end

		sock:settimeout(self.Timeout)

		local readboundary = sock:receiveuntil("--" .. boundary)
		if not readboundary then return	end

		local readline = sock:receiveuntil("\r\n")
		if not readline then return end

		self._HttpFiles_Sock = sock
	end
end)