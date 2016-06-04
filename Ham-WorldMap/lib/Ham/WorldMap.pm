package Ham::WorldMap;

use 5.006;
use strict;
use warnings;

use File::ShareDir ':ALL';

use Imager;
use Ham::Locator;

=head1 NAME

Ham::WorldMap - Creates an Imager image containing an equirectangular projection of the world map, with optional
Maidenhead locator grid and day/night illumination showing the area of enhanced propagation known as the 'grey line'.
Also utility methods for adding dots at locator positions or lat/long coords.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Ham::WorldMap;

    my $foo = Ham::WorldMap->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Matt Gumbley, M0CUV C<< <matt.gumbley at devzendo.org> >> @mattgumbley

=head1 BUGS

Please report any bugs or feature requests to C<bug-ham-worldmap at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Ham-WorldMap>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Ham::WorldMap


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Ham-WorldMap>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Ham-WorldMap>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Ham-WorldMap>

=item * Search CPAN

L<http://search.cpan.org/dist/Ham-WorldMap/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Matt Gumbley.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    L<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


=cut


sub new {
    my $class = shift;

    my $mapPngFile = dist_file('Ham-WorldMap', 'grey-map.png');
    die "Cannot locate shared data file $mapPngFile" unless -f $mapPngFile;

    my $mapImage = Imager->new();
    $mapImage->read(file => $mapPngFile) or die "Could not read map $mapPngFile: " . $mapImage->errstr;
    $mapImage = $mapImage->convert(preset => 'addalpha');

    my $locator = Ham::Locator->new();

    my $grey = Imager::Color->new(64, 64, 64);

    # TODO not cross-platform. This is for OSX...
    my $font = Imager::Font->new(file => "/Library/Fonts/Microsoft/Lucida Console.ttf");

    my $obj = {
        'height' => $mapImage->getheight(),
        'width' => $mapImage->getwidth(),
        'image' => $mapImage,
        'gridx' => $mapImage->getwidth() / 18,
        'gridy' => $mapImage->getheight() / 18,
        'locator' => $locator,
        'grey' => $grey,
        'font' => $font,
    };

    bless $obj, $class;
    return $obj;
}

sub dotAtLocator {
    my ($self, $gridLocation, $radius, $colour) = @_;

    $self->{locator}->set_loc($gridLocation);
    my ($latitude, $longitude) = $self->{locator}->loc2latlng;

    my $x = $longitude; # -180 .. 180
    $x += 180; # 0 .. 360
    $x *= ($self->{width} / 360); # 0 .. width

    my $y = - $latitude; # -90 .. 90
    $y += 90; # 0 .. 180
    $y *= ($self->{height} / 180); # 0 .. height

    my ($r, $g, $b, $a) = $colour->rgba();
    my $grey = Imager::Color->new(192, 192, 192, $a);
    $self->{image}->circle(color => $grey, r => $radius, x => $x, y => $y, aa => 1);

    $self->{image}->circle(color => $colour, r => $radius - 1, x => $x, y => $y, aa => 1);
}


sub drawLocatorGrid {
    my $self = shift;
    my $map = $self->{image};
    my $grey = $self->{grey};
    my $xinc = $self->{gridx};
    my $yinc = $self->{gridy};
    my $font = $self->{font};
    $map->box(color => $grey, xmin => 0, ymin => 0, xmax => $self->{width} - 1, ymax => $self->{height} - 1, filled => 0);
    my $x;
    my $y;
    for ($x = 0; $x <= 18; $x++) {
        for ($y = 0; $y <= 18; $y++) {
            $map->box(color => $grey, xmin => $x * $xinc, ymin => $y * $yinc, xmax => ($x + 1) * $xinc, ymax => ($y + 1) * $yinc, filled => 0);
            my $sq = chr(65 + $x) . chr(65 + (17 - $y));
            $map->align_string(x => ($x * $xinc) + ($xinc / 2), y => ($y * $yinc) + ($yinc / 2),
                font => $font,
                string => $sq,
                color => $grey,
                halign=>'center',
                valign=>'center',
                size => 30,
                aa => 1);
        }
    }
}

1; # End of Ham::WorldMap
