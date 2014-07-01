#!/usr/bin/env perl --

use strict;
use warnings;
no  warnings"once";
use Getopt::Std ();
use List::Util qw(first);
use IO::File;
use YAML::Syck ();
use JSON::Syck ();
local $JSON::Syck::SortKeys = 1;
use URI::Fetch;
use CGI;

use utf8;
use Encode ();

# getopt
Getopt::Std::getopts 'vc:o:y' => my $opt = {};
# -v: verbose
# -c: config file
# -o: output json file
# -y: saved as yaml (for debug)

# debug
my $debug = defined $opt->{v};

main->logit("started. (pid=%d)", $$);

# load config
my $config_file = $opt->{c} // "./setting.yml";
my $config = YAML::Syck::LoadFile( $config_file )
	or die "cannot read setting.yml!: " . $!;

main->logit("config file %s loaded.", $config_file);

# set output file
my $json_file = $opt->{o} // "./count.json";

main->run;

sub run {
	my $class = shift;

	my @chunk = $class->get_chunk;
	my @result = $class->calc_count( @chunk );
	$class->save_json( @result );
	exit 0;
}

sub get_chunk {
	my $class = shift;
	
	my @chunk;
	for my $uri( @{ $config->{board} } ){
		if( my $res = URI::Fetch->fetch( $uri ) ){
			if( my $content = $res->content ){
				$class->logit("content: %s retreived. (%d bytes)", $uri, length $content);
				
				$content = eval { Encode::decode( 'euc-jp', $content ) } // $content;
				
				# to chunk
				push @chunk, $class->content2chunk( $content );
			}
		}
		else{
			die "cannot get uri $uri: " . URI::Fetch->errstr;
		}
	}
	
	return @chunk;
}

sub content2chunk {
	my $class = shift;
	my ($content) = @_;
	
	my @chunk;
	for my $line( split /\n+/o, $content ){
		next if $line !~ /<dt>/o;
		
		my $seen = {};
		for my $chunk( split m{<br>}, CGI::unescapeHTML( $line ) ){
			next if $chunk !~ /^\s*?[\-]*?\s*?(sm|nm|so)[0-9]{7,9}/o;
			$chunk =~ s/^\s+//o;
			
			my ($n, $title) = $class->parse_line( $chunk );
			
			# duplicate check
			next if defined $seen->{ $n };
			$seen->{ $n } = 1;
			
			push @chunk, $chunk;
		}
	}
	
	return @chunk;
}

sub calc_count {
	my $class = shift;
	my @chunk = @_;

	my $count_list = {};
	for my $chunk( @chunk ){
		my $is_plus = $chunk =~ s/^[\-]+\s*//o
			? 0
			: 1;
		
		my ($n, $title) = $class->parse_line( $chunk );
		
		# set id
		$count_list->{ $n }->{id} //= $class->extract_id( $n );
		
		# count
		if( $is_plus ){
			# add
			$count_list->{ $n }->{num}++;
		}
		else{
			# subtract
			$count_list->{ $n }->{num}--;
			next;    # assume empty when minus
		}
		
		# title
		if( defined $title and bytes::length( $title ) > 1 ){
			if( defined $count_list->{ $n }->{title} ){
				# length
				if( length( $title ) < length $count_list->{ $n }->{title} ){
					$count_list->{ $n }->{title} = $title;
				}
			}
			else{
				$count_list->{ $n }->{title} = $title;
			}
		}
	}

	my @ignore = map { @{ $config->{ignore}->{$_} } } qw(community wrong);

	my $sorter = sub {
		$count_list->{$b}->{num} <=> $count_list->{$a}->{num}
			||
		$count_list->{$a}->{id} <=> $count_list->{$b}->{id}
	};

	my @result;
	for my $v( sort $sorter keys %{ $count_list } ){
		# ignore
		next if first { $v eq $_ } @ignore;
		
		push @result, {
			id => $v,    # sm1234567
			vid => $count_list->{$v}->{id},    # 1234567
			title => scalar( $count_list->{$v}->{title} || q{不明} ),
			view => $count_list->{$v}->{num},    # 再生数
		};
	}
	
	# correction
	while( my ($id, $offset) = each %{ $config->{correction} } ){
		$offset = int $offset;
		if( my $video = first { $_->{id} eq $id } @result ){
			$video->{view} += $offset;
		}
		elsif( $offset > 0 ){
			# newly added
			push @result, {
				id => $id,
				vid => $class->extract_id( $id ),
				title => q{不明},
				view => $offset,
			};
		}
	}

	# skip 0
	@result = grep { $_->{view} > 0 } @result;

	$class->logit("total %d videos.", scalar @result);

	return @result;
}

sub save_json {
	my $class = shift;
	my @result = @_;
	
	my $result = { map { $_->{id} => $_->{view} } @result };

	# add date
	$result->{"created-at"} = scalar localtime;

	open my $fh, '>', $json_file or die $!;
	$fh->print( defined $opt->{y} ? YAML::Syck::Dump( $result ) : JSON::Syck::Dump( $result ) );
	$fh->close;
	
	$class->logit("saved to %s.", $json_file);
}

sub extract_id {
	my $class = shift;
	my ($str) = @_;
	
	( my $id = $str ) =~ s/^(sm|nm|so)+//o;
	
	return $id;
}

sub parse_line {
	my $class = shift;
	my ($str) = @_;

	# まず空白で切ってみる
	my ($n, $title) = split /[\s\t　]+/o, $str, 2;
	
	# 初期のログには空白で区切られていないものがあるので特別に処理する
	if( $n !~ /^(sm|nm)[0-9]{7,9}$/o ){
		($n, $title) = unpack "A9 A*", $str;
	}

	return ($n, $title);
}

sub logit {
	my $class = shift;
	my ($template, @args) = @_;
	
	return if not $debug;
	
	printf STDERR "[%s] $template\n", scalar localtime, @args;
}

__END__
