#!/usr/bin/env perl

use lib './lib';
use Parser;
use Util;
use Scripts;
use strict;
use warnings;
use List::Util qw( min max );
#use Array::Utils qw(:all);
use 5.010;




#Subroutine to find IDs of all core sequences and write them to file named core.txt
#Util::createCoreSeqFile();

#Subroutine to find all Non negative sequences and write them to file named NonNegSequences.txt
#Scripts::findNonNegativeSequences(); 




#my $minLenOfInitialElem=Util::findMinLenOfInitialElem("./db/compool.txt");   #"./db/all.txt"
#print("Min len of Initial elements among the list of sequences provided: $minLenOfInitialElem\n");



#Util::createFirstEmlemtFile("./db/compool.txt");   #"./db/all.txt"



#MAIN




#MAIN
# my @requestSeq=(1,1,2,2,2,2);
# #my @requestSeq=(0,2,6,12,20,30);
# my @LamberkMoserTh=ComputeLambekMoserInverseDirect(\@requestSeq);
# print "\n @requestSeq \n @LamberkMoserTh\n";






	# my $infile = "./db/compool.txt";
	# my @arrayOfAllSeqIDs=readFileLinebyLineInArray($infile);
	
	# my @secLMPairArray;
	# my $secLMPairString;
	
	# my @secLMPairArrayOf2;
	# my $secLMPairStringOf2;
	 
	
	
	# for (my $i=0; $i <=$#arrayOfAllSeqIDs; $i++)
	# {
		# my $seq="./db/sequences/$arrayOfAllSeqIDs[$i].txt";
		# print("\nseq:$seq ___________________________________");
		
		 # my @seqFirstElem = Parser::parseSequence($seq, \&Parser::getFirstElements);
			# print "\nLen of Seq: $#seqFirstElem\n";
			# print "S1 Seq: @seqFirstElem\n\n";

			
			# my @seqLM=ComputeLambekMoserInverseDirect(\@seqFirstElem);
			# print "\nLen of Seq seqLM: $#seqLM\n";
			# print "S1 Seq LM: @seqLM\n\n";

	# }



#SeqLMPairOf2ALL.txt
my $fileName="./db/LM/SeqLMPairOf2ALL.txt";
findLambekMoserComplementSquare($fileName);

