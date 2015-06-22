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






# my @seqComp=(1,3,4,6,8,9,11);
# my @seqPar;
# print @seqComp;
# print "\n";
# @seqPar=&computeParalellLambekSeq(@seqComp);
# print "\n";
# print @seqPar;


##my $infile = "./db/compool.txt";
#my $infile = "./db/nonn_nondecreasing1.txt";
##my @temp=createSequenceComplementPairFile($infile);



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


