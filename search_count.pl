#!/usr/bin/env perl --

use strict;
use warnings;
use Getopt::Std ();
use Scalar::Util qw(looks_like_number);
use JSON::Syck ();
use YAML::Syck ();

# getopt
Getopt::Std::getopts 'c:m:M:i:I:' => my $opt = {};
# -c: count <num>
# -m: min count <num>
# -M: max count <num>
# -i: min id <id>
# -I: max id <id>

my $count = eval { JSON::Syck::LoadFile("./output/count.json") } or YAML::Syck::LoadFile("./count.json") or die "cannot read count.json: $!";

sub sorter {
  (undef, my $id_a) = unpack "A2 A*", $a;
  (undef, my $id_b) = unpack "A2 A*", $b;
  return $id_a <=> $id_b;
}

for my $id( sort sorter grep { /^(sm|nm|so)/ } keys %{ $count } ){
  (undef, my $n) = unpack "A2 A*", $id;
  next if looks_like_number $opt->{c} && $count->{$id} != $opt->{c};
  next if looks_like_number $opt->{m} && $count->{$id} < $opt->{m};
  next if looks_like_number $opt->{M} && $count->{$id} > $opt->{M};

  next if looks_like_number $opt->{i} && $n < $opt->{i};
  next if looks_like_number $opt->{I} && $n > $opt->{I};

  print $id, "\n";
}

__END__
