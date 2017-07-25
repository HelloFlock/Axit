module Axit
  class NotAuthorizedError < StandardError; end

  module UserForAxit
    def user_for_axit
      if (obj_name = Rails.application.config.try(:user_for_axit))
        send(obj_name)
      else
        current_user
      end
    end
  end

  module Controllers
    include UserForAxit
    # This prefix is used for properly namespacing auth within
    # Auth::Controllers namespace.

    PREFIX = 'Auth::Controllers'.freeze

    private

    def axit!
      whitelisted?
    end

    def whitelisted?
      # If user isn't logged in, raise Axit::Unauthorized

      raise NotAuthorizedError if user_for_axit.nil?

      # Build auth method name, constantize it, and call a method named
      # after the action name with user_for_axit object and controller
      # params.

      !!(prefix_string.constantize)
        .send(action_name, user_for_axit, params) == true ?
        true : (raise NotAuthorizedError)

    rescue
      # If anything fails in the auth method, raise this exception and
      # indicate that auth isn't working.

      raise NotAuthorizedError
    end

    def prefix_string
      # Using params[:controller] because controller_name does not give namespace
      # and it is good enough

      c = params[:controller]
      "#{PREFIX}::#{c.camelize}"
    end

  end

  module Views
    include UserForAxit

    # This prefix is used for properly namespacing auth within
    # Auth::Views namespace.

    PREFIX = 'Auth::Views'.freeze

    private

    def can_view?(fragment, options = {})
      # Build auth method name, constantize it, call fragment name as a method
      # and pass in user_for_axit and options

      !!(prefix_string.constantize)
        .send(fragment, user_for_axit, options)
    end

    def prefix_string
      c = params[:controller]
      a = params[:action]
      "#{PREFIX}::#{c.camelize}::#{a.camelize}"
    end
  end
end
