package Tk::TIFF;
require DynaLoader;
use Tk 800.014;
require Tk::Photo;

use vars qw($VERSION @ISA);
@ISA = qw(DynaLoader);

$VERSION = '0.05';

bootstrap Tk::TIFF $Tk::VERSION;

1;
__END__
