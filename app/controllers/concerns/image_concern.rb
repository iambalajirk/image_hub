# frozen_string_literal: true

module ImageConcern
  MIN_WIDTH = 30
  MIN_HEIGHT = 30
  MAX_WIDTH = 5000
  MAX_HEIGHT = 5000

  def load_image_configs
    @image = body[:image]
    @file_name = body[:name]
    width, height = FastImage.size(image)
    @dimension = { width: width, height: height }
    @extension = body[:name].split(".")[1]
    @directory_path = request.fullpath.sub(Constant::URL_PATH_PREFIX,  "")
  end

  def check_image_validity
    unless valid_image
      # TODO: move the error messages to a yml file.
      json_response({ error: ErrorMessages[:invalid_image] }, :not_acceptable) && return
    end
  end

  private
  
  def valid_image
    dimension[:width] >= MIN_WIDTH && dimension[:width] <= MAX_WIDTH && dimension[:height] >= MIN_HEIGHT && dimension[:height] <= MAX_HEIGHT
  end

end
