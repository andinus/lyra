#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Path::Tiny;
use IPC::Run3;

my %dispatch = (
    "edit" => \&edit,
    "random" => \&random,
    "help" => \&HelpMessage,
);

if ( $ARGV[0]
         and $dispatch{ $ARGV[0] } ) {
    $dispatch{ $ARGV[0] }->();
} elsif ( scalar @ARGV == 0 ) {
    HelpMessage();
} else {
    say "lyra: no such option";
}

sub HelpMessage {
    say qq{Usage:
    edit
        Edit the file. (opens in \$EDITOR)
    random
        Print a random fortune.
    help
        Show this text.}
}

sub fortune_file_path {
    my $fortune_file = "$ENV{HOME}/quotes.txt";
    $fortune_file = $ARGV[1] if $ARGV[1]; # Use $ARGV[1] as path if it exists.
    return $fortune_file;
}

sub edit {
    my @editor = split(/ /, $ENV{EDITOR});
    push @editor, "vi"
        unless scalar @editor; # Push "vi" if @editor is empty.

    my $fortune_file = fortune_file_path();
    run3 [ @editor, $fortune_file ];
}

sub random {
    my $fortune_file = fortune_file_path();
    my $file = path($fortune_file)->absolute;
    my @fortunes = split/\n%\n/, $file->slurp;
    say $fortunes[ rand @fortunes ]; # Print random fortune.
}
