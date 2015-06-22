package Parser;
use lib './lib';
use Util;

sub parseSequence {
	# @args = ($filename, parser_ref1, parser_ref2, ...)
	my ($filename, $parser) = @_;
	open FILE, $filename or die "Couldn't open file: $filename $!"; 
	my $content_string = "";
	while (<FILE>){
		$content_string .= $_;
	}
	close FILE;
	# Uses the parser_refs parser funtion refs
	my @result = $parser->($content_string);
	return @result;
}

sub getReferences {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $id = "";
	$id = $1 if $string =~ /^%I\s(A[0-9]{6,8})\s/mg;

	# Find all id refs in the file
	my @seq = $string =~ m/A[0-9]{6}/smg;
	my @seq_clean;
	foreach (@seq) {
		if ($_ ne $id) {
			push @seq_clean, Util::trim($_);
		}
	}
	
	return @seq_clean;
}

sub getName {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $var = "";
	$var = $1 if $string =~ /^%N\sA[0-9]{6,8}\s(.*)\n/mg;
	my @ret;
	push @ret, $var;
	return @ret;
}

#takes in the string containing whole content of seq file
sub getFirstElements {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $var = "";
	$var = $1 if $string =~ /^%S\sA[0-9]{6,8}\s(.*)\n/mg;
	$var = $var . $1 if $string =~ /^%T\sA[0-9]{6,8}\s(.*)\n/mg;
	$var = $var . $1 if $string =~ /^%U\sA[0-9]{6,8}\s(.*)\n/mg;
	my @ret = split(/,/,$var);
	return @ret;
}

sub getKeyValues {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $var = "";
	$var = $1 if $string =~ /^%K\sA[0-9]{6,8}\s(.*)\n/mg;
	my @ret = split(/,/,$var);
	return @ret;
}

sub getOffset {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $var = "";
	$var = $1 if $string =~ /^%O\sA[0-9]{6,8}\s(.*)\n/mg;
	my @ret = split(/,/,$var);
	return @ret;
}

sub getFormula {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $var = "";
	$var = $1 if $string =~ /^%F\sA[0-9]{6,8}\s(.*)\n/mg;
	my @ret;
	push @ret, $var;
	return @ret;
}


#Subroutine to find all Non negative sequences and write them to file named NonNegSequences.txt
#here I am using the all sequences of folder not from file having all seq ids
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
	
	&Util::writeArrayToFile("./db/Strange.txt",@universeSequence);
	return @nonNegSeq;
	
}



1;
