# -*- mode: perl; -*-

use Test2::V0 -no_srand;
use Test::Alien;
use Alien::NodeJS;

alien_ok 'Alien::NodeJS';

ok(my $version = Alien::NodeJS->version);
ok(my $npm_ver = Alien::NodeJS->npm_version);

is(Alien::NodeJS->node_version, $version, 'same version reported');
like($npm_ver, qr/^[0-9\.]+$/, 'npm version - version like number');

run_ok(['node', '--version'])->exit_is(0, 'node runs')
  ->out_like(qr/^\Q$version\E$/, 'node version equals module reported version')
  ->diag;

run_ok(['npm', '--version'])->exit_is(0, 'npm runs')
  ->out_like(qr/^\Q$npm_ver\E$/, 'npm version equals module reported version')
  ->diag;


done_testing;
