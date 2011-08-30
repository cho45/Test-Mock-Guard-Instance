use strict;
use warnings;

use Test::More;
use Test::Name::FromLine;
use Test::Mock::Guard::Instance qw(mock_guard_instance);

{ package Some::Class;
	sub new { bless {} => shift }
	sub foo { "foo" }
	sub bar { 1 }
};


{
	my $obj1 = Some::Class->new;
	my $guard1 = mock_guard_instance($obj1, +{ foo => sub { "bar" }, bar => 10 } );
	is $obj1->foo, "bar";
	is $obj1->bar, 10;

	my $obj2 = Some::Class->new;
	my $guard2 = mock_guard_instance($obj2, +{ foo => sub { "baz" }, bar => 20 } );
	is $obj2->foo, "baz";
	is $obj2->bar, 20;

	is $obj1->foo, "bar";
	is $obj1->bar, 10;

	my $another = Some::Class->new;
	is $another->foo, "foo";
	is $another->bar, 1;
}

my $outofscope = Some::Class->new;
is $outofscope->foo, "foo";
is $outofscope->bar, 1;

done_testing;
