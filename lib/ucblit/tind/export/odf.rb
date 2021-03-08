# TODO: Replace RODF with something more flexible, complete, and easy to use, so we don't need these subclasses.
Dir.glob(File.expand_path('odf/*.rb', __dir__)).sort.each(&method(:require))
