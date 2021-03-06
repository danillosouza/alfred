package Alfred::Task;
require Exporter;

use 5.10.0;
use strict;
use autodie;
use warnings;

use File::Basename;
use File::Path qw/make_path/;
use Cwd qw/abs_path getcwd/;
use Try::Tiny;

use Alfred::Logger;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw//;
our $VERSION   = 1.00;


##
## Returns path of the task module.
sub task_path {
    my $task = shift;
    $task =~ s/::/\//g;
    $task = dirname(abs_path($0)) . "/tasks/${task}.pm";

    return $task;
}


##
## Verify if the given task exists.
sub task_exists {
    my $task = task_path shift;
    return -e $task;
}


##
## Show help message for given task.
sub task_help {
    my $task = shift;
    my $path = task_path $task;

    if (task_exists $task) {
        # try to run 'help' method
        eval {
            require $path;
            chdir getcwd;
            eval("${task}::help()");
            exit;
        }
    }

    say("There is no help info for the task '${task}'.");
}


##
## Runs the given task.
sub task_run {
    my $data = shift;
    my $path = task_path $data->{task};

    if (task_exists $data->{task}) {
        # try to run 'main' method
        try {
            require $path;
            chdir getcwd;
            my $response = eval("${\$data->{task}}::main(\$data->{options})");

            unless ($@) {
                Alfred::Logger::success $data->{task}, $response;
            }
            else {
                Alfred::Logger::error $data->{task}, $@;
            }
        }
        catch{
            Alfred::Logger::error $data->{task}, $_;
        }
    }
}


##
## Create a new task module.
sub task_new {
    my $task = shift;
    my $path = task_path $task;

    if (!-e $path) {
        eval {
            make_path dirname $path;
            my $perl5lib  = $ENV{PERL5LIB};
            my $localpath = $perl5lib
                            ? '$ENV{PERL5PATH}'
                            : "'". dirname(abs_path($0)).'/local/lib/perl5' ."'";

            # file content
            open(my $FH, '>', $path);
            print $FH <<"TASK";
package ${task};
require Exporter;

BEGIN {
    push \@INC, ${localpath}
}

use 5.10.0;
use strict;
use autodie;
use warnings;

our \@ISA       = qw/Exporter/;
our \@EXPORT    = qw//;
our \@EXPORT_OK = qw//;
our \$VERSION   = 1.00;


##
## Entry Point
sub main {
    my \$params = shift;

}


##
## Help text for your task
sub help {

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

TASK

            close $FH;
        }
        and return abs_path $path;
    }

    return undef;
}


42;
