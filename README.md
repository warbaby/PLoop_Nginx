PLoop_Nginx
====

**PLoop_Nginx** is a web framework for [nginx][] server with [ngx_lua][] module.

It's an implement for the [PLoop_Web][] which provides features like page rendering, session & cookie management, MVC supporting and etc. The **PLoop_Nginx** module is used as the middleware between the [PLoop_Web][] and the [ngx_lua][].

The System only support UTF-8 for now.


Install
====

1. First You should follow the installation in [ngx_lua][].

2. Use `git clone https://github.com/kurapica/PLoop_Ngzinx.git` clone the project to your disk, the project has added the [PLoop][] and [PLoop_Web][] as sub modules. So, if you download it directly, you should also download the [PLoop][] and [PLoop_Web][], then extract them into the PLoop_Nginx.

2. Using `./nginx -p /path to the the ploop_nginx/` to start server, use the browser open `http://localhost/index.lsp`, you'll see a test page if all works fine.


Server Life Cycle
====

* Init - use `init_by_lua_file` directive to load the framework from the [PLoop][], [PLoop_Web][] and **PLoop_NgxLua** modules, also with other custom modules like data modules.

* Service - use `content_by_lua` directive to create a http context object and process the request, this is the entry point for the web framework.

	* When the context object started the process of the request, first it'll check the registered routes to find which one will be used to handle the request.

	* If there is one route match the request's url, it'll be mapped to a content file's path, the file can be a mixed page file like *index.lsp*, or a controller like *homecontroller.lua*, also can be static files like *index.js*, *global.css*. Those files are called resource files, don't like the web framework, those resource files won't be loaded until they are accessed.

	* In the resource system, resource loaders can be registered to files with specific suffix. Those loaders are used to convert those files to an enum, struct, interface, class or an object. The result would be cached so there is no need to reload those resouce files, you also can set `System.Web.DebugMode=true` to force reload the resource file if it's modified.

	* If the result of loading the resource file is a class that extend `System.Web.IContextHandler`, its object would be used to generate response for the request, or else the 404 would be send back. The lua server page like *index.lsp* and controller file like *homecontroller.lua* are all classes that extend `System.Web.IContextHandler`, so request those files would generate the response.

	* The actual request process are more complex. You can find details in [PLoop_Web][].


* There are no stop phase since there is no directive to register a handler for the worker's exiting. But you may add a context handler in the *config.lua* to check if the worker is exiting like :

		IContextHandler {
			ProcessPhase = ContextProcessPhase.InitProcess,

			Process = function(self, context)
				if ngx.worker.exiting() then
					-- The worker is exiting when Nginx server quit or configuration reload
					-- do something
				end
			end,
		}


Page Rendering
====

By using the [PLoop_Web][], an useful page rendering sytem can be used to create content files, it provides support for mixed lua-html page files, master page and other features.

Here is an example of a lua server page :

	@{ session=true } -- Page directive

	@{
		-- Lua codes
		local function rollDice(num, max, add)
			add = add or 0
			for i = 1, num do add = add + math.random(max) end
			return add
		end
	}

	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>PLoop_Web Test Page</title>
		</head>
		<body>
			@-- This line is a comment
			@-- if an expression is applyed after '@', it would be used as output
			<p> Session ID : @self.Context.Session.SessionID </p>
			@-- if the line after @ started with keywords, if would be a line of lua statement
			@ local rollResult = rollDice(3, 6, 5)
			<p> roll dice 3d6+5 is @rollResult </p>
			<p> roll dice 2d6+3 is @rollDice(2 6, 3) </p>
		</body>
	</html>

The result would be :

	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>PLoop_Web Test Page</title>
		</head>
		<body>
			<p> Session ID : 645775C9-2881-DF0D-43B3-1FBF04FFA2F1 </p>
			<p> roll dice 3d6+5 is 19 </p>
			<p> roll dice 2d6+3 is 11 </p>
		</body>
	</html>

