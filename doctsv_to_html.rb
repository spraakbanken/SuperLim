#Usage: ruby doctsv_to_html.rb yourfile lineend
# lineend = "\n" (Unix) or "\r\n" (Windows) or "\r" (Mac)
# yourfile = e.g. resource1_documentation_sheet.tsv. Must be in the same folder
# output = resource1_documentation_sheet.html
# The script can deal with: 1) rows that contain two cells separated by \t, even if one or both cells are empty; 2) empty lines; 3) non-empty lines that do not contain a \t. Those are treated as belonging to the second cell (field value) in the previous row (this helps dealing with e.g. lists where items are separated by line breaks). IF YOU HAVE SMTH ELSE in your tsv, the script may work incorrectly. Have a look at the example tsv: that's what the script processes correctly.
# If you copied your tsv from the Google doc, the resulting html might contain some extra " (mostly in the multi-lined cells). Delete them manually.

f = File.open(ARGV[0],"r:utf-8")
lineend = ARGV[1]
if !["\\n", "\\r\\n", "\\r"].include?(lineend)
    STDERR.puts "Warning: Unknown line break. Expected:  \\n (Unix) or \\r\\n (Windows) or \\r (Mac). I'll try with what you provided, though."
end

fields = [[],[]]

f.each_line do |line|
    line.gsub!("\"\"","\"") #remove double quotes which may emerge when copying from a spreadsheet
    line1 = line.gsub(lineend,"") #remove line end 
    if line1 != "\t" and line1 != "" #empty lines ignored
        if line1.include?("\t")
            line2 = line.split("\t")
            fields[0] << line2[0] #field name. 
            fields[1] << line2[1].to_s #value. Convert to string in order to process nils correctly
        else #if !line.include?("\t") #untabulated lines mean there are line breaks within the cell
            fields[1][-1] << "<br> #{line1}" #deal with lists etc.
        end
    end
end

o = File.open("#{ARGV[0].split(".")[0]}.html","w:utf-8")
o.puts "<table style=\"width:100%\">"

for i in 0..fields[0].length-1 
    o.puts "<tr>"
    o.puts "<td>#{fields[0][i]}</td>"
    o.puts "<td>#{fields[1][i]}</td>"
    o.puts "</tr>"
end

o.puts "</table>"