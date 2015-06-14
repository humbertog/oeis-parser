#!/usr/bin/env perl

use lib './lib';
use Parser;
use Util;
use strict;
use warnings;


# Create file with the sequences with 1 degree of separation from core seq:
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


getFirstDegreeOfSeparation();








