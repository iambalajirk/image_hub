class DirectoryController < ApiApplicationController
	before_action :load_path, :load_directory_configs
	before_action :load_directory_contents, :only => :index

	attr_accessor :path, :level, :name, :directory_id, :parent_directory_id, :images, :directories

	include DirectoryConcern
	include StorageConcern
	include FileSystemConcern

	def index
		# Load all the images and directory inside this directory also show the meta.
		json_response(index_response, :ok) and return
	end

	def create
		# Receive the request and create a new sub-directory.
	end

	private

	def load_path
		@path = request.fullpath.sub(Constant::DIRECTORY_URL_PATH_PREFIX,  "")
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
