module Api
  class ResultsController < BaseController
    before_action :set_additional_attributes, :only => [:index, :show]

    private

    def set_additional_attributes
      @additional_attributes = %w(result_set)
    end

    def results_query_resource(object)
      object.miq_report_results
    end
  end
end
