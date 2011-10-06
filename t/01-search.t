use Test::More;

use lib 't/lib';

use strict;
use warnings;

BEGIN {
    use_ok('Test');
}

my $schema = Test->initialize;

my $resultset = $schema->resultset('Person');

my $person0 = $resultset->new({
    name    => 'FooBar',
    age     => 18,
});

$person0->insert;

ok $resultset->search_dezi( { name => 'Foo*' } );

done_testing;


