package Nav_Bar;

##use strict;

=head1 Nav_Bar

Nav_Bar forms the navigation bar header for each page, with specific highlights

=cut

=head2 new

Takes three arguments - page name, owner name and team name(can be null)

=cut

sub new {
  my $class=shift;
  #my $self=shift;
  my $self={};
  my @args = @_;
  $self->{PAGE}    = "$args[0]" if scalar(@args) > 0;
  $self->{OWNER}   = "$args[1]" if scalar(@args) > 1;
  $self->{COMMISH} = "$args[2]" if scalar(@args) > 2;
  $self->{STATUS}  = ucfirst($args[3]) if scalar(@args) > 3;
  $self->{TEAM}    = '(' . $args[4] . ')' if scalar(@args) > 4;

  bless($self, $class);
  return $self;
}

sub print {
  my $self = shift;

  return "" unless $self->{OWNER};
  my %nav_opts;
  if ($self->{COMMISH} != 1)
  {
    %nav_opts = (
       '1My Team'       => '/cgi-bin/fantasy/teamHome.pl',
       '2Auction'       => '/cgi-bin/fantasy/getBids.pl',
       '3Player Add'    => '/cgi-bin/fantasy/getPlayer.pl',
       '4Player List'   => '/cgi-bin/fantasy/listPlayers.pl',
       '5Set Targets'   => '/cgi-bin/fantasy/getTargets.pl',
       '6Your Contracts' => '/cgi-bin/fantasy/getContracts.pl',
       '7All Contracts' => '/cgi-bin/fantasy/getLeagueContracts.pl',
       '8Keeper Tags'   => '/cgi-bin/fantasy/getTags.pl',
       '9Rosters'       => '/cgi-bin/fantasy/makeRosters.pl',
       '10Draft Results' => '/cgi-bin/fantasy/getResults.pl'
       ##'9Rules'         => '/fantasy/rules.htm'
    );
  }
  else
  {
    %nav_opts = (
       '1My Team'       => '/cgi-bin/fantasy/teamHome.pl',
       '2Auction'       => '/cgi-bin/fantasy/getBids.pl',
       '3Player Add'    => '/cgi-bin/fantasy/getPlayer.pl',
       '4Player List'   => '/cgi-bin/fantasy/listPlayers.pl',
       '5Set Targets'   => '/cgi-bin/fantasy/getTargets.pl',
       '6Contracts'     => '/cgi-bin/fantasy/getContracts.pl',
       '7All Contracts' => '/cgi-bin/fantasy/getLeagueContracts.pl',
       '8Keeper Tags'   => '/cgi-bin/fantasy/getTags.pl',
       '9Rosters'       => '/cgi-bin/fantasy/makeRosters.pl',
       '10Draft Results' => '/cgi-bin/fantasy/getResults.pl',
       '11Tools'         => '/cgi-bin/fantasy/getTools.pl'
    );
  }
  
  
##<link rel="stylesheet" href="/fantasy/ui0208.css" type="text/css" media="screen">
print <<NAV;

<div class="container">
        <div class="header">

      <h4>Draft Status: $self->{STATUS}</h4>

                <div class="userInfo" align="right">
                        <h4>User: $self->{OWNER} $self->{TEAM}<span><a href="/cgi-bin/fantasy/logout.pl" target="_top">Log out</a></span></h4>
                </div>
                <div class="headerTitle">
                        <h2><a href="/fantasy/fantasy_main_index.htm" target="_top">Fantasy Home</a></h2>
                </div>
                <div class="nav">
                        <div class="navLinks">
                                <ul align="center">
NAV

  my $li = '';
  foreach (sort {$a <=> $b} keys %nav_opts)
  {
    ## Remove prepended number (used for sorting)
    my $real_name = $_;
    $real_name =~ s/^\d+//;

    ## Set up the option highlights
    $li = '<li>';
    $li = '<li class="pageON">' if $self->{PAGE} eq $real_name;

    print "$li<a href=\"$nav_opts{$_}\" target=\"_top\">$real_name</a></li>\n";
  }

print <<NAV;
                                </ul>
                        </div>
		</div>
	</div>
NAV

return $self->{OWNER};

}

1;
