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
			title = cell_text(cells[1]),
			organization = cell_text(cells[2]),
			location = cell_text(cells[1]),
			date = cell_text(cells[2]),
		}

		output[#output + 1] = context
	end
	local final = { rows = output }
	quarto.log.output(final)

	local template_str = load_template("_extensions/table-templater/test-template.tmpl")
	local compiled_template = pandoc.template.compile(template_str)

	local result = pandoc.template.apply(compiled_template, final)

	return pandoc.read(pandoc.layout.render(result)).blocks
end
