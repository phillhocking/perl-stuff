#!/usr/bin/perl
use LWP::Simple;
use HTML::TokeParser;

&usage() if $#ARGV != 2;

unless($ARGV[1] =~ /^[A-Z0-9_'-]+$/ 
&& $ARGV[1] !~ /^[a-z]{3}/)
{
	@exts = split(/,/, $ARGV[1]) unless
	$ARGV[1] =~ /^all$/;
} else {
	$CUR{FILTER} = 1;
	@filters = split(/,/, $ARGV[1]);
}

if(-e -f $ARGV[0])
{
	$CUR{LIST} = 1;
	open(URLIST,"<$ARGV[0]") or die $!;
	while(<URLIST>)
	{
		my $link = $_;
		next if $link !~ /^\w/;
		&parsey($link);
	}
	close URLIST;
} 
else {
	$CUR{LIST} = 0;
	&parsey($ARGV[0])
}

sub parsey
{
	my $base = get($_[0]) or die $!;
	my $p = HTML::TokeParser->new(\$base);
	while(my $token = $p->get_tag("a"))
	{
		my $url = $token->[1]{href};
		if($ARGV[1] eq 'all')
		{
			push @urlist,$url				
		}
		elsif($CUR{FILTER})
		{
			for my $filter(@filters)
			{
				push @urlist, $url
				if $url =~ /.*$filter.*/i	
			}
		}
		else {
			for my $ext(@exts)
			{
				push @urlist,$url 
				if $url =~ /$ext$/i;	
			}
		}
		
		if(lc $ARGV[2] eq 'test')
		{
			$_ =~  s/\%20/ /g and 
			print $_,"\n" foreach @urlist;
		}
		else {
			mkdir (0644,$ARGV[2]) 
			unless(-e -d $ARGV[2]);
			chdir $ARGV[2];
			for my $target(@urlist)
		   {
		   		if($target !~ /^http/i){$target="$base/$target"}
				print `wget $target`;
			}
		}
	}
}

exit(0);

sub usage
{
	die "\nperl $0 [url(s)] [ext(s)|[FILTER(s)] [DIR|test]\n\n"
}
