require './lib/family_tree_parser'

class FiltersController < ApplicationController
  before_action :set_fields, :set_all_persons

  def index
    @persons = @all_persons
    @personsforanalysis = Array.new(0)
=begin    
    puts "************** params **************"
    params.each do |i|
      puts i
    end
    puts "************ end params ************"
=end
  end

  def update
    params[:persons] = params[:persons] || Array.new
    params[:personsforanalysis] = params[:personsforanalysis] || Array.new

    @personsforanalysis = get_last_persons_by_id params[:personsforanalysis]
    @persons = get_last_persons_by_id params[:persons]

    if params[:button] == "to_left"
      to_left
    elsif params[:button] == "to_right"
      to_right
    end

    render 'index'
  end

  def to_right
    matched_persons = find_all_matches @persons

    @personsforanalysis.concat(matched_persons)
    @persons = @persons - matched_persons
  end

  def to_left
    matched_persons = find_all_matches @personsforanalysis

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
    result = []
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

    if not params[:firstname].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.firstname.include? params[:firstname] })
    end

    if not params[:lastname].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.lastname.include? params[:lastname] })
    end

    if not params[:occupation].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.occupation.include? params[:occupation] })
    end

    if not params[:date_birth].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_birth.include? params[:date_birth] })
    end

    if not params[:date_marriage].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_marriage.include? params[:date_marriage] })
    end

    if not params[:date_death].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_death.include? params[:date_death] })
    end

    if not params[:date_burial].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.date_burial.include? params[:date_burial] })
    end

    if not params[:location_birth].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_birth.include? params[:location_birth] })
    end

    if not params[:location_marriage].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_marriage.include? params[:location_marriage] })
    end

    if not params[:location_death].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_death.include? params[:location_death] })
    end

    if not params[:location_burial].strip.empty?
      matched_persons = matched_persons & (list_of_persons.select { |person| person.location_burial.include? params[:location_burial] })
    end

    return matched_persons
  end
end
