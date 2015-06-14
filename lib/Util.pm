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
	return @local_seq;
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



1;