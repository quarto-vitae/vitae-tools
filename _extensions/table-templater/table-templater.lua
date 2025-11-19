-- Helper: extract plain text from a cell
local function cell_text(cell)
	return pandoc.utils.stringify(cell)
end

local function load_template(tname)
	local fname = tname
	local f = io.open(fname, "r")
	if not f then
		error("Cannot open template " .. fname)
	end
	local content = f:read("*a")
	f:close()
	return content
end

function Table(el)
	local output = {}
	for i, row in ipairs(el.bodies[1].body) do
		local cells = row.cells
		local context = {
			n = i,
			col1 = cell_text(cells[1]),
			col2 = cell_text(cells[2]),
		}

		local template_str = load_template("_extensions/table-templater/test-template.tmpl")
		local compiled_template = pandoc.template.compile(template_str)
		local result = pandoc.template.apply(compiled_template, context)
		output[#output + 1] = result
	end
	return pandoc.read(pandoc.layout.render(pandoc.layout.concat(output))).blocks
end
