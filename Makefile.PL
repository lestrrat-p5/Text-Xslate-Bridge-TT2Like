use inc::Module::Install;

name 'Text-Xslate-Bridge-TT2Like';
all_from 'lib/Text/Xslate/Bridge/TT2Like.pm';

requires 'Text::Xslate' => '0.1045';
requires 'Scalar::Util';
requires 'URI::Escape';

WriteAll;
