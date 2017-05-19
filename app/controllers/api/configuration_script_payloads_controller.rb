module Api
  class ConfigurationScriptPayloadsController < BaseController
    def configuration_script_payloads_query_resource(object)
      object.configuration_script_payloads
    end
  end
end
