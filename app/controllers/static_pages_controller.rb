require './lib/gedcom'

class StaticPagesController < ApplicationController
	def home
		@trees = GedcomFile.where(:user_id => current_user.id)
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
		post = post_params
		gedcomfile = GedcomFile.new({
			:data => post[:data].read,
			:filename => post[:filename],
			:user_id => current_user.id
		})
		
		if gedcomfile.save then
			flash[:success] = "You have successfully uploaded #{post[:filename]}."
		else
			flash[:danger] = "Error! File with name #{post[:filename]} already exists!";
		end
		redirect_to root_path
	end

	def post_params
		params.require(:gedcomfile).permit(:filename, :data)
	end
end
