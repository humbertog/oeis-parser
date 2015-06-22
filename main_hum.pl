#!/usr/bin/env perl

use lib './lib';
use Parser;
use Scripts;
use Util;
use strict;
use warnings;
use Text::Unidecode;


my $filename = "./db/all.txt";	
#my $filename = "./db/test_sequences.txt";	


#Scripts::classifyByMonotonicity($filename);
#Scripts::createIndividuals($filename);

#my @auth = Parser::parseSequence("db/sequences/A000029.txt", \&Parser::getAuthor);
#print $auth[0]. "\n";

&createAuthors($filename);

sub createAuthors {
	# args: the file with the sequence id's to classify
	my $filename = shift;
	open FILE, $filename or die "Couldn't open file: $!"; 
	my @content_array;
	while (<FILE>){
		chomp $_;
		push @content_array, $_;
	}
	close FILE;
	
	my %authorNames;
	my %authorEmails;
	my %seq_author;
	foreach my $seq (@content_array) {
		print "$seq.\n";
		my @author_data = Parser::parseSequence("./db/sequences/$seq.txt", \&Parser::getAuthor);
		my @data_splited = split (/,|and|&/,$author_data[0]);
		foreach my $str (@data_splited) { 
				$str =~ s/Entry revised by _N. J. A. Sloane_//;
				
				my $email;
				my $auth_names;
				if ($str =~ m/(.*)\s\((.*\(AT\).*)\)/ or $str =~ m/_(.*)_\s\((.*\(AT\).*)\)/ ){
					$auth_names = $1;
					$email = $2;
					print "$auth_names\n";
					print "$email\n";
				} elsif ($str =~ m/_(.*)_/) {
					$auth_names = $1;
				}
				
				my $ID;
				if ($auth_names) {
					$ID = $auth_names;
					$ID = unidecode($ID);
					$ID =~ s/ //g;
					$ID =~ s/"//g;
					$authorNames{$ID} = $auth_names;
					if ($email) {
						$email =~ s/\(AT\)/@/;
						$authorEmails{$ID} = $email;
					}
				}
				$seq_author{$seq} = $ID;
		}
	}
	open (FILE, "> ./db_owl/XML_Authors.rdf") or die "problem opening ./db_owl/XML_Authors.rdf\n";
	close(FILE);
	foreach my $i (keys %authorNames) {		
		my $seqXMLset="<owl:NamedIndividual rdf:about=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#$i\">\n";
		$seqXMLset .= "<rdf:type rdf:resource=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#Author\"/>\n";
		$seqXMLset .= "<hasName rdf:datatype=\"&xsd;string\">$authorNames{$i}</hasName>\n";
		if (defined($authorEmails{$i})) {
				$seqXMLset .= "<hasEmail rdf:datatype=\"&xsd;string\">$authorEmails{$i}</hasEmail>\n";
		}
		$seqXMLset .= "</owl:NamedIndividual>\n\n";
		
		open (FILE, ">> ./db_owl/XML_Authors.rdf") or die "problem opening ./db_owl/XML_Authors.rdf\n";
		print FILE"$seqXMLset";
		close(FILE);
		
	}
	open (FILE, "> ./db_owl/XML_Seq_Authors.rdf") or die "problem opening ./db_owl/XML_Seq_Authors.rdf\n";
	close(FILE);
	foreach my $i (keys %seq_author) {
		my $seqXMLset;
		if ($seq_author{$i}) {
			$seqXMLset="<owl:NamedIndividual rdf:about=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#$i\">\n";
			$seqXMLset .= "<hasAuthor rdf:resource=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#$seq_author{$i}\"/>\n";
			$seqXMLset .= "</owl:NamedIndividual>\n\n";
			
			open (FILE, ">> ./db_owl/XML_Seq_Authors.rdf") or die "problem opening ./db_owl/XML_Seq_Authors.rdf\n";
			print FILE"$seqXMLset";
			close(FILE);
		}	
	}

}	