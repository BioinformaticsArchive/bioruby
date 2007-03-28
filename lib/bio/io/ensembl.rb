#
# = bio/io/ensembl.rb - An Ensembl Genome Browser client.
#
# Copyright::   Copyright (C) 2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     Ruby's
#
# $Id: ensembl.rb,v 1.5 2007/03/28 12:01:48 nakao Exp $
#
# == Description
#
# Client classes for Ensembl Genome Browser.
#
# == Examples
#
#  seq = Bio::Ensembl.human.exportview(1, 1000, 100000)
#  gff = Bio::Ensembl.human.exportview(1, 1000, 100000, ['gene'])
#
#  seq = Bio::Ensembl.mouse.exportview(1, 1000, 100000)
#  gff = Bio::Ensembl.mouse.exportview(1, 1000, 100000, ['gene', 'variation', 'genscan'])
#
#  
# == References
#
# * Ensembl
#   http:/www.ensembl.org/
#

require 'bio/command'
require 'uri'
require 'cgi'

module Bio

# == Description
#
# An Ensembl Genome Browser client class.
#
# == Examples
#
#  human = Bio::Ensembl.new('Homo_sapiens')
#  seq = human.exportview(1, 1000, 100000)
#  gff = human.exportview(1, 1000, 100000, ['gene'])
#
#  mouse = Bio::Ensembl.new('Mus_musculus')
#  seq = mouse.exportview(1, 1000, 100000)
#  gff = mouse.exportview(1, 1000, 100000, ['gene', 'variation', 'genscan'])
#
#  rice = Bio::Enesmbl.new('Oryza_sativa', 'http://www.gramene.org')
#  seq = rice.exportview(1, 1000, 100000)
#
# == References
#
# * Ensembl
#   http:/www.ensembl.org/
#
# * GRAMENE
#   http://www.gramene.org/
#
class Ensembl
  
  ENSEMBL_URL = 'http://www.ensembl.org'

  attr_reader :server

  attr_reader :organism

  def initialize(organism, server = nil)
    @server = server || ENSEMBL_URL
    @organism = organism
    @uri = [ @server.chomp('/'), @organism ].join('/')
  end

  def self.human
    self.new("Homo_sapiens")
  end

  def self.mouse
    self.new("Mus_musculus")
  end

  # Ensembl ExportView Client.
  #
  # Retrieve genomic sequence/features from Ensembl ExportView in plain text.
  # Ensembl ExportView exports genomic data (sequence and features) in 
  # several file formats including fasta, GFF and tab.
  #
  # * ExportViwe (http://www.ensembl.org/Homo_sapiens/exportview).
  #
  # == Examples
  #
  #   human = Bio::Ensembl.new('Homo_sapiens')
  #     or
  #   human = Bio::Ensembl.human
  #
  #   # Genomic sequence in Fasta format
  #   human.exportview(:seq_region_name => 1, 
  #                    :anchor1 => 1149206, :anchor2 => 1149229)
  #   human.exportview(1, 1149206, 1149229)
  #
  #   # Feature in GFF
  #   human.exportview(:seq_region_name => 1, 
  #                    :anchor1 => 1149206, :anchor2 => 1150000, 
  #                    :options => ['similarity', 'repeat', 
  #                                 'genscan', 'variation', 'gene'])
  #   human.exportview(1, 1149206, 1150000, ['variation', 'gene'])
  #
  # == Arguments
  #
  # Bio::Ensembl#exportview method allow both orderd arguments and 
  # named arguments. (Note: mandatory arguments are marked by '*').
  #
  # === Orderd Arguments
  #
  # 1. seq_region_name - Chromosome number (*)
  # 2. anchor1         - From coordination (*)
  # 3. anchor2         - To coordination (*)
  # 4. options         - Features to export (in :format => 'gff' or 'tab')
  #                      ['similarity', 'repeat', 'genscan', 'variation', 
  #                       'gene']
  #
  # === Named Arguments
  # 
  # * :seq_region_name - Chromosome number (*)
  # * :anchor1         - From coordination (*)
  # * :anchor2         - To coordination (*)
  # * :type1           - From coordination type ['bp', ]
  # * :type2           - To coordination type ['bp', ]
  # * :upstream        - Bp upstream
  # * :downstream      - Bp downstream
  # * :format          - File format ['fasta', 'gff', 'tab']
  # * :options         - Features to export (for :format => 'gff' or 'tab')
  #                      ['similarity', 'repeat', 'genscan', 'variation', 
  #                       'gene']
  # 
  def exportview(*args)
    if args.first.class == Hash
      options = args.first
    else
      options = {
        :seq_region_name => args[0], 
        :anchor1 => args[1], 
        :anchor2 => args[2],
      }
      case args.size
      when 3 then 
        options.update({:format => 'fasta'})
      when 4 then 
        options.update({:format => 'gff', :options => args[3]})
      end
    end
    
    defaults = {
      :type1 => 'bp', 
      :type2 => 'bp', 
      :downstream => '', 
      :upstream => '', 
      :format => 'fasta',
      :options => [],
      :action => 'export', 
      :_format => 'Text', 
      :output => 'txt', 
      :submit => 'Continue >>'
    }

    params = defaults.update(options)

    Bio::Command.post_form("#{@uri}/exportview", params)
  end

end # class Ensembl

end # module Bio


