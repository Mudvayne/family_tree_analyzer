require './lib/myGedcomParser'
require './lib/analyzer'

class AnalysesController < ApplicationController
  def analysis
    parser = MyGedcomParser.new
    parser.parse './royal.ged'
    @persons = parser.get_all_persons

    analyzer = Analyzer.new @persons

    @number_male_persons = analyzer.get_males_count
    @number_female_persons = analyzer.get_females_count

    @persons_with_vaid_date_fields = analyzer.get_persons_with_valid_date_fields
    @count_persons_with_birthyear_set = analyzer.get_persons_with_birthyear_set.count
    @count_persons_with_birthyear_unset = @persons.count - @count_persons_with_birthyear_set
    @count_probably_missing_death_dates = analyzer.get_count_of_probably_missing_death_dates

    @birth_occurrences_by_decade = analyzer.get_birth_accurrences_by_decade @persons_with_vaid_date_fields
    @death_occurrences_by_decade = analyzer.get_death_accurrences_by_decade @persons_with_vaid_date_fields
    @alive_persons_by_decade = analyzer.get_alive_persons_by_decade @persons_with_vaid_date_fields
    @ages = analyzer.get_ages @persons_with_vaid_date_fields
    @average_age_males = analyzer.get_average_age_of("male", @persons_with_vaid_date_fields)
    @average_age_females = analyzer.get_average_age_of("female", @persons_with_vaid_date_fields)
   
    @ten_most_common_lastnames = analyzer.get_ten_most_common_lastnames
    @ten_most_common_firstnames = analyzer.get_ten_most_common_firstnames
  end
end
