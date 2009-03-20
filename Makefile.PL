use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	NAME              => 'Correios::Frete',
        DISTNAME          => 'Correios-Frete',
	VERSION_FROM      => 'lib/Correios/Frete.pm', # finds $VERSION
	PREREQ_PM         => {
		'WWW::Mechanize'    => 1.18,
		'Test::Simple'      => 0.44,
	},
	
	($] >= 5.006001 ?     ## Add these new keywords supported since 5.006001
	(ABSTRACT      => 'Correios::Frete get the price to send with Correios (Brazilian Post-Office) your mail.',
	AUTHOR         => 'Thiago Rondon <thiago@aware.com.br>') : ()),
);
