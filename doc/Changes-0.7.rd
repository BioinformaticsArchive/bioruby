= Incompatible and important changes since the BioRuby 0.6.4 release

A lot of changes have been made to the BioRuby after the version 0.6.4
is released.

--- Ruby 1.6 series are no longer supported.

We use autoload functionality and many standard (bundled) libraries
(such as SOAP, open-uri, pp etc.) only in Ruby >1.8.2.

--- BioRuby will be loaded about 30 times faster than before.

As we changed to use autoload instead of require, time required
to start up the BioRuby library made surprisingly faster.

Other changes (including newly introduced BioRuby shell etc.) made
in this series will be described in this file.

== New features

--- BioRuby shell

A new command line user interface for the BioRuby is now included.
You can invoke the shell by

  % bioruby

--- UnitTest

Test::Unit now covers wide range of the BioRuby library.
You can run them by

  % ruby test/runner.rb

or

  % ruby install.rb config
  % ruby install.rb setup
  % ruby install.rb test

during the installation procedure.

--- Documents

README, README.DEV, doc/Tutorial.rd, doc/Tutorial.rd.ja etc. are updated
or newly added.

== Incompatible changes

--- Bio::Sequence

* Bio::Sequence::NA#gc_percent returns integer instead of float
* Bio::Sequence::NA#gc (was aliased to gc_percent) is removed

Previously, GC% is rounded to one decimal place.  However, how many digits
should be left when rounding the value is not clear and as the GC% is an
rough measure by its nature, we have changed to return integer part only.
If you need a precise value, you can calculate it by values from the
'composition' method by your own criteria.

Also, the 'gc' method is removed as the method name doesn't represent
its value is ambiguous.

* Bio::Sequence#blast
* Bio::Sequence#fasta

These two methods are removed.  Use Bio::Blast and Bio::Fasta to execute
BLAST and FASTA search.

--- Bio::NucleicAcid

Bio::NucleicAcid::Names and Bio::NucleicAcid::Weight no longer exists.

Bio::NucleicAcid::Names is renamed to Bio::NucleicAcid::Data::NAMES and
can be accessed by Bio::NucleicAcid#names, Bio::NucleicAcid.names methods
and Bio::NucleicAcid::WEIGHT hash as the Data module is included.

Bio::NucleicAcid::Weight is renamed to Bio::NucleicAcid::Data::Weight and
can be accessed by Bio::NucleicAcid#weight, Bio::NucleicAcid.weight methods
and Bio::NucleicAcid::WEIGHT hash as the Data module is included.

--- Bio::AminoAcid

Bio::AminoAcid::Names and Bio::AminoAcid::Weight no longer exists.

Bio::AminoAcid::Names is renamed to Bio::AminoAcid::Data::NAMES and
can be accessed by Bio::AminoAcid#names, Bio::AminoAcid.names methods
and Bio::AminoAcid::WEIGHT hash as the Data module is included.

Bio::AminoAcid::Weight is renamed to Bio::AminoAcid::Data::Weight and
can be accessed by Bio::AminoAcid#weight, Bio::AminoAcid.weight methods
and Bio::AminoAcid::WEIGHT hash as the Data module is included.

--- Bio::CodonTable

Bio::CodonTable::Tables, Bio::CodonTable::Definitions,
Bio::CodonTable::Starts, and Bio::CodonTable::Stops
are renamed to
Bio::CodonTable::TABLES, Bio::CodonTable::DEFINITIONS,
Bio::CodonTable::STARTS, and Bio::CodonTable::STOPS
respectively.

--- Bio::KEGG::Microarrays, Bio::KEGG::Microarray

* lib/bio/db/kegg/microarray.rb is renamed to lib/bio/db/kegg/expression.rb
* Bio::KEGG::Microarray is renamed to Bio::KEGG::EXPRESSION
* Bio::KEGG::Microarrays is removed

Bio::KEGG::Microarrays was intended to store a series of microarray
expressions as a Hash of Array -like data structure,

  gene1 => [exp1, exp2, exp3, ... ]
  gene2 => [exp1, exp2, exp3, ... ]

however, it is not utilized well and more suitable container class
can be proposed.  Until then, this class is removed.

#
# Following changes are suspended for a while (not yet introduced for now)
#
# --- Bio::Pathway
#
# * Bio::Pathway#nodes returns an Array of the node objects instead of
#   the number of the node objects.
# * Bio::Pathway#edges returns an Array of the edge objects instead of
#   the number of the edge objects.
#

--- Bio::GenBank

Bio::GenBank#gc is removed as the value can be calculated by the
Bio::Sequence::NA#gc method and the method is also changed to
return integer instead of float.

Bio::GenBank#varnacular_name is renamed to Bio::GenBank#vernacular_name
as it was a typo.

--- Bio::GenBank::Common

* lib/bio/db/genbank/common.rb is removed.

