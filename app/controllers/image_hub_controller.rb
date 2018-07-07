# frozen_string_literal: true

class ImageHubController < ApiApplicationController
  before_action :parse_image, :check_image_validity, only: :create

  attr_accessor :image, :file_name, :dimension

  include ImageConcern

  def create
    byebug
    json = { success: true }
    json_response(json, :created)
  end
end
