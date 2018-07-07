# frozen_string_literal: true

class ApiApplicationController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :parse_body, :get_user_details, only: :create

  attr_accessor :body, :user_id

  include Response
  include UserConcern

  private

  def parse_body
    @body = JSON.parse(request.raw_post)
  end
end
