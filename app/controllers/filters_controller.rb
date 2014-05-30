require './lib/family_tree_parser'

class FiltersController < ApplicationController
  before_action :set_fields, :set_all_persons

  def index
    @persons = @all_persons
    @personsforanalysis = Array.new(0)
  end

  def update
    if params[:button] == "to_left" then
      to_left
    elsif params[:button] == "to_right" then
      to_right
    end
  end

  def to_right
    params[:persons] = params[:persons] || []
    params[:personsforanalysis] = params[:personsforanalysis] || []

=begin
    @persons = []
    params[:persons].each do |person_id|
      if @all_persons_hashmap.has_key? person_id
        @persons << @all_persons_hashmap[person_id]
      end
    end
=end

    @personsforanalysis = get_last_persons_by_id params[:personsforanalysis]
    @persons = get_last_persons_by_id params[:persons]
    #@personsforanalysis = []
=begin
    params[:personsforanalysis].each do |person_id|
      if @all_persons_hashmap.has_key? person_id
        @personsforanalysis << @all_persons_hashmap[person_id]
      end
    end
=end

    if not params[:occupation].strip.empty? then
      @personsforanalysis.concat(@persons.select { |person| person.firstname == params[:occupation] })
      @persons.delete_if { |person| person.firstname == params[:occupation] }
    end

    # get all from persons where occupation = 7
    # merge_with (&) get all from persons where name = "Hans"
    # merge_with get all from persons where city = "jdfpjosdpjosdfpjo"
    # persons.remove merge_with
    # personsforanalysis concat merge_with

    render 'index'
  end

  def to_left
    @persons = Array.new
    @personsforanalysis = Array.new
    render 'index'
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
    fields = ["Firstname","Lastname","Occupation","Location: Birth","Location: Marriage","Location: Death","Location: Burial","Time: Birth","Time: Marriage","Time: Death","Time: Burial"]
    fields.each do |field|
      key = field.downcase.sub(":", "_").sub(" ", "")
      @fields[key] = field
    end
  end
end
