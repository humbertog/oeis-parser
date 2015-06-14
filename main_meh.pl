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


sub nonDec {
my $infile = "A000010.txt";
open(FH, $infile) or die "Cannot open $infile\n";
while ( my $line = <FH> )
{
	chomp($line);
	if (index($line, '%K') != -1) 
	{
		if (index($line, 'sign') != -1) 
		{
			print"$line\n\n";   
			print"Discard\n\n";   
		}
		if (index($line, 'nonn') != -1) 
		{
			print"$line\n\n";   
			print"Keep\n\n";   
		}
	}

}
}




my @var = Parser::parseSequence("A000010.txt", \&Parser::getFirstElements);
Util::printArray(@var);