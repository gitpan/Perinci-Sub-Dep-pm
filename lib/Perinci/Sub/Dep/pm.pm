package Perinci::Sub::Dep::pm;

use 5.010;
use strict;
use warnings;

use Perinci::Util qw(declare_function_dep);

our $VERSION = '0.28'; # VERSION

declare_function_dep(
    name => 'pm',
    schema => ['str*' => {}],
    check => sub {
        my ($val) = @_;
        my $m = $val;
        my $wv; # wanted version
        $m =~ s/\s*(?:>=)\s*([0-9]\S*)$// and $wv = $1;
        $m =~ s!::!/!g;
        $m .= ".pm";
        eval { require $m };
        my $e = $@;
        return "Can't load module $val" if $e;
        no strict 'refs';
        if (defined $wv) {
            require Sort::Versions;
            my $mv = ${"$m\::VERSION"};
            defined($mv) or return "Can't get version from $m";
            return "Version of $m too old ($mv, wanted $wv)"
                if Sort::Versions::versioncmp($wv, $mv) < 0;
        }
        "";
    }
);

1;
# ABSTRACT: Depend on a Perl module


__END__
=pod

=head1 NAME

Perinci::Sub::Dep::pm - Depend on a Perl module

=head1 VERSION

version 0.28

=head1 SYNOPSIS

 # in function metadata
 deps => {
     ...
     pm => 'Foo::Bar',
 }

 # specify version requirement
 deps => {
     ...
     pm => 'Foo::Bar >= 0.123',
 }

 # specify multiple modules
 deps => {
     all => [
         {pm => 'Foo'},
         {pm => 'Bar >= 1.23'},
         {pm => 'Baz'},
     ],
 }

 # specify alternatives
 deps => {
     any => [
         {pm => 'Qux'},
         {pm => 'Quux'},
     ],
 }

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

