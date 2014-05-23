require './MyGedcomParser.rb'

parser = MyGedcomParser.new
parser.parse './royal.ged'
persons = parser.get_all_persons

persons.each do |person|
  puts person.id
end