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
	my $monoticity = "none";
	$monoticity = "increasing" if $increasing_flag and $non_decreasing_flag;
	$monoticity = "decreasing" if $decreasing_flag and $non_increasing_flag;
	
	$monoticity = "non_decreasing" if !$increasing_flag and $non_decreasing_flag;
	$monoticity = "non_increasing" if !$decreasing_flag and $non_increasing_flag;
	
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
	
	my @seq;
	my @seqFirseElemLen;
	
	#my $infile = "./db/all.txt";
	my $infile = shift;

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



#Reads file line by line and puts in an array.
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


1;