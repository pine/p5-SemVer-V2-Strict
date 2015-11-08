package Semver::V2::Strict;
use strict;
use warnings;
use utf8;

our $VERSION = "0.01";

use constant PRE_RELEASE_FORMAT    => qr/(?:-(?<pre_release>[a-zA-Z0-9.\-]+))?/;
use constant BUILD_METADATA_FORMAT => qr/(?:\+(?<build_metadata>[a-zA-Z0-9.\-]+))?/;
use constant VERSION_FORMAT        =>
    qr/(?<major>[0-9]+)(?:\.(?<minor>[0-9]+))?(?:\.(?<patch>[0-9]+))?@{[PRE_RELEASE_FORMAT]}@{[BUILD_METADATA_FORMAT]}/;

use List::Util qw/min max/;
use Scalar::Util qw/looks_like_number/;

use overload (
    q{""}    => \&as_string,
    q{<=>}   => \&_cmp,
    fallback => 1,
);

sub major          { shift->{major} }
sub minor          { shift->{minor} }
sub patch          { shift->{patch} }
sub pre_release    { shift->{pre_release} }
sub build_metadata { shift->{build_metadata} }

sub new {
    my $class = shift;
    my $self  = bless {} => $class;

    $self->_init_by_version_numbers     if @_ == 0;
    $self->_init_by_version_string(@_)  if @_ == 1;
    $self->_init_by_version_numbers(@_) if @_ >= 2;

    return $self;
}

sub _init_by_version_string {
    my ($self, $version) = @_;

    die 'Invalid format' unless $version =~ VERSION_FORMAT;

    $self->{major}          = $+{major};
    $self->{minor}          = $+{minor} // 0;
    $self->{patch}          = $+{patch} // 0;
    $self->{pre_release}    = $+{pre_release};
    $self->{build_metadata} = $+{build_metadata};
}

sub _init_by_version_numbers {
    my ($self, $major, $minor, $patch, $pre_release, $build_metadata) = @_;

    $self->{major}          = $major // 0;
    $self->{minor}          = $minor // 0;
    $self->{patch}          = $patch // 0;
    $self->{pre_release}    = $pre_release;
    $self->{build_metadata} = $build_metadata;
}

sub as_string {
    my $self = shift;

    my $string = $self->major.'.'.$self->minor.'.'.$self->patch;
    $string .= '-'.$self->pre_release    if $self->pre_release;
    $string .= '+'.$self->build_metadata if $self->build_metadata;

    return $string;
}

sub _cmp {
    my ($self, $other) = @_;

    return $self->major <=> $other->major if $self->major != $other->major;
    return $self->minor <=> $other->minor if $self->minor != $other->minor;
    return $self->patch <=> $other->patch if $self->patch != $other->patch;
    return $self->_compare_pre_release($self->pre_release, $other->pre_release);
}

sub _compare_pre_release {
    my ($a, $b) = @_;

    return  1 if !defined $a && $b;
    return -1 if $a && !defined $b;

    if ($a && $b) {
        my @left  = split /-|\./, $a;
        my @right = split /-|\./, $b;
        my $max   = max(scalar @left, scalar @right);

        for (my $i = 0; $i < $max; ++$i) {
            my $a = $left[$i]  // 0;
            my $b = $right[$i] // 0;

            if (looks_like_number($a) && looks_like_number($b)) {
                return $a <=> $b if $a != $b;
            }

            my $min = min(length $a, length $b);
            for (my $n = 0; $n < $min; ++$n) {
                my $c = substr($a, $n, 1) cmp substr($b, $n, 1);
                return $c if $c != 0;
            }
        }
    }

    return 0;
}

1;
__END__

=encoding utf-8

=head1 NAME

Semver::V2::Strict - It's new $module

=head1 SYNOPSIS

    use Semver::V2::Strict;

=head1 DESCRIPTION

Semver::V2::Strict is ...

=head1 LICENSE

Copyright (C) Pine Mizune.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Pine Mizune E<lt>pinemz@gmail.comE<gt>

=cut

