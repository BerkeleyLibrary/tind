Dir.glob(File.expand_path('search/*.rb', __dir__)).sort.each(&method(:require))