A page file can use another page file as master page(it's a simple inheirt), so we can build pages like :

1. *globalmaster.master* - A master page can't be used to generate response, but can be used as other page's master page.

		<html xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<title>@{title My test site}</title>
				@{head}
			</head>
			<body>
				@{body}
			</body>
		</html>

2. *rootmaster.master* - use globalmaster.master as master page with several part for head web part.

		@{ master = "globalmaster.master" }

		@{
			local function appendVerSfx(path, suffix, version)
				return path .. suffix .. (version and "?v=" .. tostring(version) or "")
			end
		}

		@javascript(name, version) {
			<script type="text/javascript" src="/js/@appendVerSfx(name, '.js', version)"></script>
		}

		@css(name, version) {
			<link rel="stylesheet" type="text/css" href="/css/@appendVerSfx(name, '.css', version)" />
		}

		@ head {
			@{csspart}
			@{jspart}
		}

3. *root.lsp* - A lua server page is used to generate response.

		@{ master = "rootmaster.master" }

		@ csspart {
			@{ css("global") }
		}

		@jspart{
			@{ javascript("jquery-2.1.4.min") }
			@{ javascript("global", 3) }
		}

4. *index.lsp* - A lua server page can also use another lua server page as master page.

		@{ master = "root.lsp" }

		@ title {
			My web site
		}

		@ body {
			<p> here is a test message. </p>
		}

So the reponse of *index.lsp* should be :

	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			<title>My web site</title>
			<link rel="stylesheet" type="text/css" href="/css/global.css" />
			<script type="text/javascript" src="/js/jquery-2.1.4.min.js"></script>
			<script type="text/javascript" src="/js/index.js?v=3"></script>
		</head>
		<body>
			<p> here is a test message. </p>
		</body>
	</html>


You can find more information in [PLoop_Web][].


MVC Example
====

For now, the module part are still under developing. Here is an example for a controller :

	import "System.Web"

	-- Define a controller inheirted from the System.Web.Controller
	class "HomeController" { Controller }

	-- function used to generate the data
	local function getData(self)
		return {
			{ Name = "Ann", Age = 12 },
			{ Name = "King", Age = 32 },
			{ Name = "July", Age = 22 },
			{ Name = "Sam", Age = 30 },
		}
	end

	-- Define an action hander for [HTTPMETHOD-GET] /home/json
	__HttpMethod__ "Get" "Json"
	function HomeController:GetJson(context)
		-- The reponse should be a json format data.
		return self:Json( getData(self) )
	end

	-- Define an action handler for [HTTPMETHOD-ANY] /home/index
	__HttpMethod__()
	function HomeController:Index(context)
		-- Use the view to generate content with datas
		-- Create a view is just like to create a lua server page
		return self:View("/view/homepage.view", { Data = getData(self) })
	end

You can find more information in [PLoop_Web][].


Get Request arguments
====

The context object has a *Request* property, we can get the request's parameters from it. So for a request like `GET /index.lsp?user=Ann&id=12321`, we can handle it like

	@{ master = "root.lsp" }

	@ {
		local user, id

		-- The OnLoad method would be called before sending out the reponse's head
		-- So we can do checking arguments and generate datas in here
		function OnLoad(self, context)
			user = context.Request.QueryString["user"]
			id = context.Request.QueryString["id"]
		end
	}

	@ body {
		User : @user <br>
		ID : @id
	}

If the request is `POST /index.lsp`, we can handle it like

	@{ master = "root.lsp" }

	@ {
		-- If you need keep the OnLoad method in a lua file to seperate the view and controller,
		-- Don't define the local variables, the two file are definitions of part classes, they don't
		-- share local variables, just use self as container to transport those datas.
		local user, id

		-- The OnLoad method would be called before sending out the reponse's head
		-- So we can do checking arguments and generate datas in here
		function OnLoad(self, context)
			user = context.Request.Form["user"]
			id = context.Request.Form["id"]
		end
	}

	@ body {
		User : @user <br>
		ID : @id
	}


Redirect
====

The url redirect must be done before sending the response head, so we can do it in a lua server page's *OnLoad* method or a controller's action, here is two examples for them :

* Lua server page

		@{ master = "root.lsp" }

		@ {
			function OnLoad(self, context)
				if not context.Request.QueryString["user"] then
					context.Response:Redirect("/err.lsp?reason=no_user")
				end
			end
		}

* Controller

		import "System.Web"

		class "HomeController" { Controller }

		-- Define an action hander for [HTTPMETHOD-GET] /home/json
		__HttpMethod__ "Get"
		function HomeController:Update(context)
			-- the action don't handle the get method
			return context.Response:Redirect("/err.lsp?reason=get_not_suport")
		end


Directory Structure
====

* [PLoop][] - The required lua module, used to provide the oop system.
* [PLoop_Web][] - The required lua module, used to provide the web framework.
* **PLoop_NgxLua** - The middleware for [PLoop_Web][] and [ngx_lua][]
	* *init.lua*
	* *HttpFiles.lua*
	* *HttpRequest.lua*
	* *HttpResponse.lua*
	* *HttpContext.lua*
* **conf** - The config files for [nginx][] and the web framework.
	* *nginx.conf*
	* *config.lua*
* **html** - The content folder for the web site
	* **static** - Static files like js, css and images.
		* **js**
			* *jquery-2.1.4.min.js*
			* *index.js*
	* **share** - The shared features for other pages
		* *globalmaster.lua*
		* *globalmaster.master*
		* *globalmethod.helper*
	* **controller** - The MVC's controllers
		* *homecontroller.lua*
	* **view** - The MVC's views
		* *homepage.view*
	* *index.lsp* - A lua server page used for test.
	* *index.lua* - A code file for index.lsp
	* *description.embed* - An embed page file


Configuration
====

There are two config file for the nginx example :

* nginx.conf - the config file for the nginx server, the most important parts in it are :

	* lua_package_path - `${prefix}?.lua;${prefix}?/init.lua` is used to make sure lua modules contained in the **PLoop_Nginx** can be loaded.

	* init_by_lua_file - `./conf/config.lua`, this is a directive of the ngx_lua, used to load the lua config file when the server is started.

	* location / { root html; } - So the *html* folder is used as the content directory, you may change it if you want another name.

	* content_by_lua - `' NgxLua.HttpContext():ProcessRequest() '`, *NgxLua.HttpContext* is used to create a http context for each http request, the context is used to start the request's process, this is the start point for the **PLoop_Web** system.

* config.lua - In the config file, we'll load lua modules, init the session management, create routers and some context handlers.

	You can find more information about it in [PLoop_Web][].








[nginx]: https://www.nginx.com/ "Nginx"
[ngx_lua]: https://github.com/openresty/lua-nginx-module/ "Openresty"
[PLoop]: https://github.com/kurapica/PLoop/ "Pure Lua Object-Oriented Program"
[PLoop_Web]: https://github.com/kurapica/PLoop_Web/ "PLoop Web Framework"