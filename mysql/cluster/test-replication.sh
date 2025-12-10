#!/bin/bash

# MySQL主从复制测试脚本
# 使用方法: ./test-replication.sh

echo "开始测试MySQL主从复制功能..."

# 测试1: 在主库插入数据
echo "=== 测试1: 在主库插入数据 ==="
docker exec mysql-master mysql -uroot -proot123 -e "
USE testdb;
INSERT INTO users (username, email) VALUES ('test_user_$(date +%s)', 'test$(date +%s)@example.com');
SELECT COUNT(*) as master_count FROM users;
"

echo "等待数据同步..."
sleep 3

# 检查从库1的数据
echo "=== 检查从库1的数据 ==="
docker exec mysql-slave1 mysql -uroot -proot123 -e "
USE testdb;
SELECT COUNT(*) as slave1_count FROM users;
SELECT username, email FROM users ORDER BY id DESC LIMIT 3;
"

# 检查从库2的数据
echo "=== 检查从库2的数据 ==="
docker exec mysql-slave2 mysql -uroot -proot123 -e "
USE testdb;
SELECT COUNT(*) as slave2_count FROM users;
SELECT username, email FROM users ORDER BY id DESC LIMIT 3;
"

# 测试2: 批量插入数据
echo "=== 测试2: 批量插入数据 ==="
docker exec mysql-master mysql -uroot -proot123 -e "
USE testdb;
INSERT INTO users (username, email) VALUES 
('batch_user1_$(date +%s)', 'batch1$(date +%s)@example.com'),
('batch_user2_$(date +%s)', 'batch2$(date +%s)@example.com'),
('batch_user3_$(date +%s)', 'batch3$(date +%s)@example.com');
"

echo "等待批量数据同步..."
sleep 3

# 检查所有节点的数据一致性
echo "=== 检查数据一致性 ==="
MASTER_COUNT=$(docker exec mysql-master mysql -uroot -proot123 -e "USE testdb; SELECT COUNT(*) FROM users;" | tail -1)
SLAVE1_COUNT=$(docker exec mysql-slave1 mysql -uroot -proot123 -e "USE testdb; SELECT COUNT(*) FROM users;" | tail -1)
SLAVE2_COUNT=$(docker exec mysql-slave2 mysql -uroot -proot123 -e "USE testdb; SELECT COUNT(*) FROM users;" | tail -1)

echo "主库记录数: $MASTER_COUNT"
echo "从库1记录数: $SLAVE1_COUNT"
echo "从库2记录数: $SLAVE2_COUNT"

if [ "$MASTER_COUNT" = "$SLAVE1_COUNT" ] && [ "$MASTER_COUNT" = "$SLAVE2_COUNT" ]; then
    echo "✅ 数据一致性测试通过!"
else
    echo "❌ 数据一致性测试失败!"
fi

# 测试3: 检查复制状态
echo "=== 测试3: 检查复制状态 ==="
echo "从库1复制状态:"
docker exec mysql-slave1 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G" | grep -E "(Replica_IO_Running|Replica_SQL_Running|Seconds_Behind_Source|Last_Error)"

echo ""
echo "从库2复制状态:"
docker exec mysql-slave2 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G" | grep -E "(Replica_IO_Running|Replica_SQL_Running|Seconds_Behind_Source|Last_Error)"

# 测试4: 测试从库只读
echo "=== 测试4: 测试从库只读 ==="
echo "尝试在从库1写入数据 (应该失败):"
docker exec mysql-slave1 mysql -uroot -proot123 -e "
USE testdb;
INSERT INTO users (username, email) VALUES ('should_fail', 'fail@example.com');
" 2>&1 | grep -E "(ERROR|denied)" || echo "从库写入测试异常"

echo ""
echo "主从复制功能测试完成!"
