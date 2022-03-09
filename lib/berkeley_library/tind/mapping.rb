Dir.glob(File.expand_path('mapping/*.rb', __dir__)).sort.each(&method(:require))
