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

  def get_birth_accurrences_by_decade
    return get_diagram_data_array_for_decade get_birth_years
  end

  def get_death_accurrences_by_decade
    return get_diagram_data_array_for_decade get_death_years
  end

  #returns an array: [0] = diagram_data_array, [1] = relevant persons
  def get_ages
    ages = Array.new
    @persons.each do |person|
      age = get_age person
      if not age == "N/A"
        #puts "Person: " + person.id + " Age: " + age.to_s
        ages.push(age)
      end
    end
    ages.sort!
    relevant_persons = ages.count
    oldest = ages.last
    actual_year = 0
    diagram_data_array = Array.new
    while actual_year <= oldest do
      size_before = ages.count
      ages.delete(actual_year)
      diagram_data_array.push(DiagramData.new(actual_year, size_before - ages.count))
      actual_year += 1
    end
    return_value = Array.new
    return_value.push(diagram_data_array)
    return_value.push(relevant_persons)
    return return_value
  end
  
  #returns an array: [0] = average are, [1] = relevant persons
  def get_average_age_of gender
    if gender == "male" then gender = "M" else gender = "F" end
    persons_for_calculation = 0;
    age_all = 0
    age = 0
    @persons.each do |person|
      if person.gender == gender || person.gender == gender.downcase
        age = get_age person
        if not age == "N/A"
          age_all += age
          persons_for_calculation += 1
        end
      end
    end
    return_value = Array.new
    return_value.push(age_all / persons_for_calculation)
    return_value.push(persons_for_calculation)
    return return_value
  end

  #slow like hell
  def get_alive_persons_by_decade
    actual_year = get_birth_years.sort!.first
    last_year = Time.new.year
    diagram_data_array = Array.new
    while actual_year <= last_year do
      count_persons = 0
      next_interval = 0
      @persons.each do |person|
        if not (get_age person) == "N/A" #valid?
          if actual_year + 50 <= last_year then next_interval = actual_year + 50 else next_interval = last_year end
          if person_alive_at_interval?(person, actual_year, next_interval) #alive in decade
            count_persons += 1
          end
        end
      end
      diagram_data_array.push(DiagramData.new(actual_year.to_s + " - " + next_interval.to_s, count_persons))
      actual_year += 50
    end
    return diagram_data_array
  end

  def get_count_by_nationalities
  end

  def get_ten_most_common_lastnames
    lastnames = Array.new
    @persons.each do |person|
      if not person.lastname == "N/A" then lastnames.push(person.lastname) end
    end

    all_lastnames = get_diagram_data_array lastnames
    return all_lastnames.sort! {|x,y| y.value <=> x.value}[0..9]
  end

  def get_ten_most_common_firstnames
    firstnames = Array.new
    @persons.each do |person|
      if not person.firstname == "N/A" then firstnames.push(person.firstname) end
    end

    all_firstnames = get_diagram_data_array firstnames
    return all_firstnames.sort! {|x,y| y.value <=> x.value}[0..9]
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

  def get_diagram_data_array values
    diagram_data_array = Array.new
    values.sort!
    while values.count > 0 do
      value = values.first
      count_before = values.count
      values.delete(value)
      diagram_data_array.push(DiagramData.new(value, count_before - values.count))
    end
    return diagram_data_array
  end

  def get_diagram_data_array_for_decade years
    years.sort!
    diagram_data_array = Array.new
    actual_year = years.first
    last_year = years.last

    while actual_year < last_year do
      births = 0
      block = actual_year + 10
      while actual_year < block do 
        size_before = years.count
        years.delete(actual_year)
        births += size_before - years.count
        actual_year += 1
      end
      diagram_data_array.push(DiagramData.new((actual_year - 10).to_s + " - " + actual_year.to_s, births))
    end
    return diagram_data_array
  end

  def get_age person
    birth_year = get_year person.date_birth
    if not birth_year == "N/A" 
      death_year = get_year person.date_death
      if death_year == "N/A" #alive
        death_year = Time.new.year
      end
      age = (death_year - birth_year)
      if age > -1 && age <= 110 #person not relevant (wrong data!)
        age = (death_year - birth_year)
        return age
      end
    end
    return "N/A"
  end

  def get_birth_years
    birth_years = Array.new
    @persons.each do |person|
      year = get_year person.date_birth
      if not year == "N/A"
        birth_years.push(year)
      end
    end
    return birth_years
  end

  def get_death_years
    death_years = Array.new
    @persons.each do |person|
      year = get_year person.date_death
      if not year == "N/A"
        death_years.push(year)
      end
    end
    return death_years
  end

  def person_alive_at_interval? person, from_year, to_year
    birth_year = get_year person.date_birth
    death_year = get_year person.date_death

    if birth_year == "N/A" || death_year == "N/A" then return false end
    if birth_year <= to_year && death_year >= from_year then return true else return false end
  end
end