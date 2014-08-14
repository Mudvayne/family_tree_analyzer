require 'zip'
require './lib/myGedcomParser.rb'

class GedcomFile < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :filename
  validate :parse_gedcom_file

  def self.create_zip_archive
    users = User.all.select { |user| user.gedcom_files.size > 0 }
    
    io = StringIO.new
    Zip::OutputStream.write_buffer(io) do |output_stream|
      users.each do |user|
        user.gedcom_files.each do |gedcom_file|
          path = user.escape_mail_for_filesystem + "/" + gedcom_file.filename + ".ged"
          output_stream.put_next_entry(path)
          output_stream.puts(gedcom_file.data)
        end
      end
    end
    io.rewind
    return io.string
  end

  def filename_with_extension
    return filename + ".ged"
  end

  def parse_gedcom_file
    gedcom_data = StringIO.new
    gedcom_data.write(data)
    gedcom_data.rewind
    parser = MyGedcomParser.new
    begin
      parser.parse gedcom_data
      if parser.get_all_persons.count > 0
        return parser
      else
        raise ArgumentError.new
      end
    rescue => e
      errors.add(:base, "Invalid gedcom file")
      return false
    end
  end

  def self.get_data_hash gedcom_file_id
    cache_key = "FAMILY_" + gedcom_file_id
    Rails.cache.fetch(cache_key) do
      parser = GedcomFile.find(gedcom_file_id).parse_gedcom_file
      all_persons = parser.get_all_persons
      all_persons_hashmap = Hash.new
      all_persons.each do |person|
        all_persons_hashmap[person.id] = person
      end

      all_families = parser.get_all_families
      all_families_hashmap = Hash.new
      all_families.each do |family|
        all_families_hashmap[family.id] = family
      end
      
      {
        :all_persons => all_persons,
        :all_persons_hashmap => all_persons_hashmap,
        :all_families => all_families,
        :all_families_hashmap => all_families_hashmap
      }
    end
  end
end
