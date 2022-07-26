# frozen_string_literal: true

module SpecViews
  class MailMessageExtractor
    attr_reader :mail, :failure_message, :body

    def initialize(mail, expected_status:)
      @mail = mail
      @body = extract_body(mail)
      return if body.present?

      @failure_message = "Failed to find mail part"
    end

    def extractor_failure?
      failure_message.present?
    end

    def extract_body(part)
      return part.raw_source if part.respond_to?(:raw_source) && part.raw_source.present?
      return extract_body(part.body) if part.respond_to?(:body)
      return part if part.is_a?(String)
      return if nil unless part.respond_to?(:parts)

      part.parts.map do |inner_part|
        extract_body(inner_part)
      end.compact.first
    end
  end
end
