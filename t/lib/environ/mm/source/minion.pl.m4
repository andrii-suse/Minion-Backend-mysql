#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::IOLoop;
use Mojo::Server::Daemon;
use Mojo::mysql;
use Mojo::File;
use lib Mojo::File::curfile->dirname->dirname->child('lib')->to_string;

my $conn = Mojo::mysql->new;
$conn->dsn($ENV{TEST_MYSQL});

# print STDERR "DSN:: " . $ENV{TEST_MYSQL} . "\n";

plugin Minion => { mysql => $conn };
my $auth = app->routes->under('/minion');
plugin 'Minion::Admin' => { route => $auth };

sub mymain {

my $minion = app->minion;

unless ($minion) {
    print STDERR "Couldnt register minion plugin\n";
    return 1;
}

$minion->add_task(test => sub () {  print "TASK TEST"; });

my $operation = shift;

if ($operation eq 'enqueue') {
    my $task = shift // 'test';
    my $queue = pop @_;

    return $minion->enqueue( $task => [@_], queue => $queue ) if $queue;
    return $minion->enqueue( $task => [@_]);
}

if ($operation eq 'shoot') {
    my $queue = shift;
    return $minion->perform_jobs({ queues => [$queue] }) if $queue;
    return $minion->perform_jobs();
}



if ($operation eq 'start') {
    get '/' => {text => "Hello World! : use /minion path to access minion\n"};

    my $port   = __port;
    my $daemon = Mojo::Server::Daemon->new(
        app    => app,
        listen => ["http://*:$port"]
    );
    return $daemon->run;
}

print STDERR "Unknown operation: " . ( $operation // '<undefined>' ) . "\n";
return 1;

};

my $res = mymain(@ARGV);
exit (1) unless $res;
exit (0);
