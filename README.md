# SpecViews
Render views from controller specs for comparision

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

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'spec_views'
```

And this to RSpec's rails_helper.rb:
```ruby
require 'spec_views/support'
```

And then execute:
```bash
$ bundle
```

Ignore some generated files in your .gitignore:
```bash
/spec/fixtures/views/*/challenger.html
/spec/fixtures/views/*/last_run.txt
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
