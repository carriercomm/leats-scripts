#!/bin/bash

echo "Setting up ALTS..This may take a few minutes.."
echo "Please be patient.."

mkdir /ALTS 2>/dev/null
chmod 755 /ALTS
echo -en ".";

mkdir -p /ALTS/EXAM
chmod 700 /ALTS/EXAM
echo -en ".";

mkdir -p /ALTS/RESULTS
chmod 700 /ALTS/RESULTS
echo -en ".";

mkdir -p /ALTS/lib/
chmod 755 /ALTS/lib
echo -en ".";

pp -o /ALTS/lib/ALTSLogin.pl /leats-scripts/ALTSLogin.pl
chmod 6755 /ALTS/lib/ALTSLogin.pl
echo -en ".";

pp -o /ALTS/lib/ALTSLogout.pl /leats-scripts/ALTSLogout.pl
chmod 6755 /ALTS/lib/ALTSLogout.pl
echo -en ".";

pp -o /ALTS/lib/ExerciseCoding /leats-scripts/ExerciseCoding.pl
chmod 6755 /ALTS/lib/ExerciseCoding
echo -en ".";

pp -o /ALTS/lib/Perl2SetUIDExecutable /leats-scripts/Perl2SetUIDExecutable.pl
chmod 6755 /ALTS/lib/Perl2SetUIDExecutable
echo -en ".";

pp -o /ALTS/lib/Results2Html /leats-scripts/Results2Html.pl 
chmod 6755 /ALTS/lib/Results2Html
echo -en ".";

/ALTS/lib/Perl2SetUIDExecutable /ALTS/lib/ALTSLogin.pl /ALTS/ALTSLogin
chmod 6755 /ALTS/ALTSLogin
echo -en ".";

/ALTS/lib/Perl2SetUIDExecutable /ALTS/lib/ALTSLogout.pl /ALTS/ALTSLogout
chmod 6755 /ALTS/ALTSLogout
echo ".";

