#
# bio/db/sptr.rb - SwissProt and TrEMBL protein sequence database parsing
# 
# BioRuby class for Bio::SPTR
# 
#   Copyright (C) 2001 Mitsuteru S. Nakao <n@bioruby.org>
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
#  $Id: sptr.rb,v 1.4 2001/11/06 16:58:52 okuji Exp $
#


#Line code Content                      Occurrence in an entry
#--------- ---------------------------  --------------------------------
#     ID - identification               (begins each entry; 1 per entry)
#     AC - accession number(s)          (>=1 per entry)
#     DT - date                         (3 per entry)
#     DE - description                  (>=1 per entry)
#     GN - gene name(s)                 (>=0 per entry; optional)
#     OS - organism species             (>=1 per entry)
#     OG - organelle                    (0 or 1 per entry; optional)
#     OC - organism classification      (>=1 per entry)
#     RN - reference number             (>=1 per entry)
#     RP - reference positions          (>=1 per entry)
#     RC - reference comment(s)         (>=0 per entry; optional)
#     RX - reference cross-reference(s) (>=0 per entry; optional)
#     RA - reference author(s)          (>=1 per entry)
#     RT - reference title              (>=0 per entry; optional)
#     RL - reference location           (>=1 per entry)
#     CC - comments or notes            (>=0 per entry; optional)
#     DR - database cross-references    (>=0 per entry; optional)
#     KW - keywords                     (>=1 per entry)
#     FT - feature table data           (>=0 per entry; optional)
#     SQ - sequence header              (1 per entry)
#     bb - (blanks) The sequence data   (>=1 per entry)
#     // - termination line             (ends each entry; 1 per entry)
#--------- ---------------------------  --------------------------------

