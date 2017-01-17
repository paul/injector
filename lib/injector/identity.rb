# frozen_string_literal: true

module Injector
  # Gem identity information.
  module Identity
    def self.name
      "injector"
    end

    def self.label
      "Injector"
    end

    def self.version
      "0.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
