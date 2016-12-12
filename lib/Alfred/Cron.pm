package Alfred::Cron;
require Exporter;

use 5.10.0;
use strict;
use autodie;
use warnings;

use Config::Crontab;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw//;
our $VERSION   = 1.00;


##
## Verify if a crontab interval is valid
sub is_valid_crontime {
    return 1 if shift =~ /^((\*\/\d{1,2}|\d{1,2}\/\*|\d{1,2}-\d{1,2}|\d{1,2}(?:\,\d{1,2})?|\*)\s+){3}([A-Z][a-z]{2}|\*\/\d{1,2}|\d{1,2}\/\*|\d{1,2}-\d{1,2}|\d{1,2}(?:\,\d{1,2})?|\*)\s+([A-Z][a-z]{2}|\*\/\d{1,2}|\d{1,2}\/\*|\d{1,2}-\d{1,2}|\d{1,2}(?:\,\d{1,2})?|\*)$/;
    undef;
}


##
## Returns the username that cron must use to run the task
sub crontime_get_user {
    my $crontime = shift;
    my $username = $ENV{USER};

    if ($crontime =~ /^@([a-z][a-z0-9_-]*)\s+/i) {
        $username = $1;
        $crontime =~ s/^@[a-z][a-z0-9_-]*\s+//i;
    }

    return ($crontime, $username);
}


##
##
sub new_job {
    my $cronjob = shift;

    # creating the crontab entry
    my $cron     = Config::Crontab->new( -owner => $cronjob->{username} );
    my $cronline = $cronjob->{interval} ."\t"
                   . $ENV{ALFREDBIN} . ' run ' . $cronjob->{task}{task}." "
                   . join ' ', @{$cronjob->{task}{options}};

    $cronline =~ s/^\s+|\s+$//g;

    # add the block at the end of user crontab
    my $block = Config::Crontab::Block->new( -data => $cronline );
    $cron->read;
    $cron->last($block);
    $cron->write;
}


42;
