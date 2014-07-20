require './test'

tester = Test.new
puts "males: " + tester.get_males.count.to_s
puts "females: " + tester.get_females.count.to_s