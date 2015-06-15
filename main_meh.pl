#!/usr/bin/env perl

use lib './lib';
use Parser;
use Util;
use Scripts;
use strict;
use warnings;



#Subroutine to find IDs of all core sequences and write them to file named core.txt
#Util::createCoreSeqFile();

#Subroutine to find all Non negative sequences and write them to file named NonNegSequences.txt
Scripts::findNonNegativeSequences(); 

