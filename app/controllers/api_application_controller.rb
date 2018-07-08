# frozen_string_literal: true

class ApiApplicationController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :parse_body, :parse_api_params, only: :create
  before_action :load_user

  attr_accessor :body, :per_page, :page, :user_id

  include Response
  include UserConcern

  private

  def parse_body
    @body = JSON.parse(request.raw_post).symbolize_keys
  end

  def parse_api_params
  	@per_page = body[:per_page]
  end

  def handle_exception(&block)
    begin
      yield
    rescue Exception => e
      Rails.logger.error "Error, e :#{e}"
      json_response({:error => ErrorMessages[:something_wrong]}, :internal_server_error) and return
    end
  end
end
