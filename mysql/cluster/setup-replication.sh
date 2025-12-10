#!/bin/bash

# MySQL主从复制配置脚本
# 使用方法: ./setup-replication.sh

echo "开始配置MySQL主从复制..."

# 等待MySQL服务启动
echo "等待MySQL服务启动..."
sleep 30

# 获取主库的二进制日志文件和位置
echo "获取主库状态..."
MASTER_STATUS=$(docker exec mysql-master mysql -uroot -proot123 -e "SHOW BINARY LOG STATUS\G")
echo "$MASTER_STATUS"

# 提取文件名和位置
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

echo "主库日志文件: $MASTER_LOG_FILE"
echo "主库日志位置: $MASTER_LOG_POS"

if [ -z "$MASTER_LOG_FILE" ] || [ -z "$MASTER_LOG_POS" ]; then
    echo "错误: 无法获取主库状态"
    exit 1
fi

# 配置从库1
echo "配置从库1..."
docker exec mysql-slave1 mysql -uroot -proot123 -e "
STOP REPLICA;
RESET REPLICA;
CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='mysql-master',
    SOURCE_USER='repl',
    SOURCE_PASSWORD='repl123',
    SOURCE_LOG_FILE='$MASTER_LOG_FILE',
    SOURCE_LOG_POS=$MASTER_LOG_POS;
START REPLICA;
"

# 配置从库2
echo "配置从库2..."
docker exec mysql-slave2 mysql -uroot -proot123 -e "
STOP REPLICA;
RESET REPLICA;
CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='mysql-master',
    SOURCE_USER='repl',
    SOURCE_PASSWORD='repl123',
    SOURCE_LOG_FILE='$MASTER_LOG_FILE',
    SOURCE_LOG_POS=$MASTER_LOG_POS;
START REPLICA;
"

echo "等待复制启动..."
sleep 10

# 检查从库状态
echo "检查从库1状态..."
docker exec mysql-slave1 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G" | grep -E "(Replica_IO_Running|Replica_SQL_Running|Last_Error)"

echo "检查从库2状态..."
docker exec mysql-slave2 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G" | grep -E "(Replica_IO_Running|Replica_SQL_Running|Last_Error)"

echo "主从复制配置完成!"
echo ""
echo "连接信息:"
echo "主库: localhost:3316"
echo "从库1: localhost:3317"
echo "从库2: localhost:3318"
echo "用户名: root"
echo "密码: root123"
