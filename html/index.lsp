@{ master = "/share/masterpage.master", code="index.lua", session=true }

@{
	local function plus(a, b) return a + b end
}

@head {
	@{ javascriptInc("index", 3, "index_js") }
}

@body {
	<p>OS: @System.IO.OSType(System.IO.GetOperationSystem())</p>
	@[description.embed <!-- A description -->]
	<p>
		Session ID : @self.Context.Session.SessionID <br>
		@ local a, b = math.random(5000), math.random(5000)
		Example : @a + @b = @plus(a, b) <br>
		Example : @a * @b = @(a * b)
	</p>
	<table>
		<thead>
			<th>Name</th>
			<th>Age</th>
		</thead>
		<tbody>
		@for _, per in ipairs(self.Data) do
			<tr>
				<td>@per.Name</td>
				<td>@per.Age</td>
			</tr>
		@end
		</tbody>
	</table>
}