package Alfred::Logger;
require Exporter;

use Time::localtime;
use File::Basename;
use File::Path qw/make_path/;
use Cwd qw/abs_path/;

use 5.10.0;
use strict;
use autodie;
use warnings;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw/success warning error info/;
our $VERSION   = 1.00;


##
## Resolve task name to log directory
sub resolve_dir {
    my $task = shift;
       $task =~ s/::/_/g;
    return dirname(abs_path($0)) . '/log/' . $task;
}


##
## Get filename for task based on timestamp
sub resolve_filename {
    my $lt = localtime;
    return sprintf('%4d%02d%02d_%02d.log', $lt->year+1900, $lt->mon+1, $lt->mday, $lt->hour);
}


##
## Get ful file path for the current log
sub resolve_logfile {
    my $task = shift;
    my $path = resolve_dir $task;
    my $file = resolve_filename;

    make_path $path unless -d $path;

    return "${path}/${file}";
}


##
## Write line to logfile
sub write_log {
    my($task, $status, $message) = @_;
    my $logfile = resolve_logfile $task;
    my $lt      = localtime;

    my $logline = sprintf("[%4d-%02d-%02d %02d:%02d:%02d][%s][%s] %s\n",
        $lt->year+1900,
        $lt->mon+1,
        $lt->mday,
        $lt->hour,
        $lt->min,
        $lt->sec,
        $task,
        uc $status,
        $message);

    open my $FH, '>>', $logfile;
    print $FH $logline;
    close $FH;
}


sub success {
    my($task, $message) = @_;
    write_log $task, 'success', $message;
}

sub warning {
    my($task, $message) = @_;
    write_log $task, 'warning', $message;
}

sub error {
    my($task, $message) = @_;
    write_log $task, 'error', $message;
}

sub info {
    my($task, $message) = @_;
    write_log $task, 'info', $message;
}

42;
