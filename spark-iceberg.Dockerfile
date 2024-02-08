FROM jupyter/pyspark-notebook

ENV ICEBERG_VERSION 1.4.3
ENV SCALA_VERSION 2.12
ENV HADOOP_VERSION 3.3.4
ENV AWS_JAVA_SDK_VERSION 1.12.262

USER root

# Download Apache Iceberg jars
RUN wget -P ${SPARK_HOME}/jars -q https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_${SCALA_VERSION}/${ICEBERG_VERSION}/iceberg-spark-runtime-3.5_${SCALA_VERSION}-${ICEBERG_VERSION}.jar
RUN wget -P ${SPARK_HOME}/jars -q https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/${ICEBERG_VERSION}/iceberg-aws-bundle-${ICEBERG_VERSION}.jar
RUN wget -P ${SPARK_HOME}/jars -q https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar
RUN wget -P ${SPARK_HOME}/jars -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar

USER ${NB_UID}