-- Helper: extract plain text from a cell
local function cell_text(cell)
	return pandoc.utils.stringify(cell)
end

-- Guess a pandoc input format from a file name or extension.
-- Returns a valid pandoc format string (e.g. "markdown", "latex", "docx").
-- For unknown extensions, falls back to "markdown".
local function guess_format_from_ext(path)
  if not path or path == "" then
    return "markdown"
  end

  -- grab last extension: "foo.bar.md" -> "md"
  local ext = path:match("%.([^%.]+)$")
  if not ext then
    return "markdown"
  end
  ext = ext:lower()

  -- main mapping: extensions -> pandoc input formats
  local map = {
    -- Markdown variants
    md      = "markdown",
    markdown= "markdown",
    rmd     = "markdown",
    qmd     = "markdown",
    txt     = "markdown",   -- often plain text / markdown

    -- Common lightweight markup
    rst     = "rst",
    rest    = "rst",
    org     = "org",
    typ     = "typst",        -- Typst: no pandoc input format yet

    -- TeX / LaTeX
    tex     = "latex",

    -- HTML / XML
    html    = "html",
    htm     = "html",
    xhtml   = "html",
    xml     = "html",

    -- JSON / native AST
    json    = "json",     -- pandoc JSON AST

    -- Word processing formats
    docx    = "docx",
    docm    = "docx",     -- macro-enabled docx, still docx for parsing
    odt     = "odt",
    rtf     = "rtf",

    -- Ebooks
    epub    = "epub",
    epub2   = "epub",
    epub3   = "epub",

    -- Misc
    ipynb   = "ipynb"
  }

  return map[ext] or "markdown"
end

local function use_template(file, data)
	local f = io.open(file, "r")
	if not f then
		error("Cannot open template " .. file)
	end
	local content = f:read("*a")
	f:close()
  local format = guess_format_from_ext(file)
  local template = pandoc.template.compile(content)
	local filled = pandoc.template.apply(template, data)
  local rendered = pandoc.layout.render(filled)
  return pandoc.read(rendered, format).blocks
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
	local template_data = { rows = output }
	quarto.log.output(template_data)

  local template_file = "_extensions/vitae-entries/test-template.html"

  local cv_entries = use_template(template_file, template_data)

	return cv_entries
end
