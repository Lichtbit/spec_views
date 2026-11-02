# frozen_string_literal: true

module SpecViews
  class BatchDiff
    attr_reader :directories

    class Change
      attr_reader :key

      def initialize(key)
        @key = key
        @pairs = []
      end

      def count
        @pairs.size
      end

      def patched_champion
        Diff::LCS.patch!(champion, diff)
      end

      def champion
        directory.champion_html
      end

      def add(directory, diff)
        @pairs.push([directory, diff])
      end

      def directory
        @pairs.first&.first
      end

      def diff
        @pairs.first&.second
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
            diff_key = raw_diff.map(&:join).join
            map[diff_key] ||= Change.new(diff_key)
            map[diff_key].add(directory, diff)
          end
        end
        map.values.filter { |change| change.count > 1 }
      end
    end

    def biggest_change
      changes.max_by(&:count)
    end

    def accept_by_key!(key)
      changes.select { |change| change.key == key }.map(&:accept!)
    end
  end
end
