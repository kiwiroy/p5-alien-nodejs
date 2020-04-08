use ExtUtils::MakeMaker;
use Alien::Build::MM;

my $abmm = Alien::Build::MM->new;

WriteMakefile($abmm->mm_args(
  ABSTRACT           => 'Discover or easy install of node.js',
  DISTNAME           => 'Alien-NodeJS',
  NAME               => 'Alien::NodeJS',
  VERSION_FROM       => 'lib/Alien/NodeJS.pm',
  CONFIGURE_REQUIRES => {'Alien::Build::MM' => 0,},
  BUILD_REQUIRES     => {'Alien::Build::MM' => 0,},
  PREREQ_PM          => {
    'Alien::Base'        => 0,
    'Alien::Build'       => 0,
    'URI'                => 0,
    'Mojo::DOM58'        => 0,
    'Sort::Versions'     => 0,
  },

  META_MERGE => {
    'dynamic_config' => 0,
    'meta-spec'      => {version => 2},
    'resources'      => {
      bugtracker =>
        {web => 'https://github.com/kiwiroy/p5-alien-nodejs/issues'},
      homepage   => 'https://github.com/kiwiroy/p5-alien-nodejs',
      repository => {
        type => 'git',
        url  => 'https://github.com/kiwiroy/p5-alien-nodejs.git',
        web  => 'https://github.com/kiwiroy/p5-alien-nodejs',
      },
    },
    'x_contributors' => [],
  },

  # If you are going to write the recommended
  # tests you will will want these:
  TEST_REQUIRES => {'Test::Alien' => 0, 'Test2::Suite' => '0.000129',},
));

sub MY::postamble {
  $abmm->mm_postamble;
}
