module Axit
  class NotAuthorizedError < StandardError; end

  module Controllers
    # This prefix is used for properly namespacing auth within
    # Auth::Controllers namespace.

    PREFIX = 'Auth::Controllers'.freeze

    private

    def axit!
      whitelisted?
    end

    def whitelisted?
      # If user isn't logged in, raise Axit::Unauthorized

      raise NotAuthorizedError if current_employee.nil?

      # Build auth method name, constantize it, and call a method named
      # after the action name with current_employee object and controller
      # params.

      !!(prefix_string.constantize)
        .send(action_name, current_employee, params) == true ?
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
    # This prefix is used for properly namespacing auth within
    # Auth::Views namespace.

    PREFIX = 'Auth::Views'.freeze

    private

    def can_view?(fragment, options = {})
      # Build auth method name, constantize it, call fragment name as a method
      # and pass in current_employee and options

      !!(prefix_string.constantize)
        .send(fragment, current_employee, options)
    end

    def prefix_string
      c = params[:controller]
      a = params[:action]
      "#{PREFIX}::#{c.camelize}::#{a.camelize}"
    end
  end
end
