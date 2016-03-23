### Axit - Role based authorization for Rails.

Axit routes incoming requests to access resources like controllers, views ad part of views to their authorizers before the request reaches the resource.

So if a request say a GET /users/:id tries to acceess a user's show page, then the request is first routed to User controllers's show action's authorizer. The authorizer method will check who the logged in user is and then based on the 
access levels of that user, the method returns a true if they are allowed to perform that action. Else a false is returned and a Axit::NotAuthorizedError exception is raised.

## Controllers

To use it in a controller,

```ruby
  include Axit::Controllers
  before_action :axit!
```

Adding a method to rescue from exception is recommended. For example,

```ruby
  rescue_from Axit::NotAuthorizedError, with: :user_not_authorized
  
  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to authenticated_root_path
  end
```

### Defining Authorizers

If you want to use Axit for Users controller,

1. ```app/controllers/users_controller.rb``` 
then it's authorizer filer should be in
2. ``` app/auth/controllers/users.rb```

If there is a index action in 1 above, then a method like the following should be in 2:

```ruby
module Auth
  module Controllers
    module Users
      class << self
        def index(user)
          (user.has_role?(:company_admin, user.company) ||
           user.has_role?(:presenter, user.company) ||
           user.has_role?(:employee, user.company))
        end
      end
    end
  end
end
```

## Views
To use it in a view, we need to include Axit's view helpers. 

```ruby
include Axit::Views
```

is included in app/helpers/application_helper.rb

Similar to controllers, 

If we want to auth a fragment in this view:
``` app/views/broker/companies/index.html.erb ```
Then Axit will expect it's auth to be defined in:
``` app/auth/views/broker/companies/index.rb ```
Use like so in the view:
```erb
<% if can_view? :new_company_link %>
  <a class="btn btn-success" type="button" href="<%= new_broker_company_path  %>"> 
    NewCompany
  </a>
 <% end %>
```
The View's auth file looks like this: 
```ruby
module Auth
  module Views
    module Broker
      module Companies
        module Index
          class << self
            def new_company_link(user)
              true
            end
          end
        end
      end
    end
  end
end
```

## How we use it at Flock

We create a controller concern: 
```ruby
module Axitable
  extend ActiveSupport::Concern
  include Axit::Controllers

  included do
    before_action :axit!
    rescue_from Axit::NotAuthorizedError, with: :user_not_authorized
  end

  def user_not_authorized
    if current_user.has_role?(:presenter, current_company)
      flash[:notice] = t('authorization.controllers.presenter_not_authorized')
    else
      flash[:alert] = t('authorization.controllers.not_authorized')
    end

    if request.env['HTTP_REFERER'].present?
      if current_user.has_role?(:presenter, current_company)
        redirect_to :back
      else
        redirect_to :back, status: :unauthorized
      end
    elsif current_user.has_role?(:presenter, current_company)
      redirect_to authenticated_root_path
    else
      redirect_to authenticated_root_path, status: :unauthorized
    end
  end
end
```

Any controller that has to use Axit can only include this concern and that controller is now protected by Axit.

For example, to include Axit in Users controllers we have included it like so: 

```ruby
class UsersController < BaseController
  include Axitable
end
```
