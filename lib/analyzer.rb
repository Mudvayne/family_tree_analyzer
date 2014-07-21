require './lib/diagramData'
require './lib/gedcom_date.rb'

class Analyzer
  def initialize persons
    @persons = persons
  end

  def get_males
    males = Array.new
    @persons.each do |i|
      if i.gender == "M" || i.gender == "m"
        males.push(i)
      end
    end
    return males
  end

  def get_females
    females = Array.new
    @persons.each do |i|
      if i.gender == "F" || i.gender == "f"
        females.push(i)
      end
    end
    return females
  end

  def get_number_alive_persons
    count = 0
    @persons.each do |person|
      if person.date_death == "N/A" then count += 1 end
    end
    return count
  end

  def get_number_deceased_persons
    return @persons.count - get_number_alive_persons
  end

  def get_birth_accurrences_by_year
    birth_years = Array.new
    @persons.each do |person|
      year = get_year person.date_birth
      if not year == "N/A"
        birth_years.push(year)
      end
    end
    return get_diagram_data_array birth_years
  end

  def get_death_accurrences_by_year
    death_years = Array.new
    @persons.each do |person|
      year = get_year person.date_death
      if not year == "N/A"
        death_years.push(year)
      end
    end
    return get_diagram_data_array death_years
  end

  def get_ages_by_year

  end
  
  def get_average_age_male

  end

  def get_average_age_female
    
  end

  def get_alive_persons_by_year

  end

  def get_count_by_nationalities
  end

  def get_count_by_lastnames
  end

  def get_ten_most_common_firstnames
  end

  def get_locations_of_birth
    locations = Array.new
    @persons.each do |person|
      if not person.location_birth == "N/A" then locations.push(person.location_birth) end
    end
    return locations
  end

  def get_locations_of_death
    locations = Array.new
    @persons.each do |person|
      if not person.location_death == "N/A" then locations.push(person.location_death) end
    end
    return locations
  end

  private
  def get_year date
    d = GEDCOM::Date.safe_new( date )
    if (not d.first.has_year?) || date == "N/A"
      return "N/A"
    else
      return d.first.year
    end
  end

  def get_diagram_data_array years
    years.sort!
    diagram_data_array = Array.new
    actual_year = years.first
    last_year = years.last

    puts actual_year
    puts last_year
    while actual_year < last_year do
      size_before = years.count
      years.delete(actual_year)
      diagram_data_array.push(DiagramData.new(actual_year, size_before - years.count))
      actual_year += 1
    end
    return diagram_data_array
  end
end