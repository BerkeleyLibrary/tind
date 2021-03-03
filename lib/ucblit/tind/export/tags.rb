module UCBLIT
  module TIND
    module Export
      module Tags
        DO_NOT_EXPORT_FIELDS = ['005', '8564 ', '902  ', '903  ', '991', '998']
        DO_NOT_EDIT_FIELDS = ['001'].append(DO_NOT_EXPORT_FIELDS)

        DO_NOT_EXPORT_SUBFIELDS = ['336  a', '852  c', '901  a', '901  f', '901  g', '980  a', '982  a', '982  b', '982  p']
        DO_NOT_EDIT_SUBFIELDS = ['035  a'].append(DO_NOT_EXPORT_SUBFIELDS)
      end
    end
  end
end
