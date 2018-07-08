# frozen_string_literal: true

class ImageHubController < ApiApplicationController
  before_action :load_image_configs, :check_image_validity, :load_parent_directory, :check_image_presence, only: :create

  attr_accessor :image, :file_name, :dimension, :extension, :directory_path, :parent_directory_id

  include ImageConcern
  include FileSystemConcern
  include DirectoryConcern
  include StorageConcern

  def create
  	response = create_image
    json_response(response, :created)
  rescue => e
  	Rails.logger.error "Error while creating a new image, error :#{e}"
  	json_response( {error: 'Something went wrong'}, :internal_server_error)
  end

end
