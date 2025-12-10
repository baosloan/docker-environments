# MySQL 8.4.6 一主两从集群

基于Docker的MySQL 8.4.6一主两从复制集群配置。

## 架构

- **主库 (mysql-master)**: 端口 3316
- **从库1 (mysql-slave1)**: 端口 3317  
- **从库2 (mysql-slave2)**: 端口 3318

## 快速开始

### 1. 启动集群

```bash
docker-compose up -d
```

### 2. 等待MySQL初始化完成（约60秒）

```bash
sleep 60
```

### 3. 配置主从复制

```bash
./setup-replication.sh
```

### 4. 手动创建测试表（如果初始化脚本未执行）

```bash
docker exec mysql-master mysql -uroot -proot123 -e "
USE testdb;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO users (username, email) VALUES 
('admin', 'admin@example.com'),
('user1', 'user1@example.com'),
('user2', 'user2@example.com');
"
```

### 5. 设置从库为超级只读模式

```bash
docker exec mysql-slave1 mysql -uroot -proot123 -e "SET GLOBAL super_read_only = ON;"
docker exec mysql-slave2 mysql -uroot -proot123 -e "SET GLOBAL super_read_only = ON;"
```

### 6. 测试复制功能

```bash
./test-replication.sh
```

## 连接信息

- **主库**: localhost:3316
- **从库1**: localhost:3317
- **从库2**: localhost:3318
- **用户名**: root
- **密码**: root123
- **测试数据库**: testdb

## 复制配置详情

### MySQL 8.0+ 新语法
本集群使用MySQL 8.0+的新复制语法：
- `SHOW BINARY LOG STATUS` 替代 `SHOW MASTER STATUS`
- `CHANGE REPLICATION SOURCE TO` 替代 `CHANGE MASTER TO`
- `SHOW REPLICA STATUS` 替代 `SHOW SLAVE STATUS`
- `START/STOP REPLICA` 替代 `START/STOP SLAVE`

### 认证配置
- 复制用户使用 `GET_SOURCE_PUBLIC_KEY=1` 选项处理 `caching_sha2_password` 认证
- 从库设置为 `super_read_only` 模式确保真正的只读

## 管理命令

### 查看集群状态
```bash
docker-compose ps
```

### 查看复制状态
```bash
# 从库1
docker exec mysql-slave1 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G"

# 从库2  
docker exec mysql-slave2 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G"
```

### 测试数据同步
```bash
# 在主库插入数据
docker exec mysql-master mysql -uroot -proot123 -e "
USE testdb;
INSERT INTO users (username, email) VALUES ('test_$(date +%s)', 'test_$(date +%s)@example.com');
SELECT COUNT(*) as master_count FROM users;
"

# 检查从库数据
docker exec mysql-slave1 mysql -uroot -proot123 -e "USE testdb; SELECT COUNT(*) as slave1_count FROM users;"
docker exec mysql-slave2 mysql -uroot -proot123 -e "USE testdb; SELECT COUNT(*) as slave2_count FROM users;"
```

### 停止集群
```bash
docker-compose down
```

### 完全清理（包括数据）
```bash
docker-compose down -v
```

## 故障排除

### 检查容器日志
```bash
docker-compose logs mysql-master
docker-compose logs mysql-slave1
docker-compose logs mysql-slave2
```

### 复制错误处理
如果出现复制错误，可以跳过错误事务：
```bash
docker exec mysql-slave1 mysql -uroot -proot123 -e "
SET GLOBAL super_read_only = OFF;
STOP REPLICA;
SET GLOBAL sql_slave_skip_counter = 1;
START REPLICA;
SET GLOBAL super_read_only = ON;
"
```

### 重新配置复制
如果复制出现问题，可以重新运行配置脚本：
```bash
./setup-replication.sh
```

## 测试结果

✅ **主从复制功能测试通过**
- 主库数据成功同步到两个从库
- 从库设置为只读模式
- 复制延迟为0秒
- 数据一致性验证通过

## 注意事项

1. 从库配置为 `super_read_only` 模式，确保真正只读
2. 仅复制 `testdb` 数据库
3. 使用二进制日志进行复制
4. 复制用户配置了 `GET_SOURCE_PUBLIC_KEY=1` 处理认证
5. 使用MySQL 8.0+的新复制语法

## 文件结构

```
mysql/cluster/
├── docker-compose.yml          # Docker Compose配置
├── setup-replication.sh        # 主从复制配置脚本
├── test-replication.sh         # 复制功能测试脚本
├── init-scripts/               # 初始化脚本目录
│   └── 01-create-replication-user.sql
└── README.md                   # 说明文档
```
