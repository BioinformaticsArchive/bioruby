#
# bio/appl/clustalw/report.rb - CLUSTAL W format data (*.aln) class
#
#   Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: report.rb,v 1.1 2003/07/25 07:51:08 ng Exp $
#

require 'bio/sequence'
require 'bio/db'
require 'bio/alignment'
require 'bio/appl/alignfactory'
require 'bio/appl/clustalw'

module Bio
  class ClustalW < AlignFactory
    class Report < Bio::DB
      DELIMITER = nil

      def initialize(str, seqclass = nil)
	@raw = str
	@align = nil
	@match_line = nil
	@header = nil
	case seqclass
	when /PROTEIN/i
	  @seqclass = Bio::Sequence::AA
	when /[DR]NA/i
	  @seqclass = Bio::Sequence::NA
	else
	  if seqclass.is_a?(Module) then
	    @seqclass = seqclass
	  else
	    @seqclass = Bio::Sequence
	  end
	end
      end
      attr_reader :raw
      attr_reader :seqclass

      def header
	@header or (do_parse or @header)
      end

      def match_line
	@match_line or (do_parse or @match_line)
      end

      def align
	do_parse() unless @align
	@align
      end
      alias :alignment :align

      def [](n)
	align[n] or align.order(n)
      end

      def to_fasta(*arg)
	align.to_fasta(*arg)
      end

      def to_a
	align.to_fastaformat_array
      end

      private
      def do_parse
	return nil if @align
	a = @raw.split("\n\n")
	@header = a.shift.to_s
	@align = Bio::Alignment.new
	@match_line = ''
	if a.size > 0 then
	  a[0].gsub!(/\A\n+/, '')
	  a.collect! { |x| x.split("\n") }
	  @tagsize = ( a[0][0].rindex(/\s/) or -1 ) + 1
	  a.each do |x|
	    @match_line << x.pop.to_s[@tagsize..-1]
	  end
	  a[0].each do |y|
	    @align.store(y[0, @tagsize].sub(/\s+\z/, ''), '')
	  end
	  a.each do |x|
	    x.each do |y|
	      name = y[0, @tagsize].sub(/\s+\z/, '')
	      seq = y[@tagsize..-1]
	      @align[name] << seq
	    end
	  end
	  @align.collect! { |x| @seqclass.new(x) }
	end
	nil
      end

    end #class Report
  end #class ClustalW
end #module Bio
