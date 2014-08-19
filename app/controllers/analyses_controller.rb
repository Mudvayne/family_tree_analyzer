require './lib/myGedcomParser'
require './lib/analyzer'

class AnalysesController < ApplicationController
  def analysis
    data_hash =  GedcomFile.get_data_hash params[:id]
    @all_persons = data_hash[:all_persons]
    @all_families = data_hash[:all_families]
    @persons_for_analysis = session[:persons_for_analysis].map {|person_id| data_hash[:all_persons_hashmap][person_id] }
    puts "persons: " + @persons_for_analysis.count.to_s

=begin
    ### dummy for testing
    parser = MyGedcomParser.new
    parser.parse './Test456.ged'
    puts "START"
    @all_persons = parser.get_all_persons
    @all_families = parser.get_all_families
    @persons_for_analysis = @all_persons
=end

    analyzer = Analyzer.new @persons_for_analysis, @all_families, @all_persons

    @number_male_persons = analyzer.number_male_persons
    @number_female_persons = analyzer.number_female_persons

    @families_count = analyzer.families_count
    @average_children_per_family = analyzer.average_children_per_family

    @persons_with_vaid_date_fields = analyzer.persons_with_vaid_date_fields
    @count_persons_with_birthyear_set = analyzer.count_persons_with_birthyear_set
    @count_persons_with_birthyear_unset = analyzer.count_persons_with_birthyear_unset
    @count_probably_missing_death_dates = analyzer.count_probably_missing_death_dates

    @birth_occurrences_by_decade = analyzer.birth_occurrences_by_decade
    @death_occurrences_by_decade = analyzer.death_occurrences_by_decade
    @alive_persons_by_decade = analyzer.alive_persons_by_decade
    @ages_alive = analyzer.ages_alive
    @average_age_males_alive = analyzer.average_age_males_alive
    @average_age_females_alive = analyzer.average_age_females_alive
    @ages_deceased = analyzer.ages_deceased
    @average_age_males_deceased = analyzer.average_age_males_deceased
    @average_age_females_deceased = analyzer.average_age_females_deceased

    @average_age_of_male_at_marriage = analyzer.average_age_of_male_at_marriage
    @average_age_of_female_at_marriage = analyzer.average_age_of_female_at_marriage
    @average_age_of_male_at_first_child = analyzer.average_age_of_male_at_first_child
    @average_age_of_female_at_first_child = analyzer.average_age_of_female_at_first_child
   
    @ten_most_common_lastnames = analyzer.ten_most_common_lastnames
    @ten_most_common_firstnames_males = analyzer.ten_most_common_firstnames_males
    @ten_most_common_firstnames_females = analyzer.ten_most_common_firstnames_females
  end
end
