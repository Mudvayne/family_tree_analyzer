require './lib/myGedcomParser'
require './lib/individual'
require './lib/family'
require './lib/diagramData'
require './lib/gedcom_date.rb'

class Test

  def initialize
    parser = MyGedcomParser.new
    parser.parse './royal.ged'
    @all_persons = parser.get_all_persons
    @all_persons_hashmap = Hash.new
    @all_persons.each do |person|
      @all_persons_hashmap[person.id] = person
    end
    @families = parser.get_all_families

    #blubbor
    @persons = @all_persons
  end

  #tested
  def get_males
    males = Array.new
    @persons.each do |i|
      if i.gender == "M" || i.gender == "m"
        males.push(i)
      end
    end
    return males
  end

  #tested
  def get_females
    females = Array.new
    @persons.each do |i|
      if i.gender == "F" || i.gender == "f"
        females.push(i)
      end
    end
    return females
  end

  #tested
  def get_locations_of_birth
    puts "entering"
    locations = Array.new
    @persons.each do |person|
      if not person.location_birth == "N/A" then locations.push(person.location_birth) end
    end
    return locations
  end

  #tested
  def get_locations_of_death
    locations = Array.new
    @persons.each do |person|
      if not person.location_death == "N/A" then locations.push(person.location_death) end
    end
    return locations
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

  def get_ages_by_year

  end
  
  #returns an array: [0] = average are, [1] = relevant persons
  def get_average_age_of gender
    if gender == "male" then gender = "M" else gender = "F" end
    persons_for_calculation = 0;
    age = 0;
    @persons.each do |person|
      if person.gender == gender || person.gender == gender.downcase
        birth_year = get_year person.date_birth
        if not birth_year == "N/A" #person not relevant 
          death_year = get_year person.date_death
          if death_year == "N/A" #alive
            death_year = Time.new.year
          end
          if (death_year - birth_year) > -1 #person not relevant (negative age -> wrong data!)
            age += (death_year - birth_year)
            persons_for_calculation += 1
          end
        end
      end
    end
    return_value = Array.new
    return_value.push(age / persons_for_calculation)
    return_value.push(persons_for_calculation)
    return return_value
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
    while actual_year < last_year do
      size_before = years.count
      years.delete(actual_year)
      diagram_data_array.push(DiagramData.new(actual_year, size_before - years.count))
      actual_year += 1
    end
    return diagram_data_array
  end
end
