module Api
  class PoliciesController < BaseController
    REQUIRED_FIELDS = %w(name mode description towhat conditions_ids policy_contents).freeze

    def create_resource(type, _id, data = {})
      assert_id_not_specified(data, type)
      assert_all_required_fields_exists(data, type, REQUIRED_FIELDS)
      create_policy(data)
    end

    def edit_resource(type, id = nil, data = {})
      raise BadRequestError, "Must specify an id for editing a #{type} resource" unless id
      policy = resource_search(id, type, collection_class(:policies))
      begin
        add_policies_content(data, policy) if data["policy_contents"]
        policy.conditions = Condition.where(:id => data.delete("conditions_ids")) if data["conditions_ids"]
        policy.update_attributes(data)
      rescue => err
        raise BadRequestError, "Could not edit the policy - #{err}"
      end
      policy
    end

    private

    def create_policy(data)
      policy = MiqPolicy.create!(:name        => data.delete("name"),
                                 :description => data.delete("description"),
                                 :towhat      => data.delete("towhat"),
                                 :mode        => data.delete("mode"),
                                 :active      => true
                                )
      add_policies_content(data, policy)
      policy.conditions = Condition.where(:id => data.delete("conditions_ids")) if data["conditions_ids"]
      policy
    rescue => err
      policy.destroy if policy
      raise BadRequestError, "Could not create the new policy - #{err}"
    end

    def add_policies_content(data, policy)
      policy.miq_policy_contents.destroy_all
      data.delete("policy_contents").each do |policy_content|
        add_policy_content(policy_content, policy)
      end
    end

    def add_policy_content(policy_content, policy)
      actions_list = []
      policy_content["actions"].each do |action|
        actions_list << [MiqAction.find(action["action_id"]), action["opts"]]
      end
      policy.replace_actions_for_event(MiqEventDefinition.find(policy_content["event_id"]), actions_list)
      policy.save!
    end

    def policy_ident(policy)
      "Policy id:#{policy.id} name:'#{policy.name}'"
    end

    public

    def policies_query_resource(object)
      return {} unless object
      policy_profile_klass = collection_class(:policy_profiles)
      object.kind_of?(policy_profile_klass) ? object.members : object_policies(object)
    end

    def policies_assign_resource(object, _type, id = nil, data = nil)
      policy_assign_action(object, :policies, id, data)
    end

    def policies_unassign_resource(object, _type, id = nil, data = nil)
      policy_unassign_action(object, :policies, id, data)
    end

    def policies_resolve_resource(object, _type, id = nil, data = nil)
      policy_resolve_action(object, :policies, id, data)
    end

    private

    def policy_ident(ctype, policy)
      cdesc = (ctype == :policies) ? "Policy" : "Policy Profile"
      "#{cdesc}: id:'#{policy.id}' description:'#{policy.description}' guid:'#{policy.guid}'"
    end

    def object_policies(object)
      policy_klass = collection_class(:policies)
      object.get_policies.select { |p| p.kind_of?(policy_klass) }
    end

    def policy_specified(id, data, collection, klass)
      return klass.find(id) if id.to_i > 0
      parse_policy(data, collection, klass)
    end

    def parse_policy(data, collection, klass)
      return {} if data.blank?

      guid = data["guid"]
      return klass.find_by(:guid => guid) if guid.present?

      href = data["href"]
      href =~ %r{^.*/#{collection}/#{BaseController::CID_OR_ID_MATCHER}$} ? klass.find(from_cid(href.split('/').last)) : {}
    end

    def policy_subcollection_action(ctype, policy)
      if policy.present?
        result = yield if block_given?
      else
        result = action_result(false, "Must specify a valid #{ctype} href or guid")
      end

      add_parent_href_to_result(result)
      add_subcollection_resource_to_result(result, ctype, policy)
      log_result(result)
      result
    end

    def policy_assign_action(object, ctype, id, data)
      klass  = collection_class(ctype)
      policy = policy_specified(id, data, ctype, klass)
      policy_subcollection_action(ctype, policy) do
        api_log_info("Assigning #{policy_ident(ctype, policy)}")
        policy_assign(object, ctype, policy)
      end
    end

    def policy_unassign_action(object, ctype, id, data)
      klass  = collection_class(ctype)
      policy = policy_specified(id, data, ctype, klass)
      policy_subcollection_action(ctype, policy) do
        api_log_info("Unassigning #{policy_ident(ctype, policy)}")
        policy_unassign(object, ctype, policy)
      end
    end

    def policy_resolve_action(object, ctype, id, data)
      klass  = collection_class(ctype)
      policy = policy_specified(id, data, ctype, klass)
      policy_subcollection_action(ctype, policy) do
        api_log_info("Resolving #{policy_ident(ctype, policy)}")
        policy_resolve(object, ctype, policy)
      end
    end

    def policy_resolve(object, ctype, policy)
      res = (ctype == :policies) ? object.resolve_policies([policy.name]) : object.resolve_profiles([policy.id])
      action_result(true, "Resolving #{policy_ident(ctype, policy)}", :result => res)
    rescue => err
      action_result(false, err.to_s)
    end

    def policy_assign(object, ctype, policy)
      object.add_policy(policy)
      action_result(true, "Assigning #{policy_ident(ctype, policy)}")
    rescue => err
      action_result(false, err.to_s)
    end

    def policy_unassign(object, ctype, policy)
      object.remove_policy(policy)
      action_result(true, "Unassigning #{policy_ident(ctype, policy)}")
    rescue => err
      action_result(false, err.to_s)
    end
  end
end
