class Analyzer
  def initialize persons
    @persons = persons
  end

  def get_males
    males = Array.new
    @persons.each do |i|
      if i.male? 
        males.push(i)
      end
    end
    return males
  end

  def get_females
    femails = Array.new
    @persons.each do |i|
      if not i.male? 
        femails.push(i)
      end
    end
    return femails
  end

  def get_birth_accurrences_by_year
    start_year = get_oldest_persons_birth_year
    end_year = Time.now.to_a[5]
    #TODO
  end

  def get_death_accurrences_by_year
    start_year = get_oldest_persons_death_year
    end_year = Time.now.to_a[5]
    #TODO
  end

  def get_number_alive_persons

  end

  def get_number_death_persons
    return @persons.count - get_number_alive_persons
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
    @persons.each do |i|
      if not i.locaation_birth == "N/A" then location.push(i.locaation_birth) end
    end
    return locations
  end

  def get_locations_of_death
    locations = Array.new
    @persons.each do |i|
      if not i.locaation_death == "N/A" then location.push(i.locaation_death) end
    end
    return locations
  end

  private
  def get_oldest_persons_birth_year
    year = 999999
    @persons.each do |i|
      if i.date_birth.last < year then year = i.date_birth.last end
    end
    return year
  end

  private
  def get_oldest_persons_death_year
    year = 999999
    @persons.each do |i|
      if i.date_death.last < year then year = i.date_death.last end
    end
    return year
  end
end