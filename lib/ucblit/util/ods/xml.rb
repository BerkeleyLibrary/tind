Dir.glob(File.expand_path('xml/*.rb', __dir__)).sort.each(&method(:require))
