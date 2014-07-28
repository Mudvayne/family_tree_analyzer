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

  def get_persons_with_valid_date_fields
    valid = Array.new
    @persons.each do |person|
      date_birth = get_year person.date_birth
      date_death = get_year person.date_death
      if not date_birth == "N/A"
        if not date_death == "N/A"
          if date_death >= date_birth
            valid.push(person)
          end
        else
          if not (Time.new.year - date_birth) > 110
            valid.push(person)
          end
        end
      end
    end
    return valid
  end

  def get_persons_with_birthyear_set
    persons_wirth_birthyear_set = Array.new
    @persons.each do |person|
      if not person.date_birth == "N/A"
        persons_wirth_birthyear_set.push(person)
      end
    end
    return persons_wirth_birthyear_set
  end

  def get_count_of_probably_missing_death_dates
    count = 0
    @persons.each do |person|
      date_birth = get_year person.date_birth
      date_death = get_year person.date_death

      if date_birth == "N/A" && date_death == "N/A"
        count += 1
      elsif (not date_birth == "N/A") && person.date_birth == "N/A" 
        if Time.new.year - date_birth > 110 then count += 1 end
      end
    end
    return count
  end 

  def get_birth_accurrences_by_decade persons
    return get_diagram_data_array_for_decade(get_birth_years(persons), get_first_relevant_year(persons), get_last_relevant_year(persons))
  end

  def get_death_accurrences_by_decade persons
    return get_diagram_data_array_for_decade(get_death_years(persons), get_first_relevant_year(persons), get_last_relevant_year(persons))
  end

  def get_alive_persons_by_decade persons
    diagram_data_array = Array.new
    first_year = get_first_relevant_year persons
    last_year = get_last_relevant_year persons

    actual_year = first_year
    while actual_year < last_year do
      diagram_data_array.push(DiagramData.new(actual_year.to_s + " - " + (actual_year + 10).to_s, 0))
      actual_year += 10
      if actual_year > last_year then actual_year = last_year end
    end

    persons.each do |person|
      birth_person = get_year person.date_birth
      if not birth_person == "N/A"
        index = (birth_person - first_year) / 10 #find first relevant index for performance
        diagram_data_array.each do |i|
          if person_alive_at_interval?(person, first_year+index*10, (first_year+10)+index*10)
            diagram_data_array[index].value += 1
          else
            break #person died in this index, no need for checking greater indizes
          end
          index += 1
        end
      end
    end

    return diagram_data_array
  end

  def get_ages persons
    ages = Array.new
    persons.each do |person|
      age = get_age person
      if not age == "N/A"
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
    return diagram_data_array
  end
  
  def get_average_age_of gender, persons
    if gender == "male" then gender = "M" else gender = "F" end
    persons_for_calculation = 0;
    age_all = 0
    age = 0
    persons.each do |person|
      if person.gender == gender || person.gender == gender.downcase
        age = get_age person
        if not age == "N/A"
          age_all += age
          persons_for_calculation += 1
        end
      end
    end
    return age_all / persons_for_calculation
  end

  # nationalities here

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
    if values.count == 0 then return "N/A" end
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

  def get_diagram_data_array_for_decade years, start_year, end_year
    if years.count == 0 then return "N/A" end
    years.sort!
    diagram_data_array = Array.new
    actual_year = start_year
    last_year = end_year

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

  def get_birth_years persons
    birth_years = Array.new
    @persons.each do |person|
      year = get_year person.date_birth
      if not year == "N/A"
        birth_years.push(year)
      end
    end
    return birth_years
  end

  def get_death_years persons
    death_years = Array.new
    persons.each do |person|
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

  def get_first_relevant_year persons
    first_year = get_birth_years(persons).sort!.first
    death_years = get_death_years(persons).sort!
    if first_year > death_years.first
      first_year = death_years.first
    end
    return first_year
  end

  def get_last_relevant_year persons
    return get_death_years(persons).sort!.last
  end
end