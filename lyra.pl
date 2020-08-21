#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Path::Tiny;
use IPC::Run3;

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
    "edit" => \&edit,
    "random" => \&random,
    "help" => \&HelpMessage,
);

sub HelpMessage {
    say qq{Usage:
    edit
        Edit the file. (opens in \$EDITOR)
    random
        Print a random fortune.
    help
        Show this text.}
}

sub unveil_fortune_file {
    my $fortune_file = "$ENV{HOME}/quotes.txt";
    $fortune_file = $ARGV[1] if $ARGV[1]; # Use $ARGV[1] as path if it exists.
    unveil( $fortune_file, "r" )
        or die "Unable to unveil: $!\n"; # Unveil $path as read-only.
    return $fortune_file;
}

# Open fortune file with a text editor.
sub edit {
    # Unveil $PATH.
    foreach my $path ( split(/:/, $ENV{PATH}) ) {
        unveil( $path, "rx" )
            or die "Unable to unveil: $!\n";
    }

    my @editor = split(/ /, $ENV{EDITOR});
    push @editor, "vi"
        unless scalar @editor; # Push "vi" if @editor is empty.

    my $fortune_file = unveil_fortune_file();
    run3 [ @editor, $fortune_file ];
}

# Print a random fortune from $path.
sub random {
    my $fortune_file = unveil_fortune_file();
    my $file = path($fortune_file)->absolute;
    my @fortunes = split/\n%\n/, $file->slurp;

    say $fortunes[ rand @fortunes ]; # Print random fortune.
}

if ( $ARGV[0]
         and $dispatch{ $ARGV[0] } ) {
    $dispatch{ $ARGV[0] }->();
} elsif ( scalar @ARGV == 0 ) {
    HelpMessage();
} else {
    say "lyra: no such option";
}