sub findLambekMoserComplementSquare{
	
	my $infile =  shift;
	#my $infile = "./db/LM/SeqLMPairOf2ALLTemp.txt";	
	my @arrayOfAllSeqIDs=readFileLinebyLineInArray($infile);
	my @seqLMCompPairArray;
	my @seqLMCompPairArrayLong;
	
	my $seqPool = "./db/compool1.txt";
	my %seqHasMap1=Util::createFirstEmlemtDataStr($seqPool);   #"./db/all.txt"

	
	 for (my $i=0; $i <=$#arrayOfAllSeqIDs; $i++)
	 {
		print("\n__________________________________________________________________\n");
	 	my $seqIDsString=$arrayOfAllSeqIDs[$i];
		#print("$seqIDsString\n");

		my @first = split(/\s\|\s/, $seqIDsString);
		#print("@first\n\n");
		my $LhsLM = $first[0];
		my $RhsLM = $first[2];
		my $matchReasonLM = $first[5];
		my $measureLM = $first[6];

		#print("$LhsLM $RhsLM $measureLM\n\n");
		
		
		my $seqLhsLM="./db/sequences/$LhsLM.txt";
		my $seqRhsLM="./db/sequences/$RhsLM.txt";
		
		my @seqFirstElemLhsLM = Parser::parseSequence($seqLhsLM, \&Parser::getFirstElements);
		my @seqFirstElemRhsLM = Parser::parseSequence($seqRhsLM, \&Parser::getFirstElements);

		#print "\nLM\n\n";
		#print "\n@seqFirstElemLhsLM\n@seqFirstElemRhsLM\n\n";
		
		my @seqFirstElemLhsThComp=computeParalellComplementSeq(\@seqFirstElemLhsLM);
		my @seqFirstElemRhsThComp=computeParalellComplementSeq(\@seqFirstElemRhsLM);
		
		#print "\nTH COmp\n\n";
		#print "\n@seqFirstElemLhsThComp\n@seqFirstElemRhsThComp\n\n";
		print "\nLHS TH Comp:@seqFirstElemLhsThComp\n\n";

		# find measure btween TH complements

		my $measureThComp=findComplementDirectlyWithMeasure(\@seqFirstElemLhsThComp,\@seqFirstElemRhsThComp);	
		#print("\nCand:@seqFirstElemCand\nFind:@seqFirstElemFind\n");		
					
					
		my $seqLMCompPairString="$LhsLM | $RhsLM | $matchReasonLM | $measureLM | $measureThComp";
		print("\n$seqLMCompPairString  _____Count:$i\n");			
		push @seqLMCompPairArray,$seqLMCompPairString;

		my @arrayOfPossibleSeqLHSComp=findComplementSeqIDfromHashMap2(\@seqFirstElemLhsThComp, \%seqHasMap1);
		if(@arrayOfPossibleSeqLHSComp)
		{
			for (my $i=0; $i <= $#arrayOfPossibleSeqLHSComp; $i++)
			{
				print("LHS******\n$arrayOfPossibleSeqLHSComp[$i]\n");
				my @lhsList = split(/\s\|\s/, $arrayOfPossibleSeqLHSComp[$i]);
				print("@lhsList\n\n");
				my $LhsCompID = $lhsList[0];
				my $LhsCompIDConf = $lhsList[4];
				my $lhsCompMatchString="$seqLMCompPairString | LhsMatch $LhsCompID | $LhsCompIDConf";
				print("\n$lhsCompMatchString\n");	
				push @seqLMCompPairArrayLong,$lhsCompMatchString;

			}
		}
		else{
				print("RHS******\nNo Match\n");			
		}

		my @arrayOfPossibleSeqRHSComp=findComplementSeqIDfromHashMap2(\@seqFirstElemRhsThComp, \%seqHasMap1);
		if(@arrayOfPossibleSeqRHSComp)
		{
			for (my $i=0; $i <= $#arrayOfPossibleSeqRHSComp; $i++)
			{
				print("RHS******\n$arrayOfPossibleSeqRHSComp[$i]\n");
				my @rhsList = split(/\s\|\s/, $arrayOfPossibleSeqRHSComp[$i]);
				print("@rhsList\n\n");
				my $RhsCompID = $rhsList[0];
				my $RhsCompIDConf = $rhsList[4];
				my $rhsCompMatchString="$seqLMCompPairString | RhsMatch $RhsCompID | $RhsCompIDConf";
				print("\n$rhsCompMatchString\n");			
				push @seqLMCompPairArrayLong,$rhsCompMatchString;

			}
		}
		else{
				print("RHS******\nNo Match\n");			
		}




	 }	
	open (FILE, "> ./db/LM/Seq_LM_THComp_Measures.txt") or die "problem opening  ./db/LM/Seq_LM_THComp_Measures.txt\n";
		foreach ( @seqLMCompPairArray) {
			print FILE $_."\n";
		}

	close(FILE);
	 	
	open (FILE1, "> ./db/LM/Seq_LM_THComp_MeasuresLong.txt") or die "problem opening  ./db/LM/Seq_LM_THComp_MeasuresLong.txt\n";
		foreach ( @seqLMCompPairArrayLong) {
			print FILE1 $_."\n";
		}

	close(FILE1);



}




# my @seqComp=(1,3,4,6,8,9,11);
# my @seqPar;
# print @seqComp;
# print "\n";
# @seqPar=computeParalellComplementSeq(\@seqComp);
# print "\n";
# print @seqPar;
# print "\n";

##compute F(n)+n and G(n)+n of LM
sub computeParalellComplementSeq{		
	
	my ($array_ref1) = @_;
	my @seq = @{$array_ref1};
	my @seqPara;
	
my $j;
my $new;
	for (my $i=0; $i < $#seq+1; $i++)
		{
			$j=$i+1;
			$new=$seq[$i]+$j;
			#print("\nj: $j  Value: $seq[$i] New:$new ");
			push @seqPara,$new;
		}
	return @seqPara;
}



#redundantPairsRemoval();
sub redundantPairsRemoval{
#SeqLMPairOf2Measure.txt
	my $infile = "./db/LM/SeqLMPairOf2MeasureTemp.txt";

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



#findComplementDirectlyWithMeasureOverDB();
	
sub findComplementDirectlyWithMeasureOverDB
{
	# my @seq1=(1,2,3,5,7,8,11,90);
	# my @seq2=(4,6,9,9,10);
	# my $isComplementary=findComplementDirectlyWithMeasure(\@seq1,\@seq2);
	#print ("\nisComplementary : $isComplementary\n");
	
	my $infile = "./db/compool1.txt";
	#my $infile =  shift;
	my @arrayOfAllSeqIDsCandidates=readFileLinebyLineInArray($infile);
	my @arrayOfAllSeqIDsFinder=@arrayOfAllSeqIDsCandidates;
	#print  ("\narrayOfAllSeqIDs:@arrayOfAllSeqIDs");
	my @compPairArray;
	my $compPairString;
	
	for (my $i=0; $i <=$#arrayOfAllSeqIDsCandidates; $i++)
	{
		for (my $j=0; $j <=$#arrayOfAllSeqIDsFinder; $j++)
		{
			if($i<$j)
			{
				my $seqCandidate="./db/sequences/$arrayOfAllSeqIDsCandidates[$i].txt";		
				my $seqFinder="./db/sequences/$arrayOfAllSeqIDsFinder[$j].txt";		

				my @seqFirstElemCand = Parser::parseSequence($seqCandidate, \&Parser::getFirstElements);
				my @seqFirstElemFind = Parser::parseSequence($seqFinder, \&Parser::getFirstElements);
				my $measure1=findComplementDirectlyWithMeasure(\@seqFirstElemCand,\@seqFirstElemFind);
				if($measure1>0)
				{
					my $numOfExhaustedInt = ($seqFirstElemCand[$#seqFirstElemCand], $seqFirstElemFind[$#seqFirstElemFind])[$seqFirstElemCand[$#seqFirstElemCand] > $seqFirstElemFind[$#seqFirstElemFind]];
					#print("\n______________________________\n");
					#print("\nCand:@seqFirstElemCand\nFind:@seqFirstElemFind\n");				
					print ("$arrayOfAllSeqIDsCandidates[$i] | $arrayOfAllSeqIDsFinder[$j] | $measure1 | $numOfExhaustedInt\n");
					$compPairString="$arrayOfAllSeqIDsCandidates[$i] | $arrayOfAllSeqIDsFinder[$j] | $measure1 | $numOfExhaustedInt";
					push @compPairArray,$compPairString;

				}
			}		
		}		
	}
	open (FILE, "> ./db/LM/SeqComplementPairWithMeasure.txt") or die "problem opening  ./db/LM/SeqComplementPairWithMeasure.txt\n";
		foreach ( @compPairArray) {
			print FILE $_."\n";
		}
	print FILE "Count:". ($#compPairArray+1);
	close(FILE);
	
}

# my $return=findComplementDirectlyWithMeasure();
# print $return;
sub findComplementDirectlyWithMeasure
{
	my ($array_ref1, $array_ref2) = @_;
	my @seq1 = @{$array_ref1};
	my @seq2 = @{$array_ref2};
	# my @seq1=(0,2,3,5,7,8,11,90);
	# my @seq2=(4,6,9,9,10);
	# my @seq1=(1,1,1,1,1,1,1,1);
	# my @seq2=(4,6,9,10);

# my @seq1=(1,3,4,6,8,9,11,12,14,16,17,19,21,22,24,25,27,29,30,32,33,35,37,38,40,42,43,45,46,48,50,51,53,55,56,58,59,61,63,64,66,67,69,71,72,74,76,77,79,80,82,84,85,87,88,90,92,93,95,97,98,100,101,103,105,106,108,110);
# my @seq2=(1,3,7,12,18,26,35,45,56,69,83,98,114,131,150,170,191,213,236,260,285,312,340,369,399,430,462,495,529,565,602,640,679,719,760,802,845,889,935,982,1030,1079,1129,1180,1232,1285,1339,1394,1451,1509,1568,1628,1689);
	my @seq1New;
	my @seq2New;
	my @setUnion;
	
	my $returnFlag=0; 
	my $measure1=0;
	my $min = ($seq1[$#seq1], $seq2[$#seq2])[$seq1[$#seq1] > $seq2[$#seq2]];

	if($min==$seq2[$#seq2])  #cut seq1
	{       #print("\nIF\n");
		foreach(@seq1)
		{
			if($_ <= $min+1)
			{
				push @seq1New,$_;
			}
		}	
		@seq2New=@seq2;	
	}
	elsif($min==$seq1[$#seq1]) # cut seq2
	{	#print("\nElsIF\n");
		foreach(@seq2)
		{
			if($_ <= $min+1)
			{
				push @seq2New,$_;
			}
		}
		@seq1New=@seq1;		
	}
	else
	{	#print("\nElse\n");
		@seq1New=@seq1;
		@seq2New=@seq2;
	}
		
	@seq1New=Util::unique(\@seq1New);
	@seq2New=Util::unique(\@seq2New);

	# print("Cut point: $min \n");
	# print("\nSeq1 Old: @seq1 \n");
	# print("Seq2 Old: @seq2 \n");
	# print("\nSeq1 New: @seq1New \n");
	# print("Seq2 New: @seq2New \n");


	@setUnion=computeSetUnion(\@seq1New,\@seq2New);
	#@setUnion=(@seq1New,@seq2New);
	
	@setUnion = sort { $a <=> $b } @setUnion;

	#print "\nSize:$#setUnion\n" ;
	#print "$_ " foreach (@setUnion);

	if($setUnion[0]==0 or $setUnion[0]==1)
	{
		#Condition 1 check_______________________________________________________________________________________________
		my $sizeOfSeq1=$#seq1New+1;
		my $sizeOfSeq2=$#seq2New+1;
		my $sizeOfUnion=$#setUnion+1;
		
		#print("\n|A|:$sizeOfSeq1 + |B|:$sizeOfSeq2 = |AuB|:$sizeOfUnion");	
		
		if($sizeOfSeq1 + $sizeOfSeq2 == $sizeOfUnion)
		{
			#print("\nCondition 1 OK\n");
			$measure1= $sizeOfUnion/($#seq1+$#seq2+2);
			#print ("\nM1: $measure1");
			#print ("\nInt: $numOfExhaustedInt\n");
			my $count=0;
			for (my $i=0; $i <=$#setUnion-1; $i++)
			{				
				if($setUnion[$i+1]-$setUnion[$i]==1)
				{
					$count=$count+1;
				}			
			}
			#print("\ncount:$count  Size=$#setUnion\n");
			if($count == $#setUnion)
			{
				#print("\nCondition 2 OK\n");
				$returnFlag=$measure1; 
			}
			else
			{
				#print("\nCondition 2 NOT OK\n");
				$returnFlag=0; 
			}
			
		}
		else{
			#print("\nCondition 1 NOT OK\n");
			$returnFlag=0; 

		}
}
	else
	{
		$returnFlag=0;
	}
	return $returnFlag;

}





sub computeSetUnion{
#https://www.safaribooksonline.com/library/view/perl-cookbook/1565922433/ch04s09.html	
        my ($array_ref1, $array_ref2) = @_;
	my @a = @{$array_ref1};
	my @b = @{$array_ref2};

	my @isect;
	my @diff;
	my %isect;
	my @union = @isect = @diff = ();
	my %union = %isect = ();
	my %count = ();

	foreach my $e (@a) { $union{$e} = 1 }

	foreach my $e (@b) {
	    if ( $union{$e} ) { $isect{$e} = 1 }
	    $union{$e} = 1;
	}
	@union = keys %union;
	@isect = keys %isect;
	# print "Union:\t$_\n" foreach (@union);
	# print "Siz:$#union" ;
	return @union;
	}


sub ComputeLambekMoserInverseDirect{	
	my ($array_ref1) = @_;
	my @requestSeq = @{$array_ref1};
	#my @requestSeq=(0,2,6,12,20,30);
	
	my @LamberkMoserTh=();
	my @intArray;
	my $count=0;
	my $maxElemReq=$requestSeq[$#requestSeq];

	for (my $i=1; $i <= $#requestSeq+1; $i++)
	{
		push @intArray,$i;
		#print "$i\n";
		$count = 0;
		for (my $j=0; $j <= $#requestSeq; $j++)
		{
				if($requestSeq[$j]<$i)
				{	#print("Inside IF\n");
					$count=$count+1;
					
				}
			
		}
		#print ("$i,$requestSeq[$i-1],$count,$maxElemReq \n");
		if($i-1<$maxElemReq)
		{ 
			my $temp=$i-1;
			#print ("$temp,$maxElemReq,COunt:$count \n");		
			push @LamberkMoserTh,$count;			
		}
	}	
		return @LamberkMoserTh;
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
		
		
			my @seqLM=ComputeLambekMoserInverseDirect(\@seqFirstElem);
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

#my $infile = "./db/compool.txt";
#ComputeLambekMoserInverse($infile);

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
			
		@leftComplSeqLamberk=computeParalellLambekSeq(@leftComplSeq);	
		@rightComplSeqLamberk=computeParalellLambekSeq(@rightComplSeq);	

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


# my @seqComp=(1,3,4,6,8,9,11);
# my @seqPar;
# print @seqComp;
# print "\n";
# @seqPar=&computeParalellLambekSeq(@seqComp);
# print "\n";
# print @seqPar;

##compute F(n)-n and G(n)-n of complements
sub computeParalellLambekSeq{			
	my @seq=@_;
	my @seqPara;
	
my $j;
my $new;
	for (my $i=0; $i < $#seq+1; $i++)
		{
			$j=$i+1;
			$new=$seq[$i]-$j;
			#print("\nj: $j  Value: $seq[$i] New:$new ");
			push @seqPara,$new;
		}
	return @seqPara;
}


# my $infile = "./db/compool1.txt";
# my @temp=createSequenceComplementPairFileMeas($infile);

sub createSequenceComplementPairFileMeas{
	#my $infile = "./db/compool.txt";
	my $infile =  shift;
	my @arrayOfAllSeqIDs=readFileLinebyLineInArray($infile);
	#print  ("\narrayOfAllSeqIDs:@arrayOfAllSeqIDs");
	my @secCompPairArray;
	
	
	my @secCompPairArrayOf2;
	my $secCompPairStringOf2;
	my %seqHasMap1=Util::createFirstEmlemtDataStr($infile);   #"./db/all.txt"
	my $count=0;
	for (my $i=0; $i <=$#arrayOfAllSeqIDs; $i++)
	{	$count=$count+1;
		my $seq="./db/sequences/$arrayOfAllSeqIDs[$i].txt";		
		my @seqFirstElem = Parser::parseSequence($seq, \&Parser::getFirstElements);
		print("\nseq:$arrayOfAllSeqIDs[$i] | Len:$#seqFirstElem ___________________Count: $count ");

		 my $maxElem=max @seqFirstElem;
		if($maxElem<10000000)
		{
		#print "\nIF>>   \nmaxElem:$maxElem\n";

			my @seqComp=computeComplement($seq);
			print "\nLen of Comp: $#seqComp\n";
			#print "S1 Comp:@seqComp\n\n";
			my @arrayOfPossibleSeq=findComplementSeqIDfromHashMap3(\@seqComp, \%seqHasMap1);
			#my @arrayOfPossibleSeq=findComplementSeqIDfromHashMap1(\@seqComp);
			#print ("mmmmmmmmmmmmmmmm: @arrayOfPossibleSeq\n");
			if (@arrayOfPossibleSeq)
			{			
				for (my $j=0; $j <=$#arrayOfPossibleSeq; $j++)
				{
					$secCompPairStringOf2="$arrayOfAllSeqIDs[$i] | $#seqFirstElem | $arrayOfPossibleSeq[$j]\n";
					push @secCompPairArrayOf2,$secCompPairStringOf2;
					print ("\n$secCompPairStringOf2\n");

					
				}
			}		
			
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

	open (FILE, "> ./db/SeqCompPair_WithMeasure.txt") or die "problem opening  ./db/SeqCompPair.txt\n";
		foreach (@secCompPairArrayOf2) {
			print FILE $_;
		}
		close(FILE);
		
	return @secCompPairArrayOf2;
}



# given the computed theoretic complement, this function returns the array containing the ids of possible sequences
sub findComplementSeqIDfromHashMap3{
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
		my @seqFirstElem = Parser::parseSequence($seq, \&Parser::getFirstElements);
		print("\nseq:$arrayOfAllSeqIDs[$i] | Len:$#seqFirstElem ___________________________________");

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
					print("\n@secCompPairArrayOf2\n");
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
	#if($maxElem>4000000)	
	if($maxElem>400)	
	     
	{	my @seqFirstElemNew;
		#print("\nifmaxElem>4000000\n");
		
		for (my $i=0; $i <= $#seqFirstElem; $i++)
		{
			#print("\n$seqFirstElem[$i]");
			#if ($seqFirstElem[$i]<4000000)
			if ($seqFirstElem[$i]<400)
			                     
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
	#print "\nLen of Comp: $#seqFirstElemCompSort\n";
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


#my %seqHasMap=Util::createFirstEmlemtDataStr("./db/compool.txt");   #"./db/all.txt"

	
#Access

	# my @array1=(0, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9);
        # my @array2=(1, 1, 2);

	# my $flag=Util::areArraysEqual(\@array1, \@array2);
	# print ("\nFlag:$flag\n");






# # # # #One by one
	 # my @seqComp=(0, 2, 5, 7, 10, 13, 15, 18, 20, 23, 26, 28);
	 # print @seqComp;
	# # # #my @seqComp=Util::computeComplement("./db/sequences/A005206.txt");	
	# my %seqHasMap1=Util::createFirstEmlemtDataStr("./db/compool.txt");   #"./db/all.txt"
	 # my @arrayOfPossibleSeq=findComplementSeqIDfromHashMap1(\@seqComp, \%seqHasMap1);
	 # print "\n\n*************************************************************************Sequence:  Compl Seq @arrayOfPossibleSeq\n\n";



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



# given the computed theoretic complement, this function returns the array containing the ids of possible sequences
sub findComplementSeqIDfromHashMap{
	my (@seqThComp)=@_;
	my $seqThCompSize=$#seqThComp;
	my %seqHasMap=Util::createFirstEmlemtDataStr("./db/hash.txt");   #"./db/all.txt"
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
	    print "\n\nThe members of $group are\n";
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
					print("else ___________________________");
					print("\nseqThCompResize:@seqThCompResize");
					print("\nseqFindCompResize:@seqFindCompResize");
					
					
					for (my $iFi=0; $iFi <=$#seqThCompResize-1; $iFi++)
						
					{
						for (my $iTh=1; $iTh <=$#seqThCompResize; $iTh++)
						{
							my $diffInIndex=$iTh-$iFi;
							#print("\n $seqThCompResize[$iTh] == $seqFindCompResize[$iFi]");
							if ($seqThCompResize[$iTh]==$seqFindCompResize[$iFi] and $diffInIndex==1)
							{
								print("\n $seqThCompResize[$iTh] == $seqFindCompResize[$iFi]");
								$count++;
							}
						}
					}
					print ("\ncount: $count   seqThCompResize:$#seqThCompResize");	
					
					if($count==$#seqFindCompResize && $count>=7)
					{
						print "\n\n$group:Match by ignorning the zero of Theoretic Complement ";
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




#findNonNegativeSequences();

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
	#Printing Arrays and its count
	
	#Util::printArray("nonNegSeq:\n@nonNegSeq ");
	#Util::printArray("NegSeq:\n@negSeq ");
	#Util::printArray("otherSeq:\n@universeSequence ");
	#print $#nonNegSeq;
	#print $#negSeq;
	#print $#universeSequence;
	&Util::writeArrayToFile("./db/Strange.txt",@universeSequence);
	return @nonNegSeq;
	
}


#Reads file line by line and puts in an array.   >>>>This is now in Util
sub readFileLinebyLineInArray()
{	
	my $infile = shift;
	my @seq;
	open(FH, $infile) or die "Cannot open $infile\n";
	while ( my $line = <FH> )
	{
		chomp($line);
		push @seq,$line;
	}
	close(FH);	
	return @seq;
}


