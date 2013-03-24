#!/usr/bin/perl
##
## CGI script to print out the relevant environment variables.
## It's just one big print statement, but note the use of the
## associative %ENV array to access the environment variables.
##


print "Content-type: text/html\n\n";
print '<html>';

print '
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
 ALTS Results
</div>
';

system("/var/www/cgi-bin/Result 2>&1");

#system("/var/www/cgi-bin/02-physical_disk-1-grade");

print "</body>
</html>\n";

exit;