module Bio

  require 'bio/db'
  require 'bio/sequence'

  class SPTR < EMBLDB
    
    DELIMITER	= RS = "\n//\n"
    TAGSIZE	= 5
    
    ##
    #
    def initialize(entry)
      super(entry, TAGSIZE)
    end

    ##
    # ID Line
    # "ID  #{ENTRY_NAME} #{DATA_CLASS}; #{MOLECULE_TYPE}; #{SEQUENCE_LENGTH}."
    #
    # ENTRY_NAME = "#{X}_#{Y}"
    # X =~ /[A-Z0-9]{1,4}/ # The protein name.
    # Y =~ /[A-Z0-9]{1,5}/ # The biological source of the protein.
    # See also the SWISS-PROT dicument file SPECLIST.TXT.
    ENTRY_REGREXP=/[A-Z0-9]{1,4}_[A-Z0-9]{1,5}/
    # 
    DATA_CLASS = ["STANDARD", "PRELIMINARY"]
    #
    # MOLECULE_TYPE = 'PRT' =~ /\w{3}/ 
    #
    # SEQUENCE_LENGTH =~ /\d+ AA/
    #
    # Bio::SPTR#id_line -> Hash
    # Bio::SPTR#id_line(key) -> String/Int
    # Bio::SPTR#id_line {} -> {|key,val }
    #
    def id_line(key = nil)
      unless @data['ID']
	tmp = Hash.new
	a = @orig['ID'].split(/ +/)         
	tmp['ENTRY_NAME']      = a[1]
	tmp['DATA_CLASS']      = a[2].sub(/;/,'') 
	tmp['MOLECULE_TYPE']   = a[3].sub(/;/,'')
	tmp['SEQUENCE_LENGTH'] = a[4].to_i
	@data['ID'] = tmp
      end
      if block_given?
	@data['ID'].each do |k,v|
	  yield(k,v)
	end
      elsif key
	@data['ID'][key]
      else
	@data['ID']
      end
    end
    ##
    # Bio::SPTR#entry -> String
    #          #entry_name -> String
    #
    def entry
      id_line('ENTRY_NAME')
    end
    alias entry_name entry
    ##
    # Bio::SPTR#molecule_type -> String
    #
    def molecule
      id_line('MOLECULE_TYPE')
    end
    alias molecule_type molecule
    ##
    # Bio::SPTR#sequence_length -> Int
    #          #sequencelegth -> Int
    #          #seqlen -> Int
    #          #aalen -> Int
    #
    def sequence_length
      id_line('SEQUENCE_LENGTH')
    end
    alias sequencelength sequence_length
    alias seqlen sequence_length
    alias aalen sequence_length


    ##
    # AC Line
    # "AC   A12345; B23456;"
    # AC [AC1;]+
    #
    # Accession numbers format:
    # 1       2     3          4          5          6
    # [O,P,Q] [0-9] [A-Z, 0-9] [A-Z, 0-9] [A-Z, 0-9] [0-9]
    #
    # Bio::SPTR#ac  -> Array
    #          #accessions  -> Array
    AC_REGREXP=/[OPQ][0-9][A-Z0-9]{3}[0-9]/
    # DT Line; date (3/entry)
    # DT DD-MMM-YYY (rel. NN, Created)
    # DT DD-MMM-YYY (rel. NN, Last sequence update)
    # DT DD-MMM-YYY (rel. NN, Last annotation update)
    #
    # Bio::SPTR#dt  -> Hash
    # Bio::SPTR#dt(key)  -> String
    # key = (created|sequence|annotation)
    def dt(key = nil)
      unless @data['DT']
	tmp=Hash.new
	a=self.get('DT').split("\n")
	tmp['created']=a[0].sub(/\w{2}   /,'').strip
	tmp['sequence']=a[1].sub(/\w{2}   /,'').strip
	tmp['annotation']=a[2].sub(/\w{2}   /,'').strip
	@data['DT']=tmp
      end
      if block_given?
	@data['DT'].each do |k,v|
	  yield(k,v)
	end
      elsif key
	@data['DT'][key]
      else
	@data['DT']
      end
    end

    ##
    # DE Line; description (>=1)
    # "DE #{OFFICIAL_NAME} (#{SYNONYM})"
    # "DE #{OFFICIAL_NAME} (#{SYNONYM}) [CONTEINS: #1; #2]."
    # OFFICIAL_NAME  1/entry
    # SYNONYM        >=0
    # CONTEINS       >=0
    #
    def de 
      fetch('DE')
    end

    ##
    # GN Line: Gene name(s) (>=0, optional)
    # GN   HNS OR DRDX OR OSMZ OR BGLY.
    # GN   CECA1 AND CECA2.
    #
    # GN NAME1 [(AND|OR) NAME]+.
    #
    # Bio::SPTR#gn -> Array
    #          #gene_names -> Array
    #
    def gn 
      unless @data['GN']
	@data['GN'] = fetch('GN').sub(/.$/,'').split(/ OR | AND /)
      end
      @data['GN']
    end
    alias gene_names gn
    ##
    # Bio::SPTR#gene_name -> String
    #
    def gene_name
      @data['GN'][0]
    end

    ##
    # OS Line; organism species (>=1)
    # "OS   Trifolium repens (white clover)"
    #
    # OS   Genus species (name).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0) (name1).
    # OS   Genus species (name0), G s0 (name0), and G s (name1).
    #
    # Bio::EMBL#os  -> Array w/in Hash
    # [{'name'=>'Human', 'os'=>'Homo sapiens'}, 
    #  {'name'=>'Rat', 'os'=>'Rattus norveticus'}]
    # Bio::STPR#os[0]['name'] => "Human"
    # Bio::STPR#os[0] => {'name'=>"Human", 'os'=>'Homo sapiens'}
    # Bio::STPR#os(0) => "Homo sapiens (Human)"
    #
    # Bio::SPTR#os -> Array w/in Hash
    # Bio::SPTR#os(num) -> String
    

    ##
    # OG Line; organella (0 or 1/entry)
    # ["MITOCHONDRION", "CHLOROPLAST", "Cyanelle", "Plasmid"]
    #  or a plasmid name (e.g. "Plasmid pBR322").  
    #
    # Bio::SPTR#og  -> Array


    ##
    # OC Line; organism classification (>=1)
    # OC   Eukaryota; Alveolata; Apicomplexa; Piroplasmida; Theileriidae;
    # OC   Theileria.
    #
    # Bio::SPTR#oc  -> Array

    ##
    # R Lines
    # RN RC RP RX RA RT RL

    ##
    # CC lines (>=0, optional)
    # CC   -!- TISSUE SPECIFICITY: HIGHEST LEVELS FOUND IN TESTIS. ALSO PRESENT
    # CC       IN LIVER, KIDNEY, LUNG AND BRAIN.
    #
    # CC   -!- TOPIC: FIRST LINE OF A COMMENT BLOCK;
    # CC       SECOND AND SUBSEQUENT LINES OF A COMMENT BLOCK.
    #
    CC_TOPICS = ['ALTERNATIVE PRODUCTS','CATALYTIC ACTIVITY','CAUTION',
      'COFACTOR','DATABASE','DEVELOPMENTAL STAGE','DISEASE','DOMAIN',
      'ENZYME REGULATION','FUNCTION','INDUCTION','MASS SPECTROMETRY',
      'MISCELLANEOUS','PATHWAY','PHARMACEUTICAL','POLYMORPHISM','PTM',
      'SIMILARITY','SUBCELLULAR LOCATION','SUBUNIT','TISSUE SPECIFICITY']
    # 
    # DATABASE: NAME=Text[; NOTE=Text][; WWW="Address"][; FTP="Address"].
    # MASS SPECTROMETRY: MW=XXX[; MW_ERR=XX][; METHOD=XX][;RANGE=XX-XX].
    #
    # Bio::SPTR#cc -> Hash w/in Array
    # Bio::SPTR#cc(Int) -> String
    # Bio::SPTR#cc(TOPIC) -> Array w/in Hash
    # Bio::SPTR#cc('DATABASE') -> [{'NAME'=>String,'NOTE'=>String,
    #                               'WWW'=>URI,'FTP'=>URI}]
    # Bio::SPTR#cc('MASS SPECTROMETRY') -> [{'MW"=>Float,'MW_ERR'=>Float,
    #                                        'METHOD'=>String,'RANGE'=>String}]
    #
    def cc(num = nil)
      # @data['CC'] = {'DATABASE'=>['hoge','fuga']}
      unless @data['CC']
	cc = Hash.new
	# too /ad hoc/ (^_^;
	cmt = \
   '--------------------------------------------------------------------------'
	dlm = /-!- /
	fetch('CC').split(cmt)[0].sub(dlm,'').split(dlm).each do |tmp|
	  if tmp =~ /(^[A-Z ]+): (.+)\./
	    unless cc['$1']
	      cc[$1] = [$2]
	    else
	      cc[$1].puch($2)
	    end
	  else
	    raise "Error: CC Lines \n\n#{tmp.inspect}\n\n#{fetch('CC')}\n";
	  end
	end
	@data['CC'] = cc
      end
      if num == 'DATABASE'
	# DATABASE: NAME=Text[; NOTE=Text][; WWW="Address"][; FTP="Address"].
	tmp = Array.new
	@data['CC']['DATABASE'].each do |e|
	  db = {'NAME'=>nil,'NOTE'=>nil,'WWW'=>nil,'FTP'=>nil}
	  e.sub(/.$/,'').split(';').each do |l|
	    case l
	    when /NAME=(.+)/
	      db['NAME'] = $1
	    when /NOTE=(.+)/
	      db['NOTE'] = $1
	    when /WWW="(.+)"/
	      db['WWW'] = $1
	    when /FTP="(.+)"/
	      db['FTP'] = $1
	    end 
	  end
	  tmp.push(db)
	end
	return tmp
      elsif num == 'MASS SPECTOROMETRY'
	# MASS SPECTROMETRY: MW=XXX[; MW_ERR=XX][; METHOD=XX][;RANGE=XX-XX].
	tmp = Array.new
	@data['CC']['MASS SPECTOROMETRY'].each do |m|
	  mass = {'MW'=>nil,'MW_ERR'=>nil,'METHOD'=>nil,'RANGE'=>nil}
	  m.sub(/.$/,'').split(';').each do |l|
	    case l
	    when /MW=(.+)/
	      mass['MW'] = $1.to_f
	    when /MW_ERR=(.+)/
	      mass['MW_ERR'] = $1.to_f
	    when /METHOD="(.+)"/
	      mass['METHOD'] = $1.to_s
	    when /RANGE="(\d+-\d+)"/ 
	      mass['RANGE'] = $1          # RANGE class ? 
	    end 
	  end
	  tmp.push(mass)
	end
	return tmp
      else
	@data['CC']
      end
    end

    ##
    # DR Line; defabases cross-reference (>=0)
    # a cross_ref pre one line
    # "DR  database_identifier; primary_identifier; secondary_identifier."
    DR_DATABASE_IDENTIFIER=['EMBL','CARBBANK','DICTYDB','ECO2DBASE','ECOGENE',
      'FLYBASE','GCRDB','HIV','HSC-2DPAGE','HSSP','INTERPRO','MAIZEDB',
      'MAIZE-2DPAGE','MENDEL','MGD''MIM','PDB','PFAM','PIR','PRINTS',
      'PROSITE','REBASE','AARHUS/GHENT-2DPAGE','SGD','STYGENE','SUBTILIST',
      'SWISS-2DPAGE','TIGR','TRANSFAC','TUBERCULIST','WORMPEP','YEPD','ZFIN']
    #
    # Bio::SPTR#dr  -> Hash w/in Array


    ##
    # KW Line; keyword (>=1)
    # KW   [Keyword;]+
    # Bio::SPTR#kw  -> Array
    #          #keywords  -> Array

    ##
    # FT Line; feature table data (>=0, optional)
    #
    # Col     Data item
    # -----   -----------------
    #  1- 2   FT
    #  6-13   Key name
    # 15-20   `FROM' endpoint
    # 22-27   `TO' endpoint
    # 35-75   Description
    # -----   -----------------
    #
    # Bio::SPTR#ft -> {'Key_name'=>[{'From'=>String,'To'=>String',
    #                  'Description'=>String}],}
    # Bio::SPTR#ft(key_name) -> [{'From'=>String,'To'=>String',
    #                             'Description'=>String}],}]
    #
    def ft(key = nil)
      unless @data['FT']
	tmp = Hash.new
	dlm = 'FT   '
	get('FT').split("\n").each do |e|
	  key_name = e[5..12].strip
	  tmp[key_name] = Array.new unless tmp[key_name]
	  tmp[key_name].push({'From'=>e[14..19].strip,'To'=>e[21..26].strip, 
			       'Description'=>e[34..74].sub('.$','').strip} )
	end
	@data['FT'] = tmp
      end
      if key
	@data['FT'][key]
      else
	@data['FT']
      end
    end
    # 
    # ft('SIGNAL').each do {|s| signal=seq[s['From'].to_i..s['To'].to_i] }
    #

    ##
    # SQ Line; sequence header (1/entry)
    # SQ   SEQUENCE   233 AA;  25630 MW;  146A1B48A1475C86 CRC64;
    # SQ   SEQUENCE  \d+ AA; \d+ MW;  [0-9A-Z]+ CRC64;
    #
    # MW, Dalton unit
    # CRC64 (64-bit Cyclic Redundancy Check, ISO 3309)
    #
    # Bio::SPTRL#sq  -> Hash
    #
    def sq(key = nil)
      unless @data['SQ']
	fetch('SQ') =~ /(\d+) AA\; (\d+) MW; (.+) CRC64;/
	@data['SQ'] = { 'aalen'=>$1.to_i, 'MW'=>$2.to_i, 'CRC64'=>$3 }
      end
      if block_given?
	@data['SQ'].each do |k,v|
	  yield(k,v)
	end
      elsif key
	if key =~ /mw/ or /molecular/ or /weight/
	  @data['SQ']['MW']
	elsif key =~ /len/ or /length/ or /AA/
	  @data['SQ']['aalen']
	else
	  @data['SQ'][key]
	end
      else 
	@data['SQ']
      end
    end
    ##
    # @orig[''] as sequence
    # bb Line; (blanks) sequence data (>=1)
    # Bio::SPTR#seq  -> Bio::Sequence::AA
    #
    def seq
      Sequence::AA.new( fetch('').gsub(/ /,'').gsub(/\d+/,'') )
    end

    # // Line; termination line (end; 1/entry)

  end

