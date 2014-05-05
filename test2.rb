require 'gedcom'
puts "parse family.ged"
g = Gedcom.file("./family.ged", "r:ASCII-8BIT") #OK with LF line endings.
g.transmissions[0].summary
g.transmission[0].self_check #validate the gedcom file just loaded, printing errors found.