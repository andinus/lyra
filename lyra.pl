#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Path::Tiny;
use IPC::Run3;

my $fortune_dir = "$ENV{HOME}/fortunes";
my %fortunes = (
    # mst quotes.
    mst => "http://www.trout.me.uk/quotes.txt",

    # All these are from rindolf's website.
    sholmif => "https://www.shlomifish.org/humour/fortunes/shlomif",
    "shlomif-fav"
        => "https://www.shlomifish.org/humour/fortunes/shlomif-fav",
    "shlomif-factoids"
        => "https://www.shlomifish.org/humour/fortunes/shlomif-factoids",
    "sholmif-email-sig"
        => "https://raw.githubusercontent.com/shlomif/shlomif-email-signature/master/shlomif-sig-quotes.txt",

    # Quotes from the Joel on Software site.
    # (http://www.joelonsoftware.com/)
    "joel-on-software"
        => "https://www.shlomifish.org/humour/fortunes/joel-on-software",

    # Quotes from the essays and writings of Paul Graham.
    # (http://www.paulgraham.com/)
    "paul-graham"
        => "https://www.shlomifish.org/humour/fortunes/paul-graham",

    # “The Rules of Open-Source Programming”.
    osp_rules => "https://www.shlomifish.org/humour/fortunes/osp_rules",

    # Excerpts from the online Subversion folklore.
    # (http://subversion.tigris.org/)
    "subversion"
        => "https://www.shlomifish.org/humour/fortunes/subversion",

    # A collection of conversations from Freenode’s #perl .
    "sharp-perl"
        => "https://www.shlomifish.org/humour/fortunes/sharp-perl",
    # A collection of conversations from Freenode’s ##programming .
    "sharp-programming"
        => "https://www.shlomifish.org/humour/fortunes/sharp-programming",

    # katspace quotes (ref: rindolf's website).
    "katspace_sayings"
        => "http://katspace.com/fandom/quotes/sayings",
    "katspace_more-sayings"
        => "http://katspace.com/fandom/quotes/kaijen",
    "katspace_books"
        => "http://katspace.com/fandom/quotes/book",
    "katspace_quotes"
        => "http://katspace.com/fandom/quotes/quotes",
);

if ( $ARGV[0] ) {
    if ($fortunes{ $ARGV[0] }) {
        my $fortune_file = "$fortune_dir/$ARGV[0]";
        random($fortune_file); }
    elsif ( $ARGV[0] eq "latest") { get_latest(); }
    elsif ( $ARGV[0] eq "mirror") { get_mirror(); }
    elsif ( $ARGV[0] eq "ls") { run3[ "ls", $fortune_dir] }
} elsif ( scalar @ARGV == 0 ) {
    say "Usage: lyra <fortune>";
} else {
    say "lyra: no such fortune";
}

sub random {
    my $fortune_file = shift @_;
    my $file = path($fortune_file)->absolute;
    my @fortunes = split/\n%\n/, $file->slurp;
    say $fortunes[ rand @fortunes ]; # Print random fortune.
}

sub get_latest {
    foreach my $fortune (sort keys %fortunes) {
        ftp("$fortune_dir/$fortune", $fortunes{$fortune});
    }
}

sub get_mirror {
    require HTTP::Simple;

    # Ignore a warning, next line would've printed a warning.
    no warnings 'once';
    $HTTP::Simple::UA->verify_SSL(1);

    foreach my $fortune (sort keys %fortunes) {
        say "$fortune $fortunes{$fortune}";
        my $status =
            HTTP::Simple::getstore($fortunes{$fortune},
                                   "$fortune_dir/$fortune");
        warn "[WARN] Failed to fetch latest fortune\n"
            unless HTTP::Simple::is_success($status);
    }
}

sub ftp { run3 ["ftp", "-mvo", @_]; }
