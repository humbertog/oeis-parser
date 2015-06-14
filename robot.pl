#!/usr/bin/env perl

use strict;
use warnings;
#use WWW::Curl;
use LWP; 
use Net::SSL ();
use IO::Socket::SSL;

# subroutine to get a sequence:
sub getSequenceOEIS {
	# @args = (seq_id, agent)
	my ($seq, $handler) = @_;
	my $url = 'http://oeis.org/search?q=id:' . $seq .'&fmt=text';
	my $response = $handler->get($url);
	die "Can't get $seq -- ", $response->status_line unless $response->is_success;
	die "Hey, I was expecting HTML, not ", $response->content_type unless $response->content_type eq 'text/plain';
	return $response->content;
}

# subroutine to read the sequences file that contains the id's of sequences to download:
sub readSeqList {
	# $args = filename
	my $filename = shift;
	open FILE, $filename or die "Couldn't open file: $!"; 
	my $string = "";
	while (<FILE>){
		$string .= $_;
	}
	close FILE;
	my @seq = $string =~ m/A[0-9]{6}/smg;
	return @seq;
}



############### Authentication for CU proxy:
# proxy configuration for CU Nantes:
my $user = "";
my $pass = "";
my $domain = "domain";

my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
$ua->proxy(['http'], "http://cache.cites-u.univ-nantes.fr:3128");
$ua->credentials("http://cache.cites-u.univ-nantes.fr:3128", $domain, $user, $pass);

############### The program starts here:
my $sequences_file = "./db/degree1.txt";

my @sequences_to_download = readSeqList($sequences_file);
my $count = 1;
my $sequence;
foreach (@sequences_to_download) {
	print "Downloading $_ ($count / $#sequences_to_download)\n"; 
	$sequence = getSequenceOEIS($_, $ua);
	# write file: 
	open FILE, ">", "./db/degree1/$_.txt" or die "Couldn't open file: $!"; 
	print FILE $sequence;
	close FILE;
	$count++;
#	sleep(1);
}




