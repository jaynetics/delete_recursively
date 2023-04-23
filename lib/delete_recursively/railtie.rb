class DeleteRecursively::Railtie < ::Rails::Railtie
  config.to_prepare do
    DeleteRecursively::AssociatedClassFinder.clear_cache
  end
end
