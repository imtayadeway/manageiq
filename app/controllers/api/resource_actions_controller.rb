module Api
  class ResourceActionsController < BaseController
    def resource_actions_query_resource(object)
      object.resource_actions
    end
  end
end
