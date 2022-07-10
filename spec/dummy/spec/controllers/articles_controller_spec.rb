require 'rails_helper'
require 'spec_views/support'

Extractor = Struct.new(:container) do
  def to_html
    body
  end

  private

  def body
    container.respond_to?(:body) ? container.body : container
  end
end

RSpec::Matchers.define :match_html_fixture do |expected|
  chain :for_status do |status|
    @status = status
  end

  match do |actual|
    example = @matcher_execution_context.instance_variable_get('@_spec_view_example')
    dir_name = example.full_description.strip.gsub(/[^0-9A-Za-z.\-]/, '_').gsub('__', '_')
    run_time = $_spec_view_time
    @status ||= :ok
    @matcher = SpecViews::HtmlMatcher.new(
      actual,
      dir_name,
      expected_status: @status,
      run_time: run_time
    )
    return @matcher.match?
  end

  failure_message do |actual|
    "#{@matcher.failure_message} " \
    "Review the challenger: #{Rails.configuration.spec_views.ui_url}"
  end
end

RSpec.describe ArticlesController, type: :controller do

  describe "GET #new" do
    it_renders "the form" do
      get :new
    end

    render_views
    it 'renders the forms' do
      get :new
      expect(response).to match_html_fixture
    end
  end

  describe "GET #index" do
    it_renders "the listing" do
      get :index
    end
  end

  describe "GET #show" do
    it_renders "the page" do
      get :show, params: { id: 1 }
    end
  end

end
