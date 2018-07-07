# frozen_string_literal: true

module ImageConcern
  MIN_WIDTH = 300
  MIN_HEIGHT = 300
  MAX_WIDTH = 5000
  MAX_HEIGHT = 5000

  def parse_image
    @image = body['image']
    @file_name = body['name']
    width, height = FastImage.size(image)
    @dimension = { width: width, height: height }
  end

  def check_image_validity
    byebug
    unless valid_image
      # TODO: move the error messages to a yml file.
      json_response({ error: 'Image must be withing the following dimensions 300*300 to 5000*5000' }, :not_acceptable) && return
    end
  end

  def valid_image
    dimension[:width] >= MIN_WIDTH && dimension[:width] <= MAX_WIDTH && dimension[:height] >= MIN_HEIGHT && dimension[:height] <= MAX_HEIGHT
  end
end
