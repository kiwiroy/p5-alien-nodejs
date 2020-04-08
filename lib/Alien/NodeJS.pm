package Alien::NodeJS;

use strict;
use warnings;
use base qw(Alien::Base);

our $VERSION = '0.01';

sub node_version {
  shift->version;
}

sub npm_version {
  shift->runtime_prop->{node_npm_version};
}

1;

=encoding utf8

=head1 NAME

Alien::NodeJS - Discover or easy install of node.js

=head1 SYNOPSIS

  use Alien::NodeJS;
  use Env qw(@PATH);
  unshift @PATH, Alien::NodeJS->bin_dir;
  system 'npm', 'install';

=head1 DESCRIPTION

The latest LTS version release is installed if not already found during initial
probe. No update will be performed for update/patch releases of the same series.

=head1 METHODS

L<Alien::NodeJS> inherits all the methods from L<Alien::Base> and implements the
following new ones.

=head2 node_version

  # v12.16.1
  Alien::NodeJS->node_version;

Return the version of the C<node> binary installed. Note this is the same as
C<<<Alien::NodeJS->version>>>.

=head2 npm_version

  # 6.13.4
  Alien::NodeJS->npm_version;

Return the version of C<npm> installed.

=head1 COPYRIGHT & LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHORS

Roy Storey - <kiwiroy@cpan.org>

=cut
