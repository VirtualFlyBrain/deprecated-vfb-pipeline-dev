PIPELINE=/pipeline/
DATA=/data/mnt

echo 'Create network bridge'
#docker run -p:7474:7474 -p 7687:7687 --env=NEO4J_AUTH=neo4j/neo --env=NEO4J_dbms_read__only=false rcourt/docker-neo4j-knowledgebase
docker network create -d bridge --subnet 192.168.0.0/24 --gateway 192.168.0.1 dockernet
# docker volume rm $(docker volume ls -qf dangling=true)

# START UP KB
docker run -p:7474:7474 -p 7687:7687 --env=NEO4J_AUTH=neo4j/neo --env=NEO4J_dbms_read__only=false --env=NEO4J_dbms_memory_heap_maxSize=6G --env=NEO4J_dbms_memory_heap_initial__size=1G vfbp-kb

# Fire UP TRIPLESTORE
docker run --rm -p 8080:8080 -e RDF4J_DATA=/data -e JVM_PARAMS="-Xms1g -Xmx5g" yyz1989/rdf4j


echo 'PIPELINE'

# Transform KB to new schema
docker run -p 4000:80 --net=dockernet --env=KBpassword=neo4j/neo vfbp-kb2kb

# Remember to delete stray entities;
# MATCH (n)-[r]-() WHERE NOT n:Class AND NOT n:DataProperty AND NOT n:Individual AND NOT n:AnnotationProperty AND NOT n:ObjectProperty DELETE r,n
# Validate KB according to new schema
docker run -p 4000:80 --net=dockernet --env=KBpassword=neo4j/neo vfbp-validatekb

# Collect data for ingestion into triple store, including the OWL dump from the KB
docker run -p 4000:80 --net=dockernet --volume /data/mnt:/out --env=KBpassword=neo4j/neo vfbp-data

# Load data into triple store
docker run -p 4000:80 --net=dockernet --volume /data/mnt:/data --net=dockernet vfbp-ts

# Fire up OWLERY
docker run -p 80:8080 --env=OWLURL=http://192.168.0.1:8080/rdf4j-server/repositories/vfb?query=PREFIX+rdfs%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0APREFIX+owl%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2002%2F07%2Fowl%23%3E%0APREFIX+rdf%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0APREFIX+obo%3A+%3Chttp%3A%2F%2Fpurl.obolibrary.org%2Fobo%2F%3E%0ACONSTRUCT+%7B%3Fx+%3Fy+%3Fz%7D%0AWHERE+%7B%0A%09%3Fx+%3Fy+%3Fz+.%0A%7D%0A --net=dockernet virtualflybrain/owlery-vfb
#Run prod
docker run -p:7474:7474 -p 7687:7687 --env=NEO4J_AUTH=neo4j/neo --env=NEO4J_dbms_read__only=false --env=NEO4J_dbms_memory_heap_maxSize=3G --env=NEO4J_dbms_memory_heap_initial__size=200M --net=dockernet vfbp-prod

docker run -p 4000:80 --net=dockernet --env=KBpassword=neo4j/neo vfbp-produp
