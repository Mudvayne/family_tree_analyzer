require './lib/diagramData'
require './lib/gedcom_date.rb'

class Analyzer

  attr_reader :number_male_persons, :number_female_persons, :families_count, :average_children_per_family, 
  :persons_with_vaid_date_fields, :count_persons_with_birthyear_set, :count_persons_with_birthyear_unset, 
  :count_probably_missing_death_dates, :birth_occurrences_by_decade, :death_occurrences_by_decade, 
  :alive_persons_by_decade, :ages_alive, :average_age_males_alive, :average_age_females_alive, 
  :ages_deceased, :average_age_males_deceased, :average_age_females_deceased, :average_age_of_male_at_marriage,
  :average_age_of_female_at_marriage, :average_age_of_male_at_first_child, :average_age_of_female_at_first_child, 
  :ten_most_common_lastnames, :ten_most_common_firstnames_males, :ten_most_common_firstnames_females

  def initialize persons, all_families, all_persons
    start = Time.new

    @persons = persons
    @all_families = all_families
    @all_persons = all_persons
    @families = Array.new
    @all_persons_hashmap = Hash.new
    @all_persons.each do |person|
      @all_persons_hashmap[person.id] = person
    end
    @all_families_hashmap = Hash.new
    @all_families.each do |family|
      @all_families_hashmap[family.id] = family
    end
    get_family_ids.each do |family_id|
      @families.push(@all_families_hashmap[family_id])
    end

    puts "calculate data depending on all persons"
    calculate_data_depending_on_all_persons
    puts "calculate data depending on subset of persons"
    calculate_data_depending_on_subset_of_persons(@persons_with_vaid_date_fields, @families)

    puts "DONE. TIME NEEDED: " + (Time.new - start).to_s
  end

  def calculate_data_depending_on_all_persons
    @number_male_persons = 0
    @number_female_persons = 0
    @families_count = @families.count
    @average_children_per_family = 0
    @persons_with_vaid_date_fields = Array.new
    @count_persons_with_birthyear_set = 0
    @count_persons_with_birthyear_unset = 0
    @count_probably_missing_death_dates = 0
    @ten_most_common_lastnames = Array.new.push(DiagramData.new(0, 0))
    @ten_most_common_firstnames_males = Array.new.push(DiagramData.new(0, 0))
    @ten_most_common_firstnames_females = Array.new.push(DiagramData.new(0, 0))

    lastnames = Array.new
    firstnames_male = Array.new
    firstnames_female = Array.new

    @persons.each do |person|

      date_birth = get_year person.date_birth
      date_death = get_year person.date_death

      #males count
      if person.gender == "M" || person.gender == "m"
        @number_male_persons += 1
        #firstnames
        if not person.firstname == "N/A"
          firstnames_male.push(person.firstname)
        end
      end

      #females count
      if person.gender == "F" || person.gender == "f"
        @number_female_persons += 1
        #firstnames
        if not person.firstname == "N/A"
          firstnames_female.push(person.firstname)
        end
      end

      #persons with valid date fields
      if not date_birth == "N/A"
        if not date_death == "N/A"
          if date_death >= date_birth
            @persons_with_vaid_date_fields.push(person)
          end
        else
          if not (Time.new.year - date_birth) > 110
            @persons_with_vaid_date_fields.push(person)
          end
        end
      end

      #persons with birth year set/unset
      if not person.date_birth == "N/A"
        @count_persons_with_birthyear_set+=1
      else
        @count_persons_with_birthyear_unset+=1
      end

      #count persons with probably missing death date
      if date_birth == "N/A" && date_death == "N/A"
         @count_probably_missing_death_dates += 1
      elsif (not date_birth == "N/A") && person.date_birth == "N/A" 
        if Time.new.year - date_birth > 110 
          @count_probably_missing_death_dates += 1 
        end
      end

      #most common lastnames
      if not person.lastname == "N/A" then lastnames.push(person.lastname) end
    end

    #initialisation counting variables
    all_children = 0.to_f
    @families.each do |family|
      #average children per family
      all_children += family.children.count
    end

    #average children per family
    @average_children_per_family = all_children / @families_count

    #names
    @ten_most_common_lastnames = get_diagram_data_array(lastnames).sort! {|x,y| y.value <=> x.value}[0..9]
    @ten_most_common_firstnames_males = get_diagram_data_array(firstnames_male).sort! {|x,y| y.value <=> x.value}[0..9]
    @ten_most_common_firstnames_females = get_diagram_data_array(firstnames_female).sort! {|x,y| y.value <=> x.value}[0..9]

    all_lastnames = get_diagram_data_array lastnames
    return all_lastnames.sort! {|x,y| y.value <=> x.value}[0..9]
  end

  def calculate_data_depending_on_subset_of_persons persons, families
    @birth_occurrences_by_decade = Array.new.push(DiagramData.new(0, 0))
    @death_occurrences_by_decade = Array.new.push(DiagramData.new(0, 0))
    @alive_persons_by_decade = Array.new.push(DiagramData.new(0, 0))
    @ages_alive = Array.new.push(DiagramData.new(0, 0))
    @average_age_males_alive = 0
    @average_age_females_alive = 0
    @ages_deceased = Array.new.push(DiagramData.new(0, 0))
    @average_age_males_deceased = 0
    @average_age_females_deceased = 0
    @average_age_of_male_at_marriage = 0
    @average_age_of_female_at_marriage = 0
    @average_age_of_male_at_first_child = 0
    @average_age_of_female_at_first_child = 0

    birth_years = Array.new
    death_years = Array.new

    ages_alive = Array.new
    males_alive = 0
    females_alive = 0
    ages_males_alive = 0
    ages_females_alive = 0

    ages_deceased = Array.new
    males_deceased = 0
    females_deceased = 0
    ages_males_deceased= 0
    ages_females_deceased = 0

    persons.each do |person|

      birth_year = get_year person.date_birth
      death_year = get_year person.date_death

      #birth years
      if not birth_year == "N/A"
        birth_years.push(birth_year)
        death_years.push(death_year)
      end

      #ages
      age = get_age person

      if get_year(person.date_death) == "N/A" #alive
        ages_alive.push(age)
        if person.gender == "M" || person.gender == "m"
          males_alive += 1
          ages_males_alive += age 
        end
        if person.gender == "F" || person.gender == "f"
          females_alive += 1
          ages_females_alive += age
        end
      else #deceased
        ages_deceased.push(age)
        if person.gender == "M" || person.gender == "m"
          males_deceased += 1
          ages_males_deceased += age 
        end
        if person.gender == "F" || person.gender == "f"
          females_deceased += 1
          ages_females_deceased += age
        end
      end
    end

    #first relevant year
    first_relevant_year = birth_years.sort.first
    if not first_relevant_year == nil #if nil -> further calculations impossible

      @birth_occurrences_by_decade = Array.new
      @death_occurrences_by_decade = Array.new
      @alive_persons_by_decade = Array.new
      @ages_alive = Array.new

      if death_years.include? "N/A" then death_year = Time.new.year else death_year = death_years.sort.first end
      if first_relevant_year > death_year
        first_relevant_year = death_year
      end

      #last relevant year
      if death_years.include? "N/A" 
        last_relevant_year = Time.new.year + 1
      else
        last_relevant_year = death_years.sort.last
      end

      husbands = 0
      wifes = 0
      ages_husbands = 0
      ages_wifes = 0

      age_at_first_child_male = 0
      age_at_first_child_female = 0
      fathers = 0
      mothers = 0

      @families.each do |family|
        #average ages at marriage
        year = get_year family.date_married
        if not year == "N/A"
          if not family.husband == "N/A"
            husband = @all_persons_hashmap[family.husband]
            husband_birth_year = get_year husband.date_birth
            if not husband_birth_year == "N/A" 
              age = year.to_i - husband_birth_year.to_i
              if age > -1
                ages_husbands += age
                husbands += 1
              end
            end
          end
          if not family.wife == "N/A"
            wife = @all_persons_hashmap[family.wife]
            wife_birth_year = get_year wife.date_birth
            if not wife_birth_year == "N/A"
              age = year.to_i - wife_birth_year.to_i
              if age > -1
                ages_wifes += age
                wifes += 1
              end
            end
          end
        end

        #average age at first child
        child_birth_years = Array.new
        family.children.each do |child_id|
          child = @all_persons_hashmap[child_id]
          if not child.date_birth == "N/A"
            birth_child = get_year child.date_birth
            if not birth_child == "N/A"
              child_birth_years.push(birth_child)
            end
          end
        end
        first_child_birth_year = child_birth_years.sort!.first #first child!

        if not family.husband == "N/A"
          husband = @all_persons_hashmap[family.husband]
          husband_birth_year = get_year husband.date_birth
          if not husband_birth_year == "N/A" 
            age = first_child_birth_year.to_i - husband_birth_year.to_i
            if age > 11 && age <= 100 #plausible age for fatherhood
              age_at_first_child_male += age
              fathers += 1
            end
          end
        end
        if not family.wife == "N/A"
          wife = @all_persons_hashmap[family.wife]
          wife_birth_year = get_year wife.date_birth
          if not wife_birth_year == "N/A" 
            age = first_child_birth_year.to_i - wife_birth_year.to_i
            if age > 11 && age <= 55 #plausible age for motherhood
              age_at_first_child_female += age
              mothers += 1
            end
          end
        end
      end 

      puts "ALIVE PERSONS BY DECADE START"
      start_time = Time.new
      # alive persons by decade
      actual_year = first_relevant_year
      while actual_year < last_relevant_year do
        @alive_persons_by_decade.push(DiagramData.new(actual_year.to_s + " - " + (actual_year + 10).to_s, 0))
        actual_year += 10
        if actual_year > last_relevant_year then actual_year = last_relevant_year end
      end
      persons.each do |person|
        birth_person = get_year person.date_birth
        if not birth_person == "N/A"
          index = (birth_person - last_relevant_year) / 10 #find first relevant index for performance
          while true do
            if person_alive_at_interval?(person, last_relevant_year+index*10, (last_relevant_year+10)+(index*10)) #this will be true, for first interval
              @alive_persons_by_decade[index].value += 1
            else
              break #person died in this index, no need for checking greater indizes
            end
            index += 1
          end
        end
      end
      puts "DONE. TIME NEEDED: " + (Time.new - start_time).to_s

      #birth_occurrences_by_decade
      @birth_occurrences_by_decade = get_diagram_data_array_for_decade(birth_years, first_relevant_year, last_relevant_year)

      #death_occurrences_by_decade
      @death_occurrences_by_decade = get_diagram_data_array_for_decade(death_years-Array.new.push("N/A"), first_relevant_year, last_relevant_year)

      #ages
      ages_alive.sort!
      oldest = ages_alive.last
      actual_year = 0
      while actual_year <= oldest do
        size_before = ages_alive.count
        ages_alive.delete(actual_year)
        @ages_alive.push(DiagramData.new(actual_year, size_before - ages_alive.count))
        actual_year += 1
      end

      ages_deceased.sort!
      oldest = ages_deceased.last
      actual_year = 0
      while actual_year <= oldest do
        size_before = ages_deceased.count
        ages_deceased.delete(actual_year)
        @ages_deceased.push(DiagramData.new(actual_year, size_before - ages_deceased.count))
        actual_year += 1
      end

      #average ages
      if males_alive > 0 then @average_age_males_alive = ages_males_alive / males_alive end
      if females_alive > 0 then @average_age_females_alive = ages_females_alive / females_alive end 

      if males_deceased > 0 then @average_age_males_deceased = ages_males_deceased / males_deceased end
      if females_deceased > 0 then @average_age_females_deceased = ages_females_deceased / females_deceased end 

      #average ages at marriage
      if husbands > 0 then @average_age_of_male_at_marriage = ages_husbands / husbands end
      if wifes > 0 then @average_age_of_female_at_marriage = ages_wifes / wifes end

      #average age at first child
      @average_age_of_male_at_first_child = age_at_first_child_male / fathers
      @average_age_of_female_at_first_child = age_at_first_child_female / mothers
    end
  end

  private
  def get_family_ids
    family_ids = Array.new
    @persons.each do |person|
      if not person.child_in_family == "N/A"
        family_ids.push(person.child_in_family) 
      end
      parent_in = person.parent_in_families
      if not parent_in == "N/A"
        parent_in.each do |family_id|
          family_ids.push(family_id)
        end
      end
    end
    family_ids = family_ids.uniq
    return family_ids
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

  def get_year date
    d = GEDCOM::Date.safe_new( date )
    if not d.is_date? then date = "N/A" end
    begin
      if (not d.first.has_year?) || date == "N/A"
        return "N/A"
      else
        year = d.first.year
        #workaround for wrong date formats
        if year == 0 #wrong format
          year = date.split(".").last
          begin
            return year.to_i
          rescue
            year = date.split(" ").last
            begin 
              return year.to_i
            rescue
              return "N/A"
            end
          end
        end
        return year
      end
    rescue
      return "N/A"
    end
  end

  def get_diagram_data_array values
    diagram_data_array = Array.new
    if values.count == 0 then return diagram_data_array.push(DiagramData.new(0, 0)) end
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
    diagram_data_array = Array.new
    if years.count == 0 then return diagram_data_array.push(DiagramData.new(0, 0)) end
    years.sort!
    
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

  def person_alive_at_interval? person, from_year, to_year
    birth_year = get_year person.date_birth
    death_year = get_year person.date_death
    if death_year == "N/A" then death_year = Time.new.year end
    if birth_year == "N/A" || death_year == "N/A" then return false end
    if birth_year <= to_year && death_year >= from_year then return true else return false end
  end
end