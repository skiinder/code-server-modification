if [ "${PROJECT_URL}" -a ! -d "$(basename ${PROJECT_URL} .git)" ]
then git clone "${PROJECT_URL}"
fi