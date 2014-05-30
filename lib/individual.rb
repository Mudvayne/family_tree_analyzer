class Individual

  attr_reader :id, :dateofbirth, :dateofmarriage, :dateofdeath, :dateofburial, :placeofbirth, :placeofmarriage, :placeofdeath, :placeofburial

  def initialize(id, name, dateofbirth, dateofmarriage, dateofdeath, dateofburial, placeofbirth, placeofmarriage, placeofdeath, placeofburial)
    @id = id
    @name = name
    @dateofbirth = dateofbirth
    @dateofmarriage = dateofmarriage
    @dateofdeath = dateofdeath
    @dateofburial = dateofburial
    @placeofbirth = placeofbirth
    @placeofmarriage = placeofmarriage
    @placeofdeath = placeofdeath
    @placeofburial = placeofburial
  end

  def firstname
    if @name == "//" || @name == "/"
      return "N/A"
    end
    if @name.split("/").first != nil && @name.split("/").first != ""
      return @name.split("/").first
    end
    return "N/A"
  end

  def lastname
    if @name == "//" || @name == "/"
      return "N/A"
    end
    if firstname == "N/A"
      return @name.delete("/")
    else
      if @name.split("/").last.size != @name.delete("/").size
        return @name.split("/").last
      else
        return "N/A"
      end
    end
  end
end