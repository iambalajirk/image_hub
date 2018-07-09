# frozen_string_literal: true

class ImageHubController < ApiApplicationController
  before_action :populate_image_configs, :verify_image, :check_image_presence, only: :create
  before_action :get_image_id, :load_image_meta, :load_image, :only => :show

  attr_accessor :image, :file_name, :extension, :width, :height, :image_id, :directory_id
  attr_accessor :image_id, :file_path # show only attributes

  include ImageConcern
  include FileSystemConcern
  include DirectoryConcern
  include StorageConcern

  def create
  	response = create_image
    json_response(response, :created)
  rescue => e
  	Rails.logger.error "Error while creating a new image, error :#{e}"
  	json_response( {error: ErrorMessages[:something_wrong]}, :internal_server_error)
  end

  def show
    response.headers['Cache-Control'] = "public, max-age=#{12.hours.to_i}"
    send_data(image, { filename: file_name, type: extension, disposition: "inline", status: :ok})
  rescue => e
    byebug
    json_response( {error: ErrorMessages[:something_wrong]}, :internal_server_error)
  end

  private

  def get_image_id
    json_response({error: 'Image ID is a must'}, :not_acceptable) and return if params[:id].nil?
    @image_id = params[:id]
  end

end
