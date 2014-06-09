class Family

  attr_reader :id, :husband, :wife, :children

  def initialize id, husband, wife, children
    @id = id
    @husband = husband
    @wife = wife
    @children = children
  end

  def to_s
    puts "TO STRING"
    string = "Family: " + id + "\nHusband: " + husband + "\nWife: " + wife + "\nChildren: "
    string_children = ""
    if not children.empty?
      children.each do |child|
        string_children += child
      end
    end
    string += string_children
    puts string
    return string
  end
end