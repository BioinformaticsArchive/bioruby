#
# bio/appl/blast.rb - BLAST wrapper
# 
#   Copyright (C) 2001 Mitsuteru S. Nakao <n@bioruby.org>
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: blast.rb,v 1.11 2002/05/28 14:49:06 k Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)

module Bio

  class Blast

    def initialize(program, db, option = '', server = 'local')
      @format	= 8
      @parser	= 'rexml'

      @program	= program
      @db	= db
      @option	= "-m #{@format} #{option}"
      @server	= server

      @blastall = 'blastall'
      @matrix	= nil
      @filter	= nil
    end
    attr_accessor :program, :db, :option, :server, :blastall, :matrix, :filter

    def format=(num)
      @format = num
      @option.gsub!(/\s*-m\s+\d+/, '')
      @option += " -m #{num} "
    end
    attr_accessor :parser

    def self.local(program, db, option = '')
      self.new(program, db, option, 'local')
    end

    def self.remote(program, db, option = '', server = 'genomenet')
      self.new(program, db, option, server)
    end

    def query(query)
      return self.send("exec_#{@server}", query)
    end


    private


    def parse_result(data)
      case @format
      when 7 || '7'
	case @parser
	when 'rexml'
	  require 'bio/appl/blast/rexml'
	when 'xmlparser'
	  require 'bio/appl/blast/xmlparser'
	end
      when 8 || '8'
	require 'bio/appl/blast/format8'
      end
      Report.new(data)
    end


    def exec_local(query)
      cmd = "#{@blastall} -p #{@program} -d #{@db} #{@option}"
      
      report = nil

      begin
	io = IO.popen(cmd, "w+")
	io.sync = true
	io.puts(query)
	io.close_write
	report = parse_result(io.read)
      rescue
	raise "[Error] command execution failed : #{cmd}"
      ensure
	io.close
      end          
      
      return report
    end


    def exec_genomenet(query)
      host = "blast.genome.ad.jp"
      path = "/sit-bin/nph-blast"

      form = {
	'prog'		=> @program,
	'dbname'	=> @db,
	'sequence'	=> CGI.escape(query),
	'other_param'	=> CGI.escape(@option),
	'matrix'	=> @matrix,	# same as -M BLOSUM80
	'filter'	=> @filter,
      }

      data = []

      form.each do |k, v|
	data.push("#{k}=#{v}") if v
      end

      report = nil

      begin
	response, result = Net::HTTP.new(host).post(path, data.join('&'))
	result_path = nil

	result.each do |line|
	  if %r|href="http://#{host}(.*?)".*Show all result|i.match(line)
	    result_path = $1
	    break
	  end
	end
	if result_path
	  response, result = Net::HTTP.new(host).get(result_path)
	  if %r|<pre>.*?</pre>.*<pre>(.*)</pre>|mi.match(result)
	    report = parse_result($1)
	  end
	end
      end

      return report
    end


    def exec_ncbi(query)
      raise NotImplementedError
    end
  end

end


if __FILE__ == $0
  begin
    require 'pp'
    alias :p :pp
  rescue
  end

  query = ARGF.read

# serv = Bio::Blast.local('blastn', 'hoge.nuc')
# serv = Bio::Blast.local('blastp', 'hoge.pep')
  serv = Bio::Blast.remote('blastp', 'genes')

  puts "Parse by -m 8 (tab-delimited)"
# serv.format = 8		# default
  p serv.query(query)

  puts "Parse by -m 7 (XML by REXML)"
  serv.format = 7
# serv.parser = 'rexml'		# default
  p serv.query(query)

  puts "Parse by -m 7 (XML by XMLParser)"
  serv.format = 7
  serv.parser = 'xmlparser'
  p serv.query(query)
end


=begin

= Bio::Blast

--- Bio::Blast.new(program, db, option = '', server = 'local')
--- Bio::Blast.local(program, db, option = '')
--- Bio::Blast.remote(program, db, option = '', server = 'genomenet')

      Returns a Blast factory object (Bio::Blast).

      For the develpper, you can add server 'hoge' by adding
      Bio::Blast#exec_hoge(query) method.

--- Bio::Blast#query(query)

      Execute fasta search and returns Report object (Bio::Blast::Report).

--- Bio::Blast#program
--- Bio::Blast#db
--- Bio::Blast#option
--- Bio::Blast#server
--- Bio::Blast#blastall
--- Bio::Blast#filter

      Accessors for the factory parameters.

== Available databases for Blast.remote(@program, @db, option, 'genomenet')

  # ----------+-------+---------------------------------------------------
  #  @program | query | @db (supported in GenomeNet)
  # ----------+-------+---------------------------------------------------
  #  blastp   | AA    | nr-aa, genes, vgenes, swissprot, swissprot-upd,
  # ----------+-------+ pir, prf, pdbstr
  #  blastx   | NA    | 
  # ----------+-------+---------------------------------------------------
  #  blastn   | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  # ----------+-------+ htgs, dbsts, embl-nonst, embnonst-upd, epd,
  #  tblastn  | AA    | genes-nt, genome, vgenes.nuc
  # ----------+-------+---------------------------------------------------

=end

