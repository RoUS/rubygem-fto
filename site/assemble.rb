#
# Simple app to process a file containing '<!-- include filename -->'
# and actually insert the contents of that file.
#
# *Not* recursive!  (I.e., won't delve into the included files for additional
# inclusions.)
#
require 'getoptlong'

opts = GetoptLong.new(
                      [ '--template-file', '-I',
                        GetoptLong::REQUIRED_ARGUMENT ],
                      [ '--output-file', '-O',
                        GetoptLong::REQUIRED_ARGUMENT ]
                      )

fnIn = ''
fnOut = ''

opts.each do |opt,arg|
  case opt
  when '--template-file'
    fnIn = arg
  when '--output-file'
    fnOut = arg
  end
end

fOut = File.open(fnOut, 'w')

File.open(fnIn, 'r').each do |line|
  if (m = line.match(/<!--\s+include\s+(\S+)\s*-->/))
    File.open(m.captures[0], 'r').each { |iLine| fOut.puts iLine }
  else
    fOut.puts line
  end
end
fOut.close

