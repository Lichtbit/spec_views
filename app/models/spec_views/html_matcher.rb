# frozen_string_literal: true

require 'diff/lcs'

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

    def diff_preview
      return nil unless champion_html.present?

      champion_lines = champion_html.lines
      challenger_lines = challenger_body.lines

      diffs = Diff::LCS.diff(champion_lines, challenger_lines)
      return nil if diffs.empty?

      first_change = diffs.first.first
      line_number = first_change.position + 1

      preview = "\nFirst difference at line #{line_number}:\n"

      if first_change.action == '-'
        old_line = first_change.element.chomp
        addition = diffs.first.find { |change| change.action == '+' && change.position == first_change.position }

        if addition
          new_line = addition.element.chomp
          truncated_old, truncated_new, marker_pos = truncate_diff_lines_with_marker(old_line, new_line)
          preview += "  - #{truncated_old}\n"
          preview += "  + #{truncated_new}\n"
          preview += "    #{' ' * marker_pos}^\n" if marker_pos
        else
          preview += "  - #{truncate_line(old_line)}\n"
        end
      elsif first_change.action == '+'
        preview += "  + #{truncate_line(first_change.element.chomp)}\n"
      end

      preview
    end

    private

    def sanitized_body
      body = remove_pack_digests_from_body(remove_digests_from_body(@extractor.body))
      body = sanitizer.sanitize(body) if sanitizer
      body
    end

    def remove_digests_from_body(body)
      body.gsub(/(-[a-z0-9]{64})(\.css|\.js|\.ico|\.png|\.jpg|\.jpeg|\.svg|\.gif)/, '\2')
    end

    def remove_pack_digests_from_body(body)
      body.gsub(%r{(packs.*/js/[a-z0-9_]+)(-[a-z0-9]{20})(\.js)}, '\1\3')
    end

    def truncate_diff_lines_with_marker(old_line, new_line, max_common_prefix: 10, max_length: 100)
      common_length = 0
      [old_line.length, new_line.length].min.times do |i|
        break if old_line[i] != new_line[i]

        common_length = i + 1
      end

      prefix_offset = 0
      prefix_marker = ''
      if common_length > max_common_prefix
        prefix_offset = common_length - max_common_prefix
        prefix_marker = '...'
      end

      old_relevant = prefix_marker + old_line[prefix_offset..]
      new_relevant = prefix_marker + new_line[prefix_offset..]

      marker_pos = prefix_marker.length + (common_length - prefix_offset)

      truncated_old = truncate_line(old_relevant, max_length)
      truncated_new = truncate_line(new_relevant, max_length)

      marker_pos = nil if marker_pos >= max_length

      [truncated_old, truncated_new, marker_pos]
    end

    def truncate_line(line, max_length = 100)
      return line if line.length <= max_length

      "#{line[0...max_length]}..."
    end
  end
end
