package Test::Mock::Guard::Instance;

use strict;
use warnings;
use Exporter::Lite;
use Scalar::Util qw(refaddr);
use Test::Mock::Guard qw(mock_guard);

our $VERSION = '0.01';
our @EXPORT_OK = qw(mock_guard_instance mock_guard);

sub mock_guard_instance {
	my ($object, $methods) = @_;
	my $refaddr = refaddr $object;
	my $guard; $guard = mock_guard(ref($object), +{
		map {
			my $name = $_;
			$name => sub {
				if (refaddr $_[0] == $refaddr) {
					ref($methods->{$name}) eq 'CODE' ? $methods->{$name}->() : $methods->{$name}
				} else {
					$guard->{restore}->{ ref($object) }->{$name}->(@_);
				}
			}
		}
		keys %$methods
	});
}

1;
__END__

=encoding utf8

=head1 NAME

Test::Mock::Guard::Instance - 

=head1 SYNOPSIS

  use Test::Mock::Guard::Instance;


=head1 DESCRIPTION

Test::Mock::Guard::Instance is 

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
