package Test::Mock::Guard::Instance;

use strict;
use warnings;
use Exporter::Lite;
use Scalar::Util qw(refaddr blessed);
use Carp;

our $VERSION = '0.01';
our @EXPORT_OK = qw(mock_guard_instance);

sub mock_guard_instance {
	my ($object, $methods) = @_;
	blessed($object) or croak "blessed object required";
	__PACKAGE__->new($object, $methods);
}

my $mocked = {};

sub new {
	my ($class, $object, $methods) = @_;
	my $klass   = ref($object);
	my $refaddr = refaddr($object);

	$mocked->{$klass}->{_mocked} ||= {};

	for my $method (keys %$methods) {
		unless ($mocked->{$klass}->{_mocked}->{$method}) {
			$mocked->{$klass}->{_mocked}->{$method} = $klass->can($method);
			no strict 'refs';
			no warnings 'redefine';
			*{"$klass\::$method"} = sub { _mocked($method, @_) };
		}
	}

	$mocked->{$klass}->{$refaddr} = $methods;

	bless +{ object => $object }, $class;
}

sub _mocked {
	my ($method, $object, @rest) = @_;
	my $klass   = ref($object);
	my $refaddr = refaddr($object);
	if (exists $mocked->{$klass}->{$refaddr} && exists $mocked->{$klass}->{$refaddr}->{$method}) {
		my $val = $mocked->{$klass}->{$refaddr}->{$method};
		ref($val) eq 'CODE' ? $val->($object, @rest) : $val;
	} else {
		$mocked->{$klass}->{_mocked}->{$method}->($object, @rest);
	}
}

sub DESTROY {
	my ($self) = @_;
	my $object  = $self->{object};
	my $klass   = ref($object);
	my $refaddr = refaddr($object);
	delete $mocked->{$klass}->{$refaddr};

	unless (keys %{ $mocked->{$klass} } == 1) {
		my $mocked = delete $mocked->{$klass}->{_mocked};
		for my $method (keys %$mocked) {
			no strict 'refs';
			no warnings 'redefine';
			*{"$klass\::$method"} = $mocked->{$method};
		}
	}
}

1;
__END__

=encoding utf8

=head1 NAME

Test::Mock::Guard::Instance - Mock methods of an instance.

=head1 SYNOPSIS

  use Test::Mock::Guard::Instance qw(mock_guard_instance);

  { package Some::Class;
      sub new { bless {} => shift }
      sub foo { "foo" }
      sub bar { 1 }
  };

  my $obj1 = Some::Class->new;

  {
      my $guard1 = mock_guard_instance($obj1, +{ foo => sub { "bar" }, bar => 10 } );
      is $obj1->foo, "bar";
      is $obj1->bar, 10;

      my $another = Some::Class->new;
      is $another->foo, "foo";
      is $another->bar, 1;
  };

  is $obj1->foo, "foo";
  is $obj1->bar, 1;

=head1 DESCRIPTION

Test::Mock::Guard::Instance is instance-scoped Test::Mock::Guard.

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
