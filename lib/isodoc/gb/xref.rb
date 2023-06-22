module IsoDoc
  module Gb
    class Xref < IsoDoc::Xref
      attr_accessor :anchors_previous, :anchors
    end
  end
end
