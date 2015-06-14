package Parser;

sub parseSequence {
	# @args = ($filename, parser_ref1, parser_ref2, ...)
	my $filename = shift;
	open FILE, $filename or die "Couldn't open file: $!"; 
	my $content_string = "";
	while (<FILE>){
		$content_string .= $_;
	}
	close FILE;
	
	# Uses the parser_refs parser funtion refs
	my $parser; 
	my @result;
	while (@_) {
		$parser = shift;
		@result = $parser->($content_string);
	}
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
			push @seq_clean, $_;
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

1;
