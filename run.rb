require './test'
require './lib/diagramData'

tester = Test.new

persons = tester.get_persons_with_valid_date_fields

persons_with_vaid_date_fields = tester.get_persons_with_valid_date_fields

data = tester.get_males_count
puts "males: " + data.to_s

data = tester.get_females_count
puts "females: " + data.to_s

data = tester.get_count_of_probably_missing_death_dates
puts "count of probably missing dates: " + data.to_s

data = tester.get_average_age_of("male",persons_with_vaid_date_fields)
puts "average age male: " + data.to_s

data = tester.get_average_age_of("female",persons_with_vaid_date_fields)
puts "average age female: " + data.to_s

data = tester.get_families_count
puts "families: " + data.to_s

data = tester.get_average_children_per_family
puts "average children per family: " + data.round(3).to_s