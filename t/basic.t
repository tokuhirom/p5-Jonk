use strict;
use warnings;
use Test::More;
use DBI;
use Jonk;

my $dbh = DBI->connect('dbi:SQLite:');

$dbh->do(q{
    CREATE TABLE job (
        id           integer,
        func         text,
        arg          text,
        enqueue_time text,
        primary key ( id )
    )
});

subtest 'enqueue' => sub {
    my $jonk = Jonk->new($dbh);
    my $job_id = $jonk->enqueue('MyWorker', 'arg');
    ok $job_id;

    my $sth = $dbh->prepare('SELECT * FROM job WHERE id = ?');
    $sth->execute($job_id);
    my $row = $sth->fetchrow_hashref;

    is $row->{arg}, 'arg';
    is $row->{func}, 'MyWorker';

    done_testing;
};

subtest 'dequeue' => sub {
    my $jonk = Jonk->new($dbh, {funcs => [qw/MyWorker/]});
    my $job = $jonk->dequeue();
    is $job->{arg}, 'arg';
    is $job->{func}, 'MyWorker';

    done_testing;
};

done_testing;

