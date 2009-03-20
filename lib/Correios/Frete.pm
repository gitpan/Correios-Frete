#!/usr/bin/perl

package Correios::Frete;

use strict;
use warnings;
use WWW::Mechanize;

use vars qw($VERSION);
use Carp;

$VERSION = '0.00001';

# TODO
use constant FRETE_PAC => '41106';
use constant FRETE_SEDEX => '40010';
use constant FRETE_SEDEX_10 => '40215';
use constant FRETE_SEDEX_HOJE => '40290';
use constant FRETE_E_SEDEX => '81019';
use constant FRETE_MALOTE => '44104';

our @EXPORT_OK = qw(\FRETE_PAC \FRETE_SEDEX);

sub new () {
	my ($class, %params) = @_;
	my $self = {};
	bless $self, $class;
	$self->_init(%params) or return undef;
	return $self;
}

sub service {
	my $self = shift;
	if (@_) { $self->{"_service"} = shift }
	return $self->{"_service"};
}

sub from {
	my $self = shift;
	if (@_) { $self->{"_from"} = shift }
	return $self->{"_from"};
}

sub to {
	my $self = shift;
	if (@_) { $self->{"_to"} = shift }
	return $self->{"_to"};
}

sub weight {
	my $self = shift;
	if (@_) { $self->{"_weight"} = shift }
	return $self->{"_weight"};
}

sub is_success {
	my $self = shift;
	return $self->{"_success"};
}

sub value {
	my $self = shift;
	if (@_) { $self->{"_value"} = shift }
	return $self->{"_value"};
}

sub get_price {
	my ($self, $service, $from, $to, $weight) = @_;
	$self->service($service) if($service);
	$self->from($from) if ($from);
	$self->to($to) if ($to);
	$self->weight($weight) if ($weight);
	
	my $parms = {};

	foreach(qw/service from to weight/) {
		$self->_croak("$_ not specified.") unless(defined $self->{"_$_"});
		$parms->{$_} = $self->{"_$_"};
	}

	my $url = $self->{"_baseurl"};
	$url .= '/encomendas/precos/calculo.cfm?';
	$url .= "Servico=$parms->{service}";
	$url .= "&cepOrigem=$parms->{from}";
	$url .= "&cepDestino=$parms->{to}";
	$url .= "&peso=$parms->{weight}";

	my $ua = $self->{"_ua"};
	my $response = $ua->get($url);

	#my @ll = $ua->links();
	# www::mechanize doesnt support JavaScript, maybe HTML::* 
	# do this better.
	my $new_link = $response->content;
	
	$new_link =~ s/\n//g;
	$new_link =~ s/^.*window.open\(\"(.*erro=)\".*/$1/;
	$url = $self->{"_baseurl"} . $new_link;
	
	$response = $ua->get($url);

	return if !$response->is_success;

	my $value = $response->content;
	$value =~ s/\n//g;
	$value =~ s/.*<b>R\$ ([0-9]*,[0-9]*).*/$1/;

	return if !$response->is_success;

	if ($response->is_success() && $value =~ /[0-9]*,[0-9]*/) {
		$self->{"_value"} = $value;
		$self->{"_success"} = 1;
	} else {
		$self->{"_success"} = 0;
	}

	return $self->is_success;
}

sub _init {
	my $self = shift;
	my %params = @_;

	my $ua = WWW::Mechanize->new(
		agent => __PACKAGE__." v. $VERSION",
	);

	my %options = (
		ua                => $ua,
		baseurl		  => 'http://www.correios.com.br',
		service           => undef,       
		from              => undef,       
		to                => undef,
		weight	 	  => undef,
		%params,
	);

	$self->{"_$_"} = $options{$_} foreach(keys %options);
	return $self;
}


sub _croak {
	my ($self, @error) = @_;
	Carp::croak(@error);
}

1;

__END__

=head1 NAME

Correios::Frete get the price to send with Correios (Brazilian Post-Office) your mail. 

=head1 SYNOPISIS

	use Correios::Frete;

	my $foo = new Correios::Frete;

	$foo->get_price('40215', '04002001', '04002002', 0.1);
	
	if ($foo->is_success) {
		print $foo->value;
	}

=head1 DESCRIPTION

Correios::Frete

=head1 METHODS

=head2 new

creates a new Correios::Frete object.

=head2 Options

=over 4

=item ua

Configure your own L<WWW::Mechanize> object, or use our default value.

=back

=head2 from

Set from cep.

=head2 to

Set to cep.

=head2 weight

Set the weight in kg.

=head2 service

Set the type of service.

	FRETE_PAC => '41106';
	FRETE_SEDEX => '40010';
	FRETE_SEDEX_10 => '40215';
	FRETE_SEDEX_HOJE => '40290';
	FRETE_E_SEDEX => '81019';
	FRETE_MALOTE => '44104';

=head2 get_price (service, from, to, weight)

Get the price!

=head2 is_success

Returns true when the last sending was successful and false when it failed.

=head2 value 

Returns the value.

=head1 AUTHOR

Thiago Rondon, E<lt>thiago@aware.com.brE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Thiago Rondon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
