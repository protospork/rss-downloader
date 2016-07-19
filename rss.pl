#!/usr/bin/perl
#
# Updater: protospork at gmail dot com
#
# Author: Craig Wilson (Craigawilson at gmail dot com)
#
# Origonal Author: Mat Miehling (mamiehling at gmail dot com)
#
# Please feel free to edit/distribute this file, but PLEASE do not
#    claim my work as your own.
#

use Modern::Perl;
use LWP::Simple;

my $debug = 1; # set to 1 to stop program actually downloading also does not delete urls.list file

my $infile = "./urls.list";	# The temp file that holds the rss feed
my $feedsfile = 'feeds'; 		# The file that contains all the feed links and names
my $destination = '/test/';	# Tte Destination to save fils
open(my $feeds, '<', $feedsfile);	# open feedsfile for reading feed info
my @lines = <$feeds>;
my $logfile = '~/rss-downloader-log.txt'; # location of the log file
# foreach loop to split the feeds file format = NAME,FEEDURL
my (@names, @rss_link);
for(@lines){
    my @temp = split(/,/, $_);
# btw everything depends on these two arrays not getting out of sync
    push(@names, $temp[0]);  	# store the name of the feed
    push(@rss_link, $temp[1]);	# store the link for the rss feed
}

#TODO:
# - dump this regex into the config file?
# - stop using a regex
my $regex = 'enclosure url="(http://.*\.m(p4|4v))"'; 	# RegEx searching for shows in .mp4 format
my @matches; 	# Array to hold the details of matches from the RegEx

my $counter = 0;

for(@rss_link){
    print $_."\n";
    getstore("$_","$infile"); 	# download the rss feed for today.

    my $downloaded = './downloaded/'.$names[$counter];
    open(my $in, '<', $infile);		# Open the temp file
    open(my $dl, '<', $downloaded);	# Open the previously downloaded file (Read-Only)

    my @prevdown = <$dl>;		# store the previously downloaded files
    print "Ignoring ".($#prevdown + 1)." files previously downloaded: \n @prevdown";

    close($dl); 	# Cloes the read-only status on the download file
    open($dl, ">>", $downloaded); 	# Open with appened

    while (my $line = <$in>){
        if ($line =~ $regex){
            my $temp = 0;
            for (@prevdown){ # Check against ignore list
                if($1."\n" eq $_){
                    $temp = 2;
                }
            }

            if ($temp == 0){
                print $dl $1."\n";		# Print link to downloaded file
                print "Download:".$1."\n";			# Print linke to screen
                if ($debug == 0){
                    print "download starting\n";
                    #WHY ARE YOU USING SYSTEM
                    system ("pushd $destination && wget $1 -nv -a $logfile && popd"); # command = move to /test/, execute "wget link", move back to previous folder
                    print "download stopping\n";
                }
            } #if $temp

        } # if $linke $regex
    } # while $line

    close($in);		# Close the file
    close($dl);
    if ($debug == 0){
        unlink($infile); 	# Delete urls.list
    }
    $counter++;
}
