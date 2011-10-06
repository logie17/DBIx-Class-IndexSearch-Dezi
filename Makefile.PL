use inc::Module::Install;

name     'DBIx-Class-IndexSearch-Dezi';
all_from 'lib/DBIx/Class/IndexSearch/Dezi.pm';
author   q{Logan Bell <loganbell@gmail.com>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

