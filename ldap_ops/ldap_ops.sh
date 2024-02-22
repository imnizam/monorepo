# This file explains some LDAP operations like -
# adding groups or users
# searching 
# modifying
# deleteing users/teams in LDAP server
# There is one LDAP server running in k8s in tsb namespace.

# Following ops are done on Mac osx platform

#port-forward ldap svc
kubectl -n tsb port-forward svc/ldap 8080:389

# add ldap user
ldapadd -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin -f users/alice.ldif

#add teams
ldapadd -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin -f teams/addteam_mb.ldif
ldapadd -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin -f teams/addteam_convai.ldif 

#add members to above teams
ldapmodify -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin -f teams/adduser_toteam_mb.ldif
ldapmodify -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin -f teams/adduser_toteam_convai.ldif 


# ldap search existing users/groups
ldapsearch -LLL  -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin -b dc=tetrate,dc=io | grep -C 5 zack

#ldap delete
ldapdelete -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin "cn=alice,ou=Kotak,dc=tetrate,dc=io"
ldapdelete -H ldap://"127.0.0.1:8080" -x -D cn=admin,dc=tetrate,dc=io -w admin "dn name"
