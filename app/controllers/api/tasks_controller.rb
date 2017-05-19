module Api
  class TasksController < BaseController
    def tasks_query_resource(object)
      klass = collection_class(:request_tasks)
      object ? klass.where(:miq_request_id => object.id) : {}
    end
  end
end
