package Alfred::Dispatcher;

use 5.10.0;
use strict;
use autodie;
use warnings;

use File::Basename;
use File::Path qw/rmtree/;
use File::Find qw/find/;
use Cwd qw/abs_path/;

use Alfred::Cron;
use Alfred::Task;
use Alfred::Queue;
use Alfred::Daemon;

##
## Constructor
sub new {
    bless {}, shift;
}


##
## HELP FROM TASK
sub help {
    my $self = shift;
    my $task = shift;

    Alfred::Task::task_help $task->{task} if $task->{task};

    # default help message
    my $help = <<"HELP";

Alfred - Easily manage your server tasks!

\$ alfred install                   - Install itself to the current user path.
\$ alfred help                      - Show this help message.
\$ alfred daemon                    - Starts Alfred daemon.
\$ alfred dismiss                   - Stops Alfred daemon.
\$ alfred list                      - List all available tasks.
\$ alfred queue                     - List all tasks currently in the queue.
\$ alfred help <task>               - Show help information for the given task.
\$ alfred create <task>             - Create a new task.
\$ alfred purge <task>              - Destroy the given task.
\$ alfred run <task>                - Execute the given task.
\$ alfred run:remote <host> <task>  - Execute the given task in a remote server.
\$ alfred schedule <task>           - Add the given task to the daemon queue.
\$ alfred cron <crontime> <task>    - Add a new crontab job to run the given task.


* `crontime` must be a valid crontab interval.

* Optionally, you can put a username with the crontime to run the task with
  the specified user, assuming the username you want to use is 'bruce', do:

  "\@bruce * * * * *"


[[ Tasks names should be valid Perl module names ]]

    - Backup::Database
    - Site::FTP::Sync
    - etc

HELP

    say($help);
    exit;
}


##
## RUN TASK
sub run {
    my $self = shift;
    my $task = shift;

    if ($task->{task}) {
        Alfred::Task::task_run $task;
        exit;
    }

    say('No task was given. Aborting...');
}


##
## NEW TASK
sub create {
    my $self = shift;
    my $task = shift;

    if ($task->{task}) {
        if (Alfred::Task::task_exists $task->{task}) {
            say("Task '${\$task->{task}}' already exists.");
            exit;
        }

        my $path = Alfred::Task::task_new $task->{task};

        if (! $path) {
            say("There was an error trying to create task '${\$task->{task}}'.");
        }
        else {
            say($path);
        }
    }
}


##
## INSTALL ALFRED TO USER PATH
sub install {
    my $self = shift;
    my $task = shift;

    unless ($ENV{ALFREDPATH} && $ENV{ALFREDBIN}) {
        open(my $FH, '>>', $ENV{HOME}.'/.bashrc');
        print $FH "\n# Alfred bin\n";
        print $FH "export PATH=\$PATH:". dirname(abs_path($0)) ."\n";
        print $FH "export ALFREDPATH=". dirname(abs_path($0)) ."\n";
        print $FH "export ALFREDBIN=". dirname(abs_path($0)) ."/alfred\n";
        close($FH);

        say('Alfred was added to the user path!');
    }
    else {
        say('Alfred is already installed on ' . $ENV{ALFREDPATH});
    }
}


##
## QUEUE TASK FOR DAEMON
sub schedule {
    my $self = shift;
    my $task = shift;

    if ($task->{task}) {
        Alfred::Queue::add_task $task;
        exit;
    }

    say('No task was given. Aborting...');
}


##
## STARTS DAEMON
sub daemon {
    Alfred::Daemon::daemonize();
}


##
## STOPS DAEMON
sub dismiss {
    Alfred::Daemon::dismiss();
}


##
## LIST ALL TASKS IN THE QUEUE
sub list {
    my $self = shift;
    my $task = shift;

    find sub {
        if (/\.pm$/) {
            my $filepath = $File::Find::name;

            $filepath =~ s/^.+\/tasks\///;
            $filepath =~ s/\//::/g;
            $filepath =~ s/\.pm$//;

            say("-> ${filepath}");
        }
    }, abs_path(dirname($0)).'/tasks';
}


##
## LIST ALL TASKS AVAILABLE
sub queue {
    my $tasks = Alfred::Queue::list_tasks();

    if (! @$tasks) {
        say('No tasks currently on the daemon queue.');
        exit;
    }

    foreach my $task (@$tasks) {
        say("-> ${task}");
    }
}


##
## PURGE GIVEN TASK
sub purge {
    my $self = shift;
    my $task = shift;

    die("No task was informed.\n")
        if (! $task->{task});

    my $task_name = my $taskr = $task->{task};
    my $tasks_dir = dirname(abs_path($0)) . '/tasks';

    $taskr =~ s/::/\//g;

    unless (defined Alfred::Task::task_exists($task_name)
            || -d "${tasks_dir}/${taskr}") {

        say("Task '${task_name}' doesn't exists.");
        exit;
    }

    $taskr = dirname(abs_path($0)) . "/tasks/${taskr}";

    # verify if is file or dir (or both)
    if (-e "${taskr}.pm") {
        unlink "${taskr}.pm";
    }

    if (-d $taskr) {
        rmtree $taskr;
    }

    die("Error trying to remove '${task_name}', verify the file permissions.\n")
        if -e "${taskr}.pm" or -d $taskr;

    say("The task '${task_name}' was removed.");
}


##
## ADD A NEW CRONJOB TO RUN THE GIVEN TASK
sub cron {
    my $self = shift;
    my $task = shift;

    # fixing task schema
    my($crontime, $username) = Alfred::Cron::crontime_get_user($task->{task});
    my $taskname = shift @{$task->{options}};
    $task->{task} = $taskname;

    die("Invalid crontab interval.\n${crontime}\n")
        unless Alfred::Cron::is_valid_crontime $crontime;

    my $cronjob = {
        username => $username,
        interval => $crontime,
        task     => $task
    };

    Alfred::Cron::new_job $cronjob;
}


##
## RUN A TASK IN A REMOTE HOST
sub run_remote {
    my $self       = shift;
    my $task       = shift;
    my $remotename = $task->{task};

    $task->{task} = shift @{$task->{options}};

    Alfred::Remote::task_run $task, $remotename;
}


42;
