#
# bio/data/aa.rb - Amino Acids
#
#   Copyright (C) 2001, 2005 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: aa.rb,v 0.8 2005/08/07 08:19:28 k Exp $
#

module Bio

  class AminoAcid

    module Data

      # IUPAC code
      # * http://www.iupac.org/
      # * http://www.chem.qmw.ac.uk/iubmb/newsletter/1999/item3.html

      Names= {

        'A' => 'Ala',
        'C' => 'Cys',
        'D' => 'Asp',
        'E' => 'Glu',
        'F' => 'Phe',
        'G' => 'Gly',
        'H' => 'His',
        'I' => 'Ile',
        'K' => 'Lys',
        'L' => 'Leu',
        'M' => 'Met',
        'N' => 'Asn',
        'P' => 'Pro',
        'Q' => 'Gln',
        'R' => 'Arg',
        'S' => 'Ser',
        'T' => 'Thr',
        'V' => 'Val',
        'W' => 'Trp',
        'Y' => 'Tyr',
        'B' => 'Asx',	# D/N
        'Z' => 'Glx',	# E/Q
        'U' => 'Sec',	# 'uga' (stop)
        '?' => 'Pyl',	# 'uag' (stop)
       
        'Ala' => 'alanine',
        'Cys' => 'cysteine',
        'Asp' => 'aspartic acid',
        'Glu' => 'glutamic acid',
        'Phe' => 'phenylalanine',
        'Gly' => 'glycine',
        'His' => 'histidine',
        'Ile' => 'isoleucine',
        'Lys' => 'lysine',
        'Leu' => 'leucine',
        'Met' => 'methionine',
        'Asn' => 'asparagine',
        'Pro' => 'proline',
        'Gln' => 'glutamine',
        'Arg' => 'arginine',
        'Ser' => 'serine',
        'Thr' => 'threonine',
        'Val' => 'valine',
        'Trp' => 'tryptophan',
        'Tyr' => 'tyrosine',
        'Asx' => 'asparagine/aspartic acid',
        'Glx' => 'glutamine/glutamic acid',
        'Sec' => 'selenocysteine',
        'Pyl' => 'pyrrolysine',

      }

      # AAindex FASG760101 - Molecular weight (Fasman, 1976)
      #   Fasman, G.D., ed.
      #   Handbook of Biochemistry and Molecular Biology", 3rd ed.,
      #   Proteins - Volume 1, CRC Press, Cleveland (1976)

      Weight = {

        'A' => 89.09,
        'C' => 121.15,	# 121.16 according to the Wikipedia
        'D' => 133.10,
        'E' => 147.13,
        'F' => 165.19,
        'G' => 75.07,
        'H' => 155.16,
        'I' => 131.17,
        'K' => 146.19,
        'L' => 131.17,
        'M' => 149.21,
        'N' => 132.12,
        'P' => 115.13,
        'Q' => 146.15,
        'R' => 174.20,
        'S' => 105.09,
        'T' => 119.12,
        'U' => 168.06,
        'V' => 117.15,
        'W' => 204.23,
        'Y' => 181.19,
      }

      def weight(x = nil)
        if x
          Weight[x]
        else
          Weight
        end
      end

      def [](x)
        Names[x]
      end

      def name(x)
        str = Names[x]
        if str and str.length == 3
          Names[str]
        else
          str
        end
      end

      def to_1(x)
        case x.to_s.length
        when 1
          x
        when 3
          three2one(x)
        else
          name2one(x)
        end
      end

      def to_3(x)
        case x.to_s.length
        when 1
          one2three(x)
        when 3
          x
        else
          name2three(x)
        end
      end

      def one2three(x)
        if x and x.length != 1
          raise ArgumentError
        else
          Names[x]
        end
      end

      def three2one(x)
        if x and x.length != 3
          raise ArgumentError
        else
          reverse[x]
        end
      end

      def one2name(x)
        if x and x.length != 1
          raise ArgumentError
        else
          Names[x]
        end
      end

      def name2one(x)
        str = reverse[x.to_s.downcase]
        if str and str.length == 3
          reverse[str]
        else
          str
        end
      end

      def three2name(x)
        if x and x.length != 3
          raise ArgumentError
        else
          Names[x]
        end
      end

      def name2three(x)
        reverse[x.downcase]
      end

      private

      def reverse
        hash = Hash.new
        Names.each do |k, v|
          hash[v] = k
        end
        hash
      end

    end


    # as instance methods
    include Data

    # as class methods
    extend Data


    # backward compatibility
    Names = Data::Names
    Weight = Data::Weight

    def aa
      Names
    end

    def self.names
      Names
    end

    private

    alias :orig_reverse :reverse
    def reverse
      unless @reverse
        @reverse = orig_reverse
      end
      @reverse
    end

  end

end


if __FILE__ == $0

  puts "### aa = Bio::AminoAcid.new"
  aa = Bio::AminoAcid.new

  puts "# Bio::AminoAcid['A']"
  p Bio::AminoAcid['A']
  puts "# aa['A']"
  p aa['A']

  puts "# Bio::AminoAcid.name('A')"
  p Bio::AminoAcid.name('A')
  puts "# aa.name('A')"
  p aa.name('A')

  puts "# Bio::AminoAcid.to_1('alanine')"
  p Bio::AminoAcid.to_1('alanine')
  puts "# aa.to_1('alanine')"
  p aa.to_1('alanine')
  puts "# Bio::AminoAcid.to_1('Ala')"
  p Bio::AminoAcid.to_1('Ala')
  puts "# aa.to_1('Ala')"
  p aa.to_1('Ala')
  puts "# Bio::AminoAcid.to_1('A')"
  p Bio::AminoAcid.to_1('A')
  puts "# aa.to_1('A')"
  p aa.to_1('A')

  puts "# Bio::AminoAcid.to_3('alanine')"
  p Bio::AminoAcid.to_3('alanine')
  puts "# aa.to_3('alanine')"
  p aa.to_3('alanine')
  puts "# Bio::AminoAcid.to_3('Ala')"
  p Bio::AminoAcid.to_3('Ala')
  puts "# aa.to_3('Ala')"
  p aa.to_3('Ala')
  puts "# Bio::AminoAcid.to_3('A')"
  p Bio::AminoAcid.to_3('A')
  puts "# aa.to_3('A')"
  p aa.to_3('A')


  puts "# Bio::AminoAcid.one2three('A')"
  p Bio::AminoAcid.one2three('A')
  puts "# aa.one2three('A')"
  p aa.one2three('A')

  puts "# Bio::AminoAcid.three2one('Ala')"
  p Bio::AminoAcid.three2one('Ala')
  puts "# aa.three2one('Ala')"
  p aa.three2one('Ala')

  puts "# Bio::AminoAcid.one2name('A')"
  p Bio::AminoAcid.one2name('A')
  puts "# aa.one2name('A')"
  p aa.one2name('A')

  puts "# Bio::AminoAcid.name2one('alanine')"
  p Bio::AminoAcid.name2one('alanine')
  puts "# aa.name2one('alanine')"
  p aa.name2one('alanine')

  puts "# Bio::AminoAcid.three2name('Ala')"
  p Bio::AminoAcid.three2name('Ala')
  puts "# aa.three2name('Ala')"
  p aa.three2name('Ala')

  puts "# Bio::AminoAcid.name2three('alanine')"
  p Bio::AminoAcid.name2three('alanine')
  puts "# aa.name2three('alanine')"
  p aa.name2three('alanine')

end

