class StaticPagesController < ApplicationController
	def home
	end

	def filters
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
