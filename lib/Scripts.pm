package Scripts;
use lib './lib';
use Util;

# Create file with the sequences with 1 degree of separation from core seq:
# The sequences that are mentioned in the files
sub getFirstDegreeOfSeparation {
	# args: the directory with the sequences from which first degree is going to be obtained
	my ($input_dir, $output_file)  = @_;
	# Get local core sequences:
	my @local_core_sequences = Util::getLocalSequences($input_dir);
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
	open (FILE, "> $output_file") || die "problem opening $output_file\n";
	foreach (@new_sequences) {
		print FILE $_."\n";
	}
	close(FILE);
}

#Subroutine to find all Non negative sequences and write them to file named NonNegSequences.txt
sub findNonNegativeSequences {
	my @var="";
	my @universeSequence;
	my @negSeq; #sign
	my @nonNegSeq; #nonn
	
	#Getting all sequence IDs from the folder containing CORE and DEGREE1 sequences
	my @seqPool=Util::getLocalSequences("./db/sequences");
	#print $#seqPool;
	#print("\n\n");
	for (my $i=0; $i < $#seqPool+1; $i++)
	{
		@var = Parser::parseSequence("./db/sequences/$seqPool[$i].txt", \&Util::getKeyValues);
		#Util::printArray(@var);	
		if ( grep( /^nonn$/, @var ) ) {
			#print "\nNon Neg for seq id: $seqPool[$i]\n";
			push @nonNegSeq, $seqPool[$i];
		}	
		elsif ( grep( /^sign$/, @var ) ) {
			#print "\nNeg for seq id: $seqPool[$i]\n";
			push @negSeq, $seqPool[$i];
		}	
		else{
			#print "\nOther Case: $seqPool[$i]\n";
			push @universeSequence, $seqPool[$i];
		}	
	}
	#Printing Arrays and its count
	
	#Util::printArray("nonNegSeq:\n@nonNegSeq ");
	#Util::printArray("NegSeq:\n@negSeq ");
	#Util::printArray("otherSeq:\n@universeSequence ");
	#print $#nonNegSeq;
	#print $#negSeq;
	#print $#universeSequence;
	&Util::writeArrayToFile("./db/NonNegSequences.txt",@nonNegSeq);
	return @nonNegSeq;
	
}

sub classifyByMonotonicity {
	# args: the file with the sequence id's to classify
	my $filename = shift;
	open FILE, $filename or die "Couldn't open file: $!"; 
	my @content_array;
	while (<FILE>){
		chomp $_;
		push @content_array, $_;
	}
	close FILE;
	
	my @none_seq;
	my @constant_seq;
	my @nondecreasing_seq;
	my @nonincreasing_seq;
	my @decreasing_seq;
	my @increasing_seq;
	
	foreach my $seq (@content_array) {
		my @first_elem = Parser::parseSequence("./db/sequences/$seq.txt", \&Parser::getFirstElements);
		my $monoticity = Util::checkMonoticity(\@first_elem);
		push (@none_seq, $seq) if ($monoticity eq "nonmonotonic");
		push (@constant_seq, $seq) if ($monoticity eq "constant");
		push (@nondecreasing_seq, $seq) if ($monoticity eq "non_decreasing");
		push (@nonincreasing_seq, $seq) if ($monoticity eq "non_increasing");
		push (@decreasing_seq, $seq) if ($monoticity eq "decreasing");
		push (@increasing_seq, $seq) if ($monoticity eq "increasing");
	}
	Util::writeArrayToFile("./db/mono_nonmonotonic.txt", @none_seq);
	Util::writeArrayToFile("./db/mono_constant.txt", @constant_seq);
	Util::writeArrayToFile("./db/mono_nondecreasing.txt", @nondecreasing_seq);
	Util::writeArrayToFile("./db/mono_nonincreasing.txt", @nonincreasing_seq);
	Util::writeArrayToFile("./db/mono_decreasing.txt", @decreasing_seq);
	Util::writeArrayToFile("./db/mono_increasing.txt", @increasing_seq);
}	


1;