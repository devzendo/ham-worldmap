use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share dist => 'share';

WriteMakefile(
    NAME             => 'Ham::WorldMap',
    AUTHOR           => q{Matt Gumbley <matt.gumbley@devzendo.org>},
    VERSION_FROM     => 'lib/Ham/WorldMap.pm',
    ABSTRACT_FROM    => 'lib/Ham/WorldMap.pm',
    LICENSE          => 'apache_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Ham-WorldMap-*' },
);

package MY;
use File::ShareDir::Install 'postamble';
