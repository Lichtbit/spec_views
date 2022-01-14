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

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install spec_views
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
