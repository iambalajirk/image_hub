class DirectoryController < ApiApplicationController
	before_action :load_directory_configs
	before_action :load_directory_contents, :only => :show
	before_action :load_new_directory_configs, :check_directory_presence, :only => :create

	attr_accessor :path, :directory_id, :level, :name, :parent_directory_id, :images, :directories, :new_directory_name

	include DirectoryConcern
	include StorageConcern
	include FileSystemConcern

	def show
		json_response(show_response_hash, :ok) and return
	end

	def create
		# Receive the request and create a new virtual sub-directory reference.
		response = create_directory
		json_response(response, :created) and return
		rescue => e
	  	Rails.logger.error "Error while creating a new directory, error :#{e}"
	  	json_response( {error: 'Something went wrong'}, :internal_server_error)
	end

	private

	def load_new_directory_configs
		@new_directory_name = body[:name]
	end

	def show_response_hash
		{
			id: directory_id,
			name: name,
			level: level,
			parent_directory_id: parent_directory_id,
			images: images,
			directories: directories
		}
	end
end
