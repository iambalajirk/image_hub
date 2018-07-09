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
      byebug
      @image = request.raw_post
      @file_name = parse_file_name
      @extension = parse_extension

      if params[:directory_id].blank? || image.blank? || file_name.blank? || extension.blank?
        json_response({ error: ErrorMessages[:invalid_create_image_request] }, :not_acceptable) && return
      end

      @directory_id = params[:directory_id] == "me" ? user_id : params[:directory_id]
      @width, @height = get_dimensions
    end
  end

  def verify_image
    handle_exception do
      json_response({ error: ErrorMessages[:invalid_image] }, :not_acceptable) && return unless valid_image
    end
  end

  private

  def parse_file_name
    request.headers['Content-Name']
  end

  def parse_extension
    request.headers['Content-Type']
  end

  def get_dimensions
    image[0x10..0x18].unpack('NN')
  end

  def valid_image
    width >= MIN_WIDTH && width <= MAX_WIDTH && height >= MIN_HEIGHT && height <= MAX_HEIGHT
  end

end
