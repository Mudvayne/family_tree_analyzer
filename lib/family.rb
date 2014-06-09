class Family

  attr_reader :id, :husband, :wife, :children

  def initialize id, husband, wife, children
    @id = id
    @husband = husband
    @wife = wife
    @children = children
  end

  def to_s
    string = "Family: " + id + " Husband: " + husband + " Wife: " + wife
    string_children = ""
    if not children.empty?
      children.each do |child|
        string_children += string_children
      end
    end
    string += string_children
  end
end