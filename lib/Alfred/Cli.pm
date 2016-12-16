package Alfred::Cli;
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
## Get requested command.
sub get_order {
    if (@ARGV) {
        my $order = $ARGV[0];
        $order =~ s/:/_/g;
        return $order;
    }

    return undef;
}


##
## Get command task and options.
sub get_task {
    my $order = get_order();
    my %task  = ();

    shift @ARGV if ($order);

    $task{task}    = @ARGV ? shift @ARGV : undef;
    $task{options} = @ARGV ? \@ARGV      : undef;

    return \%task;
}

42;
