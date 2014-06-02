require './lib/myGedcomParser'

class FiltersController < ApplicationController
  before_action :set_fields, :set_all_persons

  def index
    @persons = @all_persons
    @personsforanalysis = Array.new(0)
  end

  def update
    params[:persons] = params[:persons] || Array.new
    params[:personsforanalysis] = params[:personsforanalysis] || Array.new

    @personsforanalysis = get_last_persons_by_id params[:personsforanalysis]
    @persons = get_last_persons_by_id params[:persons]

    if params[:button] == "to_right"
      matched_persons = find_all_matches @persons
      to_right matched_persons
    elsif params[:button] == "to_left"
      matched_persons = find_all_matches @personsforanalysis
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

  def to_right matched_persons
    @personsforanalysis.concat(matched_persons)
    @persons = @persons - matched_persons
    
  end

  def to_left matched_persons
    @persons.concat(matched_persons)
    @personsforanalysis = @personsforanalysis - matched_persons
  end

  def set_all_persons
    parser = MyGedcomParser.new
    parser.parse './royal.ged'
    @all_persons = parser.get_all_persons
    @all_persons_hashmap = Hash.new
    @all_persons.each do |person|
      @all_persons_hashmap[person.id] = person
    end
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

  def set_fields
    @fields = Hash.new
    fields = ["Firstname","Lastname","Occupation","Location: Birth","Location: Marriage","Location: Death","Location: Burial","Date: Birth","Date: Marriage","Date: Death","Date: Burial"]
    fields.each do |field|
      key = field.downcase.sub(":", "_").sub(" ", "")
      @fields[key] = field
    end
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
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_marriage.include? params[:date_marriage] })
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

    if params[:location_marriage_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_marriage.include? params[:location_marriage] })
    end

    if params[:location_death_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_death.include? params[:location_death] })
    end

    if params[:location_burial_checkbox] == "on"
      checkbox_set = true
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_burial.include? params[:location_burial] })
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
    if params[:location_marriage] == "" then params[:location_marriage] = "N/A" end
    if params[:location_death] == "" then params[:location_death] = "N/A" end
    if params[:location_burial] == "" then params[:location_burial] = "N/A" end
  end
end
