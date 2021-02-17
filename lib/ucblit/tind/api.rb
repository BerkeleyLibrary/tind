Dir.glob(File.expand_path('api/*.rb', __dir__)).sort.each(&method(:require))
