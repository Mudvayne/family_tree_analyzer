require './lib/myGedcomParser'
require './lib/analyzer'

class AnalysesController < ApplicationController
  def analysis
    parser = MyGedcomParser.new
    parser.parse './royal.ged'
    @persons = parser.get_all_persons

    analyzer = Analyzer.new @persons

    @number_male_persons = analyzer.get_males.count
    @number_female_persons = analyzer.get_females.count
    @number_alive_persons = analyzer.get_number_alive_persons

    @number_deceased_persons = analyzer.get_number_deceased_persons
    @birth_occurrences_by_decade = analyzer.get_birth_accurrences_by_decade
    @death_occurrences_by_decade = analyzer.get_death_accurrences_by_decade

    @average_age_males_array = analyzer.get_average_age_of "male"
    @average_age_females_array = analyzer.get_average_age_of "female"

    ages_return_value = analyzer.get_ages

    @ages = ages_return_value[0]
    @correct_ages = ages_return_value[1]
    @valid_dates_percentage = ((100.to_f / @persons.count.to_f) * @correct_ages.to_f).round
    #@alive_persons_by_decade = analyzer.get_alive_persons_by_decade
    @ten_most_common_lastnames = analyzer.get_ten_most_common_lastnames
    @ten_most_common_firstnames = analyzer.get_ten_most_common_firstnames
  end
end
