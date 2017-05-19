module Api
  class ServiceRequestsController < BaseController
    USER_CART_ID = 'cart'.freeze

    def approve_resource(type, id, data)
      raise "Must specify a reason for approving a service request" unless data["reason"].present?
      api_action(type, id) do |klass|
        provreq = resource_search(id, type, klass)
        provreq.approve(@auth_user, data['reason'])
        action_result(true, "Service request #{id} approved")
      end
    rescue => err
      action_result(false, err.to_s)
    end

    def deny_resource(type, id, data)
      raise "Must specify a reason for denying a service request" unless data["reason"].present?
      api_action(type, id) do |klass|
        provreq = resource_search(id, type, klass)
        provreq.deny(@auth_user, data['reason'])
        action_result(true, "Service request #{id} denied")
      end
    rescue => err
      action_result(false, err.to_s)
    end

    def edit_resource(type, id, data)
      request = resource_search(id, type, collection_class(:service_requests))
      RequestEditor.edit(request, data)
      request
    end

    def find_service_requests(id)
      klass = collection_class(:service_requests)
      return klass.find(id) if User.current_user.admin_user?
      klass.find_by!(:requester => User.current_user, :id => id)
    end

    def service_requests_search_conditions
      return {} if User.current_user.admin_user?
      {:requester => User.current_user}
    end

    def get_user(data)
      user_id = data['user_id'] || parse_id(data['user'], :users)
      raise 'Must specify a valid user_id or user' unless user_id
      User.find(user_id)
    end

    def add_approver_resource(type, id, data)
      user = get_user(data)
      miq_approval = MiqApproval.create(:approver => user)
      resource_search(id, type, collection_class(:service_requests)).tap do |service_request|
        service_request.miq_approvals << miq_approval
      end
    rescue => err
      raise BadRequestError, "Cannot add approver - #{err}"
    end

    def remove_approver_resource(type, id, data)
      user = get_user(data)
      resource_search(id, type, collection_class(:service_requests)).tap do |service_request|
        miq_approval = service_request.miq_approvals.find_by(:approver_name => user.name)
        miq_approval.destroy if miq_approval
      end
    rescue => err
      raise BadRequestError, "Cannot remove approver - #{err}"
    end

    def service_requests_query_resource(object)
      return {} unless object
      klass = collection_class(:service_requests)

      case object
      when collection_class(:service_orders)
        klass.where(:service_order_id => object.id)
      else
        klass.where(:source_id => object.id)
      end
    end

    def service_requests_add_resource(target, _type, _id, data)
      result = add_service_request(target, data)
      add_parent_href_to_result(result)
      log_result(result)
      result
    end

    def service_requests_remove_resource(target, type, id, _data)
      service_request_subcollection_action(type, id) do |service_request|
        api_log_info("Removing #{service_request_ident(service_request)}")
        remove_service_request(target, service_request)
      end
    end

    def find_service_orders(id)
      if id == USER_CART_ID
        ServiceOrder.cart_for(User.current_user)
      else
        ServiceOrder.find_for_user(User.current_user, id)
      end
    end

    private

    def service_request_ident(service_request)
      "Service Request id:#{service_request.id} description:'#{service_request.description}'"
    end

    def service_request_subcollection_action(type, id)
      klass = collection_class(:service_requests)
      result =
        begin
          service_request = resource_search(id, type, klass)
          yield(service_request) if block_given?
        rescue => e
          action_result(false, e.to_s)
        end
      add_subcollection_resource_to_result(result, type, service_request) if service_request
      add_parent_href_to_result(result)
      log_result(result)
      result
    end

    def add_service_request(target, data)
      if target.state != ServiceOrder::STATE_CART
        raise BadRequestError, "Must specify a cart to add a service request to"
      end
      workflow = service_request_workflow(data)
      validation = add_request_to_cart(workflow)
      if validation[:errors].present?
        action_result(false, validation[:errors].join(", "))
      elsif validation[:request].nil?
        action_result(false, "Unable to add service request")
      else
        result = action_result(true, "Adding service_request")
        add_subcollection_resource_to_result(result, :service_requests, validation[:request])
        result
      end
    rescue => e
      action_result(false, e.to_s)
    end

    def remove_service_request(target, service_request)
      target.class.remove_from_cart(service_request, User.current_user)
      action_result(true, "Removing #{service_request_ident(service_request)}")
    rescue => e
      action_result(false, e.to_s)
    end
  end
end
