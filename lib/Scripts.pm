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
#		print FILE"$diffInd";
#		print FILE "\n</rdf:RDF>";
#		close(FILE);


}


sub redundantPairsRemoval{
#SeqLMPairOf2Measure.txt
	my $infile = "./db/LM/SeqLMPairOf2Measure.txt";

	my @lamberMoserPairs=Util::readFileLinebyLineInArray($infile);
	print "lamberMoserPairs1:$#lamberMoserPairs\n";

	pop (@lamberMoserPairs);
	my %hasmap;
	my @finalArray;
	my @bestArray;
	print "lamberMoserPairs2:$#lamberMoserPairs\n";
	
	foreach my $ln (@lamberMoserPairs) {
		my @first = split(/\s\|\s/, $ln);
		my $ids = $first[0];
		$hasmap{$ids} = $first[1] . " | " . $first[2];
		
	}
	print "lamberMoserPairs3:$#lamberMoserPairs\n";
	
	foreach my $key (keys %hasmap) {
		my @id = split(/\s->\s/, $key);
		my $reverseID = $id[1] . " -> " . $id[0];
		if(defined($hasmap{$reverseID})) {
			my $tempStr="$reverseID | $hasmap{$reverseID}";
			push @bestArray,  $tempStr; 
			delete $hasmap{$reverseID};
		}
	}
	foreach my $key (keys %hasmap) {
		push @finalArray, $key . " | " . $hasmap{$key}; 
	}
	
	
	#print &Util::printArray(@finalArray);
	print &Util::printArray(@bestArray);
	print $#bestArray . "\n";
	print $#finalArray . "\n";
}


