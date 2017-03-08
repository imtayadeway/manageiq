module Api
  class SharedVmsController < BaseController
    def index
      resources = shared_vms

      # # Roughly what we do elsewhere:
      miq_expression = filter_param(Vm)

      if miq_expression
        sql, includes, meta = miq_expression.to_sql
        if meta[:supported_by_sql]
          resources = resources.includes(includes) if includes
          resources = resources.where(sql)
        end
        ruby = miq_expression.to_ruby
        resources = resources.select { |resource| Condition.subst_matches?(ruby, resource) }
      end

      # # can't sort - it's an array
      # sort_options = sort_params(klass) if shared_vms.respond_to?(:reorder)

      # shared_vms = shared_vms.reorder(sort_options) if sort_options.present?

      # options = {}
      # options[:order] = sort_options if sort_options.present?
      # options[:offset], options[:limit] = expand_paginate_params if paginate_params?
      # options[:filter] = miq_expression if miq_expression

      # shared_vms = Rbac.filtered(shared_vms, options)

      render_collection(:shared_vms, resources)
    end

    def show
      render_resource(:shared_vms, shared_vms.find(@req.c_id))
    end

    private

    def shared_vms
      Vm.shared_with(User.current_user)
    end
  end
end
