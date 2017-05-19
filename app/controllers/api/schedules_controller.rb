module Api
  class SchedulesController < BaseController
    def schedules_query_resource(object)
      object ? object.list_schedules : {}
    end
  end
end
