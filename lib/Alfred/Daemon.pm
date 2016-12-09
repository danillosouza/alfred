package Alfred::Daemon;
require Exporter;

use 5.10.0;
use strict;
use autodie;
use warnings;

use Proc::Daemon;
use File::Basename;
use File::Touch;
use Cwd qw/abs_path/;

use Alfred::Queue;
use Alfred::Task;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw//;
our $VERSION   = 1.00;

#############################################################
## Daemon creates a lockfile in the user home directory,   ##
## so before it starts, it checks if this file exists and  ##
## only runs if it's missing.                              ##
##---------------------------------------------------------##
## Daemon stops when a file called '.alfred-dismiss' is    ##
## present in the user home directory.                     ##
#############################################################

my $daemon;
my $pid;
my $lockfile = $ENV{HOME}.'/.alfred';
my $killfile = $ENV{HOME}.'/.alfred-dismiss';


##
## Initialize Alfred Daemon
sub daemonize {
    if (-e $lockfile) {
        print "There is another instance of Alfred running as daemon.\n";
        exit;
    }

    touch $lockfile;

    $daemon = Proc::Daemon->new(
        work_dir => dirname(abs_path($0)),
        pid_file => $lockfile
    );

    $daemon->Init;

    # child code
    while (1) {
        if (-e $killfile) {
            unlink $killfile;
            unlink $lockfile;
            exit;
        }

        my $task = Alfred::Queue::next_task();

        Alfred::Task::task_run $task if $task and $task->{task};
        Alfred::Queue::complete_task $task->{id};
    }
}


##
## Stops Alfred Daemon
sub dismiss {
    touch $killfile if -e $lockfile;
}


42;
