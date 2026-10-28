# frozen_string_literal: true

module SpecViews
  module Support
    class << self
      attr_accessor :run_time

      def freeze_time
        time = Rails.configuration.spec_views.freeze_time
        time.is_a?(String) ? Time.zone.parse(time) : time
      end
    end

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
  c.before(:suite) do
    SpecViews::Support.run_time = Time.zone.now
  end
  c.include_context 'SpecViews ViewSanitizer'
  %i[controller feature mailer request].each do |type|
    c.extend SpecViews::Support::SpecViewExample, type: type
    c.include ActiveSupport::Testing::TimeHelpers, type: type
    c.before(:each, type: type) do
      time = SpecViews::Support.freeze_time
      travel_to(time) if time
    end
    c.after(:each, type: type) do
      travel_back
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
      example = RSpec.current_example
      description = example.full_description
      description = "#{description}-#{@affix}" if @affix.present?
      @status ||= :ok
      @matcher = matcher.second.new(
        actual,
        description,
        expected_status: @status,
        run_time: SpecViews::Support.run_time,
        sanitizer: view_sanitizer,
        type: example.metadata[:type]
      )
      return @matcher.match?
    end

    failure_message do |_actual|
      "#{@matcher.failure_message} " \
        "Review the challenger: #{Rails.configuration.spec_views.ui_url}"
    end
  end
end
