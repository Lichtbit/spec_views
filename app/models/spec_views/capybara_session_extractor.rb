# frozen_string_literal: true

module SpecViews
  class CapybaraSessionExtractor
    attr_reader :page, :failure_message

    def initialize(page, expected_status:)
      @page = page
      @status_match = response_status_match?(page, expected_status)
      return if @status_match

      @failure_message = "Unexpected response status #{page.status_code}."
    end

    def extractor_failure?
      failure_message.present?
    end

    def body
      page.source
    end

    private

    def response_status_match?(page, expected_status)
      page.status_code == expected_status ||
        Rack::Utils::SYMBOL_TO_STATUS_CODE.invert[page.status_code] == expected_status.to_sym
    end
  end
end
