#!/usr/bin/perl
use DBI;
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use CGI::Cookie;
my $cgi = new CGI;

# files
$image_path =   'http://www.zwermp.com/cgi-bin/fantasy/pics/';
$bid_error_file = './error_logs/bid_errors.txt';
$team_error_file = './error_logs/team_errors.txt';


########################
#
# Header Print
#
########################

sub Header()
{

print "Cache-Control: no-cache\n";
print "Content-type: text/html\n\n";

print <<HEADER;

<HTML>
<HEAD>
<TITLE>Auction Page</TITLE>


<script language="JavaScript">
<!--
function createRequestObject() {

    var ro;
    try
    {
        // Firefox, Opera 8.0+, Safari
        ro = new XMLHttpRequest();
    }
    catch (e)
    {
       // Internet Explorer
       try
       {
          ro = new ActiveXObject("Msxml2.XMLHTTP");
       }
       catch (e)
       {
          try
          {
             ro = new ActiveXObject("Microsoft.XMLHTTP");
          }
          catch (e)
          {
             alert("ERROR: Your browser does not support AJAX!");
             return false;
          }
       }
    }
    return ro;
}
-->
</script>


<script language="JavaScript">
<!--
   var http = createRequestObject()
-->
</script>


<script language="JavaScript">
<!--
var ourInterval = setInterval("table_loop()", 6000);
-->
</script>


<script language="JavaScript">
<!--
function pswd_checker(mysize)
{
  if (bid_form.TEAM_PASSWORD.value == '')
  {
    alert("Please enter a password")
    return (false);
  }

  if (bid_form.TEAMS.value == 'Select A Team')
  {
    alert("Please select a Team")
    return (false)
  }

  // Check to make sure at least one new bid was made
  //  and that bid entries are numbers
  var bid_made = false
  var bids_ok = true;
  var check = '0123456789'
  for (counter = 1; counter < PLAYER_TABLE_1.rows.length; counter++)
  {
    counter2 = Math.floor(counter/2) + 1

    var text = "bid_form.NEW_BID_" + counter2 + ".value"
    var text2 = PLAYER_TABLE_1.rows[counter].cells[0].firstChild.nodeValue

    for (var i = 0; i < eval(text).length; i++)
    {
      var chr = eval(text).charAt(i);

      for (var j = 0; j < check.length; j++) 
      {
        if (chr == check[j])
        {
          break
        }

        // Should only reach here is a non-numeric entry is used
        if (j == (check.length - 1))
        {
          bids_ok = false
        }
      }

       if (bids_ok == false) break;
    }

    if ((eval(text) != 0) && (eval(text) != ''))
    {
      bid_made = true
    }
  }

  if (bid_made == false)
  {
    alert("You must make at least one new bid to submit this form!")
    return(false)
  }

  if (bids_ok == false)
  {
    alert("Your bids must only contain numbers!")
    return(false)
  }

  return(true)
}
-->
</script>


<script language="JavaScript">
<!--
function table_loop()
{

  var player_names = ""

  for (var i = 1; i < PLAYER_TABLE_1.rows.length; i++)
  { 
    player_names = player_names + PLAYER_TABLE_1.rows[i].cells[0].firstChild.nodeValue + ";"
  }
  sndReq(bid_form.league.value + "," + player_names)

}
-->
</script>


<script language="JavaScript">
<!--
function sndReq(action) {
    http.open('GET','checkBids.pl?action='+action)
    http.onreadystatechange = handleResponse
    http.send(null)
}
-->
</script>


<script language="JavaScript">
<!--
// Handle the response from the perl code
//  Writes new bids/bidders to the table
function handleResponse() 
{
    if(http.readyState == 4)
    {
        var response = http.responseText
        var update = new Array()
        var players = new Array()

        if(response.indexOf(';') != -1) 
        {
            update = response.split(';')
        }

        for (var i = 0; i < (update.length - 2); i++)
        {
          players[i] = update[i].split(',')
        }

        var found = new Array(players.length)
        for (var i = 0; i<found.length; i++)
        {
          found[i] = 0
        }

        var count = 0
        for (var i = 1; i < PLAYER_TABLE_1.rows.length; i++)
        { 
          player_name = PLAYER_TABLE_1.rows[i].cells[0].firstChild.nodeValue

          for (var x = 0; x < players.length; x++)
          {
            if (players[x][0] == player_name)
            {

              found[x] = 1
              //If player has been won already, make his row red
              if (players[x][2] == "NA")
              {
                PLAYER_TABLE_1.rows[i].style.backgroundColor = "red"
                PLAYER_TABLE_1.rows[i].cells[2].firstChild.nodeValue = players[x][2]
                PLAYER_TABLE_1.rows[i].cells[3].firstChild.nodeValue = players[x][3]
                PLAYER_TABLE_1.rows[i].cells[4].firstChild.nodeValue = players[x][4]
                var input_num = i //Math.floor(i/2) + 1
                eval("bid_form.NEW_BID_" + input_num + ".disabled = true")
              }
              
              //If the leading bidder is this owner
              else if (players[x][3] == bid_form.team_id.value)
              {
                PLAYER_TABLE_1.rows[i].style.backgroundColor = "98FB98"
              }
              //If the bid has changed since last update
              else if (players[x][2] != PLAYER_TABLE_1.rows[i].cells[2].firstChild.nodeValue)
              {
                PLAYER_TABLE_1.rows[i].style.backgroundColor = "yellow"
                PLAYER_TABLE_1.rows[i].cells[2].firstChild.nodeValue = players[x][2]
                PLAYER_TABLE_1.rows[i].cells[3].firstChild.nodeValue = players[x][3]
                PLAYER_TABLE_1.rows[i].cells[4].firstChild.nodeValue = players[x][4]
              }
              else 
              {
                PLAYER_TABLE_1.rows[i].style.backgroundColor = "#EEEEEE"
              }

              break
            }
          }
          count++
        } // end for loop

        
        // add new rows, when needed
        for (var i = 0; i<found.length; i++)
        {
          if (found[i] == 0)
          {
            count++
            addRowToTable(players[i][0],players[i][1],players[i][2],players[i][3],players[i][4],count)
          }
        }


        //update total players input
        bid_form.total_players.value = count

        // update clock
        time_table.rows[1].cells[0].firstChild.nodeValue = update[update.length - 2];
    }
}

-->
</script>


<script language="JavaScript">
<!--
function addRowToTable(name,position,bid,bidder,time,num)
{
  var lastRow = PLAYER_TABLE_1.rows.length;
  // if there's no header row in the table, then iteration = lastRow + 1
  var row = PLAYER_TABLE_1.insertRow(lastRow);
 
  var cell1 = row.insertCell(0);
  var textNode1 = document.createTextNode(name);
  cell1.appendChild(textNode1);
  var cell2 = row.insertCell(1);
  var textNode2 = document.createTextNode(position);
  cell2.appendChild(textNode2);
  var cell3 = row.insertCell(2);
  var textNode3 = document.createTextNode(bid);
  cell3.appendChild(textNode3);
  var cell4 = row.insertCell(3);
  var textNode4 = document.createTextNode(bidder);
  cell4.appendChild(textNode4);
  var cell5 = row.insertCell(4);
  var textNode5 = document.createTextNode(time);
  cell5.appendChild(textNode5);

  var cell6 = row.insertCell(5);
  var textNode6 = document.createTextNode("Bid: ");
  var el  = document.createElement('input')
  var el2 = document.createElement('input')
  el.type = 'text'
  el.name = 'NEW_BID_' + num
  el.size = 13
  el.value = 0
  el2.type = 'hidden'
  el2.name = 'PLAYER_NAME_' + num
  el2.value = name
  cell6.appendChild(textNode6);
  cell6.appendChild(el);
  cell6.appendChild(el2);

  cell1.id= num + ' 0'
  cell1.rowspan=1
  cell1.valign="middle"
  cell2.id= num + ' 1'
  cell2.rowspan=1
  cell2.valign="middle"
  cell3.id= num + ' 2'
  cell3.rowspan=1
  cell3.valign="middle"
  cell4.id= num + ' 3'
  cell4.rowspan=1
  cell4.valign="middle"
  cell5.id= num + ' 4'
  cell5.rowspan=1
  cell5.valign="middle"
  cell6.id= num + ' 5'
  cell6.rowspan=1
  cell6.valign="middle"

  row.bgColor = "#FFFF00";
}
-->
</script>

<LINK REL=StyleSheet HREF="http://www.zwermp.com/cgi-bin/fantasy/style.css" TYPE="text/css" MEDIA=screen>

</HEAD>
<BODY>
<h2 align=center><u>Welcome to The Fantasy Baseball League Auction!</u></h2>

<p align=center><a href="http://www.zwermp.com/cgi-bin/fantasy/fantasy_main_index.htm">Fantasy Home</a>
<br>

<iframe src="nav.htm" width="100%" height="60" scrollbars="no" frameborder="0"></iframe>

HEADER

}


