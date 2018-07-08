class DirectoryController < ApiApplicationController
	before_action :load_path, :load_directory_configs
	before_action :load_directory_contents, :only => :index
	before_action :load_new_directory_configs, :check_directory_presence, :only => :create

	attr_accessor :path, :level, :name, :directory_id, :parent_directory_id, :images, :directories, :new_directory_name

	include DirectoryConcern
	include StorageConcern
	include FileSystemConcern

	def index
		# Load all the images and directory inside this directory also show the meta.
		json_response(index_response, :ok) and return
	end

	def create
		# Receive the request and create a new sub-directory.
		response = create_directory
		json_response(response, :created) and return
		rescue => e
	  	Rails.logger.error "Error while creating a new directory, error :#{e}"
	  	json_response( {error: 'Something went wrong'}, :internal_server_error)
	end

	private

	def load_path
		@path = request.fullpath.sub(Constant::DIRECTORY_URL_PATH_PREFIX,  "")
	end

	def load_new_directory_configs
		@new_directory_name = body[:name]
	end

	def index_response
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