end # module Bio


# testing codes
if __FILE__ == $0
end


=begin
= NAME

  sptr.rb - A parser object class for SWISS-PROT/TrEMBL entry


== Usage:

  require 'bio/db/sptr'
  emb=Bio::SPTR.new(data)



== Author

  Mitsuteru S. Nakao <n@BioRuby.org>
  The BioRuby Project (http://BioRuby.org/)

== Class

  class  Bio::SPTR

== Methods

* Initialize
--- Bio::SPTR#new(a_sp_entry)

* ID Line (Identification)
--- Bio::SPTR#id_line -> Hash
--- Bio::SPTR#id_line(key) -> String
       key = (ENTRY_NAME|MOLECULE_TYPE|DATA_CLASS|SEQUENCE_LENGTH)
--- Bio::SPTR#entry -> String
             #entryname -> String
--- Bio::SPTR#molecule -> String
--- Bio::SPTR#division -> String
--- Bio::SPTR#sequencelength -> Int
    
* AC Lines (Accession number)
--- Bio::SPTR#ac -> Array
--- Bio::SPTR#accession -> String
 
* GN Line (Gene name(s))
--- Bio::SPTR#gn -> Array

* DT Lines (Date) 
--- Bio::SPTR#dt -> Hash
--- Bio::SPTR#dt(key) -> String
      key = (created|annotation|sequence)
--- Bio::SPTR.dt['updated']

* DE Lines (Description)
--- Bio::SPTR#de -> String

* KW Lines (Keyword)
--- Bio::SPTR#kw -> Array

* OS Lines (Organism species)
--- Bio::SPTR#os -> Array

* OC Lines (organism classification)
--- Bio::SPTR#oc -> Array

* OG Line (Organella)
--- Bio::SPTR#og -> String

* R Lines (Reference) 
      RN RC RP RX RA RT RL
--- Bio::SPTR#ref -> String 

* DR Lines (Database cross-reference)
--- Bio::SPTR#dr -> Hash
--- Bio::SPTR#dr(dbname) -> Array

* FT Lines (Feature table data)
--- Bio::SPTR#ft -> Hash
--- Bio::SPTR#ft(key) -> Array

* SQ Lines (Sequence header and data)
      SQ bb
--- Bio::SPTR#sq -> Hash
--- Bio::EMBL#seq -> Bio::Sequece::AA

=end
