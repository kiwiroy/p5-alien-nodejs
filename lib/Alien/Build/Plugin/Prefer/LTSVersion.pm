package Alien::Build::Plugin::Prefer::LTSVersion;

use strict;
use warnings;

use Alien::Build::Plugin;

use Data::Dumper;

has filter  => qr/[1-9][0-9]*\.x$/;
has url     =>;
has version => qr/([0-9]+)/;

sub init {
  my ($self, $meta) = @_;

  $self->url($meta->prop->{start_url});

  $meta->before_hook(
    download => sub {
      my $build = shift;
      my $mp    = $build->meta_prop;
      my $html  = $build->fetch;
      my $res   = $build->decode($html);

      local $build->meta->{hook};
      $build->meta->apply_plugin('Prefer::SortVersions' =>
          (version => $self->version, filter => $self->filter,));
      $build->meta->apply_plugin(
        'Prefer::GoodVersion' => filter => sub {
          (my $as_int = shift->{version}) =~ s{^[^0-9]*([0-9]+).*$}{$1};
          return _is_even_non_zero($as_int);
        }
      );

      my $lts_dir = $build->prefer($res);
      $self->url($lts_dir->{list}[0]{url});
    }
  );

  $meta->around_hook(
    fetch => sub {
      my $orig = shift;
      my ($build, $url) = @_;
      $url ||= $self->url;
      return $orig->($build, $url) if $url;
    }
  );
}

sub _is_even_non_zero {
  my ($int) = @_;
  return unless $int;
  return !($int % 2);
}

1;
