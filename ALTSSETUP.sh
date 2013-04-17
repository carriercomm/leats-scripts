#!/bin/bash

echo "Setting up ALTS..This may take a few minutes.."
echo "Please be patient.."

echo -en "[                   ] 0% \r";

mkdir /ALTS 2>/dev/null
chmod 755 /ALTS

mkdir -p /ALTS/EXAM
chmod 700 /ALTS/EXAM

mkdir -p /ALTS/RESULTS
chown root:apache /ALTS/RESULTS
chmod 750 /ALTS/RESULTS


mkdir -p /ALTS/EXERCISES
chmod 700 /ALTS/EXERCISES


mkdir -p /ALTS/lib/
chmod 700 /ALTS/lib


pp -o /ALTS/lib/ALTSLogin.pl /leats-scripts/ALTSLogin.pl
chmod 6755 /ALTS/lib/ALTSLogin.pl
echo -en "[##                 ] 10%    \r";


pp -o /ALTS/lib/ALTSLogout.pl /leats-scripts/ALTSLogout.pl
chmod 6755 /ALTS/lib/ALTSLogout.pl
echo -en "[###                ] 15%    \r";

pp -o /ALTS/lib/activate.pl /leats-scripts/activate.pl
chmod 6755 /ALTS/lib/activate.pl
echo -en "[####               ] 20%    \r";


pp -o /ALTS/lib/ExerciseCoding /leats-scripts/ExerciseCoding.pl
chmod 6755 /ALTS/lib/ExerciseCoding
echo -en "[#####              ] 25%    \r";


pp -o /ALTS/lib/Perl2SetUIDExecutable /leats-scripts/Perl2SetUIDExecutable.pl
chmod 6755 /ALTS/lib/Perl2SetUIDExecutable
echo -en "[######             ] 30%    \r";


pp -o /ALTS/lib/Results2Html /leats-scripts/Results2Html.pl 
chmod 6755 /ALTS/lib/Results2Html
echo -en "[#######            ] 35%    \r";


/ALTS/lib/Perl2SetUIDExecutable "/leats-scripts/activate.pl" /ALTS/activate
chmod 6755 /ALTS/activate
echo -en "[########           ] 40%    \r";


/ALTS/lib/Perl2SetUIDExecutable /ALTS/lib/ALTSLogin.pl /ALTS/ALTSLogin
chmod 6755 /ALTS/ALTSLogin
echo -en "[#########          ] 45%    \r";


/ALTS/lib/Perl2SetUIDExecutable /ALTS/lib/ALTSLogout.pl /ALTS/ALTSLogout
chmod 6755 /ALTS/ALTSLogout
echo -en "[##########         ] 50%    \r";


pp -o /ALTS/lib/ALTSHome.pl /leats-scripts/ALTSHome.pl
chmod 6755 /ALTS/lib/ALTSHome.pl
echo -en "[##########         ] 55%    \r";

/ALTS/lib/Perl2SetUIDExecutable /ALTS/lib/ALTSHome.pl /var/www/cgi-bin/ALTSHome
chmod 6755 /var/www/cgi-bin/ALTSHome
echo -en "[##########         ] 60%   \r";

pp -o /ALTS/lib/guest-management.pl /leats-scripts/guest-management.pl
chmod 6755 /ALTS/lib/guest-management.pl
echo -en "[##########         ] 65%   \r";

/ALTS/lib/Perl2SetUIDExecutable "/ALTS/lib/guest-management.pl -reset 2>/dev/null" /ALTS/RESET
chmod 6755 /ALTS/RESET
/ALTS/lib/Perl2SetUIDExecutable "/ALTS/lib/guest-management.pl -install 2>/dev/null" /ALTS/REINSTALL
chmod 6755 /ALTS/REINSTALL
echo -en "[##########         ] 70%   \r";


mkdir -p /ALTS/SECURITY; chmod -R 400 /ALTS/SECURITY
cp -p /leats-scripts/SECURITY/* /ALTS/SECURITY/ 1>/dev/null 2>&1;


unlink /ALTS/Grade 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Grade /ALTS/Grade
unlink /ALTS/Break 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Break /ALTS/Break
unlink /ALTS/Description 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Description /ALTS/Description

#/leats-scripts/ScriptReady.pl ALL 1>/dev/null
echo -en "[################# ] 95%     \r";


echo -en "[###################] 100%    \r";
echo "";
echo "SETUP DONE.";
echo ""

