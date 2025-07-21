Dir.glob(File.expand_path('api/*.rb', __dir__)).each(&method(:require))
