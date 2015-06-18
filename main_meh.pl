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
my $infile = "./db/compool.txt";
ComputeLambekMoserInverse($infile);
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

	my $seqPath;
	for (my $i=0; $i <= $#secCompPairArrayOf2; $i++)
	{
		#print("$secCompPairArrayOf2[$i]\n");
		my @values = split(',', $secCompPairArrayOf2[$i]);
		$leftCompl=$values[0];
		$rightCompl=$values[1];
		
		print("\n$leftCompl,$rightCompl");		$seqPath="./db/sequences/$leftCompl.txt";
		@leftComplSeq = Parser::parseSequence($seqPath, \&Parser::getFirstElements);

		$seqPath="./db/sequences/$rightCompl.txt";
		@rightComplSeq = Parser::parseSequence($seqPath, \&Parser::getFirstElements);

		print("\nleftComplSeq:@leftComplSeq");		print("\nrightComplSeq:@rightComplSeq \n");
			
		@leftComplSeqLamberk=computeParalellLambekSeq(@leftComplSeq);			@rightComplSeqLamberk=computeParalellLambekSeq(@rightComplSeq);	

		print("\nleftComplSeq Lamberk:@leftComplSeqLamberk");
		print("\nrightComplSeq Lamberk:@rightComplSeqLamberk \n");
		
		@arrayOfPossibleSeqLeftLam=&findComplementSeqIDfromHashMap(@leftComplSeqLamberk);
		print ("\narrayOfPossibleSeqLeftLam: @arrayOfPossibleSeqLeftLam\n");		@arrayOfPossibleSeqRightLam=&findComplementSeqIDfromHashMap(@rightComplSeqLamberk);
		print ("\narrayOfPossibleSeqRightLam: @arrayOfPossibleSeqRightLam\n");
	}
}
# my @seqComp=(1,3,4,6,8,9,11);
# my @seqPar;
# print @seqComp;
# print "\n";# @seqPar=&computeParalellLambekSeq(@seqComp);
# print "\n";# print @seqPar;
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
		#print("\nseq:$seq ___________________________________");
		my @seqComp=Util::computeComplement($seq);
		#print "\nLen of Comp: $#seqComp\n";
		#print "S1 Comp:@seqComp\n\n";
		my @arrayOfPossibleSeq=&findComplementSeqIDfromHashMap(@seqComp);
		
		if (@arrayOfPossibleSeq)
		{			
			for (my $j=0; $j <=$#arrayOfPossibleSeq; $j++)
			{
				$secCompPairStringOf2="$arrayOfAllSeqIDs[$i],$arrayOfPossibleSeq[$j]";
				push @secCompPairArrayOf2,$secCompPairStringOf2;
			}
		}				if (!@arrayOfPossibleSeq)
		{
			@arrayOfPossibleSeq=("NA");
		}
		$secCompPairString="$arrayOfAllSeqIDs[$i] -> @arrayOfPossibleSeq\n";		
		push @secCompPairArray,$secCompPairString;
		
	}

	#print @secCompPairArray;

	# #One by one
	# my @seqComp=Util::computeComplement("./db/sequences/A005206.txt");
	# my @arrayOfPossibleSeq=&findComplementSeqIDfromHashMap(@seqComp);
	# print "\n\nSequence: A005206 Compl Seq ID:@arrayOfPossibleSeq\n\n";

	open (FILE, "> ./db/SeqCompPair.txt") or die "problem opening ./db/core.txt\n";
		foreach (@secCompPairArray) {
			print FILE $_;
		}
		close(FILE);
		
	return @secCompPairArrayOf2;
}


#


#my %seqHasMap=Util::createFirstEmlemtDataStr("./db/compool.txt");   #"./db/all.txt"

# given the computed theoretic complement, this function returns the array containing the ids of possible sequences
sub findComplementSeqIDfromHashMap{
	my (@seqThComp)=@_;
	my $seqThCompSize=$#seqThComp;
	my %seqHasMap=Util::createFirstEmlemtDataStr("./db/compool.txt");   #"./db/all.txt"
	my @seqFindComp;
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
	    #print "\n\nThe members of $group are\n";
	    foreach (@{$seqHasMap{$group}}) 
	    {
		@seqFindComp=@{$seqHasMap{$group}};
		#print "\t$_\n";
	    }
		if($#seqFindComp<=$seqThCompSize)
		{
			#print("IF :\nseqFindComp: $#seqFindComp<=seqThCompSize: $seqThCompSize");
			@seqThCompResize=();
			for (my $i=0; $i <=$#seqFindComp; $i++)
				{
					push @seqThCompResize,$seqThComp[$i];
				}	
				@seqFindCompResize=();
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
				@seqThCompResize=();
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
							if ($seqThCompResize[$iTh]==$seqFindCompResize[$iFi])
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
					
					for (my $iFi=0; $iFi <=$#seqThCompResize-1; $iFi++)
						
					{
						for (my $iTh=1; $iTh <=$#seqThCompResize; $iTh++)
						{
							if ($seqThCompResize[$iTh]==$seqFindCompResize[$iFi])
							{
								#print("\n $seqThCompResize[$iTh] == $seqFindCompResize[$iFi]");
								$count++;
								}
						}
					}
					#print ("\ncount: $count   seqThCompResize:$#seqThCompResize");	
					
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


