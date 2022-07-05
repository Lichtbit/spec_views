# SpecViews
Render views from controller specs for comparision.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'spec_views'
```

And this to RSpec's rails_helper.rb:
```ruby
require 'spec_views/support'
```

Then execute:
```bash
$ bundle
```

Ignore some generated files in your .gitignore:
```bash
/spec/fixtures/views/*/challenger.*
/spec/fixtures/views/*/last_run.txt
```

## Usage
Replace selected RSpec `it` methods with `render`:

```ruby
RSpec.describe HomeController, type: :controller do
  describe 'GET #show' do
    render 'homepage' do
      get :show
    end
  end
end
```

Run this spec to see it failing. Open SpecView UI [http://localhost:3000/spec_views](http://localhost:3000/spec_views) on Rails development server to accept the new view. When rerunning the spec it compares its rendering with the reference view. Use SpecView UI to review, accept or reject changed views.

## Configuration
Configure SpecView by adding and modifying lines to `config/environments/test.rb` and `config/environments/development.rb`:

```ruby
config.spec_views.directory = 'spec/fixtures/views'
config.spec_views.ui_url = 'http://localhost:3000/spec_views'
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
