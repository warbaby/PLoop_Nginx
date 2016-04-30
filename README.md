PLoop_Nginx
====

**PLoop_Nginx** is a web framework for [nginx](https://www.nginx.com/) server with [ngx_lua](https://github.com/openresty/lua-nginx-module) module.

It's an implement for the [PLoop_Web](https://github.com/kurapica/PLoop_Web) which provides features like page rendering, session & cookie management, MVC supporting and etc. The **PLoop_Nginx** module is used as the middleware between the [PLoop_Web](https://github.com/kurapica/PLoop_Web) and the [ngx_lua](https://github.com/openresty/lua-nginx-module).

The System only support UTF-8 for now.


Install
====

1. First You should follow the installation in [ngx_lua](https://github.com/openresty/lua-nginx-module#installation).

2. Use `git clone https://github.com/kurapica/PLoop_Nginx.git` clone the project to your disk, the project has added the [PLoop](https://github.com/kurapica/PLoop) and [PLoop_Web](https://github.com/kurapica/PLoop_Web) as sub modules. So, if you download it directly, you should also download the [PLoop](https://github.com/kurapica/PLoop) and [PLoop_Web](https://github.com/kurapica/PLoop_Web), then extract them into the PLoop_Nginx.

2. Using `./nginx -p /path to the the ploop_nginx/` to start server, use the browser open `http://localhost/index.lsp`, you'll see a test page if all works fine.


Page Rendering
====

By using the [PLoop_Web](https://github.com/kurapica/PLoop_Web), an useful page rendering sytem can used for content files, it provides support for mixed lua-html page files, master page and other features.

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

		@{ master = globalmaster.master }

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

		@{ master = rootmaster.master }

		@ csspart {
			@{ css("global") }
		}

		@jspart{
			@{ javascript("jquery-2.1.4.min") }
			@{ javascript("global", 3) }
		}

4. *index.lsp* - A lua server page can also use another lua server page as master page.

		@{ master = root.lsp }

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


You can find more information in [PLoop_Web](https://github.com/kurapica/PLoop_Web).


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
	function HomeController:GetJson()
		-- The reponse should be a json format data.
		return self:Json( getData(self) )
	end

	-- Define an action handler for [HTTPMETHOD-ANY] /home/index
	__HttpMethod__()
	function HomeController:Index()
		-- Use the view to generate content with datas
		return self:View("/view/homepage.view", { Data = getData(self) })
	end

You can find more information in [PLoop_Web](https://github.com/kurapica/PLoop_Web).


Directory Structure
====

* [PLoop](https://github.com/kurapica/PLoop) - The required lua module, used to provide the oop system.
* [PLoop_Web](https://github.com/kurapica/PLoop_Web) - The required lua module, used to provide the web framework.
* **PLoop_NgxLua** - The middleware for [PLoop_Web](https://github.com/kurapica/PLoop_Web) and [ngx_lua](https://github.com/openresty/lua-nginx-module)
	* *init.lua*
	* *HttpFiles.lua*
	* *HttpRequest.lua*
	* *HttpResponse.lua*
	* *HttpContext.lua*
* **conf** - The config files for [nginx](https://www.nginx.com/) and the web framework.
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

	* `require "PLoop_NgxLua"` - The **Ploop_NgxLua** will load the **PLoop_Web**, and the **PLoop_Web** would load the **PLoop**, so you only need require **PLoop_NgxLua** to install all modules.

	* `namespace "MyWeb"` - Define a namespace for the _G, any features that loaded from the content files like *index.lsp* would be defined under the namespace *MyWeb*.

		The are many type features for the web development, lua server page used to generate output for response, master page used to provide layout for lua sever pages(the super class of the lua server pages), helper page used to provide useful method to help create the server pages(helper is loaded as interface for the lua server page to extend).

		Without a namespace, when reload a file, a new class or interface should be generated from the file, if the file is a master page, the lua server pages inherited from it must all be reloaded. If there is a namespace, reload the file will only update the existed class or interface, so any other files related to it will receive the updating without been reloaded.

	* `System.Web.DebugMode = true` - If the debug mode is turn on, the content files like *index.lsp* would be reloaded when modified, checking the last modified time of files would pay some cost, so you'd better turn off it when you deploy it.

		There is a major issue in the reload system. In the pure lua, there is no api to get a file's last writed time, but by using `io.popen`, we can call shell command and read its output, so we can get a file's last writed time by using shell commands like dir, ls and etc.

		But there is one problem for it, the shell commands are different in each operation systems, for now, the PLoop only provide support for dos, macosx(uname return 'Darwin') and some linux system(uname return 'Linux').

		If you find the reload system won't work, or you can try to write an expression to the client :

				<p>OS: @System.IO.OSType(System.IO.GetOperationSystem()) </p>

		If the output is Unknown, it's means the PLoop don't know how to handle the commands in your OS.

		In this condition, you may contact me with information about your system so I can add support in the PLoop lib, or you can using some 3rd lua modules to provide a function to retrieve the file's last modified time, and assign it to the *System.Resource* in the *config.lua* like :

				System.Resource.GetLastWriteTime = func

	* `System.Web.IOutputLoader.DefaultRenderConfig` - You may change the *index.lsp* file content like :

			@{ noindent=true, nolinebreak=true }
			<html>
				<head>
				</head>
				<body>
				</body>
			</html>

		The reponse output would be :

			<html><head></head><body></body></html>

		The *System.Web.IOutputLoader* is the root resource loader of the web system, it add a special rule for those content files : if the first line of the file contains one lua table, it would be loaded as the page's config.

		The page's config may contains several settings :

		* namespace - The namespace of the page like 'MyWeb.Common'.

		* master - The master (super class page) of the page like '/share/mainmaster.master' .

		* helper - The helper (extend interface page) of the page, like '/share/globalhelper.helper', if there are several helpers, seperated them with ',' .

		* code - The lua code file, it'll combine the page to create the result type.

		* context - Whether the page extend IHttpContext, if true, the page can access context properties directly like `self.Request`, if false, the page can only access context properties like `self.Context.Request`.

		* session - Whether the page require Session, if true, the page can access the `self.Context.Session` to control the session, if false, `self.Context.Session` will just return nil, so the session would not be created in current context processing.

		* reload - hether reload the file when modified in non-debug mode

		* encode - Whether auto encode the output with HtmlEncode(only for expressions)

		* noindent - Whether discard the indent of the output. The operation is done when loading the file to a result type, not its objects are used to generate output for response.

		* nolinebreak - Whether discard the line breaks of the output. The operation is done when loading the file to a result type, not its objects are used to generate output for response.

		* linebreak - The line break chars. Default '\n' .

		* engine - The render engine of the output page. A render engine is used to generate class or interface's definition based on the file's content. It also provide rules to help developers to create template files more easily. For now, the lua server page, master page, helper are all using *System.Web.PageRenderEngine*, so you can use things like `@data.Name`. And the static files like js, css are using a static render engine. Normally you don't need to set it.

		* asclass - The target resource's type, whether the content file should be a class. Default true. You also shouldn't touch it.

		When the page's config is loaded, it'd be converted to *System.Web.RenderConfig*'s object. A *RenderConfig* object could set a default *RenderConfig* object, so it will use the default object's settings if it don't have one.

		For a lua server page, it's config's default config should be *System.Web.LuaServerPageLoader.DefaultRenderConfig*, and the *LuaServerPageLoader.DefaultRenderConfig*'s default config should be *PageLoader.DefaultRenderConfig*, and its default config should be *IOutputLoader.DefaultRenderConfig*. So, it's a config chain to keep settings more organizable.

		Here is a tree map for the config chain :

		* IOutputLoader.DefaultRenderConfig
			* PageLoader.DefaultRenderConfig
				* MasterPageLoader.DefaultRenderConfig
					* master page's config
				* EmbedPageLoader.DefaultRenderConfig
					* embed page's config
				* HelperPageLoader.DefaultRenderConfig
					* helper page's config
				* LuaServerPageLoader.DefaultRenderConfig
					* lua server page's config
			* StaticFileLoader.DefaultRenderConfig
				* JavaScriptLoader.DefaultRenderConfig
					* javascript file's config, something like `//{noindent=true}`
				* CssLoader.DefaultRenderConfig
					* css file's config, something like `/*{noindent=true}*/`

		So, if we need the give all generated types a same namespace, we can set it like :

			System.Web.IOutputLoader.DefaultRenderConfig.namespace = "MyWebSite.Pages"

		And if we need all lua server pages use the same master page :

			System.Web.LuaServerPageLoader.DefaultRenderConfig.master = "/share/globalmaster.master"

		The page still can use page config to override these settings like :

			@{ master = "/share/anothermaster.master" }

		We'll see more details like how to create custom file type and render engine in the [[Resource Loader|resource_loader]] part.

	* Logger settings - You may find more information about the log system in [System.Logger](https://github.com/kurapica/PLoop/wiki/logger). You only need to modify the log level in the *config.lua*.

			-- You may change the LogLevel to filter the messages
			System.Logger.DefaultLogger.LogLevel = System.LogLevel.Debug

	* Session settings - We need two things to setup the session management :

		* ISessionIDManager - Used to retrieve session id from the request or create a session id and save it to the response(like cookie).

		* ISessionStorageProvider - A session will have an *Item* property used to contain serializable values. ISessionStorageProvider will be used to create, save, load those items for a session id.

		Those two are interfaces, so we need to implement them.

			GuidSessionIDManager { CookieName = "MyWebSessionID", TimeOutMinutes = 10 }

		*GuidSessionIDManager* is used to create guid as session id and save them in the cookie with name *MyWebSessionID* and a time out.

			TableSessionStorageProvider()

		*TableSessionStorageProvider* is just use a in-memory table to manage the session items, it's very simple, and may only be used under web development.

		We'll see more about session in [[HttpSession.lua|HttpSession|]].

	* Routes - For now, you can ignore the first *Route* example in the *config.lua*, focus on two main routes :

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

		Here we create two *Route* object to handle the request's url, the first parameter like `"/mvc/{Controller?}/{Action?}/{Id?}"` and `".*.lsp"` are used to match the request's url, the first defined route would be first used to match the url, when one match it, the other routes would be ignored.

		The url matching pattern is using lua regex string with some additional rules :

		* If the url ended with a suffix, the suffix would be converted to a tail match, as an example : ".*.lsp" -> "^.*%.[lL][sS][pP]$", so it will match a request that ask for a lua server page.

		* if the url contains items like `{name}`, the name in the braces is useless, just some tips. the item would be convert to `(%w+)`. If the item is `{name?}`, means the item is optinal, then it would be converted to `(%w*)`. If you want give a match for it, you can do it like `{id|%d*}`. If one item is optional, all items after it would optional, the seperate between them would also be optional, only one seperate can be used between those items. Normally it's used for mvc action maps :

			/{controller}/{action?}/{id?|%d*} -> ^/(%w+)/?(%w*)/?(%d*)$

		The second parameter of the Route creation is a *System.Callable*, it means the value can be a function, a lambda expression or a callable object.

		When the url matched, the callable value would be called with the request object and matched strings(the whole url can be get by `request.Url`). The first return value would be an absolute path to the content file(The root is defined in nginx.conf), and any other return values would be used when creating object of the type generated by the content file.

		So if the content file is a *System.Web.Controller*, it will use the `{Action = action, Id = id}` as an init-table to create object, so the object would know which action is called.

		For content file like lua server page, the request url is the file path, so we could use the `request.Url` directly.

		Be careful in some OS like CentOS, it's file system is case sensitive, it's better to keep your content file and directory's name in lower case, and use `string.lower` on the return value like :

			--- MVC route
			Route("/mvc/{Controller?}/{Action?}/{Id?}",
				function (request, controller, action, id)
					controller = controller ~= "" and controller or "home"
					action = action ~= "" and action or "index"
					return ('/controller/%scontroller.lua'):format(controller:lower()), {Action = action, Id = id}
				end
			)

			--- Direct map
			Route(".*.lsp", "r=>r.Url:lower()")

		You can find more information in **PLoop_Web**.

