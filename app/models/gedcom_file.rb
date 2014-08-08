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
end
