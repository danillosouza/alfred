package Alfred::Database;
require Exporter;

use DBI;
use File::Basename;
use Cwd qw/abs_path/;

our @ISA       = qw/Exporter/;
our @EXPORT    = qw//;
our @EXPORT_OK = qw/init_db/;
our $VERSION   = 1.00;


##
## Initialize/create database
sub init_db {
    my $dbfile = dirname(abs_path($0)) . '/tasks.alf';
    my $dbh    = DBI->connect("dbi:SQLite:dbname=${dbfile}", '', '', { RaiseError => 1 })
        or die("Error stablishing database connection.\n");

    my $sql_create = join '', (
        'CREATE TABLE IF NOT EXISTS main.tasks (',
        'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,',
        'task TEXT NOT NULL,',
        'params TEXT,',
        'done TINYINT(1) NOT NULL DEFAULT 0,',
        'created_at DATETIME NOT NULL,',
        'runned_at DATETIME)'
    );

    # create table if not exists
    $dbh->do($sql_create);
    return $dbh;
}


42;
