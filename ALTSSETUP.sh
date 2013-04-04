#!/bin/bash

echo "Setting up ALTS..This may take a few minutes.."
echo "Please be patient.."

mkdir /ALTS 2>/dev/null
chmod 755 /ALTS
echo -en "[#                   ] 5% \r";

mkdir -p /ALTS/EXAM
chmod 700 /ALTS/EXAM
echo -en "[##                  ] 10% \r";

mkdir -p /ALTS/RESULTS
chown root:apache /ALTS/RESULTS
chmod 750 /ALTS/RESULTS
echo -en "[###                 ] 15% \r";


mkdir -p /ALTS/EXERCISES
chmod 700 /ALTS/EXERCISES
echo -en "[####                ] 20% \r";


mkdir -p /ALTS/lib/
chmod 755 /ALTS/lib
echo -en "[#####               ] 25% \r";


pp -o /ALTS/lib/ALTSLogin.pl /leats-scripts/ALTSLogin.pl
chmod 6755 /ALTS/lib/ALTSLogin.pl
echo -en "[#######             ] 35% \r";


pp -o /ALTS/lib/ALTSLogout.pl /leats-scripts/ALTSLogout.pl
chmod 6755 /ALTS/lib/ALTSLogout.pl
echo -en "[#########          ] 45% \r";

pp -o /ALTS/lib/activate.pl /leats-scripts/activate.pl
chmod 6755 /ALTS/lib/activate.pl
echo -en "[#########          ] 50% \r";


pp -o /ALTS/lib/ExerciseCoding /leats-scripts/ExerciseCoding.pl
chmod 6755 /ALTS/lib/ExerciseCoding
echo -en "[###########        ] 55% \r";


pp -o /ALTS/lib/Perl2SetUIDExecutable /leats-scripts/Perl2SetUIDExecutable.pl
chmod 6755 /ALTS/lib/Perl2SetUIDExecutable
echo -en "[#############      ] 65% \r";


pp -o /ALTS/lib/Results2Html /leats-scripts/Results2Html.pl 
chmod 6755 /ALTS/lib/Results2Html
echo -en "[###############    ] 75% \r";


/ALTS/lib/Perl2SetUIDExecutable "/leats-scripts/activate.pl" /ALTS/activate
chmod 6755 /ALTS/activate
echo -en "[################   ] 80% \r";


/ALTS/lib/Perl2SetUIDExecutable /ALTS/lib/ALTSLogin.pl /ALTS/ALTSLogin
chmod 6755 /ALTS/ALTSLogin
echo -en "[################   ] 85% \r";


/ALTS/lib/Perl2SetUIDExecutable /ALTS/lib/ALTSLogout.pl /ALTS/ALTSLogout
chmod 6755 /ALTS/ALTSLogout
echo -en "[#################  ] 90%\r";

mkdir -p /ALTS/SECURITY; chmod -R 400 /ALTS/SECURITY
cp -p /leats-scripts/SECURITY/* /ALTS/SECURITY/ 1>/dev/null 2>&1;


unlink /ALTS/Grade 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Grade /ALTS/Grade
unlink /ALTS/Break 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Break /ALTS/Break
unlink /ALTS/Description 1>/dev/null 2>&1; ln -s /var/www/cgi-bin/Description /ALTS/Description

/leats-scripts/ScriptReady.pl 1>/dev/null 2>&1
echo -en "[################# ] 95%\r";


echo -en "[###################] 100%\r";
echo "";
echo "SETUP DONE.";
echo ""