Renamed to Bio::NCBIDB::Common to make simplify the autoload dependency.

--- Bio::EMBL::Common

* lib/bio/db/embl/common.rb is removed.

Renamed to Bio::EMBLDB::Common to make simplify the autoload dependency.

--- Bio::KEGG::GENES

* lib/bio/db/kegg/genes.rb

linkdb method is changed to return a Hash of an Array of entry IDs
instead of a Hash of a entry ID string.

--- Bio::TRANSFAC

* Bio::TFMATRIX is renamed to Bio::TRANSFAC::MATRIX
* Bio::TFSITE   is renamed to Bio::TRANSFAC::SITE
* Bio::TFFACTOR is renamed to Bio::TRANSFAC::FACTOR
* Bio::TFCELL   is renamed to Bio::TRANSFAC::CELL
* Bio::TFCLASS  is renamed to Bio::TRANSFAC::CLASS
* Bio::TFGENE   is renamed to Bio::TRANSFAC::GENE

--- Bio::GFF

* Bio::GFF2 is renamed to Bio::GFF::GFF2
* Bio::GFF3 is renamed to Bio::GFF::GFF3

--- Bio::Alignment

* Old Bio::Alignment class is renamed to Bio::Alignment::OriginalAlignment.
  Now, new Bio::Alignment is a module. However, you don't mind so much
  because most of the class methods previously existed are defined
  to delegate to the new Bio::Alignment::OriginalAlignment class,
  for keeping backward compatibility.
* New classes and modules are introduced. Please refer RDoc.
* each_site and some methods changed to return Bio::Alignment::Site,
  which inherits Array (previously returned Array).
* consensus_iupac now returns only standard bases
  'a', 'c', 'g', 't', 'm', 'r', 'w', 's', 'y', 'k', 'v',
  'h', 'd', 'b', 'n', or nil (in SiteMethods#consensus_iupac) or
  '?' (or missing_char, in EnumerableExtension#consensus_iupac).
  Note that consensus_iupac now does not return u and invalid letters
  not defined in IUPAC standard even if all bases are equal.
* There are more and more changes to be written...

--- Bio::PDB

In 0.7.0:

* Bio::PDB::Atom is removed. Instead, please use Bio::PDB::Record::ATOM and
  Bio::PDB::Record::HETATM.
* Bio::PDB::FieldDef is removed and Bio::PDB::Record is completely
  changed. Now, records is changed from hash to Struct objects.
  (Note that method_missing is no longer used.)
* In records, "do_parse" is now automatically called.
  Users don't need to call do_parse explicitly.
  (0.7.0 feature: "inspect" does not call do_parse.)
  (0.7.1 feature: "inspect" calls do_parse.)
* In the "MODEL" record, model_serial is changed to serial.
* In records, record_type is changed to record_name.
* In most records contains real numbers, return values are changed
  to float instead of string.
* Pdb_AChar, Pdb_Atom, Pdb_Character, Pdb_Continuation,
  Pdb_Date, Pdb_IDcode, Pdb_Integer, Pdb_LString, Pdb_List,
  Pdb_Real, Pdb_Residue_name, Pdb_SList, Pdb_Specification_list,
  Pdb_String, Pdb_StringRJ and Pdb_SymOP are moved under
  Bio::PDB::DataType.
* There are more and more changes to be written...

In 0.7.1:

* Heterogens and HETATMs are completely separeted from residues and ATOMs.
  HETATMs (Bio::PDB::Record::HETATM objects) are stored in
  Bio::PDB::Heterogen (which inherits Bio::PDB::Residue).
* Waters (resName=="HOH") are treated as normal heterogens.
  Model#solvents is still available but it will be deprecated.
* In Bio::PDB::Chain, adding "LIGAND" to the heterogen id is no longer
  available. Instead, please use Chain#get_heterogen_by_id method.
  In addition, Bio::{PDB|PDB::Model::PDB::Chain}#heterogens, #each_heterogen,
  #find_heterogen, Bio::{PDB|PDB::Model::PDB::Chain::PDB::Heterogen}#hetatms,
  #each_hetatm, #find_hetatm methods are added.
* Bio::PDB#seqres returns Bio::Sequence::NA object if the chain seems to be
  a nucleic acid sequence.
* There are more and more changes to be written...

=== Deleted files

: lib/bio/db/genbank.rb
: lib/bio/db/embl.rb

These files are removed as we changed to use autoload.  You can safely
replace

  require 'bio/db/genbank'

or

  require 'bio/db/embl'

in your code to

  require 'bio'

and this change will also speeds up loading time even if you only need
one of the sub classes under the genbank/ or embl/ directory.

: lib/bio/extend.rb

This file contained some additional methods to String and Array classes.
The methods added to Array are already included in Ruby itself since the
version 1.8, and the methods added to String are moved to the BioRuby shell
(lib/bio/shell/plugin/seq.rb).


