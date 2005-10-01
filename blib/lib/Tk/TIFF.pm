package Tk::TIFF;
require DynaLoader;
use Tk 800.014;
use Tk::Photo;

use vars qw($VERSION @ISA);
@ISA = qw(DynaLoader);

$VERSION = '0.10';

bootstrap Tk::TIFF $Tk::VERSION;

#
# There are now two new functions:
#   # Get current value of global HistEqual Flag.
#   $hist_equal = Tk::TIFF::getHistEqual();
#
#   # Set new value to true or false, returning new value.
#   $hist_equal = Tk::TIFF::setHistEqual(0|1);
#

1;
__END__
