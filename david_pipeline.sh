# Code for deploying a new KB

# Create network bridge. This is necessary if you want to run the KB on localhost and access it from the pipeline containers. Here, you create a bridge called dockernet.
docker network create -d bridge --subnet 192.168.0.0/24 --gateway 192.168.0.1 dockernet
# docker volume rm $(docker volume ls -qf dangling=true)

# Pull KB with neo2owl plugin and start
docker pull virtualflybrain/docker-neo4j-knowledgebase:neo2owl
docker run -p:7474:7474 -p 7687:7687 --env=NEO4J_AUTH=neo4j/neo --env=NEO4J_dbms_read__only=false --env=NEO4J_dbms_memory_heap_maxSize=6G --env=NEO4J_dbms_memory_heap_initial__size=1G virtualflybrain/docker-neo4j-knowledgebase:neo2owl

# Now the KB is running. Open new terminal window

# Transform KB to new schema
docker pull matentzn/vfb-pipeline-kb2kb
docker run -p 4000:80 --net=dockernet --env=KBpassword=neo4j/neo matentzn/vfb-pipeline-kb2kb

# Remember to delete stray entities;
# MATCH (n)-[r]-() WHERE NOT n:Class AND NOT n:DataProperty AND NOT n:Individual AND NOT n:AnnotationProperty AND NOT n:ObjectProperty DELETE r,n
# Validate KB according to new schema
docker pull matentzn/vfb-pipeline-validatekb
docker run -p 4000:80 --net=dockernet --env=KBpassword=neo4j/neo matentzn/vfb-pipeline-validatekb
