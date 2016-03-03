module Axit
  class NotAuthorizedError < StandardError; end

  module Controllers
    PREFIX = 'Auth::Controllers'.freeze

    private

    def axit!
      whitelisted?
    end

    def whitelisted?
      !!(prefix_string.constantize)
        .send(action_name, current_user) == true ?
        true : (raise NotAuthorizedError)

    rescue
      raise NotAuthorizedError
    end

    def prefix_string
      # controller name does not give namespace
      c = params[:controller]
      "#{PREFIX}::#{c.camelize}"
    end
  end

  module Views
    PREFIX = 'Auth::Views'.freeze

    private

    def can_view?(fragment)
      !!(prefix_string.constantize)
        .send(fragment, current_user)
    end

    def prefix_string
      c = params[:controller]
      a = params[:action]
      "#{PREFIX}::#{c.camelize}::#{a.camelize}"
    end
  end
end
