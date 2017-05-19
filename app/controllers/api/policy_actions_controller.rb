module Api
  class PolicyActionsController < BaseController
    def policy_actions_query_resource(object)
      return {} unless object.respond_to?(:miq_actions)
      object.miq_actions
    end
  end
end
