require 'gedcom'
puts "parse TGC551LF.ged"
g = Gedcom.file("./TGC551LF.ged", "r:ASCII-8BIT") #OK with LF line endings.
#g.transmissions[0].summary
#g.transmission[0].self_check #validate the gedcom file just loaded, printing errors found.
#puts 

puts "parse TGC55CLF.ged"
g.file("./TGC55CLF.ged", "r:ASCII-8BIT") #Ok with CR LF line endings.
g.transmissions[1].summary #Prints numbers of each level 1 record type found.
g.transmission[1].self_check #validate the gedcom file just loaded, printing errors found.

#print the parsed file to see if it matches the source file.
#Note CONT and CONC breaks may end up in different places
#Note Order of TAGS at the same level may be different
#Note User TAGS are output as Notes.
File.open( "./TGC551LF.out", "w:ASCII-8BIT") do |file|
  file.print g.transmissions[0].to_gedcom
end
File.open( "./TGC55CLF.out", "w:ASCII-8BIT") do |file|
  file.print g.transmissions[1].to_gedcom
end
puts "\nComplete"