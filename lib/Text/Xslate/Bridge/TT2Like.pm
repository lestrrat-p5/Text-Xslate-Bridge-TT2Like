package Text::Xslate::Bridge::TT2Like;
use strict;
use warnings;
use base qw(Text::Xslate::Bridge);
use 5.008001;

use Scalar::Util 'blessed';
use URI::Escape qw/uri_escape/;

our $VERSION = '0.00002';

__PACKAGE__->bridge(
    scalar => {
        item    => \&text_item,
        list    => \&text_list,
        hash    => \&text_hash,
        length  => \&text_length,
        size    => \&text_size,
        defined => \&text_defined,
        match   => \&text_match,
        search  => \&text_search,
        repeat  => \&text_repeat,
        replace => \&text_replace,
        remove  => \&text_remove,
        split   => \&text_split,
        chunk   => \&text_chunk,
        substr  => \&text_substr,
    },
    hash => {
        item    => \&hash_item,
        hash    => \&hash_hash,
        size    => \&hash_size,
        each    => \&hash_each,
        keys    => \&hash_keys,
        values  => \&hash_values,
        items   => \&hash_items,
        pairs   => \&hash_pairs,
        list    => \&hash_list,
        exists  => \&hash_exists,
        defined => \&hash_defined,
        delete  => \&hash_delete,
        import  => \&hash_import,
        sort    => \&hash_sort,
        nsort   => \&hash_nsort,
    },
    array => {
        item    => \&list_item,
        list    => \&list_list,
        hash    => \&list_hash,
        push    => \&list_push,
        pop     => \&list_pop,
        unshift => \&list_unshift,
        shift   => \&list_shift,
        max     => \&list_max,
        size    => \&list_size,
        defined => \&list_defined,
        first   => \&list_first,
        last    => \&list_last,
        reverse => \&list_reverse,
        grep    => \&list_grep,
        join    => \&list_join,
        sort    => \&list_sort,
        nsort   => \&list_nsort,
        unique  => \&list_unique,
        import  => \&list_import,
        merge   => \&list_merge,
        slice   => \&list_slice,
        splice  => \&list_splice,
    },
    function => {
        # 'html'            => \&html_filter, # Xslate has builtin filter for html escape, and it is not overridable.
        'html_para'       => \&html_paragraph,
        'html_break'      => \&html_para_break,
        'html_para_break' => \&html_para_break,
        'html_line_break' => \&html_line_break,
        'xml'             => \&xml_filter,
        'uri'             => \&uri_escape,
        'url'             => \&uri_escape,
        'upper'           => sub { uc $_[0] },
        'lower'           => sub { lc $_[0] },
        'ucfirst'         => sub { ucfirst $_[0] },
        'lcfirst'         => sub { lcfirst $_[0] },
        # 'stderr'          => sub { print STDERR @_; return '' }, # anyone want this??
        'trim'            => sub { for ($_[0]) { s/^\s+//; s/\s+$// }; $_[0] },
        'null'            => sub { return '' },
        'collapse'        => sub { for ($_[0]) { s/^\s+//; s/\s+$//; s/\s+/ /g };
                                $_[0] },
    },
);

sub text_item {
    $_[0];
}

sub text_list { 
    [ $_[0] ];
}

sub text_hash { 
    { value => $_[0] };
}

sub text_length { 
    length $_[0];
}

sub text_size { 
    return 1;
}

sub text_defined { 
    return 1;
}

sub text_match {
    my ($str, $search, $global) = @_;
    return $str unless defined $str and defined $search;
    my @matches = $global ? ($str =~ /$search/g)
        : ($str =~ /$search/);
    return @matches ? \@matches : '';
}

sub text_search { 
    my ($str, $pattern) = @_;
    return $str unless defined $str and defined $pattern;
    return $str =~ /$pattern/;
}

sub text_repeat { 
    my ($str, $count) = @_;
    $str = '' unless defined $str;  
    return '' unless $count;
    $count ||= 1;
    return $str x $count;
}

sub text_replace {
    my ($text, $pattern, $replace, $global) = @_;
    $text    = '' unless defined $text;
    $pattern = '' unless defined $pattern;
    $replace = '' unless defined $replace;
    $global  = 1  unless defined $global;

    if ($replace =~ /\$\d+/) {
        # replacement string may contain backrefs
        my $expand = sub {
            my ($chunk, $start, $end) = @_;
            $chunk =~ s{ \\(\\|\$) | \$ (\d+) }{
                $1 ? $1
                    : ($2 > $#$start || $2 == 0) ? '' 
                    : substr($text, $start->[$2], $end->[$2] - $start->[$2]);
            }exg;
            $chunk;
        };
        if ($global) {
            $text =~ s{$pattern}{ &$expand($replace, [@-], [@+]) }eg;
        } 
        else {
            $text =~ s{$pattern}{ &$expand($replace, [@-], [@+]) }e;
        }
    }
    else {
        if ($global) {
            $text =~ s/$pattern/$replace/g;
        } 
        else {
            $text =~ s/$pattern/$replace/;
        }
    }
    return $text;
}

sub text_remove { 
    my ($str, $search) = @_;
    return $str unless defined $str and defined $search;
    $str =~ s/$search//g;
    return $str;
}
    
sub text_split {
    my ($str, $split, $limit) = @_;
    $str = '' unless defined $str;
    
    # we have to be very careful about spelling out each possible 
    # combination of arguments because split() is very sensitive
    # to them, for example C<split(' ', ...)> behaves differently 
    # to C<$space=' '; split($space, ...)>
    
    if (defined $limit) {
        return [ defined $split 
                 ? split($split, $str, $limit)
                 : split(' ', $str, $limit) ];
    }
    else {
        return [ defined $split 
                 ? split($split, $str)
                 : split(' ', $str) ];
    }
}

sub text_chunk {
    my ($string, $size) = @_;
    my @list;
    $size ||= 1;
    if ($size < 0) {
        # sexeger!  It's faster to reverse the string, search
        # it from the front and then reverse the output than to 
        # search it from the end, believe it nor not!
        $string = reverse $string;
        $size = -$size;
        unshift(@list, scalar reverse $1) 
            while ($string =~ /((.{$size})|(.+))/g);
    }
    else {
        push(@list, $1) while ($string =~ /((.{$size})|(.+))/g);
    }
    return \@list;
}

sub text_substr {
    my ($text, $offset, $length, $replacement) = @_;
    $offset ||= 0;
    
    if(defined $length) {
        if (defined $replacement) {
            substr( $text, $offset, $length, $replacement );
            return $text;
        }
        else {
            return substr( $text, $offset, $length );
        }
    }
    else {
        return substr( $text, $offset );
    }
}

sub hash_item { 
    my ($hash, $item) = @_; 
    $item = '' unless defined $item;
    $hash->{ $item };
}

sub hash_hash { 
    $_[0];
}

sub hash_size { 
    scalar keys %{$_[0]};
}

sub hash_each { 
    # this will be changed in TT3 to do what hash_pairs() does
    [ %{ $_[0] } ];
}

sub hash_keys { 
    [ keys   %{ $_[0] } ];
}

sub hash_values { 
    [ values %{ $_[0] } ];
}

sub hash_items {
    [ %{ $_[0] } ];
}

sub hash_pairs { 
    [ map { 
        { key => $_ , value => $_[0]->{ $_ } } 
      }
      sort keys %{ $_[0] } 
    ];
}

sub hash_list { 
    my ($hash, $what) = @_;  
    $what ||= '';
    return ($what eq 'keys')   ? [   keys %$hash ]
        :  ($what eq 'values') ? [ values %$hash ]
        :  ($what eq 'each')   ? [        %$hash ]
        :  # for now we do what pairs does but this will be changed 
           # in TT3 to return [ $hash ] by default
        [ map { { key => $_ , value => $hash->{ $_ } } }
          sort keys %$hash 
          ];
}

sub hash_exists { 
    exists $_[0]->{ $_[1] };
}

sub hash_defined { 
    # return the item requested, or 1 if no argument 
    # to indicate that the hash itself is defined
    my $hash = shift;
    return @_ ? defined $hash->{ $_[0] } : 1;
}

sub hash_delete { 
    my $hash = shift; 
    delete $hash->{ $_ } for @_;
}

sub hash_import { 
    my ($hash, $imp) = @_;
    $imp = {} unless ref $imp eq 'HASH';
    @$hash{ keys %$imp } = values %$imp;
    return '';
}

sub hash_sort {
    my ($hash) = @_;
    [ sort { lc $hash->{$a} cmp lc $hash->{$b} } (keys %$hash) ];
}

sub hash_nsort {
    my ($hash) = @_;
    [ sort { $hash->{$a} <=> $hash->{$b} } (keys %$hash) ];
}

sub list_item {
    $_[0]->[ $_[1] || 0 ];
}

sub list_list { 
    $_[0];
}

sub list_hash { 
    my $list = shift;
    if (@_) {
        my $n = shift || 0;
        return { map { ($n++, $_) } @$list }; 
    }
    no warnings;
    return { @$list };
}

sub list_push {
    my $list = shift; 
    push(@$list, @_); 
    return '';
}

sub list_pop {
    my $list = shift; 
    pop(@$list);
}

sub list_unshift {
    my $list = shift; 
    unshift(@$list, @_); 
    return '';
}

sub list_shift {
    my $list = shift; 
    shift(@$list);
}

sub list_max {
    no warnings;
    my $list = shift; 
    $#$list; 
}

sub list_size {
    no warnings;
    my $list = shift; 
    $#$list + 1; 
}

sub list_defined {
    # return the item requested, or 1 if no argument to 
    # indicate that the hash itself is defined
    my $list = shift;
    return @_ ? defined $list->[$_[0]] : 1;
}

sub list_first {
    my $list = shift;
    return $list->[0] unless @_;
    return [ @$list[0..$_[0]-1] ];
}

sub list_last {
    my $list = shift;
    return $list->[-1] unless @_;
    return [ @$list[-$_[0]..-1] ];
}

sub list_reverse {
    my $list = shift; 
    [ reverse @$list ];
}

sub list_grep {
    my ($list, $pattern) = @_;
    $pattern ||= '';
    return [ grep /$pattern/, @$list ];
}

sub list_join {
    my ($list, $joint) = @_; 
    join(defined $joint ? $joint : ' ', 
         map { defined $_ ? $_ : '' } @$list);
}

sub _list_sort_make_key {
   my ($item, $fields) = @_;
   my @keys;

   if (ref($item) eq 'HASH') {
       @keys = map { $item->{ $_ } } @$fields;
   }
   elsif (blessed $item) {
       @keys = map { $item->can($_) ? $item->$_() : $item } @$fields;
   }
   else {
       @keys = $item;
   }
   
   # ugly hack to generate a single string using a delimiter that is
   # unlikely (but not impossible) to be found in the wild.
   return lc join('/*^UNLIKELY^*/', map { defined $_ ? $_ : '' } @keys);
}

sub list_sort {
    my ($list, @fields) = @_;
    return $list unless @$list > 1;         # no need to sort 1 item lists
    return [ 
        @fields                          # Schwartzian Transform 
        ?   map  { $_->[0] }                # for case insensitivity
            sort { $a->[1] cmp $b->[1] }
            map  { [ $_, _list_sort_make_key($_, \@fields) ] }
            @$list
        :  map  { $_->[0] }
           sort { $a->[1] cmp $b->[1] }
           map  { [ $_, lc $_ ] } 
           @$list,
    ];
}

sub list_nsort {
    my ($list, @fields) = @_;
    return $list unless @$list > 1;     # no need to sort 1 item lists
    return [ 
        @fields                         # Schwartzian Transform 
        ?  map  { $_->[0] }             # for case insensitivity
           sort { $a->[1] <=> $b->[1] }
           map  { [ $_, _list_sort_make_key($_, \@fields) ] }
           @$list 
        :  map  { $_->[0] }
           sort { $a->[1] <=> $b->[1] }
           map  { [ $_, lc $_ ] } 
           @$list,
    ];
}

sub list_unique {
    my %u; 
    [ grep { ++$u{$_} == 1 } @{$_[0]} ];
}

sub list_import {
    my $list = shift;
    push(@$list, grep defined, map ref eq 'ARRAY' ? @$_ : undef, @_);
    return $list;
}

sub list_merge {
    my $list = shift;
    return [ @$list, grep defined, map ref eq 'ARRAY' ? @$_ : undef, @_ ];
}

sub list_slice {
    my ($list, $from, $to) = @_;
    $from ||= 0;
    $to    = $#$list unless defined $to;
    $from += @$list if $from < 0;
    $to   += @$list if $to   < 0;
    return [ @$list[$from..$to] ];
}

sub list_splice {
    my ($list, $offset, $length, @replace) = @_;
    if (@replace) {
        # @replace can contain a list of multiple replace items, or 
        # be a single reference to a list
        @replace = @{ $replace[0] }
        if @replace == 1 && ref $replace[0] eq 'ARRAY';
        return [ splice @$list, $offset, $length, @replace ];
    }
    elsif (defined $length) {
        return [ splice @$list, $offset, $length ];
    }
    elsif (defined $offset) {
        return [ splice @$list, $offset ];
    }
    else {
        return [ splice(@$list) ];
    }
}

sub xml_filter {
    my $text = shift;
    for ($text) {
        s/&/&amp;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
        s/"/&quot;/g;
        s/'/&apos;/g;
    }
    return $text;
}

sub html_paragraph  {
    my $text = shift;
    return "<p>\n" 
           . join("\n</p>\n\n<p>\n", split(/(?:\r?\n){2,}/, $text))
           . "</p>\n";
}

sub html_para_break  {
    my $text = shift;
    $text =~ s|(\r?\n){2,}|$1<br />$1<br />$1|g;
    return $text;
}

sub html_line_break  {
    my $text = shift;
    $text =~ s|(\r?\n)|<br />$1|g;
    return $text;
}

1;

__END__

=head1 NAME

Text::Xslate::Bridge::TT2Like - TT2 Variable Method Clone For Text::Xslate

=head1 SYNOPSIS

    use Text::Xslate;

    my $xslate = Text::Xslate->new(
        module => [
            'Text::Xslate::Bridge::TT2Like'
        ],
    );

    # Note that all methods require a set of parenthesis to be
    # recognized as a method.
    $xslate->render_string(
        '<: $foo.length() :>',
        { foo => "foo" }
    );

    $xslate->render_string(
        '<: $foo.replace("foo", "bar") :>',
        { foo => "foo" }
    );

=head1 DESCRIPTION

Text::Xslate::Bridge::TT2Like exports Template-Toolkit variable methods into
Text::Xslate namespace, such that you can use them on your variables.

The only difference between this module and Text::Xslate::Bridge::TT2 is that
Bridge::TT2 uses Template::Toolkit underneath, while this module is independent
of Template::Toolkit and therefore does not require TT to be installed

=head1 ACKNOWLEDGEMENT

Original code was taken from Template::VMethods, Template::Filters by Andy Wardley.

=head1 AUTHOR

Copyright (c) 2010 Daisuke Maki C<< <daisuke@endeworks.jp> >>

=head1 LICENSE 

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
