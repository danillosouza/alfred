package Alfred::Queue;
require Exporter;

use 5.10.0;
use strict;
use autodie;
use warnings;

use Alfred::Database qw/init_db/;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw//;
our $VERSION   = 1.00;


##
## Retrieve the next task to be executed
sub next_task {
    my $dbh = init_db();
    my $sth = $dbh->prepare('SELECT * FROM tasks WHERE done = 0 ORDER BY id LIMIT 1');

    $sth->execute();

    die 'ERROR!: ' . $sth->errstr . "\n"
        if ($sth->err);

    # return undef unless $sth->rows > 0;

    my $row  = $sth->fetchrow_hashref();
    my $task = {
        id      => $row->{id},
        task    => $row->{task},
        options => $row->{params},
    };

    return $task;
}


##
## Register a new task to the queue
sub add_task {
    my $task = shift;
    my $dbh  = init_db();
    my $sth  = $dbh->prepare('INSERT INTO tasks (task, params, done, created_at, runned_at) VALUES (?, ?, 0, CURRENT_TIMESTAMP, NULL)');

    $sth->bind_param(1, $task->{task});
    $sth->bind_param(2, $task->{options});
    $sth->execute();

    die 'ERROR!: ' . $sth->errstr . "\n"
        if ($sth->err);
}


##
## Set a queued task as completed.
sub complete_task {
    my $id  = shift;
    my $dbh = init_db();
    my $sth = $dbh->prepare('UPDATE tasks SET done = 1, runned_at = CURRENT_TIMESTAMP WHERE id = ?');

    $sth->bind_param(1, $id);
    $sth->execute();

    die 'ERROR!: ' . $sth->errstr . "\n"
        if ($sth->err);
}


##
## List all tasks currently in the queue
sub list_tasks {
    my $dbh = init_db();
    my $sth = $dbh->prepare('SELECT * FROM tasks WHERE done = 0 ORDER BY id');
    my @tasks;

    $sth->execute();

    die 'ERROR!: ' . $sth->errstr . "\n"
        if ($sth->err);

    while (my $row = $sth->fetchrow_hashref()) {
        push @tasks, $row->{task};
    }

    return \@tasks;
}


42;
