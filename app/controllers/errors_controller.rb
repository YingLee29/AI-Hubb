class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  layout "layouts/login_layout"

  def errors_404
  end

  def errors_500
  end

  def errors_403
  end
end
