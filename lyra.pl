#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Path::Tiny;
use IPC::Run3;

my $fortune_dir = "$ENV{HOME}/fortunes";

if ( $ARGV[0] ) {
    if (-e "$fortune_dir/$ARGV[0]") {
        my $fortune_file = "$fortune_dir/$ARGV[0]";
        random($fortune_file);
    } elsif ( $ARGV[0] eq "ls") {
        run3[ "ls", $fortune_dir];
    } else {
        say "lyra: no such fortune";
    }
} else {
    say "Usage: lyra <fortune>";
}

sub random {
    my $fortune_file = shift @_;
    my $file = path($fortune_file)->absolute;
    my @fortunes = split/\n%\n/, $file->slurp;
    say $fortunes[ rand @fortunes ]; # Print random fortune.
}
