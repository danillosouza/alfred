package Foo::Bar;
require Exporter;

##
## Dummy task for demonstration.
##

use 5.10.0;
use strict;
use autodie;
use warnings;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw//;
our $VERSION   = 1.00;


sub main {
    say('Heeeeeey!');
}

sub help {
    say('Hooooooo!');
}


42;
