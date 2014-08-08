require './lib/myGedcomParser'
require './lib/analyzer'

class AnalysesController < ApplicationController
  def analysis
    parser = current_user.gedcom_files.find(params[:id]).parse_gedcom_file
    @persons = parser.get_all_persons.keep_if {|person| session[:persons_for_analysis].include?(person.id) }

    @families = parser.get_all_families

    analyzer = Analyzer.new @persons, @families

    @number_male_persons = analyzer.get_males_count
    @number_female_persons = analyzer.get_females_count

    @families_count = analyzer.get_families_count
    @average_children_per_family = analyzer.get_average_children_per_family

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

    @average_age_of_male_at_marriage = analyzer.get_average_age_of_male_at_marriage
    @average_age_of_female_at_marriage = analyzer.get_average_age_of_female_at_marriage
    @average_age_of_male_at_first_child = analyzer.get_average_age_of_male_at_first_child
    @average_age_of_female_at_first_child = analyzer.get_average_age_of_female_at_first_child
   
    @ten_most_common_lastnames = analyzer.get_ten_most_common_lastnames
    @ten_most_common_firstnames = analyzer.get_ten_most_common_firstnames
  end
end
