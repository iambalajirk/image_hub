# frozen_string_literal: true

module UserConcern
	include Constant
	
  def load_user
    # Can be replaced with the actual user finding and loading their userIdlogic in future.
    @user_id = SAMPLE_USER_ID
  end
end
