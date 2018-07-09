# frozen_string_literal: true

module ImageConcern
  MIN_WIDTH = 300
  MIN_HEIGHT = 300
  MAX_WIDTH = 5000
  MAX_HEIGHT = 5000

  # The root folder for the user will be created when the user signs up!!.
  # Here we will check the root folder and the folder in the request is present or not(using directory_path).
  # recursively check for the folders if the end folder exists or not. Throw error if so.
  # The root directory ID will be by default the user_id.
  def populate_image_configs
    handle_exception do
      @image = request.raw_post
      @file_name = parse_file_name
      @extension = parse_extension

      if params[:directory_id].blank? || image.blank? || file_name.blank? || extension.blank?
        json_response({ error: ErrorMessages[:invalid_create_image_request] }, :not_acceptable) && return
      end

      @directory_id = params[:directory_id] == 'me' ? user_id : params[:directory_id]
      @width, @height = get_dimensions
      json_response({ error: ErrorMessages[:unknown_extension] }, :not_acceptable) && return if width.nil? || height.nil?
    end
  end

  def verify_image
    handle_exception do
      json_response({ error: ErrorMessages[:invalid_image] }, :not_acceptable) && return unless valid_image
    end
  end

  def check_image_presence
    handle_exception do
      image_key = image_unique_id(user_id, directory_id, file_name)
      @image_id = generate_hash(image_key)

      meta = get_image_meta(user_id, image_id)

      # Raising conflict if there is another image with the same file name.
      # We can handle this differently too. Rename the original file with (1) suffix.
      json_response({ error: ErrorMessages[:image_exists] }, :conflict) && return if meta.present?
      true
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
    if extension == 'image/png'
      image[0x10..0x18].unpack('NN')
    elsif extension == 'image/gif'
      image[6..10].unpack('SS')
    elsif extension == 'image/jpeg' # Hack to get JPEG image size for now.
      base64 = Base64.encode64(image)
      FastImage.size "data:image/jpeg;base64,#{base64}"
    end
  end

  def valid_image
    width >= MIN_WIDTH && width <= MAX_WIDTH && height >= MIN_HEIGHT && height <= MAX_HEIGHT
  end
end
