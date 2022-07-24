# frozen_string_literal: true

module SpecViews
  class HtmlMatcher < BaseMatcher
    delegate :champion_html, to: :directory

    protected

    def subject_name
      'View'
    end

    def content_type
      :html
    end

    def challenger_body
      sanitized_body
    end

    def match_challenger
      champion_html == challenger_body
    end

    private

    def sanitized_body
      remove_pack_digests_from_body(remove_digests_from_body(@extractor.body))
    end

    def remove_digests_from_body(body)
      body.gsub(/(-[a-z0-9]{64})(\.css|\.js|\.ico|\.png|\.jpg|\.jpeg|\.svg|\.gif)/, '\2')
    end

    def remove_pack_digests_from_body(body)
      body.gsub(%r{(packs.*/js/[a-z0-9_]+)(-[a-z0-9]{20})(\.js)}, '\1\3')
    end
  end
end
