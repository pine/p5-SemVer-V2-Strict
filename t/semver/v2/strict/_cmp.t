use strict;
use warnings;
use utf8;

use Scalar::Util qw/refaddr/;
use Test::Mock::Guard qw/mock_guard/;

use t::Util;
use SemVer::V2::Strict;

sub create_instance { SemVer::V2::Strict->new(@_) }

subtest basic => sub {
    subtest '# ==' => sub {
        my $a = create_instance('1.0.0-rc2');
        my $b = create_instance('1.0.0-rc2');

        is $a, $b;
    };

    subtest '# <=' => sub {
        my $v1 = create_instance('1.0.0-alpha');
        my $v2 = create_instance('1.0.0-alpha.1');
        my $v3 = create_instance('1.0.0-alpha.beta');
        my $v4 = create_instance('1.0.0-beta');
        my $v5 = create_instance('1.0.0-beta.2');
        my $v6 = create_instance('1.0.0-beta.11');
        my $v7 = create_instance('1.0.0-rc.1');
        my $v8 = create_instance('1.0.0');
        my $v9 = create_instance('2.0.0');

        cmp_ok $v1, '<', $v2;
        cmp_ok $v2, '<', $v3;
        cmp_ok $v3, '<', $v4;
        cmp_ok $v4, '<', $v5;
        cmp_ok $v5, '<', $v6;
        cmp_ok $v6, '<', $v7;
        cmp_ok $v7, '<', $v8;
        cmp_ok $v8, '<', $v9;
    };
};

done_testing;
