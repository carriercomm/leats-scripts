#!/bin/bash

service slapd stop

echo "## INFO ## Creating /etc/openldap/slapd.conf..";
echo "pidfile     /var/run/openldap/slapd.pid
argsfile    /var/run/openldap/slapd.args" > /etc/openldap/slapd.conf 

echo "## INFO ## Clear slapd.d..."
rm -rfv /etc/openldap/slapd.d/* 

echo "## INFO ## run slaptest";
slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d 
echo ""
#olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break


echo "## INFO ## Modify /etc/openldap/slapd.d/cn=config/olcDatabase\={0}config.ldif"
cat '/etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif' | sed 's/olcAccess:\s{0}to\s\*.*/olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break/' > '/tmp/config.ldif.tmp'; cp '/tmp/config.ldif.tmp' '/etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif'; rm -f '/tmp/config.ldif.tmp'
cat '/etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif'


echo ""
echo '## INFO ##  Creating /etc/openldap/slapd.d/cn=config/olcDatabase\={1}monitor.ldif'
echo 'dn: olcDatabase={1}monitor
objectClass: olcDatabaseConfig
olcDatabase: {1}monitor
olcAccess: {1}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break
olcAddContentAcl: FALSE
olcLastMod: TRUE
olcMaxDerefDepth: 15
olcReadOnly: FALSE
olcMonitoring: FALSE
structuralObjectClass: olcDatabaseConfig
creatorsName: cn=config
modifiersName: cn=config' > '/etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif'
cat '/etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif'

echo ""
echo "## INFO ##  Setting up permission "
chown -R ldap. /etc/openldap/slapd.d 
chmod -R 700 /etc/openldap/slapd.d 

echo "## INFO ##  Run slapd "
/etc/rc.d/init.d/slapd start 
chkconfig slapd on 


echo "## INFO ##  Add schemas"
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif 

echo ""
echo "## INFO ##  Creating backend.ldif"
echo 'dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulepath: /usr/lib64/openldap
olcModuleload: back_hdb

dn: olcDatabase=hdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcHdbConfig
olcDatabase: {2}hdb
olcSuffix: dc=pelda,dc=hu
olcDbDirectory: /var/lib/ldap
olcRootDN: cn=admin,dc=pelda,dc=hu
olcRootPW: {SSHA}0MiivyaYcFqiBhe8l96Je3frU7vLIPjX
olcDbConfig: set_cachesize 0 2097152 0
olcDbConfig: set_lk_max_objects 1500
olcDbConfig: set_lk_max_locks 1500
olcDbConfig: set_lk_max_lockers 1500
olcDbIndex: objectClass eq
olcLastMod: TRUE
olcMonitoring: TRUE
olcDbCheckpoint: 512 30
olcAccess: to attrs=userPassword by dn="cn=admin,dc=pelda,dc=hu" write by anonymous auth by self write by * none
olcAccess: to attrs=shadowLastChange by self write by * read
olcAccess: to dn.base="" by * read
olcAccess: to * by dn="cn=admin,dc=pelda,dc=hu" write by * read
' > ./backend.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -f ./backend.ldif 
rm -f ./backend.ldif

echo ""
echo "## INFO ##  Creating frontend.ldif"
echo 'dn: dc=pelda,dc=hu
objectClass: top
objectClass: dcObject
objectclass: organization
o: ServerALTS
dc: pelda

dn: cn=admin,dc=pelda,dc=hu
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
userPassword: {SSHA}0MiivyaYcFqiBhe8l96Je3frU7vLIPjX

dn: ou=people,dc=pelda,dc=hu
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=pelda,dc=hu
objectClass: organizationalUnit
ou: groups
' > ./frontend.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./frontend.ldif 


echo "## INFO ##  Creating frontend.ldif"
echo 'dn: dc=pelda,dc=hu
objectClass: top
objectClass: dcObject
objectclass: organization
o: ServerALTS
dc: pelda' > ./frontend.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./frontend.ldif

echo "## INFO ##  Creating frontend.ldif"
echo 'dn: cn=admin,dc=pelda,dc=hu
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
userPassword: {SSHA}0MiivyaYcFqiBhe8l96Je3frU7vLIPjX' > ./frontend.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./frontend.ldif

echo "## INFO ##  Creating frontend.ldif"
echo 'dn: ou=people,dc=pelda,dc=hu
objectClass: organizationalUnit
ou: people' > ./frontend.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./frontend.ldif


rm -f ./frontend.ldif

echo 'dn: uid=student,ou=people,dc=pelda,dc=hu
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: student
sn: student
givenName: student
cn: student
displayName: student
uidNumber: 500
gidNumber: 500
userPassword: {crypt}$6$983GGBt0$kY2Sw.1rlzHCcAoE9ymni0kAuu/EQkFdYHeeayDqqdjTp3x2uJQ3GpOYcpq37t6V3RZ5XWKv217YgMqAaQskR/
gecos: student
loginShell: /bin/bash
homeDirectory: /home/student
shadowExpire: -1
shadowFlag: 0
shadowWarning: 7
shadowMin: 0
shadowMax: 99999
shadowLastChange: 15612

dn: uid=ldapuser1,ou=people,dc=pelda,dc=hu
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
uid: ldapuser1
sn: ldapuser1
givenName: ldapuser1
cn: ldapuser1
displayName: ldapuser1
uidNumber: 551
gidNumber: 500
userPassword: {SSHA}5ofIP03NDWC2ygV8HU3OcZafpuOmzknM
gecos: ldapuser1
loginShell: /bin/bash
homeDirectory: /home/ldapuser1
shadowExpire: -1
shadowFlag: 0
shadowWarning: 7
shadowMin: 0
shadowMax: 99999
shadowLastChange: 15825' > ./ldapusers.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./ldapusers.ldif 

echo 'dn: uid=ldapuser1,ou=people,dc=pelda,dc=hu
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
uid: ldapuser1
cn: ldapuser1
uidNumber: 551
gidNumber: 500
userPassword: ldapuser1
gecos: ldapuser1
loginShell: /bin/bash
homeDirectory: /home/ldapuser1
shadowExpire: -1
shadowFlag: 0
shadowWarning: 7
shadowMin: 0
shadowMax: 99999
shadowLastChange: 15825' > ./ldapusers.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./ldapusers.ldif

echo 'dn: uid=ldapuser2,ou=people,dc=pelda,dc=hu
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
uid: ldapuser2
cn: ldapuser2
uidNumber: 552
gidNumber: 500
userPassword: ldapuser2
gecos: ldapuser2
loginShell: /bin/bash
homeDirectory: /home/ldapuser2
shadowExpire: -1
shadowFlag: 0
shadowWarning: 7
shadowMin: 0
shadowMax: 99999
shadowLastChange: 15825' > ./ldapusers.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./ldapusers.ldif

echo 'dn: uid=ldapuser3,ou=people,dc=pelda,dc=hu
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
uid: ldapuser3
cn: ldapuser3
uidNumber: 553
gidNumber: 500
userPassword: ldapuser3
gecos: ldapuser3
loginShell: /bin/bash
homeDirectory: /home/ldapuser3
shadowExpire: -1
shadowFlag: 0
shadowWarning: 7
shadowMin: 0
shadowMax: 99999
shadowLastChange: 15825' > ./ldapusers.ldif

ldapadd -x -D cn=admin,dc=pelda,dc=hu -w "@lts33" -f ./ldapusers.ldif

rm -f ./ldapusers.ldif
