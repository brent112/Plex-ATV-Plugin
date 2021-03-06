package Ivar;
use strict;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	$self->{NAME} = shift;
	$self->{TYPE} = shift;
	$self->{CLASS} = undef;
	bless($self, $class);
	return $self;
}

##################### #
# Setters and Getters #
# #####################
sub name {
	my $self = shift;
	if(@_) { $self->{NAME} = shift; }
	return $self->{NAME};
}

sub type {
	my $self = shift;
	if(@_) { $self->{TYPE} = shift; }
	return $self->{TYPE};
}

sub class {
	my $self = shift;
	if(@_) { $self->{CLASS} = shift; }
	return $self->{CLASS};
}
##### #
# END #
# #####

sub initializers {
	my $self = shift;
	return "class_addIvar(\$".$self->class->name.", \"".$self->{NAME}."\", sizeof(".$self->{TYPE}."), 0, \@encode(".$self->{TYPE}.")); ";
}

1;
