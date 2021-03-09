Dir.glob(File.expand_path('ods/*.rb', __dir__)).sort.each(&method(:require))
