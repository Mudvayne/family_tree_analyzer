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
    @birth_occurrences_by_year = analyzer.get_birth_accurrences_by_year
    @death_occurrences_by_year = analyzer.get_death_accurrences_by_year
  end
end
