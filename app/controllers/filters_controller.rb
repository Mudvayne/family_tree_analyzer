require './lib/myGedcomParser'

class FiltersController < ApplicationController
  before_action :set_fields, :set_all_persons_and_families

  def index
    @persons = @all_persons
    @persons_for_analysis = Array.new(0)
  end

  def update
    params[:persons] = params[:persons] || Array.new
    params[:persons_for_analysis] = params[:persons_for_analysis] || Array.new

    @persons_for_analysis = get_last_persons_by_id params[:persons_for_analysis]
    @persons = get_last_persons_by_id params[:persons]

    if params[:button] == "to_right"
      matched_persons = find_all_matches @persons
      to_right matched_persons
    elsif params[:button] == "to_left"
      matched_persons = find_all_matches @persons_for_analysis
      to_left matched_persons
    end

    case matched_persons.count
    when 0
      flash.now[:warning] = "0 matches! try a different filter."
    when 1
      flash.now[:success] = "one match!"
    else
      flash.now[:success] = matched_persons.count.to_s + " matches!"
    end

    render 'index'
  end

  private
  def set_fields
    @fields = Hash.new
    fields = ["Firstname","Lastname","Occupation","Location: Birth","Location: Death","Location: Burial","Date: Birth","Date: Marriage","Date: Death","Date: Burial"]
    fields.each do |field|
      key = field.downcase.gsub(":", "_").gsub(" ", "")
      @fields[key] = field
    end
  end
  
  def set_all_persons_and_families
    family = './royal.ged'

=begin
    if not Rails.cache.exist?(family)
=end
      parser = MyGedcomParser.new
      parser.parse family
      @all_persons = parser.get_all_persons
      @all_persons_hashmap = Hash.new
      @all_persons.each do |person|
        @all_persons_hashmap[person.id] = person
      end
      @families = parser.get_all_families
=begin
      Rails.cache.write(family + "all_persons_hashmap", @all_persons_hashmap)
      Rails.cache.write(family + "all_persons", @all_persons)
      Rails.cache.write(family + "families", @families)
      Rails.cache.write(family, true) # signal that this family is cached
    else
      @all_persons = Rails.cache.fetch(family + "all_persons")
      @all_persons_hashmap = Rails.cache.fetch(family + "all_persons_hashmap")
      @families = Rails.cache.fetch(family + "families")
    end
=end
  end
  
  def to_right matched_persons
    @persons_for_analysis.concat(matched_persons)
    @persons = @persons - matched_persons
  end
  
  def to_left matched_persons
    @persons.concat(matched_persons)
    @persons_for_analysis = @persons_for_analysis - matched_persons
  end
  
  def get_last_persons_by_id ids
    result = Array.new
    ids.each do |person_id|
      if @all_persons_hashmap.has_key? person_id
        result << @all_persons_hashmap[person_id]
      end
    end
    return result
  end

  def find_all_matches list_of_persons
    matched_persons = list_of_persons
    handle_empty_fields
    checkbox_set = false

    if params[:all_radiobox] == "on"
      return matched_persons
    end

    if params[:firstname_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.firstname.include? params[:firstname] })
    end

    if params[:lastname_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.lastname.include? params[:lastname] })
    end

    if params[:occupation_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.occupation.include? params[:occupation] })
    end

    if params[:date_birth_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_birth.include? params[:date_birth] })
    end

    if params[:date_marriage_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (get_persons_married_at_date params[:date_marriage])
    end

    if params[:date_death_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_death.include? params[:date_death] })
    end

    if params[:date_burial_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_burial.include? params[:date_burial] })
    end

    if params[:location_birth_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_birth.include? params[:location_birth] })
    end

    if params[:location_death_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_death.include? params[:location_death] })
    end

    if params[:location_burial_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_burial.include? params[:location_burial] })
    end

    if params[:relatives_checkbox] == "on"
      checkbox_set = true
      relatives = Array.new

      if params[:relative_filter_type] == "kekule"
        relative_id = find_person_by_kekule(params[:relative_person_id], params[:relative_kekule_number].to_i)
        relatives.push(get_person_by_id relative_id)
      elsif params[:relative_filter_type] == "descendants"
        descendent_ids = find_all_descendants(params[:relative_person_id], Array.new)
        descendent_ids.each do |descendent_id|
          relatives.push(get_person_by_id descendent_id)
        end
      elsif params[:relative_filter_type] == "ancestors"
        ancestor_ids = find_all_ancestors(params[:relative_person_id], Array.new)
        ancestor_ids.each do |ancestor_id|
          relatives.push(get_person_by_id ancestor_id)
        end
      end
      matched_persons = matched_persons & relatives
    end

    if matched_persons.count == list_of_persons.count && checkbox_set == false #no matches
      return Array.new
    else
      return matched_persons
    end
  end

  def handle_empty_fields
    if params[:firstname] == "" then params[:firstname] = "N/A" end
    if params[:lastname] == "" then params[:lastname] = "N/A" end
    if params[:occupation] == "" then params[:occupation] = "N/A" end
    if params[:date_birth] == "" then params[:date_birth] = "N/A" end
    if params[:date_marriage] == "" then params[:date_marriage] = "N/A" end
    if params[:date_death] == "" then params[:date_death] = "N/A" end
    if params[:date_burial] == "" then params[:date_burial] = "N/A" end
    if params[:location_birth] == "" then params[:location_birth] = "N/A" end
    if params[:location_death] == "" then params[:location_death] = "N/A" end
    if params[:location_burial] == "" then params[:location_burial] = "N/A" end
  end

