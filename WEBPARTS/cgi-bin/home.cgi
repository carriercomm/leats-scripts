#!/usr/bin/perl

use strict;
use warnings;

print "Content-type: text/html\n\n";

print "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\"><head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<title>ALTS</title>";

if (-f "/var/www/cgi-bin/ALTSHome")
{
        system("/var/www/cgi-bin/ALTSHome 2>/dev/null");
}
else
{
        print "Home binary can't be found!"; exit 1;
}

exit;

