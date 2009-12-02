#
# test/unit/bio/db/kegg/test_compound.rb - Unit test for Bio::KEGG::COMPOUND
#
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/compound'

module Bio
  class TestKeggCompound < Test::Unit::TestCase

    def setup
      testdata_kegg = Pathname.new(File.join(BioRubyTestDataPath, 'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, "C00025.compound"))
      @obj = Bio::KEGG::COMPOUND.new(entry)
    end

    def test_entry_id
      assert_equal('C00025', @obj.entry_id)
    end

    def test_name
      assert_equal("L-Glutamate", @obj.name)
    end

    def test_names
      assert_equal(["L-Glutamate", "L-Glutamic acid", "L-Glutaminic acid", "Glutamate"], @obj.names)
    end

    def test_formula
      assert_equal("C5H9NO4", @obj.formula)
    end

    def test_mass
      assert_equal(147.0532, @obj.mass)
    end

    def test_dblinks
      assert_equal([ "CAS: 56-86-0",
                     "PubChem: 3327",
                     "ChEBI: 16015",
                     "KNApSAcK: C00001358",
                     "PDB-CCD: GLU",
                     "3DMET: B00007",
                     "NIKKAJI: J9.171E" ], @obj.dblinks)
    end

  end
end
