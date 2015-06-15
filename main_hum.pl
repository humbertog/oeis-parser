#!/usr/bin/env perl

use lib './lib';
use Parser;
use Util;
use strict;
use warnings;

my @first_elem = Parser::parseSequence("./db/core/A000001.txt", \&Parser::getFirstElements);
my $monoticity = Util::checkMonoticity([3, 1, 3]);
Util::printArray(@first_elem);
print $monoticity . "\n";




