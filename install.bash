START_DIR=$(pwd)
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sudo echo "Cached sudo"

cd ${PROJECT_ROOT}
chmod +x run_buggy_server.bash
sed -e "s|@PROJECT_ROOT@|${PROJECT_ROOT}|g" buggy_server.template.service > buggy_server.service
sudo cp buggy_server.service /etc/systemd/system/buggy_server.service

sudo systemctl daemon-reload

cd ${START_DIR}