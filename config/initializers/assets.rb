Rails.application.config.assets.precompile << 'spree_stripe_manifest.js'
Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
