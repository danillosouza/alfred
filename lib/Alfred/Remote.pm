package Alfred::Remote;
require Exporter;

use 5.10.0;
use strict;
use autodie;
use warnings;

use Try::Tiny;
use YAML::Tiny;
use Net::SSH::Perl;

use Alfred::Logger;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw//;
our $VERSION   = 1.00;


##
## Read configuration for remote hosts
sub task_run {
    my $task       = shift;
    my $remotename = shift;
    my $configfile = shift || 'remotes.yaml';

    # reading config file
    try {
        my $yaml   = YAML::Tiny->read($configfile);
        my $config = $yaml->[0]{$remotename};

        # connecting via ssh
        try {
            my $ssh = Net::SSH::Perl->new($config->{host});
            $ssh->login($config->{user}, $config->{pass});

            my($alfpath) = $ssh->cmd('echo $ALFREDBIN');
            chomp $alfpath;

            try {
                my $cmd       = $alfpath .' run '. $task->{task} .' '. join(' ', @{$task->{options}});
                my($response) = $ssh->cmd($cmd);
                chomp $response;

                Alfred::Logger::success "REMOTE: ${response}";
            }
            catch {
                Alfred::Logger::error 'Unable to find an Alfred installation on remote host.';
            }
        }
        catch {
            Alfred::Logger::error 'Could not connect to remote server.';
            die("Could not connect to remote server.\n");
        }
    }
    catch {
        Alfred::Logger::error 'Could not read remotes config file.';
        die("Could not read remotes config file.\n");
    }
}


42;
