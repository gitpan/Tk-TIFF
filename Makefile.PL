use Tk::MMutil;
use Tk::Config;

Tk::MMutil::TkExtMakefile
  (
   'NAME'          => 'Tk::TIFF',
   'DEFINE'        => '-DHAVE_TIFF_H',
   ## for FreeBSD and the old tiff34 name and location for includes, use
   ## the following:
   #'LIBS'          => ['-ltiff34 -ljpeg'],
   #'INC'           => '-I/usr/local/include/tiff34',
   'LIBS'          => ['-ltiff -ljpeg'],
   'INC'           => '',
   'OBJECT'        => '$(O_FILES)',
   'VERSION_FROM'  => 'TIFF.pm',
   'dist'      => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => '.gz',
                   'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},
   'PREREQ_PM'     => {'Tk' => 800.014 },
   );


