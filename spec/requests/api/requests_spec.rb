RSpec.describe "Requests API" do
  let(:template) { FactoryGirl.create(:service_template, :name => "ServiceTemplate") }

  context "authorization" do
    it "is forbidden for a user without appropriate role" do
      api_basic_authorize

      run_get requests_url

      expect(response).to have_http_status(:forbidden)
    end

    it "does not list another user's requests" do
      other_user = FactoryGirl.create(:user)
      FactoryGirl.create(:service_template_provision_request,
                         :requester   => other_user,
                         :source_id   => template.id,
                         :source_type => template.class.name)
      api_basic_authorize collection_action_identifier(:requests, :read, :get)

      run_get requests_url

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("name" => "requests", "count" => 1, "subcount" => 0)
    end

    it "does not show another user's request" do
      other_user = FactoryGirl.create(:user)
      service_request = FactoryGirl.create(:service_template_provision_request,
                                           :requester   => other_user,
                                           :source_id   => template.id,
                                           :source_type => template.class.name)
      api_basic_authorize action_identifier(:requests, :read, :resource_actions, :get)

      run_get requests_url(service_request.id)

      expected = {
        "error" => a_hash_including(
          "message" => /Couldn't find MiqRequest/
        )
      }
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to include(expected)
    end

    it "a user can list their own requests" do
      _service_request = FactoryGirl.create(:service_template_provision_request,
                                            :requester   => @user,
                                            :source_id   => template.id,
                                            :source_type => template.class.name)
      api_basic_authorize collection_action_identifier(:requests, :read, :get)

      run_get requests_url

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("name" => "requests", "count" => 1, "subcount" => 1)
    end

    it "a user can show their own request" do
      service_request = FactoryGirl.create(:service_template_provision_request,
                                           :requester   => @user,
                                           :source_id   => template.id,
                                           :source_type => template.class.name)
      api_basic_authorize action_identifier(:requests, :read, :resource_actions, :get)

      run_get requests_url(service_request.id)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("id"   => service_request.id.to_s,
                                              "href" => a_string_matching(requests_url(service_request.id)))
    end

    it "lists all the service requests if you are admin" do
      @group.miq_user_role = @role = FactoryGirl.create(:miq_user_role, :role => "administrator")
      other_user = FactoryGirl.create(:user)
      service_request_1 = FactoryGirl.create(:service_template_provision_request,
                                             :requester   => other_user,
                                             :source_id   => template.id,
                                             :source_type => template.class.name)
      service_request_2 = FactoryGirl.create(:service_template_provision_request,
                                             :requester   => @user,
                                             :source_id   => template.id,
                                             :source_type => template.class.name)
      api_basic_authorize collection_action_identifier(:requests, :read, :get)

      run_get requests_url

      expected = {
        "count"     => 2,
        "subcount"  => 2,
        "resources" => a_collection_containing_exactly(
          {"href" => a_string_matching(requests_url(service_request_1.id))},
          {"href" => a_string_matching(requests_url(service_request_2.id))},
        )
      }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(expected)
    end

    it "an admin can see another user's request" do
      @group.miq_user_role = @role = FactoryGirl.create(:miq_user_role, :role => "administrator")
      other_user = FactoryGirl.create(:user)
      service_request = FactoryGirl.create(:service_template_provision_request,
                                           :requester   => other_user,
                                           :source_id   => template.id,
                                           :source_type => template.class.name)
      api_basic_authorize action_identifier(:requests, :read, :resource_actions, :get)

      run_get requests_url(service_request.id)

      expected = {
        "id"   => service_request.id.to_s,
        "href" => a_string_matching(requests_url(service_request.id))
      }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(expected)
    end
  end

  context "request creation" do
    it "is forbidden for a user to create a request without appropriate role" do
      api_basic_authorize

      run_post(requests_url, gen_request(:create, :options => { :request_type => "service_reconfigure" }))

      expect(response).to have_http_status(:forbidden)
    end

    it "is forbidden for a user to create a request with a different request role" do
      api_basic_authorize :vm_reconfigure

      run_post(requests_url, gen_request(:create, :options => { :request_type => "service_reconfigure" }))

      expect(response).to have_http_status(:forbidden)
    end

    it "fails if the request_type is missing" do
      api_basic_authorize

      run_post(requests_url, gen_request(:create, :options => { :src_id => 4 }))

      expect_bad_request(/Invalid request - /)
    end

    it "fails if the request_type is unknown" do
      api_basic_authorize

      run_post(requests_url, gen_request(:create,
                                         :options => {
                                           :request_type => "invalid_request"
                                         }))

      expect_bad_request(/Invalid request - /)
    end

    it "fails if the request is missing a src_id" do
      api_basic_authorize :service_reconfigure

      run_post(requests_url, gen_request(:create, :options => { :request_type => "service_reconfigure" }))

      expect_bad_request(/Could not create the request - /)
    end

    it "fails if the requester is invalid" do
      api_basic_authorize :service_reconfigure

      run_post(requests_url, gen_request(:create,
                                         :options   => {
                                           :request_type => "service_reconfigure",
                                           :src_id       => 4
                                         },
                                         :requester => { "user_name" => "invalid_user"}))

      expect_bad_request(/Unknown requester user_name invalid_user specified/)
    end

    it "succeed" do
      api_basic_authorize :service_reconfigure

      service = FactoryGirl.create(:service, :name => "service1")
      run_post(requests_url, gen_request(:create,
                                         :options      => {
                                           :request_type => "service_reconfigure",
                                           :src_id       => service.id
                                         },
                                         :auto_approve => false))

      expected = {
        "results" => [
          a_hash_including(
            "description"    => "Service Reconfigure for: #{service.name}",
            "approval_state" => "pending_approval",
            "type"           => "ServiceReconfigureRequest",
            "requester_name" => api_config(:user_name),
            "options"        => a_hash_including("src_id" => service.id.to_s)
          )
        ]
      }
      expect(response.parsed_body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "succeed immediately with optional data and auto_approve set to true" do
      api_basic_authorize :service_reconfigure

      approver = FactoryGirl.create(:user_miq_request_approver)
      service = FactoryGirl.create(:service, :name => "service1")
      run_post(requests_url, gen_request(:create,
                                         :options      => {
                                           :request_type => "service_reconfigure",
                                           :src_id       => service.id,
                                           :other_attr   => "other value"
                                         },
                                         :requester    => { "user_name" => approver.userid },
                                         :auto_approve => true))

      expected = {
        "results" => [
          a_hash_including(
            "description"    => "Service Reconfigure for: #{service.name}",
            "approval_state" => "approved",
            "type"           => "ServiceReconfigureRequest",
            "requester_name" => approver.name,
            "options"        => a_hash_including("src_id" => service.id.to_s, "other_attr" => "other value")
          )
        ]
      }
      expect(response.parsed_body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "exposes various attributes in the request resources" do
      ems = FactoryGirl.create(:ems_vmware)
      vm_template = FactoryGirl.create(:template_vmware, :name => "template1", :ext_management_system => ems)
      request = FactoryGirl.create(:miq_provision_request,
                                   :requester => @user,
                                   :src_vm_id => vm_template.id,
                                   :options   => {:owner_email => 'tester@example.com', :src_vm_id => vm_template.id})
      FactoryGirl.create(:miq_dialog,
                         :name        => "miq_provision_dialogs",
                         :dialog_type => MiqProvisionWorkflow)

      FactoryGirl.create(:classification_department_with_tags)

      t = Classification.where(:description => 'Department', :parent_id => 0).includes(:tag).first
      request.add_tag(t.name, t.children.first.name)

      api_basic_authorize action_identifier(:requests, :read, :resource_actions, :get)
      run_get requests_url(request.id), :attributes => "workflow,v_allowed_tags,v_workflow_class"

      expected_response = a_hash_including(
        "id"               => request.id.to_s,
        "workflow"         => a_hash_including("values"),
        "v_allowed_tags"   => [a_hash_including("children")],
        "v_workflow_class" => a_hash_including(
          "instance_logger" => a_hash_including("klass" => request.workflow.class.to_s))
      )

      expect(response.parsed_body).to match(expected_response)
      expect(response).to have_http_status(:ok)
    end

    it "can access attributes of its workflow" do
      ems = FactoryGirl.create(:ems_vmware)
      vm_template = FactoryGirl.create(:template_vmware, :name => "template1", :ext_management_system => ems)
      request = FactoryGirl.create(:miq_provision_request,
                                   :requester => @user,
                                   :src_vm_id => vm_template.id,
                                   :options   => {:owner_email => 'tester@example.com', :src_vm_id => vm_template.id})
      FactoryGirl.create(:miq_dialog,
                         :name        => "miq_provision_dialogs",
                         :dialog_type => MiqProvisionWorkflow)

      FactoryGirl.create(:classification_department_with_tags)

      t = Classification.where(:description => 'Department', :parent_id => 0).includes(:tag).first
      request.add_tag(t.name, t.children.first.name)

      api_basic_authorize action_identifier(:requests, :read, :resource_actions, :get)
      run_get requests_url(request.id), :attributes => "workflow.values"

      expected_response = a_hash_including(
        "id"       => request.id.to_s,
        "workflow" => a_hash_including("values")
      )

      expect(response.parsed_body).to match(expected_response)
      expect(response).to have_http_status(:ok)
    end

    it "does not throw a DelegationError exception when workflow is nil" do
      ems = FactoryGirl.create(:ems_vmware)
      vm_template = FactoryGirl.create(:template_vmware, :name => "template1", :ext_management_system => ems)
      request = FactoryGirl.create(:service_template_provision_request,
                                   :requester   => @user,
                                   :source_id   => vm_template.id,
                                   :source_type => vm_template.class.name)

      api_basic_authorize action_identifier(:requests, :read, :resource_actions, :get)
      run_get requests_url(request.id), :attributes => "workflow,v_allowed_tags,v_workflow_class"

      expected_response = a_hash_including(
        "id"               => request.id.to_s,
        "v_workflow_class" => {}
      )

      expect(response.parsed_body).to match(expected_response)
      expect(response.parsed_body).not_to include("workflow")
      expect(response.parsed_body).not_to include("v_allowed_tags")
      expect(response).to have_http_status(:ok)
    end
  end

  context "request update" do
    it "is forbidden for a user without appropriate role" do
      api_basic_authorize

      run_post(requests_url, gen_request(:edit))

      expect(response).to have_http_status(:forbidden)
    end

    it "fails with an invalid request id" do
      api_basic_authorize collection_action_identifier(:requests, :edit)

      run_post(requests_url(999_999), gen_request(:edit, :options => { :some_option => "some_value" }))

      expected = {
        "error" => a_hash_including(
          "message" => /Couldn't find MiqRequest/
        )
      }
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to include(expected)
    end

    it "succeed" do
      api_basic_authorize(action_identifier(:requests, :edit))

      service = FactoryGirl.create(:service, :name => "service1")
      request = ServiceReconfigureRequest.create_request({ :src_id => service.id }, @user, false)

      run_post(requests_url(request.id), gen_request(:edit, :options => { :some_option => "some_value" }))

      expected = {
        "id"      => request.id.to_s,
        "options" => a_hash_including("some_option" => "some_value")
      }

      expect_single_resource_query(expected)
      expect(response).to have_http_status(:ok)
    end

    it "fails without an id" do
      api_basic_authorize(collection_action_identifier(:requests, :edit))
      service = FactoryGirl.create(:service, :name => "service1")
      ServiceReconfigureRequest.create_request({:src_id => service.id}, @user, false)

      run_post(requests_url, gen_request(:edit, :options => {:some_option => "some_value"}))

      expect(response.parsed_body).to include_error_with_message(/Must specify a id/)
      expect(response).to have_http_status(:bad_request)
    end
  end

  context "Requests approval" do
    let(:service1)      { FactoryGirl.create(:service, :name => "service1") }
    let(:request1)      { ServiceReconfigureRequest.create_request({ :src_id => service1.id }, @user, false) }
    let(:request1_url)  { requests_url(request1.id) }

    let(:service2)      { FactoryGirl.create(:service, :name => "service2") }
    let(:request2)      { ServiceReconfigureRequest.create_request({ :src_id => service2.id }, @user, false) }
    let(:request2_url)  { requests_url(request2.id) }

    it "supports approving a request" do
      api_basic_authorize collection_action_identifier(:requests, :approve)

      run_post(request1_url, gen_request(:approve, :reason => "approval reason"))

      expected_msg = "Request #{request1.id} approved"
      expect_single_action_result(:success => true, :message => expected_msg, :href => request1_url)
    end

    it "fails approving a request if the reason is missing" do
      api_basic_authorize collection_action_identifier(:requests, :approve)

      run_post(request1_url, gen_request(:approve))

      expected_msg = /Must specify a reason for approving a request/
      expect_single_action_result(:success => false, :message => expected_msg)
    end

    it "supports denying a request" do
      api_basic_authorize collection_action_identifier(:requests, :deny)

      run_post(request1_url, gen_request(:deny, :reason => "denial reason"))

      expected_msg = "Request #{request1.id} denied"
      expect_single_action_result(:success => true, :message => expected_msg, :href => request1_url)
    end

    it "fails denying a request if the reason is missing" do
      api_basic_authorize collection_action_identifier(:requests, :deny)

      run_post(request1_url, gen_request(:deny))

      expected_msg = /Must specify a reason for denying a request/
      expect_single_action_result(:success => false, :message => expected_msg)
    end

    it "supports approving multiple requests" do
      api_basic_authorize collection_action_identifier(:requests, :approve)

      run_post(requests_url, gen_request(:approve, [{:href => request1_url, :reason => "approval reason"},
                                                    {:href => request2_url, :reason => "approval reason"}]))

      expected = {
        "results" => a_collection_containing_exactly(
          {
            "message" => a_string_matching(/Request #{request1.id} approved/i),
            "success" => true,
            "href"    => a_string_matching(request1_url)
          },
          {
            "message" => a_string_matching(/Request #{request2.id} approved/i),
            "success" => true,
            "href"    => a_string_matching(request2_url)
          }
        )
      }
      expect(response.parsed_body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "supports denying multiple requests" do
      api_basic_authorize collection_action_identifier(:requests, :approve)

      run_post(requests_url, gen_request(:deny, [{:href => request1_url, :reason => "denial reason"},
                                                 {:href => request2_url, :reason => "denial reason"}]))

      expected = {
        "results" => a_collection_containing_exactly(
          {
            "message" => a_string_matching(/Request #{request1.id} denied/i),
            "success" => true,
            "href"    => a_string_matching(request1_url)
          },
          {
            "message" => a_string_matching(/Request #{request2.id} denied/i),
            "success" => true,
            "href"    => a_string_matching(request2_url)
          }
        )
      }
      expect(response.parsed_body).to include(expected)
      expect(response).to have_http_status(:ok)
    end
  end

  context "resource hrefs" do
    it "returns the requests href reference for objects of different subclasses" do
      provision_request = FactoryGirl.create(:service_template_provision_request, :requester => @user)
      automation_request = FactoryGirl.create(:automation_request, :requester => @user)
      api_basic_authorize collection_action_identifier(:requests, :read, :get)

      run_get requests_url, :expand => :resources

      expected = [
        a_hash_including('href' => a_string_including(requests_url(provision_request.id))),
        a_hash_including('href' => a_string_including(requests_url(automation_request.id)))
      ]
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['resources']).to match_array(expected)
    end
  end

  context 'Tasks subcollection' do
    let(:request) do
      FactoryGirl.create(:service_template_provision_request,
                         :requester   => @user,
                         :source_id   => template.id,
                         :source_type => template.class.name)
    end

    it 'redirects to request_tasks subcollection' do
      FactoryGirl.create(:miq_request_task, :miq_request_id => request.id)
      api_basic_authorize collection_action_identifier(:service_requests, :read, :get)

      run_get("#{requests_url(request.id)}/tasks")

      expect(response).to have_http_status(:moved_permanently)
      expect(response.redirect_url).to include("#{requests_url(request.id)}/request_tasks")
    end

    it 'redirects to request_tasks subresources' do
      task = FactoryGirl.create(:miq_request_task, :miq_request_id => request.id)
      api_basic_authorize action_identifier(:services, :read, :resource_actions, :get)

      run_get("#{requests_url(request.id)}/tasks/#{task.id}")

      expect(response).to have_http_status(:moved_permanently)
      expect(response.redirect_url).to include("#{requests_url(request.id)}/request_tasks/#{task.id}")
    end
  end
end
