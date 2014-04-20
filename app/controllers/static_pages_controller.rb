class StaticPagesController < ApplicationController
	def home
		@gedcomfile = GedcomFile.new
		puts "test"
	end

	def filters
	end

	def select_tree
	end

	def upload
		#@gedcomfile.read_data(post_params["file"])
		#@gedcomfile.save
		#render :nothing => true
		puts "test"
	end

	def post_params
		allow = [:data, :filename]
		params.require(:file).permit(allow)
	end
end
