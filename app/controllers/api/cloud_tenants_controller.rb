module Api
  class CloudTenantsController < BaseController
    def cloud_tenants_query_resource(object)
      object.cloud_tenants
    end
  end
end
