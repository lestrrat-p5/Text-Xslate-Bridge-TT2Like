use strict;
use Test::More;
use t::TT2LikeTest qw(render_ok);

use_ok "Text::Xslate";
use_ok "Text::Xslate::Bridge::TT2Like";

# note(Text::Xslate::Bridge::TT2Like->dump);

render_ok q{[% "foo\n\nbar" | html_para | mark_raw %]}, undef, "<p>\nfoo\n</p>\n\n<p>\nbar</p>\n";
render_ok q{[% "foo\n\nbar" | html_para | mark_raw %]}, undef, "<p>\nfoo\n</p>\n\n<p>\nbar</p>\n";
render_ok q{[% "foo\n\nbar" | html_break | mark_raw %]}, undef, "foo\n<br />\n<br />\nbar";
render_ok q{[% "foo\n\nbar" | html_para_break | mark_raw %]}, undef, "foo\n<br />\n<br />\nbar";
render_ok q{[% "foo\n\nbar" | html_line_break | mark_raw %]}, undef, "foo<br />\n<br />\nbar";
render_ok q{[% "&'" | xml  | mark_raw %]}, undef, "&amp;&apos;";
render_ok q{[% "my file.html" | uri  | mark_raw %]}, undef, "my%20file.html";
render_ok q{[% "my file.html" | url  | mark_raw %]}, undef, "my%20file.html";
render_ok '[% "foo" | upper %]', undef, "FOO", "foo.uc";
render_ok '[% "fOo" | lower %]', undef, "foo", "foo.lc";
render_ok '[% "foo" | ucfirst %]', undef, "Foo";
render_ok '[% "FOO" | lcfirst %]', undef, "fOO";
render_ok '[% "  FOO  " | trim %]', undef, "FOO";
render_ok '[% "  I am    a  pen.  " | collapse %]', undef, "I am a pen.";


done_testing();
