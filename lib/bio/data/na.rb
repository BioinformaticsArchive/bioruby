#
# bio/data/na.rb - Nucleic Acids
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: na.rb,v 0.9 2005/08/07 08:19:28 k Exp $
#

module Bio

  class NucleicAcid

    module Data

      # IUPAC code
      # * Faisst and Meyer (Nucleic Acids Res. 20:3-26, 1992)
      # * http://www.ncbi.nlm.nih.gov/collab/FT/

      Names = {

        'y'	=> '[tc]',	# pYrimidine
        'r'	=> '[ag]',	# puRine
        'w'	=> '[at]',	# Weak
        's'	=> '[gc]',	# Strong
        'k'	=> '[tg]',	# Keto
        'm'	=> '[ac]',	# aMino

        'b'	=> '[tgc]',	# not A
        'd'	=> '[atg]',	# not C
        'h'	=> '[atc]',	# not G
        'v'	=> '[agc]',	# not T

        'n'	=> '[atgc]',

        'a'	=> 'a',
        't'	=> 't',
        'g'	=> 'g',
        'c'	=> 'c',
        'u'	=> 'u',

        'A'	=> 'adenine',
        'T'	=> 'thymine',
        'G'	=> 'guanine',
        'C'	=> 'cytosine',
        'U'	=> 'uracil',

      }

      Weight = {

        # Calculated by BioPerl's Bio::Tools::SeqStats.pm :-)

        'a'	=> 135.15,
        't'	=> 126.13,
        'g'	=> 151.15,
        'c'	=> 111.12,
        'u'	=> 112.10,

        :adenine	=> 135.15,
        :thymine	=> 126.13,
        :guanine	=> 151.15,
        :cytosine	=> 111.12,
        :uracil		=> 112.10,

        :deoxyribose_phosphate	=> 196.11,
        :ribose_phosphate	=> 212.11,

        :hydrogen	=> 1.00,
        :water		=> 18.015,

      }

      def weight(x = nil, rna = nil)
        if x
          if x.length > 1
            if rna
              phosphate = Weight[:ribose_phosphate]
            else
              phosphate = Weight[:deoxyribose_phosphate]
            end
            hydrogen    = Weight[:hydrogen]
            water       = Weight[:water]

            total = 0.0
            x.each_byte do |byte|
              base = byte.chr.downcase
              total += Weight[base] + phosphate - hydrogen * 2
            end
            total -= water * (x.length - 1)
          else
            Weight[x.to_s.downcase]
          end
        else
          Weight
        end
      end

      def [](x)
        Names[x]
      end

      def name(x)
        Names[x.to_s.upcase]
      end

      def to_re(seq)
        str = ""
        seq.to_s.downcase.each_byte do |base|
          if re = Names[base.chr]
            str += re
          else
            str += "."
          end
        end
        Regexp.new(str)
      end

    end


    # as instance methods
    include Data

    # as class methods
    extend Data


    # backward compatibility
    Names = Data::Names
    Weight = Data::Weight

    def na
      Names
    end

    def self.names
      Names
    end

  end

end


if __FILE__ == $0

  puts "### na = Bio::NucleicAcid.new"
  na = Bio::NucleicAcid.new

  puts "# na.to_re('yrwskmbdhvnatgc')"
  p na.to_re('yrwskmbdhvnatgc')

  puts "# Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')"
  p Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')

  puts "# na.weight('A')"
  p na.weight('A')

  puts "# Bio::NucleicAcid.weight('A')"
  p Bio::NucleicAcid.weight('A')

  puts "# na.weight('atgc')"
  p na.weight('atgc')

  puts "# Bio::NucleicAcid.weight('atgc')"
  p Bio::NucleicAcid.weight('atgc')

end
