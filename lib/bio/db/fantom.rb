#
# bio/db/fantom.rb - RIKEN FANTOM2 database classes
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
#  $Id: fantom.rb,v 1.4 2003/04/25 14:11:10 ng Exp $
#

begin
  require 'rexml/document'
  rescue LoadError
end

require 'bio/db'
require 'bio/sequence'

module Bio

  module FANTOM

    class MaXML < DB
      # DTD of MaXML(Mouse annotation XML)
      # http://fantom.gsc.riken.go.jp/maxml/maxml.dtd

      DELIMITER = RS = "\n--EOF--\n"
      # This class is for {allseq|repseq|allclust}.sep.xml,
      # not for {allseq|repseq|allclust}.xml.

      Data_XPath = ''

      def initialize(x)
	if x.is_a?(REXML::Element) then
	  @elem = x
	else
	  if x.is_a?(String) then
	    x = x.sub(/#{Regexp.escape(DELIMITER)}\z/om, "\n")
	  end
	  doc = REXML::Document.new(x)
	  @elem = doc.elements[self.class::Data_XPath]
	  #raise 'element is null' unless @elem
	  @elem = REXML::Document.new('') unless @elem
	end
      end

      attr_reader :elem

      def gsub_entities(str)
	# workaround for bug?
	if str then
	  str.gsub(/\&\#(\d{1,3})\;/) { sprintf("%c", $1.to_i) }
	else
	  str
	end
      end

      def entry_id
	unless defined?(@entry_id)
	  @entry_id = @elem.attributes['id']
	end
	@entry_id
      end
      def self.define_element_text_method(array)
	array.each do |tagstr|
	  module_eval ("
	    def #{tagstr}
	      unless defined?(@#{tagstr})
		@#{tagstr} = gsub_entities(@elem.text('#{tagstr}'))
	      end
	      @#{tagstr}
	    end
	  ")
	end
      end
      private_class_method :define_element_text_method

      class Cluster < MaXML
	# (MaXML cluster)
	# ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allclust.sep.xml.gz

	Data_XPath = 'maxml-clusters/cluster'

	def representative_seqid
	  unless defined?(@representative_seqid)
	    @representative_seqid =
	      gsub_entities(@elem.text('representative-seqid'))
	  end
	  @representative_seqid
	end

	def sequences
	  unless defined?(@sequences)
	    @sequences = MaXML::Sequences.new(@elem)
	  end
	  @sequences
	end

	def sequence(idstr = nil)
	  idstr ? sequences[idstr] : representative_sequence
	end

	def representative_sequence
	  sequences[representative_seqid]
	end

	def representative_annotations
	  e = representative_sequence
	  e ? e.annotations : nil
	end

	define_element_text_method(%w(fantomid))
      end #class MaXML::Cluster

      class Sequences < MaXML
	Data_XPath = 'maxml-sequences'

	include Enumerable
	def each
	  to_a.each { |x| yield x }
	end

	def to_a
	  unless defined?(@sequences)
	    @sequences = @elem.get_elements('sequence')
	    @sequences.collect! { |e| MaXML::Sequence.new(e) }
	  end
	  @sequences
	end

	def get(idstr)
	  unless defined?(@hash)
	    @hash = {}
	  end
	  unless @hash.member?(idstr) then
	    @hash[idstr] = self.find do |x|
	      x.altid.values.index(idstr)
	    end
	  end
	  @hash[idstr]
	end

	def [](*arg)
	  if arg[0].is_a?(String) and arg.size == 1 then
	    get(arg[0])
	  else
	    to_a[*arg]
	  end
	end
      end #class MaXML::Sequences

      class Sequence < MaXML
	# (MaXML sequence)
	# ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allseq.sep.xml.gz
	# ftp://fantom2.gsc.riken.go.jp/fantom/2.1/repseq.sep.xml.gz
	
	Data_XPath = 'maxml-sequences/sequence'

	def altid(t = nil)
	  unless defined?(@altid)
	    @altid = {}
	    @elem.each_element('altid') do |e|
	      @altid[e.attributes['type']] = gsub_entities(e.text)
	    end
	  end
	  if t then
	    @altid[t]
	  else
	    @altid
	  end
	end

	def annotations
	  unless defined?(@annotations)
	    @annotations =
	      MaXML::Annotations.new(@elem.elements['annotations'])
	  end
	  @annotations
	end

	define_element_text_method(%w(seqid fantomid cloneid rearrayid accession annotator version modified_time comment))
      end #class MaXML::Sequence

      class Annotations < MaXML
	Data_XPath = nil

	include Enumerable
	def each
	  to_a.each { |x| yield x }
	end

	def to_a
	  unless defined?(@a)
	    @a = @elem.get_elements('annotation')
	    @a.collect! { |e| MaXML::Annotation.new(e) }
	  end
	  @a
	end

	def get_all_by_qualifier(qstr)
	  unless defined?(@hash)
	    @hash = {}
	  end
	  unless @hash.member?(qstr) then
	    @hash[qstr] = self.find_all do |x|
	      x.qualifier == qstr
	    end
	  end
	  @hash[qstr]
	end

	def get_by_qualifier(qstr)
	  a = get_all_by_qualifier(qstr)
	  a ? a[0] : nil
	end

	def [](*arg)
	  if arg[0].is_a?(String) and arg.size == 1 then
	    get_by_qualifier(arg[0])
	  else
	    to_a[*arg]
	  end
	end

	def cds_start
	  unless defined?(@cds_start)
	    e = get_by_qualifier('cds_start')
	    @cds_start = e ? e.anntext.to_i : nil
	  end
	  @cds_start
	end

	def cds_stop
	  unless defined?(@cds_stop)
	    e = get_by_qualifier('cds_stop')
	    @cds_stop = e ? e.anntext.to_i : nil
	  end
	  @cds_stop
	end

	def gene_name
	  unless defined?(@gene_name)
	    e = get_by_qualifier('gene_name')
	    @gene_name = e ? e.anntext : nil
	  end
	  @gene_name
	end

	def data_source
	  unless defined?(@data_source)
	    e = get_by_qualifier('gene_name')
	    @data_source = e ? e.datasrc[0] : nil
	  end
	  @data_source
	end

	def evidence
	  unless defined?(@evidence)
	    e = get_by_qualifier('gene_name')
	    @evidence = e ? e.evidence : nil
	  end
	  @evidence
	end
      end #class MaXML::Annotations

      class Annotation < MaXML
	def entry_id
	  nil
	end

	class DataSrc < String
	  def initialize(text, href)
	    super(text)
	    @href = href
	  end
	  attr_reader :href
	end

	def datasrc
	  unless defined?(@datasrc)
	    @datasrc = []
	    @elem.each_element('datasrc') do |e|
	      text = e.text
	      href = e.attributes['href']
	      @datasrc << DataSrc.new(gsub_entities(text), gsub_entities(href))
	    end
	  end
	  @datasrc
	end

	define_element_text_method(%w(qualifier srckey anntext evidence))
      end #class MaXML::Annotation

    end #class MaXML

  end #module FANTOM

end #module Bio

=begin

 Bio::FANTOM are database classes treating RIKEN FANTOM2 data.
 FANTOM2 is available at ((<URL:http://fantom2.gsc.riken.go.jp/>)).

= Bio::FANTOM::MaXML::Cluster

 This class is for 'allclust.sep.xml' found at
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allclust.sep.xml.gz>)).
 Not that this class is not suitable for 'allclust.xml'.

--- Bio::FANTOM::MaXML::Cluster.new(str)

--- Bio::FANTOM::MaXML::Cluster#entry_id

--- Bio::FANTOM::MaXML::Cluster#fantomid

--- Bio::FANTOM::MaXML::Cluster#representative_seqid

--- Bio::FANTOM::MaXML::Cluster#sequences

 Lists sequences in this cluster.
 Returns Bio::FANTOM::MaXML::Sequences object.

--- Bio::FANTOM::MaXML::Cluster#sequence(id_str)

 Shows a sequence information of given id.
 Returns Bio::FANTOM::MaXML::Sequence object or nil.


= Bio::FANTOM::MaXML::Sequences

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Cluster class.

 This class can also be used for 'allseq.sep.xml' and 'repseq.sep.xml',
 but you'd better using Bio::FANTOM::MaXML::Sequence class.

 In addition, this class can be used for 'allseq.xml' and 'repseq.xml',
 but you'd better not to use them, becase of the speed is very slow.

--- Bio::FANTOM::MaXML::Sequences#to_a

 Returns an Array of Bio::FANTOM::MaXML::Sequence objects.

--- Bio::FANTOM::MaXML::Sequences#each

--- Bio::FANTOM::MaXML::Sequences#[](x)

 Same as to_a[x] when x is a integer.
 Same as get[x] when x is a string.

--- Bio::FANTOM::MaXML::Sequences#get(id_str)

 Shows a sequence information of given id.
 Returns Bio::FANTOM::MaXML::Sequence object or nil.


= Bio::FANTOM::MaXML::Sequence

 This class is for 'allseq.sep.xml' and 'repseq.sep.xml' found at
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/allseq.sep.xml.gz>)) and
 ((<URL:ftp://fantom2.gsc.riken.go.jp/fantom/2.1/repseq.sep.xml.gz>)).
 Not that this class is not suitable for 'allseq.xml' and 'repseq.xml'.

 In addition, the instances of this class are automatically created
 by Bio::FANTOM::MaXML::Sequences class.

--- Bio::FANTOM::MaXML::Sequence.new(str)

--- Bio::FANTOM::MaXML::Sequence#entry_id

--- Bio::FANTOM::MaXML::Sequence#altid(type_str = nil)

 Returns hash of altid if no arguments are given.
 Returns ID as a string if a type of ID (string) is given.

--- Bio::FANTOM::MaXML::Sequence#annotations

 Get lists of annotation data.
 Returns an Array of Bio::FANTOM::MaXML::Annotation objects.

--- Bio::FANTOM::MaXML::Sequence#seqid

--- Bio::FANTOM::MaXML::Sequence#fantomid

--- Bio::FANTOM::MaXML::Sequence#cloneid

--- Bio::FANTOM::MaXML::Sequence#rearrayid

--- Bio::FANTOM::MaXML::Sequence#accession

--- Bio::FANTOM::MaXML::Sequence#annotator

--- Bio::FANTOM::MaXML::Sequence#version

--- Bio::FANTOM::MaXML::Sequence#modified_time

--- Bio::FANTOM::MaXML::Sequence#comment

= Bio::FANTOM::MaXML::Annotation

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Sequence class.

--- Bio::FANTOM::MaXML::Annotation#datasrc

 Returns an Array of Bio::FANTOM::MaXML::Annotation::DataSrc objects.

--- Bio::FANTOM::MaXML::Annotation#qualifier

--- Bio::FANTOM::MaXML::Annotation#srckey

--- Bio::FANTOM::MaXML::Annotation#anntext

--- Bio::FANTOM::MaXML::Annotation#evidence

= Bio::FANTOM::MaXML::Annotation::DataSrc < String

 The instances of this class are automatically created
 by Bio::FANTOM::MaXML::Annotation class.

---- Bio::FANTOM::MaXML::Annotation::DataSrc#href

 Shows a link URL to database web page as an String.

= References

* ((<URL:http://fantom2.gsc.riken.go.jp/>))

=end
