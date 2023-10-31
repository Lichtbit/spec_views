# frozen_string_literal: true

module SpecViews
  class BatchDiff
    attr_reader :directories

    Change = Struct.new(:hash, :count) do
      def patched_champion
        Diff::LCS.patch!(champion, diff)
      end

      def champion
        directory.champion_html
      end

      def add(directory, diff)
        @pairs ||= []
        @pairs.push([directory, diff])
        self.count += 1
      end

      def directory
        @pairs&.first&.first
      end

      def diff
        @pairs&.first&.second
      end

      def accept!
        @pairs.each do |directory, diff|
          patched_champion = Diff::LCS.patch!(directory.champion_html, diff)
          directory.write_champion(patched_champion)
          directory.remove_challenger if patched_champion == directory.challenger_html
        end
      end
    end

    def initialize(directories)
      @directories = directories.select(&:challenger?).select(&:champion?).reject(&:binary?)
    end

    def changes
      @changes ||= begin
        map = {}
        @directories.each do |directory|
          diffs = Diff::LCS.diff(directory.champion_html, directory.challenger_html)
          diffs.each do |diff|
            raw_diff = diff.map do |change|
              element = change.element
              element = '\r' if element == "\r"
              element = '\n' if element == "\n"
              [change.action, element]
            end
            diff_hash = raw_diff.map(&:join).join
            map[diff_hash] ||= Change.new(diff_hash, 0)
            map[diff_hash].add(directory, diff)
          end
        end
        map.values.filter { |change| change.count > 1 }
      end
    end

    def biggest_change
      changes.max_by(&:count)
    end

    def accept_by_hash!(hash)
      changes.select { |change| change.hash == hash }.map(&:accept!)
    end

    private

    def get_view(path, html_safe: true)
      content = File.read(path)
      content = content.html_safe if html_safe
      content
    rescue Errno::ENOENT
      ''
    end
  end
end
