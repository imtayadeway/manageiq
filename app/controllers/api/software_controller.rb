module Api
  class SoftwareController < BaseController
    def software_query_resource(object)
      object.guest_applications
    end
  end
end
