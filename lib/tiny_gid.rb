# frozen_string_literal: true

require "uri"

module TinyGID
  VERSION = "0.0.1"
  FORMAT = "gid://%s/%s/%s"

  module MethodMissing  # :nodoc:
    def method_missing(name, *arguments, &block)
      # TODO: need to ensure we're not calling ourselves

      id = arguments.shift
      raise ArgumentError, "gid::#{name} requires an ID" unless id

      params = (arguments[0] || {}).dup
      raise TypeError, "gid::#{name} params must be a Hash. Received: #{params.class}" unless params.is_a?(Hash)

      app = params.delete(:__app__) || TinyGID.app
      raise "gid::#{name} cannot be generated: missing app name" unless app

      gid = sprintf(FORMAT, app, name, URI.encode_www_form_component(id))
      return gid unless params.any?

      gid << "?" << URI.encode_www_form(params)
    end
  end

  include MethodMissing         # 🤸‍♀️
  extend MethodMissing          # 🤸‍♂️

  class << self
    # In GlobalID app names must be valid URI hostnames: alphanumeric and hyphen characters only
    def app=(name)
      @app = name
    end

    def app(name = nil)
      if block_given?
        raise ArgumentError, "block provided without an app name to scope to" unless name

        begin
          og = @app
          @app = name

          yield self
        ensure
          @app = og
        end

        return
      end

      # No block but given a name, just set it :|
      @app = name if name

      return @app if @app
      return Rails.application.name if defined?(Rails) && Rails.respond_to?(:application)
    end

    # Necessary?
    # def to_sc(gid)
    #   # TODO:
    #   # value, params = TinyGID.to_sc("gid://shopify/Product/123?is_a=headache")
    #   gid.to_s.split("/")[-1]
    # end
  end

  def initialize(app)
    raise ArgumentError "app required" if app.to_s.strip.empty?
    @app = app
  end

  def method_missing(name, *arguments, &block)
    id = arguments.shift

    options = arguments.shift || {}
    options = options.merge(:__app__ => @app) unless options.include?(:app)

    super(name, id, options, &block)
  end
end
