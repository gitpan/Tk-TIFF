#!/usr/local/bin/perl -w
# -*- perl -*-

#
# $Id: test.pl,v 1.6 2003/10/22 19:09:46 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

BEGIN { $last = 12; print "1..$last\n" }

use Tk;
use Tk::TIFF;
use File::Compare;

$ok = 1;
print "ok " . $ok++ . "\n";
$tmp = "/tmp";

$top = new MainWindow(-width => 800, -height => 600);

@tifflist = qw(test-none.tif test-2channel.tif test-lzw.tif test-packbits.tif
               test-float.tif);

# string read first
if (eval { require MIME::Base64; }) {
	foreach (@tifflist) {
		open(F, $_) or die "Can't open $_: $!";
		binmode F;
		undef $/;
		my $buf = <F>;
		close F;
		my $p;
		eval { $p = $top->Photo(-data => MIME::Base64::encode_base64($buf)) };
		if ($p && !$@) {
			print "ok " . $ok++ . " $_\n";
		} else {
			print "not ok " . $ok++ . " $_\n";
			warn "\t$@\n" if $@;
		}
	}
} else {
	print "ok " . $ok++ . " # skipping test: no MIME::Base64 installed\n"
	for (1..scalar(@tifflist));
}

foreach (@tifflist) {
	my $p;
	eval { $p = $top->Photo(-file => $_) };
	if ($p && !$@) {
		push @p, $p;
		print "ok " . $ok++ . " $_\n";
	} else {
		print "not ok " . $ok++ . " $_\n";
		warn "\t$@\n" if $@;
	}
}

if (!-d $tmp && !-w $tmp) {
	for(; $ok <= $last; $ok++) {
		print "ok $ok # skipping test: $tmp not writeable\n"
	}
	exit 0;
}


foreach (@p) {
	$t = $top->Label(-image => $_)->pack(-side => 'left', -expand => 1);
	$t->configure(-width => 800, -height => 600);
	$top->update;
	sleep 1;
	$t->destroy;
}

# Don't use the first image (with colors), because there are problems
# with ppc-linux (different colors for both images), but rather
# test if the monochrome image is the same.
if (!$p[1]) {
    print "ok " . $ok++ . " # skipping test: no photos available\n"
	for (1..3);
} else {
    $p[1]->write("$tmp/tifftest2.tif");

    print ((!-r "$tmp/tifftest2.tif" ? "not " : "") . "ok " . $ok++ . " Write tifftest2.tif\n");

    $p2 = $top->Photo(-file => "$tmp/tifftest2.tif");
    $p2->write("$tmp/tifftest3.tif");

    print STDOUT ((compare("$tmp/tifftest2.tif", "$tmp/tifftest3.tif") != 0
		   ? "not " : "") . "ok " . $ok++ . " tifftest2.tif == tifftest3.tif\n");

    $p2->write("$tmp/tifftest4.tif", '-format' => ['tiff', -compression => 'lzw']);
    print ((!-r "$tmp/tifftest4.tif" ? "not " : "") . "ok " . $ok++ . " Write lzw tiff\n");
}

#cleanup
for (<$tmp/tifftest*.tif>) {
    unlink $_;
}
