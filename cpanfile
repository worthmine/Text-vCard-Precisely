requires 'perl', 'v5.12.5';

requires 'Moo',              '2.003';
requires 'Type::Tiny',       '1.004';
requires 'MooX::HandlesVia', '0.001009';
requires 'Email::Valid',     '1.202';
requires 'DateTime::TimeZone', '2.19';

requires 'Data::UUID',          '1.226';
requires 'URI',                 '1.76';
requires 'Data::Validate::URI', '0.07';
requires 'Path::Tiny',          '0.114';
requires 'Text::LineFold',      '2018.012';
requires 'Text::vFile::asData', '0.08';

on 'test' => sub {
    requires 'Test::More';
    requires 'Data::Section::Simple', '0.07';
    requires 'Text::Diff',            '1.45';
};