########################
#
# Header2 Print
#
########################

sub Header2($$)
{
    my $player_num = shift;
    my $time_string = shift;

print <<HEADER2;

    </p>

    <br><br>
    <p align=center>Click to see the <A href="http://www.zwermp.com/cgi-bin/fantasy/rules.htm" target="rules">rules</a>.
    <br><br>

    <table cellpadding=5 frame="box" id="time_table">
     <tr align=center><td><b>Current Time</b></td></tr>
     <tr align=center><td>$time_string</td></tr>
    </table>
    
    <br><br>

    <form name="bid_form" action="http://www.zwermp.com/cgi-bin/fantasy/putBids.pl" method="post">
HEADER2
}

####################
#
# Footer1 Print
#
####################

sub Footer1($)
{
my $namer = shift;

  if ($use_IP_flag eq 'yes')
  {
print <<FOOTER1;

<br><br>
<p align=center>
<a name="BIDDING"><b>Enter Bid(s) for Team $namer</b></a>

FOOTER1
  }
  else
  {
print <<FOOTER1;

<br><br>
<p align=center>
<a name="BIDDING"><b>Enter Bid(s) for Selected Team</a>

FOOTER1
}


}

####################
#
# Footer2 Print
#
####################

sub Footer2($$$)
{
  my $league = shift;
  my $total_players = shift;
  my $team_name = shift;

  if ($use_IP_flag eq 'yes')
  {
print <<FOOTER2;

    <br>
    <input type="hidden" name="TEAMS" value="$team_name">

FOOTER2

  } # end if
  
  else  ## not using IP for bidder identification - must choose team and enter password
  {

print <<FOOTER2;

    <br>
    <table>
     <tr>
      <td align=middle>User Name</td>
      <td align=middle>Password</td>
     </tr>
     <tr>
      <td align=middle> 
       <select name="TEAMS">

FOOTER2
   
   ## Output each team name as an option in the pull-down - default to cookie team name if available
   # Connect to DB
   $dbh = DBI->connect("DBI:mysql:doncote_draft:localhost","doncote_draft","draft")
                  or die "Couldn't connect to database: " .  DBI->errstr;

   #Get Team List
   $sth = $dbh->prepare("SELECT * FROM teams WHERE league = '$league'")
        or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute() or die "Cannot execute: " . $sth->errstr();

   while (($tf_owner, $tf_name, $tf_league, $tf_adds, $tf_sport) = $sth->fetchrow_array())
   {
     $check = "";
     if ($tf_name eq $team_name)
     {
        $check = "selected";
     }

     PrintOwner($tf_owner,$tf_name,$check);
   }
   
   $sth->finish();
   $dbh->disconnect();


print <<FOOTER2;

        </select>
      </td>
      <td align=middle>
        <input type="password" name="TEAM_PASSWORD">
      </td>
     </tr>
    </table>
    <br>

FOOTER2

  } # end else

print <<FOOTER2;

    <input type="submit" value="Submit My Bid!" id=submit1 name=submit1>
    <input type="reset" value="Clear The Forms" id=reset1 name=reset1>
    <br>
    Note: If your bids are too low they will not be recorded.

    <input type="hidden" id=total name="total_players" value=$total_players>
    <input type="hidden" id=league name="league" value=$league_t>


    </form>
    </p>    

    </BODY>
    </HTML>

FOOTER2

}


