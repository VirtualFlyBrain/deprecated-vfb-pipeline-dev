PIPELINE=/pipeline/

cd ${PIPELINE}vfb-pipeline-kb2kb; docker build -t vfbp-kb2kb .
cd ${PIPELINE}vfb-pipeline-validatekb; docker build -t vfbp-validatekb .
cd ${PIPELINE}docker-neo4j-knowledgebase; docker build -t vfbp-kb .
cd ${PIPELINE}vfb-pipeline-collectdata; docker build -t vfbp-data .
cd ${PIPELINE}vfb-pipeline-updatetriplestore; docker build -t vfbp-ts .
cd /pipeline/vfb-pipeline-update-prod; docker build -t vfbp-produp .
cd ${PIPELINE}vfb-prod; docker build -t vfbp-prod .
