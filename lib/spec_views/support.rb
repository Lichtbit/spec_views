# frozen_string_literal: true

require 'timecop'

module SpecViews
  module Support
    module SpecViewExample
      def it_renders(description = nil, focus: nil, pending: nil, status: :ok, &block)
        context do
          render_views if respond_to?(:render_views)
          options = {}
          options[:focus] = focus unless focus.nil?
          options[:pending] = pending unless pending.nil?
          description = "renders #{description}" if description.is_a?(String)
          it(description, options) do
            instance_eval(&block)
            expect(response).to match_html_fixture.for_status(status)
          end
        end
      end
    end
  end
end

RSpec.shared_context 'SpecViews ViewSanitizer' do
  let(:view_sanitizer) { SpecViews::ViewSanitizer.new }
end

RSpec.configure do |c|
  c.before(:suite) do |_example|
    $_spec_view_time = Time.zone.now # rubocop:disable Style/GlobalVars
  end
  c.include_context 'SpecViews ViewSanitizer'
  %i[controller feature mailer request].each do |type|
    c.extend SpecViews::Support::SpecViewExample, type: type
    c.before(type: type) do |example|
      @_spec_view_example = example
    end
    c.before(:each, type: type) do
      Timecop.freeze(Time.zone.local(2024, 2, 29, 0o0, 17, 42))
    end
    c.after(:each, type: type) do
      Timecop.return
    end
  end
end

matchers = [
  [:match_html_fixture, SpecViews::HtmlMatcher],
  [:match_pdf_fixture, SpecViews::PdfMatcher]
]

matchers.each do |matcher|
  RSpec::Matchers.define matcher.first do |_expected|
    chain :for_status do |status|
      @status = status
    end
    chain :with_affix do |affix|
      @affix = affix
    end

    match do |actual|
      example = @matcher_execution_context.instance_variable_get('@_spec_view_example')
      description = example.full_description
      description = "#{description}-#{@affix}" if @affix.present?
      type = example.metadata[:type]
      run_time = $_spec_view_time # rubocop:disable Style/GlobalVars
      @status ||= :ok
      @matcher = matcher.second.new(
        actual,
        description,
        expected_status: @status,
        run_time: run_time,
        sanitizer: view_sanitizer,
        type: type
      )
      return @matcher.match?
    end

    failure_message do |_actual|
      "#{@matcher.failure_message} " \
        "Review the challenger: #{Rails.configuration.spec_views.ui_url}"
    end
  end
end