=begin
  def find_all_descendants person_id, descendent_ids
    @families.each do |family|
      if family.husband == person_id || family.wife == person_id
        family.children.each do |child|
          if not descendent_ids.include? child 
            descendent_ids.push(child) 
            find_all_descendants child, descendent_ids
          end
        end
      end
    end
    return descendent_ids
  end
=end

  def find_all_descendants person_id, descendent_ids
    person = get_person_by_id person_id
    family_ids = person.parent_in_families
    if not family_ids == "N/A"
      families = Array.new
      family_ids.each do |family_id|
        families.push(get_family_by_id family_id)
      end
      families.each do |family|
        if family.husband == person_id || family.wife == person_id
          family.children.each do |child|
            if not descendent_ids.include? child 
              descendent_ids.push(child) 
              find_all_descendants child, descendent_ids
            end
          end
        end
      end
    end
    return descendent_ids
  end

  def find_all_ancestors person_id, ancestor_ids
    person = get_person_by_id person_id
    if not person.child_in_family == nil
      family = get_family_by_id person.child_in_family
      if not family == "no such family"
        if (not ancestor_ids.include? family.husband) && (not family.husband == "N/A")
          ancestor_ids.push(family.husband)
          find_all_ancestors(family.husband,ancestor_ids)
        end
        if (not ancestor_ids.include? family.wife) && (not family.wife == "N/A")
          ancestor_ids.push(family.wife)
          find_all_ancestors(family.wife, ancestor_ids)
        end
      end
    end
    return ancestor_ids
  end

#returns found person_id or nil if no person was found
  def find_person_by_kekule person_id, kekule
    if kekule < 1 then return nil end
    #generate path
    calc = kekule
    path = Array.new

    while calc > 1 do 
      if calc % 2 == 0 
        path.push(0) #male
      else 
        path.push(1) #female
      end
      calc /= 2
    end
    path.reverse! #reverse the path for cycle later

    actual_person_id = person_id
    family_id = ""
    
    #go through path
    while path.count > 0 do
      person = get_person_by_id actual_person_id
      family_id = person.child_in_family
      if family_id == "N/A" then return nil end #person with empty FAMC field found in path -> return nil
      family = get_family_by_id family_id

      if path.shift == 0 # go for father
        actual_person_id = family.husband
      else # go for mother
        actual_person_id = family.wife
      end
    end
    return actual_person_id
  end

  def get_person_by_id person_id
    @all_persons.each do |person|
      if person.id == person_id
        return person
      end
    end
    return "no such person"
  end

  def get_family_by_id family_id
    @families.each do |family|
      if family.id == family_id
        return family
      end
    end
    return "no such family"
  end

  def get_persons_married_at_date date_marriage
    persons = Array.new
    @families.each do |family|
      if family.date_married.include? date_marriage
        persons.push(get_person_by_id family.husband)
        persons.push(get_person_by_id family.wife)
      end
    end
    return persons
  end
end