package Foo::Bar;
require Exporter;

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
    my $params = shift;

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

Foo::Bar - Dummy module for demonstration purposes.

=head1 SYNOPSIS

Show a dummy message for entry point and help of the Task.

=head1 DESCRIPTION

This module was created so you can run something right after downloading
Alfred, you can play with it however you want before creating your own Tasks.

=cut
