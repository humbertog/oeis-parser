#!/usr/bin/env perl

use lib './lib';
use Parser;
use Util;
use strict;
use warnings;


# Create file with the sequences with 1 degree of separation from core seq:12345
sub getFirstDegreeOfSeparation {
	# Get local core sequences:
	my @local_core_sequences = Util::getLocalSequences("./db/core");
	my @seq_referenced_ids;
	# Get sequences referenced by the core sequences:
	foreach (@local_core_sequences) {
		push(@seq_referenced_ids, Parser::parseSequence("./db/core/". $_ . ".txt", \&Parser::getReferences));
	}
	print $#seq_referenced_ids + 1 . "\n";
	# remove duplicated
	@seq_referenced_ids = Util::unique(\@seq_referenced_ids);
	print $#seq_referenced_ids + 1 . "\n";

	# Get the sequences that are refered in the core sequences files minus the 
	# core sequences
	my @new_sequences = Util::arrayDifference(\@seq_referenced_ids, \@local_core_sequences);
	print $#new_sequences + 1 . "\n";

	# Write new sequences to file (they will later be downloaded):
	open (FILE, "> ./db/degree1.txt") || die "problem opening ./db/degree1.txt\n";
	foreach (@new_sequences) {
		print FILE $_."\n";
	}
	close(FILE);
}
#getFirstDegreeOfSeparation();


sub createCoreSeqFile {
my @coreSeq=Util::getLocalSequences("./db/core");
#Util::printArray(@coreSeq);
open (FILE, "> ./db/core.txt") || die "problem opening ./db/core.txt\n";
	foreach (@coreSeq) {
		print FILE $_."\n";
	}
	close(FILE);
}
#createCoreSeqFile();


sub findNonNegativeSequences {
	my @var="";
	my @universeSequence;
	my @negSeq; #sign
	my @nonNegSeq; #nonn
	
	my @seqPool=Util::getLocalSequences("./db/core");
	my @degree1Seq=Util::getLocalSequences("./db/degree1");
	push(@seqPool,@degree1Seq);  #@seqPool having all sequences
	#Util::printArray(@seqPool);
	my @seqPool1=("A000010","A000001sign","A000001notany");
	#Util::printArray(@seqPool1);
	for (my $i=0; $i < $#seqPool1+1; $i++)
	{
		#print("$seqPool1[$i]\n");
		@var = Parser::parseSequence("./db/core/$seqPool1[$i].txt", \&getKeyValues);
		#Util::printArray(@var);	
		if ( grep( /^nonn$/, @var ) ) {
			#print "\nNon Neg for seq id: $seqPool1[$i]\n";
			push @nonNegSeq, $seqPool1[$i];
		}	
		elsif ( grep( /^sign$/, @var ) ) {
			#print "\nNeg for seq id: $seqPool1[$i]\n";
			push @negSeq, $seqPool1[$i];
		}	
		else{
			#print "\nOther Case: $seqPool1[$i]\n";
			push @universeSequence, $seqPool1[$i];
		}	
	}
	Util::printArray("nonNegSeq:\n@nonNegSeq ");
	#Util::printArray("NegSeq:\n@negSeq ");
	#Util::printArray("otherSeq:\n@universeSequence ");
	return @nonNegSeq;
}

findNonNegativeSequences(); 


sub writeArrayToFile
{
	my $fileName = shift;
	my $arrayToWrite_ref = shift;
	open (FILE, "> $fileName") || die "problem opening $fileName\n";
	foreach (@{$arrayToWrite_ref}) {
		print FILE $_."\n";
	}
	close(FILE);
}





sub getKeyValues {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $var = "";
	$var = $1 if $string =~ /^%K\sA[0-9]{6,8}\s(.*)\n/mg;
	my @ret = split(/,/,$var);
	return @ret;
}

#my @var = Parser::parseSequence("./db/core/A000010.txt", \&getKeyValues);
#Util::printArray(@var);



#my @var = Parser::parseSequence("A000010.txt", \&Parser::getFirstElements);
#Util::printArray(@var);

