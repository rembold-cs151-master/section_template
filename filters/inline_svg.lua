local function file_info( path )
  filename, basename, extension = path:match('(([^/]-).?([^.]+))$')

  return {
    path = string.sub(path, 0, -#filename - 1),
    filename = filename,
    basename = basename,
    extension = extension,
  }
end

local function read_file( path )
    local file = io.open( path, "rb" )
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

function Image( elem )
  local ext = file_info( elem.src ).extension 

  if ext == "svg" then
    local svg = read_file( elem.src )
    return pandoc.RawInline( "html", svg )
  else
    return elem
  end
end
