require './test'
require './lib/diagramData'

tester = Test.new

persons = tester.get_persons_with_valid_date_fields
last_relevant_year = tester.get_last_relevant_year persons

persons_with_vaid_date_fields = tester.get_persons_with_valid_date_fields

data = tester.get_males
puts "males: " + data.count.to_s

data = tester.get_females
puts "females: " + data.count.to_s

data = tester.get_count_of_probably_missing_death_dates
puts "count of probably missing dates: " + data.to_s

data = tester.get_average_age_of("male",persons_with_vaid_date_fields)
puts "average age male: " + data.to_s

data = tester.get_average_age_of("female",persons_with_vaid_date_fields)
puts "average age female: " + data.to_s