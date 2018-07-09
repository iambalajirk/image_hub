# frozen_string_literal: true

module ImageConcern
  MIN_WIDTH = 30
  MIN_HEIGHT = 30
  MAX_WIDTH = 5000
  MAX_HEIGHT = 5000

  # The root folder for the user will be created when the user signs up!!.
  # Here we will check the root folder and the folder in the request is present or not(using directory_path).
  # recursively check for the folders if the end folder exists or not. Throw error if so.
  # The root directory ID will be by default the user_id.
  def load_image_configs
    handle_exception do 
      @image = body[:image]
      @file_name = body[:name]
      @parent_directory_id = params[:_directory_id] == "me" ? user_id : params[:_directory_id]

      width, height = FastImage.size(image)
      @dimension = { width: width, height: height }
      @extension = file_name.split(".")[1]
    end
  end

  def check_image_validity
    handle_exception do
      json_response({ error: ErrorMessages[:invalid_image] }, :not_acceptable) && return unless valid_image
    end
  end

  def validate_request?
    handle_exception do
      json_response({ error: ErrorMessages[:directory_not_present] }, :not_acceptable) && return if params[:_directory_id].blank? 
      json_response({ error: ErrorMessages[:invalid_create_image_request] }, :not_acceptable) && return if body[:image].blank? || body[:name].blank?
    end
  end

  private
  
  def valid_image
    dimension[:width] >= MIN_WIDTH && dimension[:width] <= MAX_WIDTH && dimension[:height] >= MIN_HEIGHT && dimension[:height] <= MAX_HEIGHT
  end

end
