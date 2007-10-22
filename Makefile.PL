# -*- perl -*-
use Tk::MMutil;
use Tk::Config;
use Tk;
use Config;

#####################################################################
# CONFIG Vars

# Set to 1 for older FreeBSDs with the obsolete tiff34 library name
my $tiff34 = 0;

# Set to 1 if your system needs Photo.so to be included
my $need_photo_so = 0;

#
######################################################################

my $Author = 'Slaven Rezic (eserte@cs.tu-berlin.de)';

# check endianess...
my $adddef = "";
if ($Config{"byteorder"} eq '4321' ||
    $Config{"byteorder"} eq '87654321') {
    $adddef = "-DWORDS_BIGENDIAN";
} elsif ($Config{"byteorder"} ne '1234' &&
	 $Config{"byteorder"} ne '12345678') {
    warn "Unknown byte order $Config{byteorder}. ".
	 "Please report to $Author!\n";
}

if ($Tk::VERSION <= 800.015) { # XXX not sure about the right version
    $adddef .= " -DUSE_IMGSEEK";
}

my @libs;
my @inc;
# check for tiff34
if ($tiff34) {
    push @inc,  qw(-I/usr/local/include/tiff34);
    push @libs, qw(-L/usr/local/lib -ltiff34 -ljpeg);
} else {
    push @inc,  qw(-I/usr/local/include);
    push @libs, qw(-L/usr/local/lib -ltiff -ljpeg);
}
push @libs, "-lz";

# include Photo.so
my $photo_so = "";
if ($need_photo_so) {
    foreach ($Config{"installsitelib"}, $Config{"installarchlib"}) {
	my $test_so = "$_/auto/Tk/Photo/Photo." . $Config{'dlext'};
	if (-r $test_so) {
	    $photo_so = $test_so;
	    last;
	}
    }
}

my $LIBS = join(" ", @libs);
my $INC  = join(" ", @inc);

if (eval { require Devel::CheckLib; 1; }) {
    my(@libpath) = map { s/^-L//; $_ } grep { /^-L/ } split / /, $LIBS;
    my(@lib)     = map { s/^-l//; $_ } grep { /^-l/ } split / /, $LIBS;
    Devel::CheckLib::assert_lib(lib => \@lib, libpath => \@libpath);
}

Tk::MMutil::TkExtMakefile
  (
   'NAME'          => 'Tk::TIFF',
   'DEFINE'        => "-DHAVE_TIFF_H $adddef",
   'LIBS'          => [ $LIBS ],
   'INC'           => $INC,
   'OBJECT'        => '$(O_FILES) ' . $photo_so,
   'VERSION_FROM'  => 'TIFF.pm',
   'PREREQ_PM'     => {'Tk' => 800.014 },
   'AUTHOR'        => $author,
   'ABSTRACT'      => 'Tk::Photo loader for TIFF files',
   'EXTRA_META'    => <<'EOF',
configure_requires:
  Tk::MMutil: 0
  Tk::Config: 0
  Tk: 0
EOF
  );

sub MY::postamble {
    my $postamble = "";

    if (defined $ENV{USER} && $ENV{USER} eq 'eserte' && $^O =~ /bsd/i && -f "../../perl.release.mk") {
	$postamble .= <<'EOF';

.include "../../perl.release.mk"
.include "../../perl.cvs.mk"

EOF
    }

    $postamble;
}
