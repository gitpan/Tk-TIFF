# -*- perl -*-
use Tk::MMutil;
use Tk::Config;
use Config;

#####################################################################
# CONFIG Vars

# Set to 1 for older FreeBSDs with the obsolete tiff34 library name
my $tiff34 = 0;

# Set to 1 if your system needs Photo.so to be included
my $need_photo_so = 0;

#
######################################################################

# check endianess...
my $adddef = "";
if ($Config{"byteorder"} eq '4321') {
    $adddef = "-DWORDS_BIGENDIAN";
} elsif ($Config{"byteorder"} ne '1234') {
    warn "Unknown byte order $Config{byteorder}. ".
	 "Please report to the author!\n";
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

Tk::MMutil::TkExtMakefile
  (
   'NAME'          => 'Tk::TIFF',
   'DEFINE'        => "-DHAVE_TIFF_H $adddef",
   'LIBS'          => [ join(" ", @libs)],
   'INC'           =>   join(" ", @inc),
   'OBJECT'        => '$(O_FILES) ' . $photo_so,
   'VERSION_FROM'  => 'TIFF.pm',
   'dist'          => { 'COMPRESS'=>'gzip -9f', 'SUFFIX' => '.gz',
                        'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)' },
   'PREREQ_PM'     => {'Tk' => 800.014 },
   'AUTHOR'        => 'Slaven Rezic (eserte@cs.tu-berlin.de)',
  );
