--=============================
-- NgxLua.HttpRequest
--
-- Author : Kurapica
-- Create Date : 2015/10/22
--=============================

_ENV = Module "NgxLua.HttpRequest" "1.0.0"

class "HttpRequest" (function (_ENV)
	inherit (System.Web.HttpRequest)

	local function strtrim(s)
		return s and (s:gsub("^%s*(.-)%s*$", "%1")) or ""
	end

	property "ContentLength" { Set = false, Default = function() return ngx.var.content_length end }

	property "ContentType" { Set = false, Default = function () return ngx.var.content_type end }

	property "Cookies" { Set = false, Default = function()
			local cookies = {}
    		local _cookie = ngx.var.http_cookie

    		if _cookie then
    			_cookie:gsub("([^;=]*)=([^;]*)", function(key, value)
    				key = strtrim(key)
    				value = strtrim(value)
    				if key ~= "" then cookies[key] = value end
    			end)
    		end

    		return cookies
		end
	}

	property "Form" { Set = false, Default = function() ngx.req.read_body() return ngx.req.get_post_args() or {} end }

	property "HttpMethod" { Set = false, Default = function() return HttpMethod[ngx.var.request_method] end }

	property "IsSecureConnection" { Set = false, Default = function() return ngx.var.https == "on" end }

	property "QueryString" { Set = false, Default = function() return ngx.req.get_uri_args() or {} end }

	property "RawUrl" { Set = false, Default = function () return ngx.var.request_uri end }

	property "Root" { Set = false, Default = function() return ngx.var.realpath_root end }

	property "Url" { Set = false, Default = function () return ngx.var.uri end }
end)