# ignoring files by Zeitwerk when spree_frontend isn't loaded
unless ::Spree::Core::Engine.frontend_available?
    Dir.chdir(Rails.root.join(".."))
    files_to_ignore = Dir["**/spree_stripe/payments_controller.rb"]
    files_to_ignore.each { |file| 
      Rails.autoloaders.main.ignore(Rails.root.join("../#{file}"))
    }
end