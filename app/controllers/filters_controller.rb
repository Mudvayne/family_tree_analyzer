require './lib/myGedcomParser'

class FiltersController < ApplicationController
  before_action :set_fields, :set_all_persons_and_families

  def index
    @persons = @all_persons
    @persons_for_analysis = Array.new(0)
    session[:persons] = @persons.map { |person| person.id }
    session[:persons_for_analysis] = @persons_for_analysis.map { |person| person.id }
    sort_lists
  end

  def update
    @persons = session[:persons].map {|person_id| @all_persons_hashmap[person_id] }
    @persons_for_analysis = session[:persons_for_analysis].map {|person_id| @all_persons_hashmap[person_id] }

    if params[:button] == "to_right"
      matched_persons = find_all_matches @persons
      @persons_for_analysis.concat(matched_persons)
      @persons = @persons - matched_persons
    elsif params[:button] == "to_left"
      matched_persons = find_all_matches @persons_for_analysis
      @persons.concat(matched_persons)
      @persons_for_analysis = @persons_for_analysis - matched_persons
    end

    case matched_persons.count
    when 0
      flash.now[:warning] = "0 matches! try a different filter."
    when 1
      flash.now[:success] = "one match!"
    else
      flash.now[:success] = matched_persons.count.to_s + " matches!"
    end
    sort_lists

    session[:persons] = @persons.map { |person| person.id }
    session[:persons_for_analysis] = @persons_for_analysis.map { |person| person.id }
    
    render 'index'
  end

  def ajax_persons_not_for_analysis
    ajax_pagination session[:persons].map {|person_id| @all_persons_hashmap[person_id] },
                             lambda{ |person| [person.firstname, person.lastname] }
  end

  def ajax_persons_for_analysis
    ajax_pagination session[:persons_for_analysis].map {|person_id| @all_persons_hashmap[person_id] },
                             lambda{ |person| [person.firstname, person.lastname] }
  end

  def ajax_all_persons
    ajax_pagination @all_persons, lambda{ |person| [person.firstname, person.lastname,
                                                    person.id, person.date_birth, person.date_death,
                                                    person.location_birth, person.location_death,] }
  end

  private
  def ajax_pagination data_source, mapper
    start = params[:start].to_i
    length = params[:length].to_i
    if params[:search].nil? || params[:search][:value].nil?
      search = ""
    else
      search = params[:search][:value]
    end

    search_array = params[:columns].values.map { |col| col[:search][:value] }
    paginated_persons = data_source
            .map(&mapper)
            .select { |person| person.any? { |attribute| attribute.include? search } }
            .select { |person| person.each_with_index.map { |attribute, i| attribute.include? search_array[i] }.all? }

    render json: {
      data: paginated_persons.slice(start, length),
      recordsTotal: data_source.count,
      recordsFiltered: paginated_persons.count
    }
  end

  def sort_lists
    @persons.sort! {|x,y| x.firstname.downcase <=> y.firstname.downcase}
    @persons_for_analysis.sort! {|x,y| x.firstname.downcase <=> y.firstname.downcase}
  end

  def set_fields
    @fields = Hash.new
    fields = ["Firstname","Lastname","Occupation","Location: Birth","Location: Death","Location: Burial","Date: Birth","Date: Marriage","Date: Death","Date: Burial"]
    fields.each do |field|
      key = field.downcase.gsub(":", "_").gsub(" ", "")
      @fields[key] = field
    end
  end
  
  def set_all_persons_and_families
    if current_user.gedcom_files.where(id: params[:id]).count == 0
      raise ArgumentError.new "invalid user"
    end

    persons_and_family_data = GedcomFile.get_data_hash params[:id]

    @all_persons = persons_and_family_data[:all_persons]
    @all_persons_hashmap = persons_and_family_data[:all_persons_hashmap]
    @all_families = persons_and_family_data[:all_families]
    @all_families_hashmap = persons_and_family_data[:all_families_hashmap]
  end
  
  def get_persons_by_id ids
    result = Array.new
    ids.each do |person_id|
      if @all_persons_hashmap.has_key? person_id
        result << @all_persons_hashmap[person_id]
      end
    end
    return result
  end

  def find_all_matches list_of_persons
    matched_persons = list_of_persons.clone
    handle_empty_fields
    checkbox_set = false

    if params[:all_radiobox] == "on"
      return matched_persons
    end

    if params[:firstname_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.firstname.include? params[:firstname] }
    end

    if params[:lastname_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.lastname.include? params[:lastname] }
    end

    if params[:occupation_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.occupation.include? params[:occupation] }
    end

    if params[:date_birth_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.date_birth.include? params[:date_birth] }
    end

    if params[:date_marriage_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (get_persons_married_at_date params[:date_marriage])
    end

    if params[:date_death_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.date_death.include? params[:date_death] }
    end

    if params[:date_burial_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.date_burial.include? params[:date_burial] }
    end

    if params[:location_birth_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.location_birth.include? params[:location_birth] }
    end

    if params[:location_death_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.location_death.include? params[:location_death] }
    end

    if params[:location_burial_checkbox] == "on"
      checkbox_set = true
      matched_persons.keep_if { |person| person.location_burial.include? params[:location_burial] }
    end

    if params[:relatives_checkbox] == "on"
      checkbox_set = true
      relatives = Array.new

      if params[:relative_filter_type] == "kekule"
        relative_id = find_person_by_kekule(params[:relative_person_id], params[:relative_kekule_number].to_i)
        relatives.push(@all_persons_hashmap[relative_id] )
      elsif params[:relative_filter_type] == "descendants"
        descendent_ids = find_all_descendants(params[:relative_person_id], Array.new)
        descendent_ids.each do |descendent_id|
          relatives.push(@all_persons_hashmap[descendent_id])
        end
      elsif params[:relative_filter_type] == "ancestors"
        ancestor_ids = find_all_ancestors(params[:relative_person_id], Array.new)
        ancestor_ids.each do |ancestor_id|
          relatives.push(@all_persons_hashmap[ancestor_id])
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
    person = @all_persons_hashmap[person_id]
    family_ids = person.parent_in_families
    if not family_ids == "N/A"
      families = Array.new
      family_ids.each do |family_id|
        families.push(@all_families_hashmap[family_id])
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
    person = @all_persons_hashmap[person_id]
    if not person.child_in_family == nil
      family = @all_families_hashmap[person.child_in_family]
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
      person = @all_persons_hashmap[actual_person_id]
      family_id = person.child_in_family
      if family_id == "N/A" then return nil end #person with empty FAMC field found in path -> return nil
      family = @all_families_hashmap[family_id]

      if path.shift == 0 # go for father
        actual_person_id = family.husband
      else # go for mother
        actual_person_id = family.wife
      end
    end
    return actual_person_id
  end

  def get_persons_married_at_date date_marriage
    persons = Array.new
    @all_families.each do |family|
      if family.date_married.include? date_marriage
        persons.push(@all_persons_hashmap[family.husband])
        persons.push(@all_persons_hashmap[family.wife])
      end
    end
    return persons
  end
end