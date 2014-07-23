require './test'
require './lib/diagramData'

tester = Test.new
data = tester.get_death_accurrences_by_year
count_alives = tester.get_number_alive_persons
count_deceased = tester.get_number_deceased_persons

males = tester.get_average_age_of "male"
puts "males = " + tester.get_males.count.to_s + " relevant = " + males[1].to_s + " average age = " + males[0].to_s


#puts "persons: " + (count_alives + count_deceased).to_s + " alive: " + count_alives.to_s + " deceased: " + count_deceased.to_s


#data.each do |d|
#  puts "year: " + d.label.to_s + " count: " + d.value.to_s
#end