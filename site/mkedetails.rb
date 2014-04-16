#
# Make template .include files for any effectors that don't have 'em.
#

require 'cgi'
require '../lib/fto'
include FormatText

FTO.findEffectors('.').each do |e|
  fname = e.id + '.include'
  next if (File.exist?(fname) && File.size?(fname))
  File.open(fname, 'a+') do |f|
    f.puts "<!-- Effector: #{CGI.escapeHTML(e.shortname || e.syntax)}\n" +
      "     UUID: #{CGI.escapeHTML(e.id)}\n" +
      "     Category: #{CGI.escapeHTML(e.category)}\n" +
      "     Name: #{CGI.escapeHTML(e.name)}\n" +
      "-->\n"
    f.close
  end
end