######################
#
# Add Player
#
######################


sub AddPlayer($$$$$$)
{
	my $name = shift;
	my $pos = shift;
	my $bid = shift;
	my $bidder = shift;
	my $time = shift;
        my $count = shift;

print <<EOM;

  <tr>
 
    <td id="$count 0" rowspan=1 valign="middle">$name</td>
    <td id="$count 1" rowspan=1 valign="middle">$pos</td>
    <td id="$count 2" rowspan=1 valign="middle">$bid</td>
    <td id="$count 3" rowspan=1 valign="middle">$bidder</td>
    <td id="$count 4" rowspan=1 valign="middle">$time</td>
    <td id="$count 5" rowspan=1 valign="middle">Bid: <input type="text" name="NEW_BID_$count" size=13 value=0><input type="hidden" name="PLAYER_NAME_$count" value="$name"></td>
  </tr>
EOM

}

######################
#
# Print Hidden
#
######################


sub PrintHidden($$)
{
my $field1 = shift;
my $field2 = shift;

print <<EOM;

<input type="hidden" name="session" value="$field1">
<input type="hidden" name="team_id" value="$field2">

EOM

}



######################
#
# Print Owner
#
######################



sub PrintOwner($$)
{
my $owner = shift;
my $name  = shift;
my $check = shift;

print <<EOM;

  <option value="$owner" $check> 
  $name
  </option>

EOM

}



