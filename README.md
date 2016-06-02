### Axit - Role based authorization for Rails.

Axit helps you authorize incoming requests by routing these requets to the corresponding controller auth before the request reaches your controller action.
It also helps you write generic, easy to read auth methods for managing what parts of an HTML view a user is able to see.

## Controllers

If a request say a GET /users/:id tries to access a user's show page, then the request is first routed to User controllers's show action's authorizer. The authorizer method will check who the logged in user is and then based on the
access levels of that user, the method returns a true if they are allowed to perform that action. Else a false is returned and a Axit::NotAuthorizedError exception is raised.

To use it in a controller,

```ruby
  include Axit::Controllers
  before_action :axit!
```

Adding a method to rescue from exception is recommended. For example,

```ruby
  rescue_from Axit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    redirect_to authenticated_root_path, notice: 'You are not authorized to perform this action.'
  end
```

### Defining Controller Authorizers

If you want to use Axit for Users controller,

1. ```app/controllers/users_controller.rb```
then it's authorizer file should be in
2. ``` app/auth/controllers/users.rb```

If there is a index action in 1 above, then a method like the following should be in 2:
Note: This auth method should accept two arguments - user (which is current_user) and params (controller request params)

```ruby
module Auth
  module Controllers
    module Users
      class << self
        def index(user, params = {})
          user.has_role?(:admin, Company.find(params[:company_id]))
        end
      end
    end
  end
end
```

## Views
To use it in a view, we need to include Axit's view helpers.

For example,

```ruby
include Axit::Views
```

is included in app/helpers/application_helper.rb

If we want to auth a view fragment in this view:
``` app/views/broker/companies/index.html.erb ```
Then Axit will expect it's auth to be defined in:
``` app/auth/views/broker/companies/index.rb ```

The View's auth file looks like this:

```ruby
module Auth
  module Views
    module Broker
      module Companies
        module Index
          class << self
            def new_company_link(user, options = {})
              user.is_an_admin? ||
                user.has_role?(:admin, Company.find(options[:company_id]))
            end
          end
        end
      end
    end
  end
end
```

To use in a view file, use Axit's can_view helper in an IF clause
```erb
<% if can_view? :new_company_link %>
  <a class="btn btn-success" type="button" href="<%= new_company_path  %>">
    NewCompany
  </a>
 <% end %>
```

You may also pass in options with can_view? like so:

```erb
<% if can_view? :new_company_link, { custom_param: params[:company_id] } %>
  <a class="btn btn-success" type="button" href="<%= new_company_path  %>">
    NewCompany
  </a>
 <% end %>
```

## How we use it at Flock
For controller auth, we create a controller concern:

```ruby
module Axitable
  extend ActiveSupport::Concern
  include Axit::Controllers

  included do
    before_action :axit!
    rescue_from Axit::NotAuthorizedError, with: :user_not_authorized
  end

  def user_not_authorized
    redirect_to authenticated_path, notice: 'You are not authorized to perform this action'
  end
end
```

Any controller that has to use Axit only has to include this concern and that controller is now protected by Axit.
For example, to include Axit in Users controllers we simple include the concerns.

```ruby
class UsersController < BaseController
  include Axitable
end
```
