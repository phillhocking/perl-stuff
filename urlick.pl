#!/usr/bin/perl
use LWP::Simple;
use URI::Escape;
use HTML::TokeParser;

&usage() if $#ARGV != 2;

unless($ARGV[1] =~ /^f:/)
{
	@exts = split(/,/, $ARGV[1]) unless
	$ARGV[1] =~ /^all$/;
} 
elsif($ARGV[1] =~ /^f:/) 
{
	$CUR{FILTER} == 1;
	$ARGV[1] =~ s/f://;
	@filters = split(/,/, $ARGV[1]);
}

if(-e -f $ARGV[0])
{
	$CUR{LIST} == 1;
	open(URLIST,"<$ARGV[0]") or die $!;
	@urlist = <URLIST>;
	close(URLIST);
	foreach(@urlist)
	{
		chomp;
		next unless /^\w/;
		&parsey($_);	
	}
} 
else {
	$CUR{LIST} == 0;
	$ARGV[0]  = "http://$ARGV[0]" if 
	$ARGV[0]  !~ /^http/i;
	&parsey($ARGV[0])
}

sub parsey
{
	my $base = get($_[0]) or die $!;
	my $p = HTML::TokeParser->new(\$base);
	while(my $token = $p->get_tag("a"))
	{
		my $url = $token->[1]{href};
		#push @dirlist, $url if $url =~ /\/$/;
		
		if($ARGV[1] eq 'all')
		{
			$CUR{ALL} == 1;
			push @urlist, $url
			if $url !~ /\/$/;
			push @dirlist, $url
			if $url =~ /\w+\/$/;				
		}
		elsif($CUR{FILTER})
		{
		for my $filter(@filters)
		{
			push @urlist, $url
			if $url =~ /$filter/i;	
		}}
		else {
		for my $ext(@exts)
		{
			push @urlist,$url 
			if $url =~ /$ext$/i;	
		}}
	}
	
	if($ARGV[2] eq 'test')
	{
		print uri_unescape($_),"\n"
		foreach @urlist;
	}
	elsif($ARGV[2] eq 'list')
	{
		open(LIST,">>urlist.txt") or die $!;
		for my $url(@urlist)
		{
			$url = "$base/$url" if $url !~ /^http/i;
			print LIST $url, "\n";
			print "\n* wrote to urlist.txt\n";
		}
	}
	elsif($ARGV[2] eq 'get'){
		for my $target(@urlist)
		{
		   	if($target !~ /^http/i){$target="$base/$target"}
		   	next if $target =~ /^\./;
			print `wget $target`;
		}
	}
}

exit(0);

sub usage
{
	die "\nperl $0 [url(s)] [ext(s)|[f:FILTER(s)] [test|list|get]\n\n"
}