#findDirectLambekMoserInverse();
sub findDirectLambekMoserInverse{
	my $infile = "./db/compool1.txt";
	#my $infile =  shift;
	my @arrayOfAllSeqIDs=readFileLinebyLineInArray($infile);
	#print  ("\narrayOfAllSeqIDs:@arrayOfAllSeqIDs");

	
	
	my @secLMPairArrayOf2;
	my $secLMPairStringOf2;
	
	my %seqHasMap1=Util::createFirstEmlemtDataStr($infile);   #"./db/all.txt"


	for (my $i=0; $i <=$#arrayOfAllSeqIDs; $i++)
	{
		my $seq="./db/sequences/$arrayOfAllSeqIDs[$i].txt";
		
		 my @seqFirstElem = Parser::parseSequence($seq, \&Parser::getFirstElements);
#		print("\nseqID:$i, $seq ___________________________________\nLen:$#seqFirstElem @seqFirstElem");
		
		
			my @seqLM=Util::ComputeLambekMoserInverseDirect(\@seqFirstElem);
			#print ("\nLen:$#seqLM seqLM:@seqLM\n");
			
			my @arrayOfPossibleSeq=findComplementSeqIDfromHashMap2(\@seqLM, \%seqHasMap1);
			
			my @secLMPairArrayOf2_t = map {$arrayOfAllSeqIDs[$i] . " | " . $#seqFirstElem . " | ". $_} @arrayOfPossibleSeq;
			@secLMPairArrayOf2 = (@secLMPairArrayOf2 , @secLMPairArrayOf2_t);
	
	}
	
	open (FILE2, "> ./db/LM/SeqLMPairOf2.txt") or die "problem opening  ./db/SeqLMPairOf2.txt\n";
		foreach (@secLMPairArrayOf2) {
			print FILE2 $_."\n";
		}
		print FILE2 "Count:". ($#secLMPairArrayOf2+1);
	close(FILE2);

}



sub createSequenceComplementPairFile{
	#my $infile = "./db/compool.txt";
	my $infile =  shift;
	my @arrayOfAllSeqIDs=readFileLinebyLineInArray($infile);
	#print  ("\narrayOfAllSeqIDs:@arrayOfAllSeqIDs");
	my @secCompPairArray;
	my $secCompPairString;
	
	my @secCompPairArrayOf2;
	my $secCompPairStringOf2;
	 
	for (my $i=0; $i <=$#arrayOfAllSeqIDs; $i++)
	{
		my $seq="./db/sequences/$arrayOfAllSeqIDs[$i].txt";
		print("\nseq:$seq ___________________________________");
		
		 my @seqFirstElem = Parser::parseSequence($seq, \&Parser::getFirstElements);
		 my $maxElem=max @seqFirstElem;
		if($maxElem<10000000)
		{
		#print "\nIF>>   \nmaxElem:$maxElem\n";

			my @seqComp=computeComplement($seq);
			print "\nLen of Comp: $#seqComp\n";
			#print "S1 Comp:@seqComp\n\n";
			my @arrayOfPossibleSeq=findComplementSeqIDfromHashMap1(\@seqComp);
			
			if (@arrayOfPossibleSeq)
			{			
				for (my $j=0; $j <=$#arrayOfPossibleSeq; $j++)
				{
					$secCompPairStringOf2="$arrayOfAllSeqIDs[$i],$arrayOfPossibleSeq[$j]";
					push @secCompPairArrayOf2,$secCompPairStringOf2;
				}
			}		
			if (!@arrayOfPossibleSeq)
			{
				@arrayOfPossibleSeq=("NA");
			}
			$secCompPairString="$arrayOfAllSeqIDs[$i] -> @arrayOfPossibleSeq\n";		
			push @secCompPairArray,$secCompPairString;
		}		
		else
		{
			print "\nMax Elelment Limit Exceed for $arrayOfAllSeqIDs[$i]\n";
		}
	}
	

	#print @secCompPairArray;

	# #One by one
	# my @seqComp=Util::computeComplement("./db/sequences/A005206.txt");
	# my @arrayOfPossibleSeq=&findComplementSeqIDfromHashMap(@seqComp);
	# print "\n\nSequence: A005206 Compl Seq ID:@arrayOfPossibleSeq\n\n";

	open (FILE, "> ./db/SeqCompPair.txt") or die "problem opening  ./db/SeqCompPair.txt\n";
		foreach (@secCompPairArray) {
			print FILE $_;
		}
		close(FILE);
		
	return @secCompPairArrayOf2;
}



sub computeComplement{
	my $seq = shift;
	my @seqFirstElem = Parser::parseSequence($seq, \&Parser::getFirstElements);
	
	#my @seqFirstElem=(0,1,3,6,11,20,36,64,117,209,381,699,1291,2387,4445,8317,15645,29494,55855,106021,201778,384941,735909,2705277,4000001);

	#my @seqFirstElem=(0,1,3,6);


	my $maxElem=max @seqFirstElem;
	
	#print  "\nInt:$maxElem\n";
	if($maxElem>4000000)
	{	my @seqFirstElemNew;
		#print("\nifmaxElem>4000000\n");
		
		for (my $i=0; $i <= $#seqFirstElem; $i++)
		{
			#print("\n$seqFirstElem[$i]");
			if ($seqFirstElem[$i]<4000000)
			{
				push @seqFirstElemNew,$seqFirstElem[$i];
			}
		}		
			#print "\n\n";
		# for (my $i=0; $i <= $#seqFirstElemNew; $i++)
			# {
				# print("\n$seqFirstElemNew[$i]");
			# }
		#print "\n\n";
		$maxElem=max @seqFirstElemNew;
		@seqFirstElem=@seqFirstElemNew;
	}


	#create Integer array of  len of Seq
	my @intArray;
	for (my $i=1; $i <= $maxElem; $i++)
	{
		push @intArray,$i;
	}	
	#complement
	#print "Len: $#seqFirstElem";
	#print "\nS1:@seqFirstElem\n";
	#print "\nLen: $#intArray";
	#print  "\nInt:@intArray\n";
				
	my @list1 = @intArray;
	my @list2 = @seqFirstElem;

	my @diff;
	my %repeats;
	for (@list1, @list2) { $repeats{$_}++ }
	for (keys %repeats) {
	    push @diff, $_ unless $repeats{$_} > 1;
	}
	my @seqFirstElemComp=@diff;

	my @seqFirstElemCompSort = sort {$a <=> $b} @seqFirstElemComp;
	print "\nLen of Comp: $#seqFirstElemCompSort\n";
	#print "\nS1 Comp:@seqFirstElemCompSort\n\n";
	
	

#Part of shortening the length of computed complement comented, now its returning whole array computed
		# my $compRetLen=0;
		# if($#seqFirstElemCompSort <= $#seqFirstElem)
		# {
			# $compRetLen=$#seqFirstElemCompSort;
		# }
		# else
		# {
			# $compRetLen=$#seqFirstElem;
		# }
		
	# my @compRet;
	# for (my $i=0; $i <= $compRetLen; $i++)
	# {
	# push @compRet,$seqFirstElemCompSort[$i];
	# }
	# #print "\nLen of Comp: $#compRet\n";
	# #print "S1 Comp:@compRet\n\n";

	# return @compRet;


	return @seqFirstElemCompSort;
}


# given the computed theoretic complement, this function returns the array containing the ids of possible sequences
sub findComplementSeqIDfromHashMap2{
        my ($array_ref1, $hash_ref) = @_;
	my @seqThComp = @{$array_ref1};
	my %seqHasMap = %{$hash_ref};
	my $seqThCompSize=$#seqThComp;	
	my @arrayOfPossibleSeqToReturn=();	
	my $arrayOfPossibleSeqToReturnString;
	
		
	foreach my $group (keys %seqHasMap) 
	{		
		#my $ret="Nomatch";
		my $ret="NM";

		my @seqFindComp = @{$seqHasMap{$group}};
		# my @seqFindComp =(2, 5, 7, 10, 13, 15, 18, 20, 23, 26, 28);
	
		my $seqFindCompSize= $#seqFindComp;
		my $minLen;
		my $maxLen;
		my $measure=0;
		if ($seqFindCompSize <= $seqThCompSize) {
			$minLen = $seqFindCompSize;
			$maxLen = $seqThCompSize;
		} else{
			$minLen = $seqThCompSize;
			$maxLen = $seqFindCompSize;
		}
		
		
		my @seqThCompResize=@seqThComp;
		my @seqFindCompResize=@seqFindComp ;
		
		
		#print "Group:$group \n";
		if ($seqThComp[0] == 0 and $seqFindComp[0] != 0) {
			if ($seqFindCompSize <= $seqThCompSize) {
				$minLen = $seqFindCompSize;
				splice(@seqThCompResize, $minLen+2);
				my $seqThCompResize_str = join(",", @seqThCompResize);
				my $seqFindCompResize_str = join(",", @seqFindCompResize);
				if ("0,$seqFindCompResize_str" eq $seqThCompResize_str) {
					#$ret = "Ignoring 0 of TH";
					$ret = "0T";
					$measure=($minLen+1)/($maxLen+1);
					$arrayOfPossibleSeqToReturnString="$group | $seqThCompSize | $seqFindCompSize | $ret | $measure";
					push @arrayOfPossibleSeqToReturn, $arrayOfPossibleSeqToReturnString;
					#print("\nseqThCompResize_str:$seqThCompResize_str \nseqFindCompResize_str:$seqFindCompResize_str\n");

				}

			} else{
				$minLen = $seqThCompSize;
				splice(@seqFindCompResize, $minLen);
				my $seqThCompResize_str = join(",", @seqThCompResize);
				my $seqFindCompResize_str = join(",", @seqFindCompResize);
				if ("0,$seqFindCompResize_str" eq $seqThCompResize_str) {
					#$ret = "Ignoring 0 of TH";
					$ret = "0T";
					$measure=($minLen+1)/($maxLen+1);
					$arrayOfPossibleSeqToReturnString="$group | $seqThCompSize | $seqFindCompSize | $ret | $measure";
					push @arrayOfPossibleSeqToReturn, $arrayOfPossibleSeqToReturnString;
					#print("\nseqThCompResize_str:$seqThCompResize_str \nseqFindCompResize_str:$seqFindCompResize_str\n");

				}

			}
			
		} elsif ($seqThComp[0] != 0 and $seqFindComp[0] == 0) {
			if ($seqFindCompSize <= $seqThCompSize) {
				$minLen = $seqFindCompSize;
				splice(@seqThCompResize, $minLen);
				my $seqThCompResize_str = join(",", @seqThCompResize);
				my $seqFindCompResize_str = join(",", @seqFindCompResize);
				if ("0,$seqThCompResize_str" eq $seqFindCompResize_str) {
					#$ret = "Ignoring 0 of Find";
					$ret = "0F";
					$measure=($minLen+1)/($maxLen+1);
					$arrayOfPossibleSeqToReturnString="$group | $seqThCompSize | $seqFindCompSize | $ret | $measure";
					push @arrayOfPossibleSeqToReturn, $arrayOfPossibleSeqToReturnString;
					#print("\nseqThCompResize_str:$seqThCompResize_str \nseqFindCompResize_str:$seqFindCompResize_str\n");

				}

			} else{
				$minLen = $seqThCompSize;
				splice(@seqFindCompResize, $minLen+2);
				my $seqThCompResize_str = join(",", @seqThCompResize);
				my $seqFindCompResize_str = join(",", @seqFindCompResize);
				if ("0,$seqThCompResize_str" eq $seqFindCompResize_str) {
					#$ret = "Ignoring 0 of Find";
					$ret = "0F";
	
					$measure=($minLen+1)/($maxLen+1);
					$arrayOfPossibleSeqToReturnString="$group | $seqThCompSize | $seqFindCompSize | $ret | $measure";
					push @arrayOfPossibleSeqToReturn, $arrayOfPossibleSeqToReturnString;
					#print("\nseqThCompResize_str:$seqThCompResize_str \nseqFindCompResize_str:$seqFindCompResize_str\n");

				}

			}
	
		} else {

			splice(@seqThCompResize,$minLen+1);
			splice(@seqFindCompResize,$minLen+1);
			my $seqThCompResize_str = join(",", @seqThCompResize);
			my $seqFindCompResize_str = join(",", @seqFindCompResize);
			
			if ($seqThCompResize_str eq $seqFindCompResize_str) {
				#$ret = "Perfect match";
				$ret = "PM";
					$measure=($minLen+1)/($maxLen+1);
					$arrayOfPossibleSeqToReturnString="$group | $seqThCompSize | $seqFindCompSize | $ret | $measure";
					push @arrayOfPossibleSeqToReturn, $arrayOfPossibleSeqToReturnString;
					#print("\nseqThCompResize_str:$seqThCompResize_str \nseqFindCompResize_str:$seqFindCompResize_str\n");

			}
		}
		#print $measure."\n";
		# print "-----------------------";
		# print $ret."\n";
		# print "@seqThCompResize\n";
		# print "@seqFindCompResize\n";
		
		   
	}
	return @arrayOfPossibleSeqToReturn;
}


# given the computed theoretic complement, this function returns the array containing the ids of possible sequences
sub findComplementSeqIDfromHashMap1{
        my ($array_ref1) = @_;
	my @seqThComp = @{$array_ref1};

	my $seqThCompSize=$#seqThComp;
	my %seqHasMap=Util::createFirstEmlemtDataStr("./db/compool.txt");   #"./db/all.txt"
	##################my @seqFindComp;
	my $seqFindCompSize;
	my @seqThCompResize;
	my @seqFindCompResize=();
	my @arrayOfPossibleSeqToReturn=();

	# # # Access elements		
	# print"1st\n";	
	# print $seqHasMap{A001950}[0];	#acces the reference
	# print"\n2nd\n";	
	# my $array_reference=$seqHasMap{A000201};
	# print $array_reference;
	# my @array=@$array_reference;
	# print"\n";	
	# print @array;
	
	foreach my $group (keys %seqHasMap) 
	{
		my @seqFindComp;
	    #print "\n\nThe members of $group are\n";
	    foreach (@{$seqHasMap{$group}}) 
	    {
		@seqFindComp=@{$seqHasMap{$group}};
		#print "\t$_\n";
	    }
	    #print @seqFindComp;
		if($#seqFindComp<=$seqThCompSize)
		{
			#print("IF :\nseqFindComp: $#seqFindComp<=seqThCompSize: $seqThCompSize");
			@seqThCompResize=();
			for (my $i=0; $i <=$#seqFindComp; $i++)
				{
					push @seqThCompResize,$seqThComp[$i];
				}	
				#@seqFindCompResize=();
				@seqFindCompResize=@seqFindComp;
		}
		else{
			#print("Else: \nseqFindComp: $#seqFindComp <= seqThCompSize: $seqThCompSize");       	
			@seqFindCompResize=();
			#print("\n\nOutside Loop seqFindCompResize: @seqFindCompResize  end\n");

			for (my $i=0; $i <=$seqThCompSize; $i++)
				{
					push @seqFindCompResize,$seqFindComp[$i];
				}	
					#print("\n\nWithin Loop: seqFindComp: @seqFindComp    END");

					#print("\n\nWithin Loop: seqFindCompResize: @seqFindCompResize  END");
				#@seqThCompResize=();
				@seqThCompResize=@seqThComp;
		}
		#print("\noutside loop");
	       
		#print("\n\nseqThComp: @seqThComp");
		#print("\n\nseqThCompResize: @seqThCompResize");
		#print("\n\nseqFindComp: @seqFindComp");
		#print("\n\nseqFindCompResize: @seqFindCompResize");
		
	       my $count=0; 
			if (@seqThCompResize ~~ @seqFindCompResize && $#seqFindCompResize>=7 )
				{
					#print "\n\n$group: Regular Match  ";
					push @arrayOfPossibleSeqToReturn,$group;
				}
			else
			{
				if($seqFindCompResize[0]==0)
				{
					for (my $iTh=0; $iTh <=$#seqThCompResize-1; $iTh++)
					{
						for (my $iFi=1; $iFi <=$#seqThCompResize; $iFi++)
						{
							my $diffInIndex=$iFi-$iTh;
							if ($seqThCompResize[$iTh]==$seqFindCompResize[$iFi] and $diffInIndex==1)
							{
								#print("\n $seqThCompResize[$iTh] == $seqFindCompResize[$iFi]");
								$count++;
								}
						}
					}
					#print ("\ncount: $count   seqThCompResize:$#seqThCompResize");	
					
					if($count==$#seqThCompResize && $count>=7)
					{
						#print "\n\n$group:Match by ignorning the zero of Comapred Complement ";
						push @arrayOfPossibleSeqToReturn,$group;
					}     
				}
				elsif($seqThCompResize[0]==0){
					# print("else ___________________________");
					# print("\nseqThCompResize:@seqThCompResize");
					# print("\nseqFindCompResize:@seqFindCompResize");
					
					
					for (my $iFi=0; $iFi <=$#seqThCompResize-1; $iFi++)
						
					{
						for (my $iTh=1; $iTh <=$#seqThCompResize; $iTh++)
						{
							my $diffInIndex=$iTh-$iFi;
							#print("\n $seqThCompResize[$iTh] == $seqFindCompResize[$iFi]");
							if ($seqThCompResize[$iTh]==$seqFindCompResize[$iFi] and $diffInIndex==1)
							{
								#print("\n $seqThCompResize[$iTh] == $seqFindCompResize[$iFi]");
								$count++;
							}
						}
					}
#					print ("\ncount: $count   seqThCompResize:$#seqThCompResize");	
					
					if($count==$#seqFindCompResize && $count>=7)
					{
						#print "\n\n$group:Match by ignorning the zero of Theoretic Complement ";
						push @arrayOfPossibleSeqToReturn,$group;
					}
				}
						
				else{
					#print "\n$group: NO Match";
				     }
			}

		   
	}
	return @arrayOfPossibleSeqToReturn;
}




#my $infile = "./db/compool.txt";
#ComputeLambekMoserInverse($infile);

#by complement method
sub ComputeLambekMoserInverse{
	my $infile =  shift;
	my @secCompPairArrayOf2;
	@secCompPairArrayOf2=createSequenceComplementPairFile($infile);

	#print @secCompPairArrayOf2;

	#print("\n\n");
	my $leftCompl; #IDs
	my $rightCompl;

	my @leftComplSeq; #Sequence arrays
	my @rightComplSeq;

	my @leftComplSeqLamberk; #Sequence arrays Lamberk
	my @rightComplSeqLamberk;
	my @arrayOfPossibleSeqLeftLam;
	my @arrayOfPossibleSeqRightLam;

	my @lanberkMoserPairsArray;
	my @lanberkMoserPairsString;
	my $seqPath;
	my @LMPairIDArray;
	my $LMPairIDString;



	my @LMPairIDArrayOnly;
	my $LMPairIDStringOnly;
	my @CPairIDArrayOnly;
	my $CPairIDStringOnly;



	open (FILE, "> ./db/LamebrkPairs.txt") or die "problem opening  ./db/LamebrkPairs.txt\n";
		

	for (my $i=0; $i <= $#secCompPairArrayOf2; $i++)
	{
		#print("$secCompPairArrayOf2[$i]\n");
		my @values = split(',', $secCompPairArrayOf2[$i]);
		$leftCompl=$values[0];
		$rightCompl=$values[1];
		
		print("\nLeft COmp:$leftCompl, Right Comp: $rightCompl");
		print FILE "\nLeft COmp:$leftCompl, Right Comp: $rightCompl";


		$seqPath="./db/sequences/$leftCompl.txt";
		@leftComplSeq = Parser::parseSequence($seqPath, \&Parser::getFirstElements);

		$seqPath="./db/sequences/$rightCompl.txt";
		@rightComplSeq = Parser::parseSequence($seqPath, \&Parser::getFirstElements);

		#print("\nleftComplSeq:@leftComplSeq");
		print FILE "\nleftComplSeq:@leftComplSeq";
		#print("\nrightComplSeq:@rightComplSeq \n");
		print FILE "\nrightComplSeq:@rightComplSeq \n";
			
		@leftComplSeqLamberk=Util::computeParalellLambekSeq(@leftComplSeq);	
		@rightComplSeqLamberk=Util::computeParalellLambekSeq(@rightComplSeq);	

		print("\nleftComplSeq Lamberk:@leftComplSeqLamberk");
		print FILE "\nleftComplSeq Lamberk:@leftComplSeqLamberk";
		print("\nrightComplSeq Lamberk:@rightComplSeqLamberk \n");
		print FILE "\nrightComplSeq Lamberk:@rightComplSeqLamberk \n";
		
		@arrayOfPossibleSeqLeftLam=findComplementSeqIDfromHashMap1(\@leftComplSeqLamberk);
		
		if (!@arrayOfPossibleSeqLeftLam)
		{
			@arrayOfPossibleSeqLeftLam=("NA");
		}
		
		print ("\narrayOfPossibleSeqLeftLam: @arrayOfPossibleSeqLeftLam\n");
		print FILE "\narrayOfPossibleSeqLeftLam: @arrayOfPossibleSeqLeftLam\n";
		@arrayOfPossibleSeqRightLam=findComplementSeqIDfromHashMap1(\@rightComplSeqLamberk);
		if (!@arrayOfPossibleSeqRightLam)
		{
			@arrayOfPossibleSeqRightLam=("NA");
		}

		print ("\narrayOfPossibleSeqRightLam: @arrayOfPossibleSeqRightLam\n");
		print FILE "\narrayOfPossibleSeqRightLam: @arrayOfPossibleSeqRightLam\n";
		
		print FILE "__________________________________________________________________________________";
		
		$LMPairIDString="LC:$leftCompl RC:$rightCompl LLM:@arrayOfPossibleSeqLeftLam RLM: @arrayOfPossibleSeqRightLam\n\n";
		push @LMPairIDArray, $LMPairIDString;
		
		
		$CPairIDStringOnly="$leftCompl $rightCompl\n";
		push @CPairIDArrayOnly,$CPairIDStringOnly;
		$LMPairIDStringOnly="LLM:@arrayOfPossibleSeqLeftLam RLM: @arrayOfPossibleSeqRightLam\n";
		push @LMPairIDArrayOnly,$LMPairIDStringOnly;
		
	}
	
	
		close(FILE);
		
		
		open (OUT, "> ./db/LamebrkPairsID.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@LMPairIDArray) {
			print OUT $_;
		}
		close(OUT);
		
		
		open (OUT1, "> ./db/CPairIDArrayOnly.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@CPairIDArrayOnly) {
			print OUT1 $_;
		}
		close(OUT1);
		
		open (OUT2, "> ./db/LMPairIDArrayOnly.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@LMPairIDArrayOnly) {
			print OUT2 $_;
		}
		close(OUT2);
}




1;