######################
#
# List Error
#
######################


sub ListError($)
{
my $message = shift;

print <<EOM;

$message

EOM

}


##############
#
# Main Function
#
##############

# variables for players
my @name;
my @pos;
my @bid;
my @bidder;
my @time;
my @team;
my @ez_time;
my $count = 0;
my $total_players = 0;


## Connect to the DB
$dbh = DBI->connect("DBI:mysql:doncote_draft:localhost","doncote_draft","draft")
              or die "Couldn't connect to database: " .  DBI->errstr;

# find out the name of the session user
my $query = new CGI;
my $cookie = "SESS_ID";
my $id = $query->cookie(-name => "$cookie");
my $ip = "";
my $userAddr = $ENV{REMOTE_ADDR};

# If the cookie is valid, get the IP that the session is for
if($id){
  $sth = $dbh->prepare("SELECT * FROM sessions WHERE sess_id = '$id'")
        or die "Cannot prepare: " . $dbh->errstr();
  $sth->execute() or die "Cannot execute: " . $sth->errstr();
      ($ip, $user, $password, $sess_id, $team_t, $sport_t, $league_t)  = $sth->fetchrow_array();
  $sth->finish();
}

# If the session is from a different IP, force the user to sign in
if ($ip ne $userAddr)
{
  open(TEAM,">$team_error_file");
  flock(TEAM,2);
  print TEAM "<b>You must login!</b>\n";
  close(TEAM);

  $dbh->disconnect();
  print "Location: http://www.zwermp.com/cgi-bin/fantasy/getTeam.pl\n\n";
  exit;
}
else
{

  #Get League Data
  $sth = $dbh->prepare("SELECT * FROM leagues WHERE name = '$league_t'")
           or die "Cannot prepare: " . $dbh->errstr();
  $sth->execute() or die "Cannot execute: " . $sth->errstr();
  ($league_name,$password,$owner,$draftType,$draftStatus,$contractStatus,$sport,$categories,$positions,$max_members,$cap,$auction_start_time,$auction_end_time,$auction_length,$bid_time_extension,$bid_time_buffer,$TZ_offset,$login_extend_time,$use_IP_flag) = $sth->fetchrow_array();
  $sth->finish();

  $auction_start_time = $auction_start_time - $TZ_offset;
  $auction_end_time = $auction_end_time - $TZ_offset;


  $players_auction_file = "auction_players";
  $players_won_file = "players_won";
  $messagefile = "./text_files/message_board_$league_t.txt";

  Header();

  # DB-style

  $sth = $dbh->prepare("SELECT COUNT(*) FROM $players_auction_file WHERE league = '$league_t'")
        or die "Cannot prepare: " . $dbh->errstr();
  $total_players = $sth->execute() or die "Cannot execute: " . $sth->errstr();
  $sth->finish();

  #time stuff.
  ($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time);
  my $RealMonth = $Month + 1;
  if($RealMonth < 10)
  {
     $RealMonth = "0" . $RealMonth; 
  }
  if($Day < 10)
  {
     $Day = "0" . $Day; # add a leading zero to one-digit days
  }
  $Fixed_Year = $Year + 1900;
  $time_string = "AM";
  if($Hour >= 12)
  {
   $time_string = "PM";
  }
  if ($Minute < 10)
  {
    $Minute = '0' . $Minute;
  }

  $auction_string_hour = $Hour%12;
  $auction_string = "$RealMonth/$Day - $auction_string_hour:$Minute $time_string";


  Header2($total_players,$auction_string);
  PrintHidden($num,$team_t);


  open(MESSAGES, "<$bid_error_file");
   flock(MESSAGES,1);
   @LINES=<MESSAGES>;
   chomp (@LINES);
  close(MESSAGES);
  $SIZE=@LINES;

  #only print the messages if they are meant for this user (or if we are not tracking who the user is)
  for ($x=0;$x<$SIZE;$x++)
  {
      #print any errors
      ($myteam, $myleague, $myline) = split(';',$LINES[$x]);
      if ((($myleague eq $league_t) & ($myteam eq $team_t) & ($use_IP_flag eq 'yes')) | ($use_IP_flag eq 'no'))
      {
         ListError($myline);
      }
  }

## Set up player auction table
print <<TBL;

<p align=center>
<table cellpadding=5 frame="box" id="PLAYER_TABLE_1">
<tr>
    <th>Player</th>
    <th>Position</th>
    <th>High Bid</th>
    <th>Bidder</th>
    <th>End Time</th>
    <th>Your Bid</th>
</tr>

TBL


  ## Trying to add players-won logic here . . .
  $sth_while = $dbh->prepare("SELECT * FROM $players_auction_file WHERE league = '$league_t'")
          or die "Cannot prepare: " . $dbh->errstr();
  $sth_while->execute() or die "Cannot execute: " . $sth_while->errstr();

  $player_print_count = 1;

  while (($name,$pos,$bid,$bidder,$time,$ez_time,$league) = $sth_while->fetchrow_array())
  {
      $time_over = 0;
      ($end_month,$end_day,$end_hour,$end_minute) = split(':',$ez_time);

      # If the player goes unclaimed, flag it
      $player_claimed = 1;
      if ($bidder eq '<b>UNCLAIMED</b>')
      {
	  $player_claimed = 0;
      }

      ## CRAZY auction-done logic ... Removed time-strings - see if still works!!!!!
      if
      (
       ($RealMonth == $end_month) 
         && 
       (
        ($Day > $end_day)
         || 
        (
         ($Day == $end_day)
          && 
         (
          ($Hour > $end_hour)
           || 
          (
           ($Hour == $end_hour)
            &&
           ($Minute >= $end_minute)
          )
         )
        )
       )
      )
     {
      
	 $time_over = 1;

         # in case our server is in a different time zone . . .
         $right_hour = $Hour + $TZ_offset;
         if($right_hour >= 0) 
         {
           $right_hour = $right_hour%12;
         }

         if ($player_claimed == 1)
         {
             ## Get owner name for winning team
             $sth = $dbh->prepare("SELECT * FROM teams WHERE name = '$bidder' AND league = '$league_t'")
                   or die "Cannot prepare: " . $dbh->errstr();
             $sth->execute() or die "Cannot execute: " . $sth->errstr();
             ($tf_owner, $tf_name, $tf_league, $tf_adds, $tf_sport) = $sth->fetchrow_array();
             $sth->finish();

             # If an owner is not found, send the email to the commish
             if ($tf_name =~ /^$/)
             {
                 # default to commissioners email
        	 $tf_owner = 'COMMISSIONER';
                 $owner_email = "akeely\@coe.neu.edu";
             }
             else
             {
                 ##Get owner email info!!
                 my $table = "passwd";
                 $sth = $dbh->prepare("SELECT email FROM $table WHERE name = '$tf_owner'")
                    or die "Cannot prepare: " . $dbh->errstr();
                 $sth->execute() or die "Cannot execute: " . $sth->errstr();
        
                 $owner_email = $sth->fetchrow_array();
                 $sth->finish();
              }


              ########################
              #                      #
              # SEND EMAIL TO WINNER #
              #                      #
              ########################

              my $mailprog = '/usr/sbin/sendmail';
              my $recipient = "$owner_email";

              $code_num = int(rand(100000));   
              open(CODE, ">>$code_file");
              flock(CODE,2);
              print CODE "$user;$league_t;$code_num\n";
              close(CODE);
    
              $right_hour = $Hour + $TZ_offset;
              if($right_hour >= 0) 
              {
                $right_hour = $right_hour%12;
              }

              open(MSG, ">>$messagefile");
              flock(MSG,2);
              print MSG "<b>AUCTION ALERT</b>;$RealMonth/$Day/$Fixed_Year ($right_hour:$Minute $time_string EST);<b>The bidding for $name has been won by $bidder for a price of $bid.</b>\n";
              close(MSG);


              open (MAIL, "|$mailprog -t");
              print MAIL "To: $recipient\n";
              print MAIL "Subject: $bidder has won the auction on $name!\n\n";

              # print message here, with same syntax, eg.
              print MAIL "Congratulations! You have won the fantasy baseball auction on $name, for the final bid of $bid. This player has been added to your team roster, so please visit the roster screen to view the changes and see how much money you have remaining.\n\nAlso, you may now add a new player to the auction, or defer the decision to the commissioner. Please go to http://www.zwermp.com/cgi-bin/fantasy/getPlayer.pl and select a player who has not yet been auctioned. This only allows for ONE new player addition with an initial $0.50 bid, so be sure that you think about which player you want to add at this time.\n\nAgain, if you do not want to add a player yourself, simply check the box to give the commissioner permission to add a new player, and he will take care of it. Be warned that once you give permission to the commissioner, this one addition will be revoked.\n\nCongratulations on acquiring $name, and good luck with the season!";

              close(MAIL);

              # DB-style
              # update players won file
              $sth = $dbh->prepare("INSERT INTO $players_won_file VALUES('$name','$pos','$bid','$bidder','$time','$ez_time','$league_t')") or die "Cannot prepare: " . $dbh->errstr();
              $sth->execute() or die "Cannot execute: " . $sth->errstr();
              $sth->finish();
   
              $sth = $dbh->prepare("DELETE FROM $players_auction_file WHERE name = '$name' AND league = '$league_t'")
                     or die "Cannot prepare: " . $dbh->errstr();
              $sth->execute() or die "Cannot execute: " . $sth->errstr();
              $sth->finish();

         } #end if (player_claimed)

         else
         {
              #if time is over but the player was not claimed, just remove him from the auction
              # DB-style
              $sth = $dbh->prepare("DELETE FROM $players_auction_file WHERE name = '$name' AND league = '$league_t'")
                      or die "Cannot prepare: " . $dbh->errstr();
              $sth->execute() or die "Cannot execute: " . $sth->errstr();
     
              $sth->finish();

              open(MSG, ">>$messagefile");
               flock(MSG,1);
               print MSG "<b>AUCTION ALERT</b>;$RealMonth/$Day/$Fixed_Year ($right_hour:$Minute $time_string EST);<b>$name was not claimed in the auction</b>\n";
              close(MSG);
         }


     } #end if (time_over)

     else
     {
         AddPlayer($name,$pos,$bid,$bidder,$time,$player_print_count);
         $player_print_count++;
     }

     ########################
     # Else if the time is not over, do nothing - leave players in the database
     ########################

} #end for-loop
$sth_while->finish();

$dbh->disconnect();

print "</table>";

Footer1($user);
Footer2($league_t,($a_num-1), $team_t);

}

