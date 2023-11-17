module SpreeStripe
  VERSION = '1.0.0.beta'.freeze

  module_function

  # Returns the version of the currently loaded SpreeStripe as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
