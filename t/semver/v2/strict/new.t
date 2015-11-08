use strict;
use warnings;
use utf8;

use Test::Mock::Guard qw/mock_guard/;

use t::Util;
use Semver::V2::Strict;

subtest basic => sub {
    subtest '# 0' => sub {
        my $guard = mock_guard('Semver::V2::Strict', {
            _init_by_version_numbers => sub { is @_, 1 },
            _init_by_version_string  => sub { },
        });

        Semver::V2::Strict->new;

        is $guard->call_count('Semver::V2::Strict', '_init_by_version_numbers'), 1;
        is $guard->call_count('Semver::V2::Strict', '_init_by_version_string'),  0;
    };

    subtest '# 1' => sub {
        my $guard = mock_guard('Semver::V2::Strict', {
            _init_by_version_numbers => sub { },
            _init_by_version_string  => sub {
                isa_ok $_[0], 'Semver::V2::Strict';
                is     $_[1], '1.2.3';
            },
        });

        Semver::V2::Strict->new('1.2.3');

        is $guard->call_count('Semver::V2::Strict', '_init_by_version_numbers'), 0;
        is $guard->call_count('Semver::V2::Strict', '_init_by_version_string'),  1;
    };

    subtest '# > 2' => sub {
        my $guard = mock_guard('Semver::V2::Strict', {
            _init_by_version_numbers => sub {
                isa_ok shift, 'Semver::V2::Strict';
                cmp_deeply [ @_ ], [ 1, 2, 3, 'alpha', '100' ];
            },
            _init_by_version_string  => sub { },
        });

        Semver::V2::Strict->new(1, 2, 3, 'alpha', '100');

        is $guard->call_count('Semver::V2::Strict', '_init_by_version_numbers'), 1;
        is $guard->call_count('Semver::V2::Strict', '_init_by_version_string'),  0;
    };
};

done_testing;
