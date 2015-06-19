#!/usr/bin/env perl

use lib './lib';
use strict;
use warnings;
#use WWW::Curl;
use LWP; 
use Util;
use Parser;
use WWW::Mechanize;
#use Net::SSL ();
#use IO::Socket::SSL;

# subroutine to get a sequence:
sub getSequenceOEISByID {
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
my $user = "E14C566A";
my $pass = "1qa2ws3ed.";
my $domain = "domain";

#my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
my $ua = WWW::Mechanize -> new(ssl_opts => { verify_hostname => 0 });
#$ua->proxy(['http'], "http://cache.cites-u.univ-nantes.fr:3128");
#$ua->credentials("http://cache.cites-u.univ-nantes.fr:3128", $domain, $user, $pass);


my $ua_2 = WWW::Mechanize -> new(ssl_opts => { verify_hostname => 0 });
#$ua_2->proxy(['http'], "http://cache.cites-u.univ-nantes.fr:3128");
#$ua_2->credentials("http://cache.cites-u.univ-nantes.fr:3128", $domain, $user, $pass);


############### The program starts here:
my $sequences_file = "./db/test_sequences.txt";

my @sequences_to_download = readSeqList($sequences_file);
#my $count = 1;
#my $sequence;
#foreach (@sequences_to_download) {
#	print "Downloading $_ ($count / $#sequences_to_download)\n"; 
#	$sequence = getSequenceOEIS($_, $ua);
#	 write file: 
#	open FILE, ">", "./db/robot_test/$_.txt" or die "Couldn't open file: $!"; 
#	print FILE $sequence;
#	close FILE;
#	$count++;
##	sleep(1);
#}


# Receive a file with the ID's  of the sequences that will be searched in OEIS
# by its first elements
my $filename = "./db/test_sequences.txt";
open FILE, $filename or die "Couldn't open file: $!"; 
my @content_array;
while (<FILE>){
	chomp $_;
	push @content_array, $_;
}
close FILE;
foreach my $seq (@content_array) {
	print "----------------------------------------" . "\n";
	my @elem = Parser::parseSequence("./db/sequences/$seq.txt", \&Parser::getFirstElements);
	# TODO: Get the complementary elements!!!!!!!!!!!!!!!
	my $match = 0;
	while (!$match and $#elem > 20) {
		my $url_firstelem = join("%2C+", @elem);
		my $url = "http://oeis.org/search?q=$url_firstelem&sort=&language=english&go=Search";
		print $url . "\n";
		my $response = $ua->get($url);
		my $link = $ua->find_all_links(text => 'text');
		print $link->[0]->url() . "\n";
		if (!$link->[0]->url()) {
			print "no search results\n";
			pop @elem;
		} else {
			my $i = 0;
			print "nres=" .$#{$link} . "\n";
			while (!$match and $i <= $#{$link}) {
				print "checking link\n";
				my $link_url = "http://oeis.org" . $link->[$i]->url();
				my $link_response = $ua_2->get($link_url);
				die "Can't get -- ", $link_response->status_line unless $link_response->is_success;
				die "Hey, I was expecting text ", $link_response->content_type unless $link_response->content_type eq 'text/plain';
				#print $link_response->content ."\n";
				my @link_f_elem = Parser::getFirstElements($link_response->content);
				$i += 1;
				my $j = 0;
				foreach my $el (@elem){
					if ($el == $link_f_elem[$j]) {
						$match = 1;
					}
					$j += 1;
				}
				#Util::printArray(@link_f_elem);
				#print "The link is:". $_->url()."\n";
			}

		}
		
	}
}	



#my $url = "http://oeis.org/search?q=0%2C+2%2C+4%2C+6%2C+8%2C+10%2C+12%2C+14%2C+16%2C+18%2C+20%2C+22%2C+24%2C+26%2C+28%2C+30%2C+32%2C+34%2C+36%2C+38%2C+40%2C+42%2C+44&sort=&language=english&go=Search";
#my $response = $ua->get($url);
#die "Can't get -- ", $response->status_line unless $response->is_success;
##die "Hey, I was expecting HTML, not ", $response->content_type unless $response->content_type eq 'text/plain';
#my $link = $ua->find_all_links(text => 'text');
#
##print "The link is:". $link->[0]->url()."\n";
#foreach (@{$link}) {
#	my $link_url = "http://oeis.org" . $_->url();
#	my $link_response = $ua_2->get($link_url);
#	die "Can't get -- ", $link_response->status_line unless $link_response->is_success;
#	die "Hey, I was expecting text ", $link_response->content_type unless $link_response->content_type eq 'text/plain';
#	print $link_response->content ."\n";
#	#print "The link is:". $_->url()."\n";
#}
#
#


#print $response->content;

