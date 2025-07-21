Dir.glob(File.expand_path('mapping/*.rb', __dir__)).each(&method(:require))
