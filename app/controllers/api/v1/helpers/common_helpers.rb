module Api
  module V1
    module Helpers
      module CommonHelpers
        def show_error status, message
          render json: {
            error: { message: message }
          }, status: status
        end
      end
    end
  end
end
