require 'abstract_unit'

module TestUrlGeneration
  class WithMountPoint < ActionDispatch::IntegrationTest
    Routes = ActionDispatch::Routing::RouteSet.new
    include Routes.url_helpers

    class ::MyRouteGeneratingController < ActionController::Base
      include Routes.url_helpers
      def index
        render :text => foo_path
      end
    end

    Routes.draw do
      get "/foo", :to => "my_route_generating#index", :as => :foo

      resources :bars

      mount MyRouteGeneratingController.action(:index), at: '/bar'
    end

    APP = build_app Routes

    def _routes
      Routes
    end

    def app
      APP
    end

    test "benchmark deprecations" do
      require 'benchmark/ips'
      Benchmark.ips do |x|
        x.report('deprecated with any?'){ bar_path("id" => 1, deprecate: "deprecate_any") }
        x.report('deprecated with each'){ bar_path("id" => 1, deprecate: "deprecate_each") }
        x.report('deprecated with original'){ bar_path("id" => 1, deprecate: "original") rescue nil }
        x.report('deprecated with symbolize'){ bar_path("id" => 1, deprecate: "symbolize") }
        x.report('deprecated with transform_keys'){ bar_path("id" => 1, deprecate: "deprecate_transform_keys") }
        x.compare!
      end
      
      Benchmark.ips do |x|
        x.report('not deprecated with any?'){ bar_path(id: 1, deprecate: "deprecate_any") }
        x.report('not deprecated with each'){ bar_path(id: 1, deprecate: "deprecate_each") }
        x.report('not deprecated with original'){ bar_path(id: 1, deprecate: "original") }
        x.report('not deprecated with symbolize'){ bar_path(id: 1, deprecate: "symbolize") }
        x.report('not deprecated with transform_keys'){ bar_path(id: 1, deprecate: "deprecate_transform_keys") }
        x.compare!
      end
    end
  end
end

