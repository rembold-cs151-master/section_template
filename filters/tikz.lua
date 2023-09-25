local system = require 'pandoc.system'

local tikz_doc_template = [[
\documentclass[border=2pt]{standalone}
\usepackage{xcolor}
\usepackage{tikz}
\usepackage{datacosmos-commands}
\begin{document}
\nopagecolor
%s
\end{document}
]]

local function tikz2image(src, filetype, outfile)
  system.with_temporary_directory('./','tikz2image', function (tmpdir)
    system.with_working_directory(tmpdir, function()
      local f = io.open('tikz.tex', 'w')
      f:write(tikz_doc_template:format(src))
      f:close()
      os.execute('pdflatex tikz.tex')
      if filetype == 'pdf' then
        os.rename('tikz.pdf', outfile)
      else
		print(system.get_working_directory())
		--Extra ../ to get us out of the temporary directory
        os.execute('pdf2svg tikz.pdf ' .. '../' .. outfile)
      end
    end)
  end)
end

local function readFile(name)
	-- Purely in case one wanted to inline the svgs
	local f = io.open(name, "r")
	local content = ""
	first_line = f:read()
	local content = f:read("*all")
	print("Content:")
	return content
end

extension_for = {
  html = 'svg',
  html4 = 'svg',
  html5 = 'svg',
  latex = 'pdf',
  beamer = 'pdf' }

local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function starts_with(start, str)
  return str:sub(1, #start) == start
end


function RawBlock(el)
  if starts_with('\\begin{tikzpicture}', el.text) then
    local filetype = extension_for[FORMAT] or 'svg'

	--[[ Prepare for my horrid lua coding... ]]--
	local ps,pe = string.find(el.text, '%%')
	local lineend,_ = string.find(el.text, '\n')
	local opts_str = string.sub(el.text, pe+2, lineend-1)
	local clean_text = string.sub(el.text,1,ps) .. string.sub(el.text, lineend, string.len(el.text))

	local opts = {}
	for elem in string.gmatch(opts_str, "([^,]+)") do
		for k, v in string.gmatch(elem, "(.+)=(.+)") do
			local key = string.gsub(k, "%s+", "")
			opts[key] = v
			--print(key .. ': ' .. v)
		end
	end

	--local fname = system.get_working_directory() .. '/../images/svg_cache/' ..
	local fname = '../images/svg_cache/' ..
        pandoc.sha1(clean_text) .. '.' .. filetype
    if not file_exists(fname) then
      tikz2image(clean_text, filetype, fname)
    end
	--local svg_inline = readFile(fname)
	return pandoc.Para({pandoc.Image({}, fname, "", opts)})
	--return pandoc.RawBlock('html', svg_inline)
  else
   return el
  end
end
