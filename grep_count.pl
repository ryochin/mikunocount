#!/usr/bin/env perl --

use strict;
use warnings;
use JSON::Syck ();
use YAML::Syck ();

my $id = shift @ARGV or die "usage: $0 <video id>";
$id =~ s{^.+/([\w\d]+)(\?.+|$)}{$1};

$id = sprintf "sm%s", $id if $id =~ /^\d/o;

my $count = eval { JSON::Syck::LoadFile("./count.json") } or YAML::Syck::LoadFile("./count.json") or die "cannot read count.json: $!";

printf "%s: %d\n", $id, $count->{ $id } // 0;

__END__
