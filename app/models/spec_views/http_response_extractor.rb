# frozen_string_literal: true

module SpecViews
  class HttpResponseExtractor
    attr_reader :response, :failure_message

    def initialize(response, expected_status:)
      @response = response
      @status_match = response_status_match?(response, expected_status)
      return if @status_match

      @failure_message = "Unexpected response status #{response.status}."
    end

    def extractor_failure?
      @status_match
    end

    def body
      response.body
    end

    private

    def response_status_match?(response, expected_status)
      response.status == expected_status ||
        response.message.parameterize.underscore == expected_status.to_s
    end
  end
end
