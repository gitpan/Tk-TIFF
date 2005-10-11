#!/usr/local/bin/perl -w
# -*- perl -*-

#
# $Id: test.pl,v 1.9 2005/10/11 20:25:32 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1998,2005 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

use strict;

my $last;
BEGIN { $last = 15; print "1..$last\n" }

use Tk;
use Tk::TIFF;
use File::Compare;

my $ok = 1;
print "ok " . $ok++ . "\n";

my $top = new MainWindow(-width => 400, -height => 480);

my @tifflist = qw(test-none.tif test-2channel.tif test-lzw.tif
		  test-packbits.tif test-float.tif);
my @tifflabels = @tifflist;

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
	    print "ok " . $ok++ . " # $_\n";
	} else {
	    warn $@ if $@;
	    print "not ok " . $ok++ . " # $_\n";
	}
    }
} else {
    print "ok " . $ok++ . " # skipping test: no MIME::Base64 installed\n"
	for (1..scalar(@tifflist));
}

my @p;
foreach (@tifflist) {
    my $p;
    eval { $p = $top->Photo(-file => $_) };
    if ($p && !$@) {
	push @p, $p;
	print "ok " . $ok++ . " # $_\n";
    } else {
	warn $@ if $@;
	print "not ok " . $ok++ . " # $_\n";
    }
}

{
    Tk::TIFF::setContrastEnhance(1);
    my $p;
    eval { $p = $top->Photo(-file => "test-float.tif") };
    if ($p && !$@) {
	push @p, $p;
	push @tifflabels, "test-float.tif (contrastEnhance=1)";
	print "ok " . $ok++ . " # Contrast-Enhanced Float TIFF\n";
    } else {
	warn $@ if $@;
	print "not ok " . $ok++ . " # Contrast-Enhanced Float TIFF\n";
    }
}

my $tmp;
if (eval { require File::Temp; 1 }) {
    $tmp = File::Temp::tempdir(CLEANUP => 1);
}
if (!$tmp || !-d $tmp || !-w $tmp) {
    for(; $ok <= $last; $ok++) {
	print "ok $ok # skipping test: ";
	if (!defined $tmp) {
	    print "cannot create temporary directory (File::Temp available?)\n";
	} else {
	    print "$tmp not writeable\n"
	}
    }
    exit 0;
}

{
    $top->packPropagate(0);
    my $t = $top->Label->pack(-expand => 1);
    my $t_label = $top->Label->pack(-fill => 'x');
    my $p_i = 0;
    foreach (@p) {
	$t->configure(-image => $_);
	$t_label->configure(-text => $tifflabels[$p_i]);
	$top->update;
	$top->tk_sleep(0.75);
	$p_i++;
    }
}

# Don't use the first image (with colors), because there are problems
# with ppc-linux (different colors for both images), but rather
# test if the monochrome image is the same.
if (!$p[1]) {
    print "ok " . $ok++ . " # skipping test: no photos available\n"
	for (1..3);
} else {
    $p[1]->write("$tmp/tifftest2.tif");

    print ((!-r "$tmp/tifftest2.tif" ? "not " : "") . "ok " . $ok++ . " # Write tifftest2.tif\n");

    my $p2 = $top->Photo(-file => "$tmp/tifftest2.tif");
    $p2->write("$tmp/tifftest3.tif");

    print STDOUT ((compare("$tmp/tifftest2.tif", "$tmp/tifftest3.tif") != 0
		   ? "not " : "") . "ok " . $ok++ . " # tifftest2.tif == tifftest3.tif\n");

    $p2->write("$tmp/tifftest4.tif", '-format' => ['tiff', -compression => 'lzw']);
    print ((!-r "$tmp/tifftest4.tif" ? "not " : "") . "ok " . $ok++ . " # Write lzw tiff\n");
}

# cleanup (not really necessary)
for (<$tmp/tifftest*.tif>) {
    unlink $_;
}

# REPO BEGIN
# REPO NAME tk_sleep /home/e/eserte/work/srezic-repository 
# REPO MD5 2fc80d814604255bbd30931e137bafa4

=head2 tk_sleep

=for category Tk

    $top->tk_sleep($s);

Sleep $s seconds (fractions are allowed). Use this method in Tk
programs rather than the blocking sleep function. The difference to
$top->after($s/1000) is that update events are still allowed in the
sleeping time.

=cut

sub Tk::Widget::tk_sleep {
    my($top, $s) = @_;
    my $sleep_dummy = 0;
    $top->after($s*1000,
                sub { $sleep_dummy++ });
    $top->waitVariable(\$sleep_dummy)
	unless $sleep_dummy;
}
# REPO END

