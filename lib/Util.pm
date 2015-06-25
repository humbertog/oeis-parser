package Util;

use Time::Piece;
use POSIX qw(strftime);


sub printArray {
	foreach(@_){
		if(defined($_)){
			print "$_\n";
		}
	}
}

sub trim {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# Returns the SET difference between arrays: (1,2,3,4) - (2,4,5) = (1,3)
sub arrayDifference {
	my $from_ref = shift;
	my $into_ref = shift;
	my %into = map {$_ => 1} @{$into_ref};
	my @ret = grep {!$into{$_}} @{$from_ref}; 
	return @ret;
}

# Returns the unique elements in an array
sub unique {
	# args: reference to an array
	my $list_ref = shift;
	my %seen =();
	my @ret = grep { ! $seen{$_} ++ } @{$list_ref}; 
	return @ret;
}
# Returns the index to the unique elements in an array
sub getUniqueIndex {
	# args: reference to an array
	my $list_ref = shift;
	my %seen =();
	my $i = 0;
	foreach(@{$list_ref}){
		$seen{$_} = $i;
		$i++;
	}
	return %seen;
}

# Returns the index corresponding to the search of the first array in the second
sub matchIndex {
	# args: references of the arrays
	(my $array1Ref, my $array2Ref) = @_;
	my %into = ();
	my $index = 0;
	foreach(@$array2Ref) {
		$into{$_} = $index;
		$index++;
	}
	my @matched = map {$into{$_}} @{$array1Ref}; 
	return @matched;
	
}

# List directory
sub readLocalFiles {
	# args: path and regular expression on the filenames that want to be listed
	(my $path, my $regExp) = @_;
	my @files;
	opendir( my $dh, $path ) or die "can't opendir $path: $!";
	if(defined($regExp)){
		@files = grep { /$regExp/ } readdir($dh);
	}else{
		@files = readdir($dh);
	}
	closedir $dh;
	return @files;
}

# Get the name of the sequences stored in the given path
sub getLocalSequences {
	# args: path to the dir
	my $path = shift;
	my @local_files = readLocalFiles($path, "^A[0-9]{6}\.txt");
	# Remove the .txt
#	my($fecha_curva) = $_ =~ /AGROCURVAS(\w+)\.zip/;
	my @local_seq = map {$_ =~ /(A[0-9]{6}).txt/} @local_files;
	@local_seq = map {trim($_)} @local_seq;
	return @local_seq;
}

#
sub checkMonoticity {
	# args: an array ref on numbers
	my $array_ref = shift;
	my $non_decreasing_flag = 1;
	my $non_increasing_flag = 1;
	my $decreasing_flag = 1;
	my $increasing_flag = 1;
	for my $i (0 .. ($#{$array_ref} - 1)) {
		$decreasing_flag = 0 if $array_ref->[$i] <= $array_ref->[$i+1];
		$increasing_flag = 0 if $array_ref->[$i] >= $array_ref->[$i+1];
		$non_decreasing_flag = 0 if $array_ref->[$i] > $array_ref->[$i+1];
		$non_increasing_flag = 0 if $array_ref->[$i] < $array_ref->[$i+1];
	}
	my $monoticity = "no_monotonic";
	$monoticity = "increasing" if $increasing_flag and $non_decreasing_flag;
	$monoticity = "decreasing" if $decreasing_flag and $non_increasing_flag;
	
	$monoticity = "nondecreasing" if !$increasing_flag and $non_decreasing_flag;
	$monoticity = "nonincreasing" if !$decreasing_flag and $non_increasing_flag;
	
	$monoticity = "constant" if $non_decreasing_flag and $non_increasing_flag;
	
	return $monoticity;
}

##################################################################
### Time subroutines
sub getWeekDays {
	# asignamos la fecha inicial
	my $fechaIni = $_[0];
	# asignamos la fecha final
	my $fechaFin = $_[1];
	
	# covertimos las fechas inicial y final a objetos de tipo Time 
	my $t_ini = Time::Piece->strptime($fechaIni, "%Y%m%d");
	my $t_fin = Time::Piece->strptime($fechaFin, "%Y%m%d");
#	print $t_ini;
	# instaciamos una arreglo donde agregaremos todas la fechas
	my @fechas = ();
	
	# mientras fecha inicial sea menor que fecha final...
	while ($t_ini <= $t_fin) {
		# checamos que la fecha no caiga en sabado o domingo
		if ($t_ini->strftime("%a") ne "Sat" && $t_ini->strftime("%a") ne "Sun") {
			# la agregamos a nuestro arreglo de fechas en formato ddmmaaaa
			push(@fechas, $t_ini->strftime("%Y%m%d") );
		}
		# incrementamos un dia a nuestra fecha inicial
		$t_ini += Time::Piece->ONE_DAY;  
	}
	# termina while
	
	# regresamo el arreglo de fechas
	return @fechas;
}

sub writeArrayToFile
{
	my $fileName = shift;
	my (@arrayToWrite_ref) = @_;
	open (FILE, "> $fileName") || die "problem opening $fileName\n";
	 foreach (@arrayToWrite_ref) {
		 print FILE $_."\n";
	 }
	close(FILE);
}

#Subroutine to get the Key value i.e. %K telling if the seq is non negative->'nonn' or negative->'sign'
sub getKeyValues {
	my $string = shift;
	# retrieves the id of the sequence that is being parsed to remove it from results
	my $var = "";
	$var = $1 if $string =~ /^%K\sA[0-9]{6,8}\s(.*)\n/mg;
	my @ret = split(/,/,$var);
	return @ret;
}

#Subroutine to find IDs of all core sequences and write them to file named core.txt
#We have to change it later as now we dnt have the folder "CORE" for core sequences, get them from the file core-sequence.txt

sub createCoreSeqFile {
my @coreSeq=Util::getLocalSequences("./db/core");
#Util::printArray(@coreSeq);
open (FILE, "> ./db/core.txt") || die "problem opening ./db/core.txt\n";
	foreach (@coreSeq) {
		print FILE $_."\n";
	}
	close(FILE);
}


sub findMinLenOfInitialElem{
	my @seq;
	my @seqFirseElemLen;
	#my $infile = "./db/all.txt";
	my $infile = shift;
	@seq=readFileLinebyLineInArray($infile);
	my @seqFirstElem;
	for (my $i=0; $i < $#seq+1; $i++)
		{
			@seqFirstElem = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getFirstElements);
			push @seqFirseElemLen,$#seqFirstElem;
			#print("SeqID: $seq[$i]    Seq Len: $#seqFirstElem\n")
		}
	use List::Util qw( min max );
	my $minlen= min @seqFirseElemLen;
	#print("Min len of Initial elements among the list of sequences provided: $minlen\n");
	return $minlen;
}

#create First Elelment File
#do it in data structure
sub createFirstEmlemtFile{
	my @seq;
	my @seqFirseElemLen;
	my $seqStringDS;
	my @seqStringDSArray;
	
	#my $infile = "./db/all.txt";
	my $infile = shift;
	
	@seq=readFileLinebyLineInArray($infile);
	my @seqFirstElem;
	for (my $i=0; $i < $#seq+1; $i++)
		{
			@seqFirstElem = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getFirstElements);
			push @seqFirseElemLen,$#seqFirstElem;
			#print("SeqID: $seq[$i]    Seq Len: $#seqFirstElem\n 1st Elem: @seqFirstElem\n")
			
			$seqStringDS="$seq[$i] @seqFirstElem";
			##print"$seqStringDS\n";
			push @seqStringDSArray,$seqStringDS;
			
		}
	open (FILE, "> ./db/SeqInitialElements.txt") or die "problem opening ./db/core.txt\n";
	foreach (@seqStringDSArray) {
		print FILE $_."\n";
	}
	close(FILE);

}



sub computeComplement{
	my $seq = shift;
	my @seqFirstElem = Parser::parseSequence($seq, \&Parser::getFirstElements);
	my $maxElem=max @seqFirstElem;
	#print  "\nInt:$maxElem\n";
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


#Not used anymore as now we are handling the complement by Hash Map not file
sub findComplementSeqIDfromFile{
	my (@seqComp)=@_;
	my $seqCompString = join(" ", @seqComp);
	#print $seqCompString;
	my $infile = "./db/SeqInitialElements.txt";
	open(FH, $infile) or die "Cannot open $infile\n";
	my $complSeqID=0;
	while ( my $line = <FH> )
	{
		chomp($line);		
		#Package Name
		if (index($line, $seqCompString) != -1) 
		{
			print "\nYes COmplement found\n$line\n";
			$complSeqID = $1 if $line =~ /^(A[0-9]{6,8})\s/mg;
		}
	}			
	close(FH);
	return $complSeqID;
}


#returns HashMap
sub createFirstEmlemtDataStr{
	my $infile = shift;
	
	my @seq;
	my @seqFirseElemLen;
	
	#my $infile = "./db/all.txt";
	
	@seq=readFileLinebyLineInArray($infile);
	my %seqHasMap;
	my @seqFirstElem;
	my $array_ref;
	for (my $i=0; $i < $#seq+1; $i++)
		{
			@seqFirstElem = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getFirstElements);
			$array_ref=[@seqFirstElem];
			$seqHasMap{$seq[$i]} =$array_ref;   # reference to an anonymous array
			#print $seqHasMap{$seq[$i]};
			push @seqFirseElemLen,$#seqFirstElem;
			#print("SeqID: $seq[$i]    Seq Len: $#seqFirstElem\n 1st Elem: @seqFirstElem\n")
			
		}
	# # Access elements		
	# print"1st\n";	
	# print $seqHasMap{A001950}[0];	#acces the reference

	# print"\n2nd\n";	
	# my $array_reference=$seqHasMap{A000201};
	# print $array_reference;
	# my @array=@$array_reference;
	# print"\n";	
	# print @array;
	
	return %seqHasMap;
}




# Example
	# my @array1=(1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 11, 12, 12, 13, 14, 14, 15, 16);
        # my @array2=(1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 11, 12, 12, 13, 14, 14, 15, 16);
        # "Perfect Match"
        
        # my @array1=(1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 11, 12, 12, 13, 14, 14, 15, 16);
        # my @array2=(0, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 11, 12, 12, 13, 14, 14, 15, 16);        
	# "Match by ignorning the 1st zero of Array 2";

        # my @array1=(0, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 11, 12, 12, 13, 14, 14, 15, 16);
        # my @array2=(1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 11, 12, 12, 13, 14, 14, 15, 16);        
	# "Match by ignorning the 1st zero of Array 1";
	
	# my @array1=(1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9);
        # my @array2=(1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 9, 10, 11, 12, 12, 13, 14, 14, 15, 16);        
	# "No Match";
	
       
#Access
	# my $flag=Util::areArraysEqual(\@array1, \@array2);
	# print ("\nFlag:$flag\n");

	
sub areArraysEqual{
        my ($array_ref1, $array_ref2) = @_;
	my @array1 = @{$array_ref1};
	my @array2 = @{$array_ref2};
	#print("\n\narray1:@array1 \narray2:@array2");

	my $array1Size=$#array1;	
	my $array2Size=$#array2;
	my @array1Resize=();
	my @array2Resize=();
	
	
	my $flag="No Match";	

	    #print @array2;
		if($#array2<=$array1Size)
		{
			#print("IF :\narray2: $#array2<=array1Size: $array1Size");
			@array1Resize=();
			for (my $i=0; $i <=$#array2; $i++)
				{
					push @array1Resize,$array1[$i];
				}	
				#@array2Resize=();
				@array2Resize=@array2;
		}
		else{
			#print("Else: \narray2: $#array2 <= array1Size: $array1Size");       	
			@array2Resize=();
			#print("\n\nOutside Loop array2Resize: @array2Resize  end\n");

			for (my $i=0; $i <=$array1Size; $i++)
				{
					push @array2Resize,$array2[$i];
				}	
					#print("\n\nWithin Loop: array2: @array2    END");

					#print("\n\nWithin Loop: array2Resize: @array2Resize  END");
				#@array1Resize=();
				@array1Resize=@array1;
		}
	
		
	       my $count=0; 
	       #print("\n\narray1Resize:@array1Resize \narray2Resize:@array2Resize");
			if (@array1Resize ~~ @array2Resize && $#array2Resize>=7 )
			{
				$flag="Perfect Match";
				#print"\n$flag\n";
					
			}
			else
			{
				if($array2Resize[0]==0 )
				{
					#print ("ifarray2Resize");
					for (my $iTh=0; $iTh <=$#array1Resize-1; $iTh++)
					{
						for (my $iFi=1; $iFi <=$#array1Resize; $iFi++)
						{
							my $diffInIndex=$iFi-$iTh;
							if ($array1Resize[$iTh]==$array2Resize[$iFi] and $diffInIndex==1)
							{
								#print("\n $array1Resize[$iTh] == $array2Resize[$iFi]");
								$count++;
								}
						}
					}
					#print ("\ncount: $count   array1Resize:$#array1Resize");	
					
					if($count==$#array1Resize && $count>=7)
					{
						$flag="Match by ignorning the 1st zero of Array 2";
						#print"\n$flag\n";
						
					}     
				}
				elsif($array1Resize[0]==0){
					#print ("ifarray1Resize");

					#print("\narray1Resize:@array1Resize");
					#print("\narray2Resize:@array2Resize");
					
					
					for (my $iFi=0; $iFi <=$#array1Resize-1; $iFi++)
						
					{
						for (my $iTh=1; $iTh <=$#array1Resize; $iTh++)
						{
							my $diffInIndex=$iTh-$iFi;
							#print("\n $array1Resize[$iTh] == $array2Resize[$iFi]");
							if ($array1Resize[$iTh]==$array2Resize[$iFi] and $diffInIndex==1)
							{
								#print("\n $array1Resize[$iTh] == $array2Resize[$iFi]");
								$count++;
							}
						}
					}
					#print ("\ncount: $count   array1Resize:$#array1Resize");	
					
					if($count==$#array2Resize && $count>=7)
					{
						$flag="Match by ignorning the 1st zero of Array 1";
						#print"\n$flag\n";
						
						
					}
				}
						
				else{
					$flag="No Match";
					#print"\n$flag\n";
				     }
			}

		   
	return $flag;

}

	
	
	
	
	
	
	
	
	
	
#Reads file line by line and puts in an array.
sub readFileLinebyLineInArray
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

sub xml_special_char {
	my $string = shift;
	$string =~ s/&/&amp;/g;
	$string =~ s/</&lt;/g;
	$string =~ s/>/&gt;/g;
	$string =~ s/"/&quot;/g;
	$string =~ s/'/&apos;/g;
	#$string =~ s/á/a/g;
	#$string =~ s/é/e/g;
	#$string =~ s/í/i/g;
	#$string =~ s/ó/o/g;
	#$string =~ s/ú/u/g;
	#$string =~ s/è/e;/g;
	#$string =~ s/ń/n;/g;
	#$string =~ s/ö/o;/g;
	#$string =~ s/ü/u;/g;
	#$string =~ s/ő/o;/g;
	
	
		
#	$string =~ s/—/-/g;
	$string =~ s/å/a/g;
	$string =~ s/™//g;
#	$string =~ s/[^!-~\s]//g;
	return $string;
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

#this function returns the measeure provided 2 arrays containing complement

#EXAMPLE
# my @seq1=(0,2,3,5,7,8,11,90);
# my @seq2=(4,6,9,9,10);
# my $return=findComplementDirectlyWithMeasure(\@seq1,\@seq2);
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
	
	
1;