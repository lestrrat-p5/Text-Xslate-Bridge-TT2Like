use inc::Module::Install;

name 'Text-Xslate-Bridge-TT2Like';
all_from 'lib/Text/Xslate/Bridge/TT2Like.pm';

requires 'Text::Xslate';
requires 'Scalar::Util';

WriteAll;