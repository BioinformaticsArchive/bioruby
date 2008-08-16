#
# test/unit/bio/appl/test_codeml.rb - Unit test for Bio::CodeML
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/codeml'

BIORUBY_ROOT  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
TEST_DATA = Pathname.new(File.join(BIORUBY_ROOT, 'test', 'data', 'codeml')).cleanpath.to_s

module Bio
  class TestCodemlData

    def self.generate_config_file
      test_config = Tempfile.new('codeml_config').path
      Bio::CodeML.create_config_file({
        :model       => 1,
        :fix_kappa   => 1,
        :aaRatefile  => TEST_DATA + '/wag.dat',
        :seqfile     => TEST_DATA + '/abglobin.aa',
        :treefile    => TEST_DATA + '/abglobin.trees',
        :outfile     => Tempfile.new('codeml_test').path,
      },test_config)
      test_config
    end

    def self.dummy_binary
      TEST_DATA + '/dummy_binary'
    end

    def self.example_config
      TEST_DATA + '/config.txt'
    end
  end

  class TestCodemlConfigGeneration < Test::Unit::TestCase

    EXAMPLE_CONFIG = TestCodemlData.generate_config_file

    def test_config_file_generated
      assert_not_nil(File.size?(EXAMPLE_CONFIG))
    end

    def test_expected_options_set_in_config_file
      produced_config = File.open(EXAMPLE_CONFIG).inject(Hash.new) do |hash,line|
        hash.store(*line.strip.split(' = '))
        hash
      end
      assert_equal(produced_config['seqfile'], TEST_DATA + '/abglobin.aa')
      assert_equal(produced_config['fix_kappa'], '1')
      assert_equal(produced_config['model'], '1')
    end
  end

  class TestConfigFileUsage < Test::Unit::TestCase
    
    def loaded
      codeml = Bio::CodeML.new(TestCodemlData.dummy_binary)
      codeml.load_options_from_file(TestCodemlData.example_config)
      codeml
    end

    def test_options_should_be_loaded_from_config
      assert_not_nil(loaded.options)
    end

    def test_correct_options_should_be_loaded
      assert_equal(File.expand_path(loaded.options[:seqfile]), File.expand_path(TEST_DATA + '/abglobin.aa'))
      assert_equal(loaded.options[:fix_kappa], '1')
      assert_equal(loaded.options[:model], '1')
    end

  end
end
