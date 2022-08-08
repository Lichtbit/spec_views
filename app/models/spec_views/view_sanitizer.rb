module SpecViews
  class ViewSanitizer
    delegate :each, to: :@sanitizers

    def initialize
      @sanitizers = []
    end

    def gsub(*args, &block)
      @sanitizers << [:gsub, args, block]
    end

    def sanitize(string)
      each do |sanitize_method, args, block|
        string = string.send(sanitize_method, *args, &block)
      end
      string
    end
  end
end