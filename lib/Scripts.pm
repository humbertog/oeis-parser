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

sub createIndividuals {	
	my $infile = shift;
	
	my $hasName;
	my $hasFirstElements;
	my $hasFormula;
	my $hasKeywords;
	my $hasOffset;

	my $seqXMLset;
	my $seqXMLsetAll;
#chan
	my $hasID;
	my @seqName;
	my @seqFormula;
	my @seqKeywords;
	my @seqOffset;
	my $header;
	
#	open FILE, "./db_owl/header.txt" or die "Couldn't open file: $!"; 
#	while (<FILE>){
#	 $header .= $_;
#	}
#	close FILE;
	
	open (FILE, "> ./db_owl/XML_Individuals.rdf") or die "problem opening ./db_owl/XML_Individuals.rdf\n";
#	print FILE $header;
	close(FILE);
	
	my @seq = Util::readFileLinebyLineInArray($infile);
	my @seqFirstElem;
	
	my $diffInd = "<owl:AllDifferent>\n <owl:distinctMembers rdf:parseType=\"Collection\">\n";
	for (my $i=0; $i < $#seq+1; $i++)
		{
			@seqName = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getName);			
			$seqName[0]  = Util::xml_special_char($seqName[0]);
			@seqFirstElem = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getFirstElements);
			my $monotonicity = Util::checkMonoticity(\@seqFirstElem);
			
			@seqFormula = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getFormula);
			$seqFormula[0]  = Util::xml_special_char($seqFormula[0]);
			@seqKeywords=Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getKeyValues);
			my $keywords = join (",", @seqKeywords);
			@seqOffset=Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getOffset);
			my $offset = join (",", @seqOffset);
		
			my $seqFirseElemLenStr;
		for (my $j=0; $j < $#seqFirstElem+1; $j++)
		{
			if($j>0)
			{
				$seqFirseElemLenStr=$seqFirseElemLenStr.",".$seqFirstElem[$j];
			}
			else
			{
				$seqFirseElemLenStr=$seqFirseElemLenStr.$seqFirstElem[$j];				
			}
		}
		
			
			
			$seqXMLset="<owl:NamedIndividual rdf:about=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#$seq[$i]\">\n<rdf:type rdf:resource=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#Sequence\"/>\n";
			$seqXMLset .= "<hasID rdf:datatype=\"&xsd;string\">$seq[$i]</hasID>\n";
			$hasName="<hasName rdf:datatype=\"&xsd;string\">$seqName[0]</hasName>\n";
			$seqXMLset=$seqXMLset.$hasName;
			$hasFirstElements="<hasFirstElements rdf:datatype=\"&xsd;string\">$seqFirseElemLenStr</hasFirstElements>\n";
			$seqXMLset=$seqXMLset.$hasFirstElements;
			$hasFormula="<hasFormula rdf:datatype=\"&xsd;string\">$seqFormula[0]</hasFormula>\n";
			$seqXMLset=$seqXMLset.$hasFormula;
			$hasKeywords="<hasKeywords rdf:datatype=\"&xsd;string\">$keywords</hasKeywords>\n";
			$seqXMLset=$seqXMLset.$hasKeywords;				
			$hasOffset="<hasOffset rdf:datatype=\"&xsd;string\">$offset</hasOffset>\n";
			$seqXMLset=$seqXMLset.$hasOffset;
			$seqXMLset .= "<hasMonotonicity rdf:datatype=\"&xsd;string\">$monotonicity</hasMonotonicity>\n";
			
			
			$seqXMLset=$seqXMLset."</owl:NamedIndividual>\n\n";
			$diffInd .= "<Sequence rdf:about=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#$seq[$i]\"/>\n";
			#print("\n\n$seqXMLset");
			# $seqXMLsetAll = $seqXMLsetAll . $seqXMLset;
			open (FILE, ">> ./db_owl/XML_Individuals.rdf") or die "problem opening ./db_owl/XML_Individuals.rdf\n";
			print FILE"$seqXMLset";
			close(FILE);

		}
		# Add different individual statement
		$diffInd .= "</owl:distinctMembers>\n </owl:AllDifferent>";
#		open (FILE, ">> ./db_owl/XML_Individuals.rdf") or die "problem opening ./db_owl/XML_Individuals.rdf\n";
	#	print FILE"$diffInd";
#		print FILE "\n</rdf:RDF>";
#		close(FILE);

		  
		
		
		
	
}



1;