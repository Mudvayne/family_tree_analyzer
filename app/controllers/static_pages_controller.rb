require './lib/gedcom'

class StaticPagesController < ApplicationController
	def home
	end

	def filters
		persons = 0
		fams = 0
		parser = GEDCOM::Parser.new do
		  before "INDI" do
		    persons += 1
		  end
		  before "FAM" do
    		fams += 1
  		end
		end
		parser.parse "./family.ged"
		@individuals = persons
		@families = fams

		@fields = ["Firstname","Lastname","Occupation","Location: Birth","Location: Marriage","Location: Death","Location: Burial","Time: Birth","Time: Marriage","Time: Death","Time: Burial"]
	end

	def select_tree
	end

	def upload
		#gedcomfile = GedcomFile.new(post_params)
		#puts post_params.path
		#Gedcom.file()
		#gedcomfile.save
		render :nothing => true
	end

	def post_params
		params.require(:gedcomfile).permit(:filename, :data)
	end
end
