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

system("/var/www/cgi-bin/Result-1");


print "</body>
</html>\n";

exit;
