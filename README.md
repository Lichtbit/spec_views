# SpecViews
Save views from request and controller specs for comparision.

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
Use the `match_html_fixture` matcher in your spec:

```ruby
RSpec.describe "Articles", type: :request do
  describe 'GET /articles' do
    it 'renders the listing' do
      get articles_path
      expect(response).to match_html_fixture
    end
  end
end
```

Run this spec to see it failing. Open SpecView UI [http://localhost:3000/spec_views](http://localhost:3000/spec_views) on Rails development server to accept the new view. When rerunning the spec it compares its rendering with the reference view. Use SpecView UI to review, accept or reject changed views.

### view_sanitizer
Sometimes it is hard to remove dynamic elements like IDs and times. Use `view_sanitizer.gsub` to replace dynamic strings with fixed ones before comparing and saving the views automatically:

```ruby
before do
  view_sanitizer.gsub(%r{(users/)[0-9]+}, '\1ID')
  view_sanitizer.gsub(/value="[0-9]+"/, 'value="ID"')
end
```

`view_sanitizer.gsub` supports the same arguments as `String#gsub` including blocks.

### it_renders
You can also use the shortcut to skip the matcher and the word "renders" from your description:

```ruby
RSpec.describe "Articles", type: :request do
  describe 'GET /articles' do
    it_renders 'the listing' do
      get articles_path
    end
  end
end
```

### Different response status
By default only status 200 responses are compared. Tell the matcher if your response has another one:

```ruby
RSpec.describe "Articles", type: :request do
  describe 'GET /articles' do
    it 'renders the listing' do
      get articles_path
      expect(response).to match_html_fixture.for_status(:not_found) # or 404
    end
  end
end
```

### Add an affix
If you have two requests with the same description, you can add an affix to the generated name:

```ruby
RSpec.describe "Articles", type: :request do
  describe 'GET /articles' do
    it 'renders the listing' do
      get articles_path
      expect(response).to match_html_fixture.with_affix('only 10')

      get articles_path(all: '1')
      expect(response).to match_html_fixture.with_affix('all')
    end
  end
end
```

### PDF matching
If your request responds with a PDF you can compare it as well:

```ruby
RSpec.describe "Articles", type: :request do
  describe 'GET /articles/1/download' do
    it 'downloads as PDF' do
      get article_path(1, format: :pdf)
      expect(response).to match_pdf_fixture
    end
  end
end
```

### Mailer specs
Compare HTML mailers. `match_html_fixture` tries to find the HTML part of your mail automatically:

```ruby
RSpec.describe NotificationsMailer, type: :mailer do
  describe '#notify' do
    let(:mail) { NotificationsMailer.signup }

    it 'renders the body' do
      expect(mail).to match_html_fixture
    end
  end
end
```

### Feature specs
Compare pages from feature specs:

```ruby
RSpec.describe 'Articles', type: :feature do
  it 'are shown as list' do
    expect(page).to match_html_fixture
  end
end
```

### Controller specs
Prefer request specs over controller specs. If you still want to use controller specs enable the `render_views` feature:

```ruby
RSpec.describe HomeController, type: :controller do
  describe 'GET #show' do
    render_views

    it 'renders the homepage' do
      get :show
      expect(response).to match_html_fixture
    end
  end
end
```

The `it_renders` shortcuts enables `render_views` automatically.

## Configuration
Configure SpecView by adding and modifying lines to `config/environments/test.rb` and `config/environments/development.rb`:

```ruby
config.spec_views.directory = 'spec/fixtures/views'
config.spec_views.ui_url = 'http://localhost:3000/spec_views'
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
