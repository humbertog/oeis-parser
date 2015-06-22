#!/usr/bin/env perl

use lib './lib';
use Parser;
use Scripts;
use Util;
use strict;
use warnings;


my $filename = "./db/all.txt";	
#my $filename = "./db/test_sequences.txt";	


#Scripts::classifyByMonotonicity($filename);
Scripts::createIndividuals($filename);