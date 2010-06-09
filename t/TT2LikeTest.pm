package 
    t::TT2LikeTest;
use Exporter 'import';
use Test::More ();
use Text::Xslate;
use Text::Xslate::Bridge::TT2Like;

our @EXPORT_OK = qw(render_xslate render_ok);

our $XSLATE = Text::Xslate->new(
    syntax   => 'TTerse',
    module   => [ 'Text::Xslate::Bridge::TT2Like' ],
);

sub render_xslate {
    my ($template, $args) = @_;
    $args ||= {
        foo => "foo",
        foobar => "foo bar",
        strings => [ "abc", "def", "ghi", "jkl" ],
        numbers => [ 1, 2, 3, 4, 5 ],
        hashmap => {
            abc => "def",
            ghi => "jkl",
        }
    };
    $XSLATE->render_string( $template, $args ),
}

sub render_ok {
    my ($template, $args, $expect, $name) = @_;


    local $Test::Builder::Level = $Test::Builder::Level + 1;
    Test::More::is(
        render_xslate( $template, $args ),
        $expect,
        $name
    );
}

1;