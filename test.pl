#!/usr/local/bin/perl -w
# -*- perl -*-

#
# $Id: test.pl,v 1.3 1999/04/14 18:14:10 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

BEGIN { $last = 8; print "1..$last\n" }

use Tk;
use Tk::TIFF;
use File::Compare;

$ok = 1;
print "ok " . $ok++ . "\n";
$tmp = "/tmp";

$top = new MainWindow;

foreach (qw(test-none.tif test-2channel.tif test-lzw.tif test-packbits.tif)) {
    push @p, $top->Photo(-file => $_);
    print "ok " . $ok++ . "\n";
}

if (!-d $tmp && !-w $tmp) {
    for(; $ok <= $last; $ok++) {
	print "ok $ok # skipping test: $tmp not writeable\n"
    }
    exit 0;
}

foreach (@p) {
    $top->Label(-image => $_)->pack(-side => 'left');
}
$top->update;
sleep 1;
# Don't use the first image (with colors), because there are problems
# with ppc-linux (different colors for both images), but rather
# test if the monochrome image is the same.
$p[1]->write("$tmp/tifftest2.tif");

print ((!-r "$tmp/tifftest2.tif" ? "not " : "") . "ok " . $ok++ . "\n");

$p2 = $top->Photo(-file => "$tmp/tifftest2.tif");
$p2->write("$tmp/tifftest3.tif");

print STDOUT ((compare("$tmp/tifftest2.tif", "$tmp/tifftest3.tif") != 0
	       ? "not " : "") . "ok " . $ok++ . "\n");

$p2->write("$tmp/tifftest4.tif", '-format' => ['tiff', -compression => 'lzw']);
print ((!-r "$tmp/tifftest4.tif" ? "not " : "") . "ok " . $ok++ . "\n");

#cleanup
for (<$tmp/tifftest*.tif>) {
    unlink $_;
}

#MainLoop;
