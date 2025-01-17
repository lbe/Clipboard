package Clipboard::Xclip;

use strict;
use warnings;

use File::Spec ();

sub copy {
    my $self = shift;
    my ($input) = @_;
    return $self->copy_to_selection($self->favorite_selection, $input);
}

sub copy_to_all_selections {
    my $self = shift;
    my ($input) = @_;
    foreach my $sel ($self->all_selections) {
        $self->copy_to_selection($sel, $input);
    }
    return;
}

sub copy_to_selection {
    my $self = shift;
    my ($selection, $input) = @_;
    my $cmd = '|xclip -i -selection '. $selection;
    my $r = open my $exe, $cmd or die "Couldn't run `$cmd`: $!\n";
    print $exe $input;
    close $exe or die "Error closing `$cmd`: $!";

    return;
}
sub paste {
    my $self = shift;
    for ($self->all_selections) {
        my $data = $self->paste_from_selection($_);
        return $data if length $data;
    }
    return undef;
}
sub paste_from_selection {
    my $self = shift;
    my ($selection) = @_;
    my $cmd = "xclip -o -selection $selection|";
    open my $exe, $cmd or die "Couldn't run `$cmd`: $!\n";
    my $result = join '', <$exe>;
    close $exe or die "Error closing `$cmd`: $!";
    return $result;
}
# This ordering isn't officially verified, but so far seems to work the best:
sub all_selections { qw(primary buffer clipboard secondary) }
sub favorite_selection { my $self = shift; ($self->all_selections)[0] }

sub xclip_available {
    # close STDERR
    open my $olderr, '>&', \*STDERR;
    close STDERR;
    open STDERR, '>', File::Spec->devnull;

    my $open_retval = open my $just_checking, 'xclip -o|';

    # restore STDERR
    close STDERR;
    open STDERR, '>&', $olderr;
    close $olderr;

    return $open_retval;
}

{
  xclip_available() or warn <<'EPIGRAPH';

Can't find the 'xclip' script.  Clipboard.pm's X support depends on it.

Here's the project homepage: http://sourceforge.net/projects/xclip/

EPIGRAPH
}

1;
