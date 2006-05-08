#
# = bio/db/embl/swissprot.rb - SwissProt database class
# 
# Copyright::   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org>
# License::     Ruby's
#
#  $Id: swissprot.rb,v 1.5 2006/05/08 14:23:51 k Exp $
#
# == Description
# 
# Name space for SwissProt specific methods.
#
# SwissProt (before UniProtKB/SwissProt) specific methods are defined in 
# this class. Shared methods for UniProtKB/SwissProt and TrEMBL classes 
# are defined in Bio::SPTR class.
#
# == Examples
#
#   str = File.read("p53_human.swiss")
#   obj = Bio::SwissProt.new(str)
#   obj.entry_id #=> "P53_HUMAN"
#
# == Referencees
#
# * Swiss-Prot Protein knowledgebase
#   http://au.expasy.org/sprot/
#
# * Swiss-Prot Protein Knowledgebase User Manual
#   http://au.expasy.org/sprot/userman.html
# 

require 'bio/db/embl/sptr'

module Bio

# Parser class for SwissProt database entry.
# See also Bio::SPTR class.
class SwissProt < SPTR
  # Nothing to do (SwissProt format is abstracted in SPTR)
end

end

