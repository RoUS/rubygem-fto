#
# Create the summary table from the internal documentation, and
# also the set of 'include's to bring per-effector docco files into
# the Effectors file.
#
require 'fto'
include FormatText

eList = FTO.findEffectors('.').select { |e| ! e.category.nil? }
idsByCategory = eList.sort_by do |e|
  sprintf('%06d', e.priority) + e.category + e.name.downcase
end

curcat = nil
eid = 5000
cats = {}
fTiptable = File.open('tiptable.include', 'w')
fTiptable.puts "      <table>"
idsByCategory.each do |e|
  unless (e.category.eql?(curcat))
    eid += 1
    ename = sprintf('E%06d', eid)
    cats[e.category] = ename
    fTiptable.puts "        <tr>\n" +
      "          <th class=\"category\" colspan=\"4\">" +
      "<a href=\"Effectors.html##{ename}\">" +
      "#{e.category.to_s}</a></th>\n" +
      "        </tr>\n" +
      "        <tr>\n" +
      "          <th>Effector Syntax</th>\n" +
      "          <th>Effector Name</th>\n" +
      "          <th>Description</th>\n" +
      "          <th>Default Width</th>\n" +
      "        </tr>"
    curcat = e.category
  end
  dColumns = ''
  unless (e.dWidth.nil?)
    case e.dWidth.class.name
    when 'Symbol'
      case e.dWidth
      when :NA          then dColumns = 'Not applicable.'
      when :asSpecified then dColumns = 'As specified.'
      when :asNeeded    then dColumns = 'As many columns as needed ' +
                                        'to represent the value.'
      else                   dColumns = '<b>UNKNWON</b>'
      end
    when 'String'
      dColumns = e.dWidth
    when 'Fixnum'
      dColumns = "#{e.dWidth} columns."
    else
      dColumns = "<b>[Error interpreting #{e.dWidth.class.name}]</b>"
    end
  end
  fTiptable.puts "        <tr>\n" +
    "          <td class=\"code\">" +
    "<a href=\"Effectors.html##{e.id}\">" +
    "#{e.syntax.to_s.gsub(' ', '&nbsp;')}</a></td>\n" +
    "          <td>#{e.name.to_s}</td>\n" +
    "          <td>#{e.description.to_s}</td>\n" +
    "          <td>#{dColumns}</td>\n" +
    "        </tr>"
end
fTiptable.puts "      </table>"
fTiptable.close

#
# Now do the skeleton for the detail page.
#
fSkeleton = File.open('std-effector-docs.intermediate', 'w')
curcat = nil
idsByCategory.each do |e|
  unless (e.category.eql?(curcat))
    fSkeleton.puts unless (curcat.nil?)
    fSkeleton.puts "    <h3 id=\"#{cats[e.category]}\">#{e.category.to_s}</h3>\n" +
         "<!-- include #{cats[e.category]}.include -->"
    fSkeleton.puts
    curcat = e.category
  end
  fSkeleton.puts "    <h4 id=\"#{e.id}\">#{e.name}</h4>\n" +
       "    <h5 class=\"code\">#{e.syntax}</h5>\n" +
       "<!-- include #{e.id}.include -->"
  fSkeleton.puts
end
fSkeleton.close
