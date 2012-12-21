#!/usr/bin/env perl --

use strict;
use warnings;
use JSON::Syck ();

my $id = shift @ARGV // die "usage: $0 <video id>";

my $count = JSON::Syck::LoadFile("./count.json") or die "cannot read count.json: $!";

printf "%s: %d\n", $id, $count->{ $id } // 0;

__END__
