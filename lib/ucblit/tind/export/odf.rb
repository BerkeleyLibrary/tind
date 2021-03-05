Dir.glob(File.expand_path('odf/*.rb', __dir__)).sort.each(&method(:require))
