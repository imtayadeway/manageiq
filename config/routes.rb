Vmdb::Application.routes.draw do
  root :to => 'dashboard#login'

  # Let's serve pictures directly from the DB
  get '/pictures/:basename' => 'picture#show', :basename => /[\da-zA-Z]+\.[\da-zA-Z]+/

  # Enablement for the REST API

  # Semantic Versioning Regex for API, i.e. vMajor.minor.patch[-pre]
  API_VERSION_REGEX = /v[\d]+(\.[\da-zA-Z]+)*(\-[\da-zA-Z]+)?/ unless defined?(API_VERSION_REGEX)

  namespace :api, :path => "api(/:version)", :version => API_VERSION_REGEX, :defaults => {:format => "json"} do
    root :to => "api#index"
    match "/", :to => "api#options", :via => :options

    unless defined?(API_ACTIONS)
      API_ACTIONS = {
        :get     => "show",
        :post    => "update",
        :put     => "update",
        :patch   => "update",
        :delete  => "destroy",
        :options => "options"
      }.freeze
    end

    def create?(request)
      action = JSON.parse(request.body.read)["action"]
      request.body.rewind
      action.blank? || action == "create" || action == "add"
    end

    Api::ApiConfig.collections.each do |collection_name, collection|
      # OPTIONS action for each collection
      match collection_name.to_s, :controller => collection_name, :action => :options, :via => :options

      scope collection_name, :controller => collection_name do
        collection.verbs.each do |verb|
          root :action => API_ACTIONS[verb], :via => verb if collection.options.include?(:primary)

          next unless collection.options.include?(:collection)

          if collection.options.include?(:arbitrary_resource_path)
            case verb
            when :get
              root :action => :index
              get "/*c_suffix", :action => :show
            else
              match "(/*c_suffix)", :action => API_ACTIONS[verb], :via => verb
            end
          else
            case verb
            when :get
              root :action => :index
              get "/:c_id", :action => :show
            when :post
              post "/", :action => "bulk_update", :constraints => ->(request) { !create?(request) }
              post "/:c_id", :action => "update", :constraints => ->(request) { !create?(request) }
              post "/", :action => "create", :constraints => ->(request) { create?(request) }
            when :put
              put "/:c_id", :action => "put"
            when :patch
              patch "/:c_id", :action => "patch"
            else
              match "(/:c_id)", :action => API_ACTIONS[verb], :via => verb
            end
          end
        end

        Array(collection.subcollections).each do |subcollection_name|
          Api::ApiConfig.collections[subcollection_name].verbs.each do |verb|
            case verb
            when :get
              get "/:c_id/#{subcollection_name}", :action => :index
              get "/:c_id/#{subcollection_name}/:s_id", :action => :show
            when :post
              post "/:c_id/#{subcollection_name}/", :action => "bulk_update"
              post "/:c_id/#{subcollection_name}/:s_id", :action => "update"
            when :put
              put "/:c_id/#{subcollection_name}/:s_id", :action => "put"
            when :patch
              patch "/:c_id/#{subcollection_name}/:s_id", :action => "patch"
            else
              match("/:c_id/#{subcollection_name}(/:s_id)", :action => API_ACTIONS[verb], :via => verb)
            end
          end
        end
      end
    end
  end

  # ping response for load balancing
  get '/ping' => 'ping#index'

  match "/auth/:provider/callback" => "sessions#create", :via => :get

  if Rails.env.development? && defined?(Rails::Server)
    logger = Logger.new(STDOUT)
    logger.level = Logger.const_get(::Settings.log.level_websocket.upcase)
    mount WebsocketServer.new(:logger => logger) => '/ws'
  end
end
