echo 'Allow new plugin to make changes..'
CONF=/data/neo4j.conf
echo 'dbms.security.procedures.unrestricted=ebi.spot.neo4j2owl.*,apoc.*' >> ${CONF}
