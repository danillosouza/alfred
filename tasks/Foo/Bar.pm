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


##
## Entry Point
sub main {
    say('Heeeeeey!');
}


##
## Help text for your task
sub help {
    say('Hooooooo!');
}

42;


__END__
=pod

=head1 NAME

${task} - ** Short description of yout Task **

=head1 SYNOPSIS

** What your task does **

=head1 DESCRIPTION

** Full description and any other info you want to include **

=cut
