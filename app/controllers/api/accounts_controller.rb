module Api
  class AccountsController < BaseController
    def accounts_query_resource(object)
      object.accounts
    end
  end
end
