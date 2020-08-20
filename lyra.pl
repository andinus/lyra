#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Path::Tiny;

use constant is_OpenBSD => $^O eq "openbsd";
require OpenBSD::Unveil
    if is_OpenBSD;
sub unveil {
    if (is_OpenBSD) {
        return OpenBSD::Unveil::unveil(@_);
    } else {
        return 1;
    }
}

# Unveil @INC.
foreach my $path (@INC) {
    unveil( $path, 'rx' )
        or die "Unable to unveil: $!\n";
}

my %dispatch = (
    "random" => \&random,
    "help" => \&HelpMessage,
);

sub HelpMessage {
    say qq{Usage:
    random
        Print a random fortune.
    help
        Show this text.}
}

# Print a random fortune from $path.
sub random {
    my $path = "$ENV{HOME}/quotes.txt";
    $path = $ARGV[1] if $ARGV[1]; # Use $ARGV[1] as path if it exists.
    unveil( $path, "r" )
        or die "Unable to unveil: $!\n"; # Unveil $path as read-only.

    my $file = path($path)->absolute;
    my @fortunes = split/\n%\n/, $file->slurp;

    say $fortunes[ rand @fortunes ]; # Print random fortune.
}

if ( $dispatch{ $ARGV[0] } ) {
    $dispatch{ $ARGV[0] }->();
} elsif ( scalar @ARGV == 0 ) {
    HelpMessage();
} else {
    say "lyra: no such option";
}
