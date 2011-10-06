package DBIx::Class::IndexSearch::Dezi;
use Moose; 
use MooseX::ClassAttribute;
use Carp;
extends 'DBIx::Class';


=head1 NAME

DBIx::Class::IndexSearch::Dezi - The great new DBIx::Class::IndexSearch::Dezi!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    package MyApp::Schema::Person; {
    use base 'DBIx::Class';
    
    __PACKAGE__->load_components(qw[
        IndexSearch::Dezi
        PK::Auto
        Core
        TimeStamp
    ]);
    
    __PACKAGE__->table('person');
    
    __PACKAGE__->add_columns(
        person_id => {
            data_type       => 'varchar',
            size            => '36',
            is_nullable     => 0,
        },
        name => {
            data_type => 'varchar',
            is_nullable => 0,
            indexed => 1 
        },
        age => {
            data_type => 'integer',
            is_nullable => 0,
        },
        email => {
            data_type => 'varchar',
            size=>'128',
        },
        created => {
            data_type => 'timestamp',
            set_on_create => 1,
            is_nullable => 0,
        },
    );
    
    __PACKAGE__->resultset_class('DBIx::Class::IndexSearch::ResultSet::Dezi');
    __PACKAGE__->belongs_to_index('FooClient', { server => 'http://localhost:6000', map_to => 'person_id' });

=head1 ATTRIBUTES

=head2 index_fields 

Registers index fields.

=cut
class_has 'index_fields' => ( 
    traits  => ['Hash'],
    is      => 'rw', 
    isa     => 'HashRef[Str]', 
    default => sub { {} },
    handles =>  {
        set_index_field => 'set',
        get_index_field => 'get',
        get_index_keys  => 'keys',
        index_key_exist => 'exists',
    } 
);

class_has 'webservice_class' => (
    is      => 'rw' 
);

class_has 'query_parameters' => (
    is      => 'rw' 
);

class_has 'map_to' => (
    is      => 'rw'
);

class_has 'webservice' => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_webservice'
);

sub _build_webservice {
    my ( $class ) = @_;

    my $package_name    = $class->webservice_class;
        
    eval "require $package_name";
    croak "Failed to load indexer: $@" if $@;

    return $package_name->new( server => $class->query_parameters->{server} ) ;
}

=head1 SUBROUTINES/METHODS

=head2 register_column ( $column, \%info )

Overrides DBIx::Class's C<register_column>. If %info contains
the key 'indexed', calls C<register_field>.

=cut

sub register_column {
    my ( $class, $column, $info ) = @_;

    $class->next::method( $column, $info );
    
    if (exists $info->{ indexed }) {
        $class->set_index_field( $column => $info->{ indexed } );
    }
    
}

=head2 register_column ( $class, $webservice_class, \%parameters )

This sets up the the webservice to use and maps the webservice index
to the DB.

=cut

sub belongs_to_index {
    my ( $class, $webservice_class, $parameters ) = @_;

    croak 'Please specify a webservice' if !$webservice_class;
    croak 'Please supply hostname ' if !$parameters->{server};
    croak 'Please supply map_to ' if !$parameters->{map_to};

    $class->webservice_class( $webservice_class );
    $class->query_parameters( $parameters || {} );
    $class->map_to( $parameters->{map_to} || '' );
}

=head1 AUTHOR

Logan Bell, C<< <loganbell at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-class-indexsearch-dezi at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-Class-IndexSearch-Dezi>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::Class::IndexSearch::Dezi


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-Class-IndexSearch-Dezi>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-Class-IndexSearch-Dezi>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-Class-IndexSearch-Dezi>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-Class-IndexSearch-Dezi/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Logan Bell.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of DBIx::Class::IndexSearch::Dezi
