require './lib/family_tree_parser'

class StaticPagesController < ApplicationController
	def home
		if current_user != nil
			@trees = GedcomFile.where(:user_id => current_user.id)
		end
	end

	def filters
		@fields = ["Firstname","Lastname","Occupation","Location: Birth","Location: Marriage","Location: Death","Location: Burial","Time: Birth","Time: Marriage","Time: Death","Time: Burial"]
		
		parser = MyGedcomParser.new
		parser.parse './family.ged'
		@persons = parser.get_all_persons
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
