# frozen_string_literal: true

require "timecop"

module SpecViews
  module Support
    module SpecViewExample
      def it_renders(description = nil, focus: nil, pending: nil, status: :ok, &block)
        context do # rubocop:disable RSpec/MissingExampleGroupArgument
          render_views
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

    RSpec.configure do |c|
      c.extend SpecViewExample, type: :controller
      c.before(:suite) do |_example|
        $_spec_view_time = Time.zone.now
      end
      c.before(type: :controller) do |example|
        @_spec_view_example = example
      end
      c.before(:each, type: :controller) do
        Timecop.freeze(Time.zone.local(2024, 2, 29, 0o0, 17, 42))
      end
      c.after(:each, type: :controller) do
        Timecop.return
      end
    end

    matchers = [
      [:match_html_fixture, SpecViews::HtmlMatcher],
      [:match_pdf_fixture, SpecViews::PdfMatcher],
    ]

    matchers.each do |matcher|
      RSpec::Matchers.define matcher.first do |expected|
        chain :for_status do |status|
          @status = status
        end

        match do |actual|
          example = @matcher_execution_context.instance_variable_get('@_spec_view_example')
          dir_name = example.full_description.strip.gsub(/[^0-9A-Za-z.\-]/, '_').gsub('__', '_')
          run_time = $_spec_view_time
          @status ||= :ok
          @matcher = matcher.second.new(
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
    end
  end
end

RSpec.configure do |rspec|
  rspec.include SpecViews::Support, type: :controller
end
