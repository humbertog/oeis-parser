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

#MAIN
my $infile = "./db/compool.txt";createIndividuals($infile);
sub createIndividuals{	
	my $hasName;
	my $hasFirstElements;
	my $hasFormula;
	my $hasKeywords;
	my $hasOffset;

	my $seqXMLset;
	my $seqXMLsetAll;
#chan
	my @seqName;
	my $seqFirseElemLenStr;
	my @seqFormula;
	my @seqKeywords;
	my @seqOffset;

	my @seq;
	my @seqFirseElemLen;
	#my $infile = "./db/all.txt";
	my $infile = shift;
	@seq=readFileLinebyLineInArray($infile);
	my @seqFirstElem;
	for (my $i=0; $i < $#seq+1; $i++)
		{
			@seqName = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getName);			
			@seqFirstElem = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getFirstElements);
			@seqFormula = Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getFormula);
			@seqKeywords=Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getKeyValues);
			@seqOffset=Parser::parseSequence("./db/sequences/$seq[$i].txt", \&Parser::getOffset);
			
		for (my $j=0; $j < $#seqFirstElem+1; $j++)
		{
			if($j>0)
			{
				$seqFirseElemLenStr=$seqFirseElemLenStr.",".$seqFirstElem[$j];
			}
			else
			{
				$seqFirseElemLenStr=$seqFirseElemLenStr.$seqFirstElem[$j];				
			}
		}
		
			push @seqFirseElemLen,$#seqFirstElem;
						$seqXMLset="<owl:NamedIndividual rdf:about=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#A000004\">\n<rdf:type rdf:resource=\"http://www.semanticweb.org/humberto/ontologies/2015/2/Sequence.owl#Sequence\"/>\n";			$hasName="<hasName rdf:datatype=\"&xsd;string\">$seqName[0]</hasName>\n";
			$seqXMLset=$seqXMLset.$hasName;
			$hasFirstElements="<hasFirstElements rdf:datatype=\"&xsd;string\">$seqFirseElemLenStr</hasFirstElements>\n";
			$seqXMLset=$seqXMLset.$hasFirstElements;
			$hasFormula="<hasFormula rdf:datatype=\"&xsd;string\">@seqFormula</hasFormula>\n";
			$seqXMLset=$seqXMLset.$hasFormula;
			$hasKeywords="<hasKeywords rdf:datatype=\"&xsd;string\">@seqKeywords</hasKeywords>\n";
			$seqXMLset=$seqXMLset.$hasKeywords;							$hasOffset="<hasOffset rdf:datatype=\"&xsd;string\">@seqOffset</hasOffset>\n";
			$seqXMLset=$seqXMLset.$hasOffset;
			$seqXMLset=$seqXMLset."</owl:NamedIndividual>\n\n\n";
			    
			print("\n\n$seqXMLset");
			$seqXMLsetAll=$seqXMLsetAll.$seqXMLset;

		}
	open (OUT, "> ./db/XML_Individuals.txt") or die "problem opening ./db/core.txt\n";
	print OUT"$seqXMLsetAll";
	close(FILE);

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

