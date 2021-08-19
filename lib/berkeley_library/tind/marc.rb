Dir.glob(File.expand_path('marc/*.rb', __dir__)).sort.each(&method(:require))
