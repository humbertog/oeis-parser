package Scripts;
use lib './lib';
use Util;

# Create file with the sequences with 1 degree of separation from core seq:
sub getFirstDegreeOfSeparation {
	# Get local core sequences:
	my @local_core_sequences = Util::getLocalSequences("./db/core");
	my @seq_referenced_ids;
	# Get sequences referenced by the core sequences:
	for my $i (0 .. $#local_core_sequences) {
		my $file = "./db/core/$local_core_sequences[$i].txt";
		my @new = &Parser::parseSequence($file, \&Parser::getReferences);
		@seq_referenced_ids = (@seq_referenced_ids, @new);
	}
	print $#seq_referenced_ids + 1 . "\n";
	# remove duplicated
	@seq_referenced_ids = Util::unique(\@seq_referenced_ids);
	print $#seq_referenced_ids + 1 . "\n";
	print $#local_core_sequences + 1 . "\n";

	# Get the sequences that are refered in the core sequences files minus the 
	# core sequences
	print @local_core_sequences . "\n";
	my @new_sequences = Util::arrayDifference(\@seq_referenced_ids, \@local_core_sequences);
	print $#new_sequences + 1 . "\n";

	# Write new sequences to file (they will later be downloaded):
	open (FILE, "> ./db/degree1.txt") || die "problem opening ./db/degree1.txt\n";
	foreach (@new_sequences) {
		print FILE $_."\n";
	}
	close(FILE);
}


1;