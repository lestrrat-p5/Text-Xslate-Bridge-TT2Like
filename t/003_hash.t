use strict;
use Test::More;
use t::TT2LikeTest qw(render_xslate render_ok);

use_ok "Text::Xslate";
use_ok "Text::Xslate::Bridge::TT2Like";

render_ok '[% hashmap.item("abc") %]', undef, "def", "hashmap.item";
render_ok '[% hashmap.size() %]', undef, 2, "hashmap.size";
render_ok '[% IF (hashmap.exists("abc")) %]exists[% ELSE %]not there[% END %]', undef, "exists", "hashmap.exists (MATCH)";
render_ok '[% IF (hashmap.exists("foo")) %]exists[% ELSE %]not there[% END %]', undef, "not there", "hashmap.exists (NO MATCH)";
render_ok '[% hashmap.defined() %]', undef, 1, "hashmap.defined";
render_ok '[% CALL hashmap.delete("abc"); FOREACH pair IN hashmap.pairs() %][% pair.key %]:[% pair.value %],[% END %]', undef, 'ghi:jkl,', 'hashmap.delete';
render_ok '[% FOREACH key IN hashmap.sort() %][% key %],[% END %]', undef, "abc,ghi,", "hashmap.sort";
render_ok '[% FOREACH key IN hashmap.keys().sort() %][% key %],[% END %]', undef, 'abc,ghi,', 'hashmap.keys';

{
    my $output = render_xslate '[% FOREACH pair IN hashmap.pairs() %][% pair.key %]:[% pair.value %],[% END %]';
    like $output, qr/abc:def,/, "hashmap.pairs";
    like $output, qr/ghi:jkl,/, "hashmap.pairs";
}

done_testing();