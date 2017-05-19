module Api
  class ClustersController < BaseController
    include Shared::Taggable

    def options
      render_options(:clusters, :node_types => EmsCluster.node_types)
    end
  end
end
