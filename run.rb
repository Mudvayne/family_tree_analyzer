require './lib/myGedcomParser'
require './lib/individual'
require './lib/family'
require './lib/diagramData'
require './lib/gedcom_date.rb'
require './test.rb'
=begin
tester = Test.new

persons = tester.get_persons_with_valid_date_fields

persons_with_vaid_date_fields = tester.get_persons_with_valid_date_fields
=end

=begin
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

data = tester.get_alive_persons_by_decade persons_with_vaid_date_fields
data.each do |i|
  puts i.label.to_s + " count: " + i.value.to_s
end



time_before = Time.new
data = tester.find_all_descendants2("@I34@", Array.new)
data.sort! { |x,y| y <=> x }
puts "*************************** 2 ***************************"
data.each do |i|
  puts i
end
puts data.count
puts "TIME NEEDED: " + (Time.new - time_before).to_s


time_before = Time.new
data = tester.find_all_descendants("@I34@", Array.new)
data.sort! { |x,y| y <=> x }
puts "*************************** 1 ***************************"
data.each do |i|
  puts i
end
puts data.count
puts "TIME NEEDED: " + (Time.new - time_before).to_s

=end

parser = MyGedcomParser.new
parser.parse './problem.ged'
@all_persons = parser.get_all_persons
@all_persons_hashmap = Hash.new
@all_persons.each do |person|
  @all_persons_hashmap[person.id] = person
end
@families = parser.get_all_families

puts "persons: " + @all_persons.count.to_s
puts "families: " + @families.count.to_s

tester = Test.new(@all_persons, @families, @all_persons)

d = GEDCOM::Date.safe_new("10.10.1805?")
puts d.to_s
puts "is date? " + d.is_date?.to_s
puts "has day? " + d.first.has_day?.to_s
puts "has month? " + d.first.has_month?.to_s
puts "has year? " + d.first.has_year?.to_s