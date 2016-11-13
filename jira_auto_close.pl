#!/usr/bin/perl
use strict;
my $username = "fred.blaise";
my $password = "1moreyeaR";
#my $filterJQL = 'project%20%3D%20"IN"%20AND%20status%20%3D%20Resolved';
#my $filterJQL = 'project%20%3D%20"IN"%20AND%20status%20%3D%20Resolved%20AND%20resolved%20<%3D%20-10d';
my $filterJQL = 'project%20%3D%20"IN"%20AND%20issuetype%20in%20standardIssueTypes()%20AND%20status%20%3D%20Resolved%20AND%20resolved%20<%3D%20-10d';
# find out in JIRA the transID. In our case, 701 is the transition from Resolved to Closed.
my $transID = "701";
my $maxResults = 200;
my $transComment = "Automatically closed by script";
my $jiraurl = "https://gottexbrokers.atlassian.net";

`/opt/local/bin/wget --quiet --no-check-certificate -O issues.txt '$jiraurl/rest/api/latest/search?os_username=$username&os_password=$password&jql=$filterJQL&maxResults=$maxResults' 2>&1`;

my $cnt = 0;

if ( !$? ) {
	open my $FF, "issues.txt";
	my $json = <$FF> ;
	close($FF);

	my @matches = $json =~ /"key":"(.*?)"/g;
	my @fissues = grep( /-/, @matches );

	print "Will process $#fissues+1 issues.\n\n";
	foreach (@fissues) {
		print "Updating issue [$_]... ";
		system("curl -H 'Content-type: application/json' -X POST -d '{ \"update\": { \"comment\": [ { \"add\": { \"body\": \"$transComment\" } } ] }, \"transition\": { \"id\": \"$transID\" } }' '$jiraurl/rest/api/latest/issue/$_/transitions?os_username=$username&os_password=$password'");

		if (!$?) {
			print "Issue udpated\n";
		}
		else {
			print "Failed to udpate issue\n";
		}
		$cnt++;
	}
} else {
	print "Unable to access JIRA [$jiraurl] [$?]\n";
}

print "\nUpdated $cnt issues\n";
