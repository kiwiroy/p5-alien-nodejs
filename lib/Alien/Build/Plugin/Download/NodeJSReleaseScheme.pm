package Alien::Build::Plugin::Download::NodeJSReleaseScheme;

use strict;
use warnings;
use Alien::Build::Plugin;
use POSIX ();

use Data::Dumper;

has filter         =>;
has latest_filter  => qr/^latest\-v[0-9]+\.x$/;
has latest_version => qr/([0-9]+)/;
has major_version  =>;
has url            =>;

sub init {
  my ($self, $meta) = @_;

  my ($name, $os, $arch, $ext) = ('node', $^O, (POSIX::uname())[4], 'tar.xz');

  ($os, $ext) = ('win', 'zip') if ($os eq 'MSWin32');
  $arch = 'x64'
    if (($os eq 'darwin')
    || ($os eq 'linux' && $arch eq 'x86_64')
    || ($os eq 'sunos'));
  $arch = 'ppc64' if ($os eq 'aix');

  my $filter  = qr/^\Q$name\E\-v[0-9\.]+\-\Q$os\E\-\Q$arch\E\.\Q$ext\E/;
  my $version = qr/^\Q$name\E\-(v[0-9\.]+)\-\Q$os\E\-\Q$arch\E\.\Q$ext\E/;

  $self->url($meta->prop->{start_url});

  my $latest_filter  = $self->latest_filter;
  my $latest_version = $self->latest_version;

  # Apply Download::Negotiate and Extract
  $meta->apply_plugin(
    Download => (
      filter  => qr/($filter|$latest_filter)/,
      version => qr/($version|$latest_version)/
    )
  );
  $meta->apply_plugin(Extract => $ext);

  # use a before 'download' to fetch/decode dist dir and prefer version
  # to set url - see around fetch
  $meta->before_hook(
    download => sub {
      my $build  = shift;
      my $mp     = $build->meta_prop;
      my $html   = $build->fetch;
      my $res    = $build->decode($html);
      my $ltsver = $self->_run_around_prefer($build, $res);

      # similar to Core::Download
      my ($pick, @other) = map { $_->{url} } @{$ltsver->{list}};
      $build->log("candidate *$pick");
      $build->log("candidate  $_") for splice @other, 0, 7;
      $build->log("candidate  ...") if @other;
      $self->url($pick);
    }
  );

  # Passing the correct URL requires an around 'fetch'
  $meta->around_hook(
    fetch => sub {
      my $orig = shift;
      my ($build, $url) = @_;
      $url ||= $self->url;
      $build->log("fetching $url");
      my $res = $orig->($build, $url);
      return $res;
    }
  );

}

sub _is_even_non_zero {
  my ($int) = @_;
  return unless $int;
  return !($int % 2);
}

sub _local_around_prefer {
  my ($candidate, $major_version) = @_;
  (my $v = $candidate->{version}) =~ s{^[^0-9]*([0-9]+).*$}{$1};
  return !!($v == $major_version) if $major_version;
  return _is_even_non_zero($v);
}

sub _run_around_prefer {
  my ($self, $build, $res) = @_;
  my $requested = $self->major_version;
  $res = $build->prefer($res);

  # filter even or requested major version
  my @list = grep { _local_around_prefer($_, $requested); } @{$res->{list}};
  return {type => 'list', list => \@list};
}

1;

=encoding utf8

=head1 NAME

Alien::Build::Plugin::Download::NodeJSReleaseScheme - Around Download::Negotiate

=head1 SYNOPSIS

  share {
    start_url 'https://nodejs.org/dist';

    plugin 'Download::NodeJSReleaseScheme' => (major_version => 13);

    # ...
  };

=head1 DESCRIPTION

L<NodeJS|https://nodejs.org/> uses the following
L<release schedule|https://nodejs.org/en/about/releases/> to distribute and
support the project. The downloads are organised primarily by the versions under
the C<dist/> directory. Selecting the version directory before the OS,
architecture and packed file is not immediately supported by
L<Alien::Build::Plugin::Download::Negotiate>. This module appropriately applies
the Download plugin using a before hook to achieve the required directory
traversal, prior to continuing as normal.

=head1 PROPERTIES

=head2 major_version

Rather than the latest LTS version (highest even numbered release), pick this
version. Needs to be a positive integer and may be odd to facilitate selection
of the current release.

=head1 COPYRIGHT & LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHORS

Roy Storey - <kiwiroy@cpan.org>

=cut
