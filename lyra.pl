#!/usr/bin/perl

use strict;
use warnings;

use Path::Tiny;

my @fortunes;
my @fortune_paths = ("$ENV{HOME}/fortunes/", "/usr/share/games/fortune/");

if (scalar @ARGV) {
    foreach my $arg (@ARGV) {
        foreach (@fortune_paths) {
            my $path = path($_);
            if (-e "$path/$arg") {
                my $fortune_file = "$path/$arg";
                read_fortunes("$path/$arg")
            }
        }
    }
} else {
    foreach (@fortune_paths) {
        my $path = path($_);
        if (-d $path) {
            for ($path->children) {
                read_fortunes($_) unless $_ =~ /\.dat$/i;
            }
        } else {
            read_fortunes($path);
        }
    }
}


if (scalar @fortunes > 0) {
    print $fortunes[ rand @fortunes ], "\n" ;
} else {
    print "lyra: no such fortune.\n";
}

sub read_fortunes {
    my $path = shift @_;
    my $file = path($path)->absolute;
    push @fortunes, split(/\n%\n/, $file->slurp);
}
