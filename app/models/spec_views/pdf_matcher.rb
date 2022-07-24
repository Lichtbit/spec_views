# frozen_string_literal: true

module SpecViews
  class PdfMatcher < BaseMatcher
    protected

    def subject_name
      'PDF'
    end

    def content_type
      :pdf
    end

    def challenger_body
      sanitized_body
    end

    def match_challenger
      champion_hash == challenger_hash
    end

    private

    def champion_hash
      @champion_hash ||= begin
        Digest::MD5.file(directory.champion_path).hexdigest
      rescue Errno::ENOENT
        nil
      end
    end

    def challenger_hash
      @challenger_hash ||= Digest::MD5.hexdigest(sanitized_body)
    end

    def sanitized_body
      @sanitized_body ||= remove_headers_from_pdf(@extractor.body)
    end

    def remove_headers_from_pdf(body)
      body
        .force_encoding('BINARY')
        .gsub(%r{^/CreationDate \(.*\)$}, '')
        .gsub(%r{^/ModDate \(.*\)$}, '')
        .gsub(%r{^/ID \[<.+><.+>\]$}, '')
    end
  end
end
