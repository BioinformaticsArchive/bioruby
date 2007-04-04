#
# bio/util/restrction_enzyme/range/sequence_range/fragment.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: fragment.rb,v 1.3 2007/04/04 18:07:44 trevor Exp $
#

require 'bio/util/restriction_enzyme/range/cut_ranges'
require 'bio/util/restriction_enzyme/range/horizontal_cut_range'
require 'bio'

module Bio; end
class Bio::RestrictionEnzyme
class Range
class SequenceRange

#
# bio/util/restrction_enzyme/range/sequence_range/fragment.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class Fragment

  attr_reader :size

  def initialize( primary_bin, complement_bin )
    @primary_bin = primary_bin
    @complement_bin = complement_bin
  end

  DisplayFragment = Struct.new(:primary, :complement)

  def for_display(p_str=nil, c_str=nil)
    df = DisplayFragment.new
    df.primary = ''
    df.complement = ''

    both_bins = (@primary_bin + @complement_bin).sort.uniq
    both_bins.each do |item|
      @primary_bin.include?(item) ? df.primary << p_str[item] : df.primary << ' '
      @complement_bin.include?(item) ? df.complement << c_str[item] : df.complement << ' '
    end

    df
  end
end # Fragment
end # SequenceRange
end # Range
end # Bio::RestrictionEnzyme
