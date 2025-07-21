Dir.glob(File.expand_path('marc/*.rb', __dir__)).each(&method(:require))
