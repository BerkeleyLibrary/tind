# TODO: can these be refinements after all?
Dir.glob(File.expand_path('marc_extensions/*.rb', __dir__)).sort.each(&method(:require))
