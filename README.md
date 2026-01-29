# Docker Development Environments

Just to record the docker development environment。

## 镜像

### Docker镜像命令

```shell
# 删除所有镜像
docker rmi -f $(docker images -aq)
```



## 容器

### Docker容器命令

```shell
# 从镜像仓库拉取镜像
docker pull $image_name:$version
# 删除所有容器
docker rm -f $(docker ps -aq)
```



## 系统

### Docker系统命令

```shell
# 查看磁盘使用概况
docker system df

# 查看详细空间使用(包含镜像、容器、卷等)
docker system df -v

# 输出格式化为人类可读
docker system df --human

# 清理所有未使用的资源(交互式确认)
docker system prune

# 强制清理(无需确认)
docker system prune -f

# 清理所有未使用的资源，包括未使用的镜像
docker system prune -a

# 清理并同时清理卷(谨慎使用！会删除未使用的卷)
docker system prune --volumes

# 组合使用：清理所有未使用的镜像、容器、卷
docker system prune -a --volumes -f
```



## 网络

### 什么是Docker网络？

Docker网络是Docker容器之间以及容器与外部世界通信的基础设施。它提供了容器间的连接、隔离和通信机制，使得容器化应用能够像传统网络应用一样进行数据交换。

### Docker网络架构

```mermaid
graph TB
    subgraph "主机网络栈"
        A[物理网卡 eth0]
        B[主机IP: 192.168.1.100]
    end
    
    subgraph "Docker网络层"
        C[docker0 网桥<br/>172.17.0.1]
        D[自定义网络<br/>10.10.0.1]
    end
    
    subgraph "容器网络"
        E[容器1<br/>172.17.0.2]
        F[容器2<br/>172.17.0.3]
        G[容器3<br/>10.10.0.2]
        H[容器4<br/>10.10.0.3]
    end
    
    A --> C
    A --> D
    C --> E
    C --> F
    D --> G
    D --> H
    
    style A fill:#e1f5fe
    style C fill:#e8f5e8
    style D fill:#fff3e0
```

### Docker网络命名空间

Docker使用Linux网络命名空间（Network Namespace）来实现容器间的网络隔离。每个容器都有自己独立的网络栈，包括：

- **网络接口**：虚拟网卡（veth pair）
- **路由表**：决定数据包的转发路径
- **防火墙规则**：iptables规则
- **网络统计信息**：网络流量统计

### Docker网络命令

```shell
docker network --help
```

![image-20260128135157934](./README.assets/image-20260128135157934.png)

```shell
# 查看所有网络
docker network ls

# 查看默认bridge网络详情
docker network inspect bridge

# 查看自定义develop网络详情(前提已通过docker network create创建了名为develop的网络)
docker network inspect develop

# 移除网络
docker network rm <network_name>

# 查看Docker守护进程网络配置
docker info | grep -i network

# 查看容器网络配置
docker inspect <container_name> | grep -A 20 "NetworkSettings"
```

### Docker网络驱动

#### Bridge网络驱动



##### 工作原理

```mermaid
sequenceDiagram
    participant Container1
    participant docker0
    participant Host
    participant External
    
    Container1->>docker0: 发送数据包
    docker0->>Host: 通过NAT转发
    Host->>External: 路由到外部网络
    External->>Host: 响应数据包
    Host->>docker0: 反向NAT
    docker0->>Container1: 转发响应
```

##### 实践示例

```shell
# 1.查看默认bridge网络
docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "0083e132a7f3f1dbb5801e826d56c867cbe725ebd12f4be73b0f79e00bb05b60",
        "Created": "2026-01-27T23:30:06.081814477Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv4": true,
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "IPRange": "",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "65535"
        },
        "Labels": {},
        "Containers": {}
    }
]

# 2. 创建自定义网络
docker network create --driver=bridge --subnet=10.10.0.0/16 --gateway=10.10.0.1 develop
docker network create \
--driver=bridge \
--subnet=10.10.0.0/16 \
--gateway=10.10.0.1 \
--opt com.docker.network.bridge.enable_icc=true \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
--opt com.docker.network.bridge.host_binding_ipv4=0.0.0.0 \
--opt com.docker.network.driver.mtu=65535 \
develop
docker network create \
--driver=bridge \
--subnet=10.10.0.0/16 \
--gateway=10.10.0.1 \
--opt com.docker.network.bridge.enable_icc=true \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
--opt com.docker.network.bridge.host_binding_ipv4=0.0.0.0 \
--opt com.docker.network.bridge.name=my_docker0 \
--opt com.docker.network.driver.mtu=65535 \
develop

docker network inspect develop
[
    {
        "Name": "develop",
        "Id": "fbb8fbe91945175ac4da146015d5157aeeec8e5fa6ef582216268d8def8cce71",
        "Created": "2026-01-26T09:33:25.244596939Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv4": true,
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "10.10.0.0/16",
                    "IPRange": "",
                    "Gateway": "10.10.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Options": {
            "com.docker.network.enable_ipv4": "true",
            "com.docker.network.enable_ipv6": "false"
        },
        "Labels": {},
        "Containers": {}
    }
]

# 移除网络
docker network rm develop

# 创建网络
docker network create --driver=bridge --subnet=10.10.0.0/16 --gateway=10.10.0.1 --opt com.docker.network.driver.mtu=65535 develop

# 测试容器联通性(注意：默认bridge不支持容器名解析)
docker exec web1 ping 172.17.0.3 # 使用IP地址

# 在自定义网络中运行容器
docker run -d --name app1 --network develop nginx
docker run -d --name app2 --network develop nginx

# 自定义网络中的容器通信(支持容器名解析)
docker exec app1 ping app2
docker exec app1 nslookup app2
```

#### Host网络驱动

Host网络驱动让容器直接使用主机的网络栈，性能最佳但安全性较低。

##### 实践示例

```shell
# 1. 使用host网络运行容器
docker run -d --name web-host --network host nginx

# 2. 查看容器网络配置（与主机相同）
docker exec web-host ip addr show
docker exec web-host ip route show

# 3. 直接访问主机端口（无需端口映射）
curl http://localhost:80

# 4. 查看网络统计
docker exec web-host cat /proc/net/dev
```

##### Host网络的优缺点

**优点：**

- 网络性能最佳，无额外开销
- 无需端口映射
- 容器可以直接绑定主机端口

**缺点：**

- 网络隔离性差
- 端口冲突风险
- 安全性较低



#### None网络驱动

None网络驱动创建完全隔离的容器，只有loopback接口。

##### 实践示例

```shell
# 1. 创建无网络容器
docker run -d --name isolated --network none alpine sleep 3600

# 2. 查看网络配置（只有lo接口）
docker exec isolated ip addr show
docker exec isolated ip route show

# 3. 测试网络连通性（应该失败）
docker exec isolated ping 8.8.8.8  # 会失败

# 4. 手动添加网络接口（高级用法）
# 创建veth pair
sudo ip link add veth0 type veth peer name veth1

# 将一端移动到容器网络命名空间
container_pid=$(docker inspect isolated --format '{{.State.Pid}}')
sudo ip link set veth1 netns $container_pid

# 在容器中配置网络
docker exec isolated ip link set veth1 up
docker exec isolated ip addr add 192.168.100.2/24 dev veth1
```

#### Overlay网络驱动

Overlay网络用于跨主机容器通信，主要在Docker Swarm模式中使用。

##### 实践示例

```shell
# 1. 初始化Swarm集群
docker swarm init --advertise-addr <MANAGER-IP>

# 2. 在其他节点加入集群
docker swarm join --token <TOKEN> <MANAGER-IP>:2377

# 3. 创建overlay网络
docker network create \
  --driver overlay \
  --attachable \
  --subnet=10.0.0.0/24 \
  multi-host-network

# 4. 在overlay网络中运行服务
docker service create \
  --name web \
  --network multi-host-network \
  --replicas 3 \
  nginx

# 5. 查看服务分布
docker service ps web

# 6. 测试跨主机通信
docker run -it --rm --network multi-host-network alpine ping web
```

#### Macvlan网络驱动

Macvlan允许容器拥有独立的MAC地址，在网络中表现为物理设备。

##### 实践示例

```shell
# 1. 创建macvlan网络
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan-net

# 2. 运行容器获得独立MAC地址
docker run -d \
  --name web-macvlan \
  --network macvlan-net \
  --ip=192.168.1.100 \
  nginx

# 3. 查看容器网络配置
docker exec web-macvlan ip addr show
docker exec web-macvlan ip route show

# 4. 从外部网络直接访问容器
ping 192.168.1.100  # 从同一网段的其他主机
```

### 容器间通信机制

#### 同一网络内的容器通信

在同一个自定义网络中，容器可以通过容器名进行通信。

实践示例：

```shell
# 1. 创建自定义网络
docker network create app-network

# 2. 启动数据库容器
docker run -d \
  --name postgres \
  --network app-network \
  -e POSTGRES_DB=myapp \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=password \
  postgres:13

# 3. 启动应用容器
docker run -d \
  --name app \
  --network app-network \
  -e DATABASE_URL=postgresql://user:password@postgres:5432/myapp \
  my-app:latest

# 4. 测试连接
docker exec app ping postgres
docker exec app nslookup postgres

# 5. 查看DNS解析
docker exec app cat /etc/resolv.conf
docker exec app dig postgres
```

#### 跨网络容器通信

容器可以连接到多个网络，实现跨网络通信。

实践示例：

```shell
# 1. 创建多个网络
docker network create frontend-net
docker network create backend-net

# 2. 启动数据库（仅在后端网络）
docker run -d \
  --name database \
  --network backend-net \
  postgres:13

# 3. 启动API服务（连接两个网络）
docker run -d --name api nginx
docker network connect frontend-net api
docker network connect backend-net api

# 4. 启动前端服务（仅在前端网络）
docker run -d \
  --name frontend \
  --network frontend-net \
  nginx

# 5. 验证网络连接
docker inspect api | grep -A 10 "Networks"
docker exec api ping database    # 可以访问
docker exec frontend ping api    # 可以访问
docker exec frontend ping database  # 无法访问（网络隔离）
```

#### 容器与主机通信

容器可以通过特殊的主机名访问主机服务。

实践示例

```shell
# 1. 在主机上启动服务
python3 -m http.server 8000 &

# 2. 从容器访问主机服务
docker run --rm alpine wget -qO- http://host.docker.internal:8000

# 3. 在Linux上使用主机IP
HOST_IP=$(ip route show default | awk '/default/ {print $3}')
docker run --rm alpine wget -qO- http://$HOST_IP:8000

# 4. 使用--add-host添加主机映射
docker run --rm \
  --add-host=myhost:192.168.1.100 \
  alpine ping myhost
```



### 网段规划



- bridge(默认模式)
    - 容器分配独立Network Namespace，通过虚拟网桥`docker0`互联。
    - 特点：隔离性强，支持端口映射(-p 80:8080)，适合单主机多容器通信。
- host模式
    - 容器共享宿主主机网络栈，无独立IP，性能最优(无NAT开销)。
    - 适用场景：高性能需求(如网络代理、实时数据处理)
- None模式
    - 无网络接口，完全隔离。用于离线计算或安全敏感任务。
- Container模式
    - 共享指定容器的Network Namespace，IP和端口一致。适用监控或日志收集。
    

问题：默认情况下所有容器通过`docker0`网桥相连，相互都可访问，缺乏安全性。
解决：创建独立网络，实现逻辑隔离。
好处：
    DNS解析：同一网络内容器可通过**容器名**直接通信(无需知道IP)。
    子网管理：自定义IP地址段，避免IP冲突。

```shell
$ docker network create --driver=bridge --subnet=10.10.0.0/16 --gateway=10.10.0.1 develop 
```
gateway(网关)的作用
1.内外网流量的路由
- 角色：网关是网络的“出口”，负责转发容器到外部网络的请求(如访问互联网)。
- 典型值：通常为子网的第一个IP(如10.10.0.1)。

2.跨网段通信
场景：容器访问非本地子网的目标(如另一物理网络中的数据)。
通信流程：
- 容器内执行ping 8.8.8.8(Google DNS).
- 数据包目标8.8.8.8不在10.10.0.0/16子网内。
- 容器将数据包发送给网关10.10.0.1(网关通常为子网的第一个IP).
- 网关通过宿主机进行NAT转换，访问互联网。

3.出站流量NAT转换
关键功能：容器访问外网时，网关将其私有IP转换为宿主机的公网IP。

![deepseek_mermaid](./README.assets/deepseek_mermaid.svg)

网络分层

- 设计原则
    - 最小权限原则：每个网络只开放必要的通信路径。
    - 分层隔离：不同层次的容器分配不同网络。
    - 服务发现优化：同一服务集群内使用自动DNS解析。
    - 出站控制：敏感服务(如数据库)禁止直接访问外网。

网络分段方案：
1.前端网络(frontend-net)
用途：托管Web服务器(如Nginx)、负载均衡器、前端应用。

```shell
docker network create --driver bridge --subnet 10.10.1.0/24 --gateway 10.10.1.1 frontend-net
```
策略：
- 允许外部访问：映射80/443端口到宿主机。
- 仅允许访问`backend-net`(应用层)的特定端口(如8080)。
- docker run -d --name nginx --network frontend-net -p 80:80 nginx

2.应用层网络(backend-net)
用途：运行业务应用(如Java/Go/Python微服务).
```shell
docker network create --driver bridge --subnet 10.10.2.0/24 --gateway 10.10.2.1 backend-net
```
策略：
- 禁止外部直接访问(不映射端口到宿主机)。
- 允许接收来自`frontend-net`的请求。
- 允许访问`database-net`的数据库端口（如MySQL的3306）。
- docker network connect backend-net nginx
- docker run --name app-service --network backend-net my-app-image

3.数据库网络(database-net)
用途：运行数据库(MySQL、PostgreSQL)、缓存(Redis)。
```shell
docker network create --driver bridge --subnet 10.10.3.0/24 --gateway 10.10.3.1 --internal database-net
```
--internal：禁止容器访问外网

策略：
- 仅允许`backend-net`的应用层容器访问。
- 完全隔离外部互联网(无NAT出站)。
- docker network connect database-net app-service

4.监控与日志网络(monitoring-net)
用途：部署Prometheus、Grafana、ELK等监控组件。
```shell
docker network create --driver bridge --subnet 10.10.4.0/24 --gateway 10.10.4.1 monitoring-net
```

策略：
- 允许所有网络访问监控的API端口（如9090、3000）。
- 监控组件主动抓取其他网络的容器（需显式连接）。

![deepseek_mermaid_net_tupo](./README.assets/deepseek_mermaid_net_tupo.svg)



- Nginx - 10.10.1.0
  - Nginx1.26 - 10.10.1.1
- MySQL - 10.10.2.0
  - MySQL8.4.6单机版 - 10.10.2.1
  - MySQL5.7单机版 - 10.10.2.2
  - 集群node1 - 10.10.2.3
  - 集群node2 - 10.10.2.4
  - 集群node3 - 10.10.2.5
- Redis - 10.10.3.0
  - Redis-7.2.10单机版 - 10.10.3.1
  - Redis-6单机版 - 10.10.3.2
  - Redis-5单机版 - 10.10.3.3
  - 集群node1 10.10.3.4
  - 集群node2 10.10.3.5
  - 集群node3 10.10.3.6
  - Cluster 10.10.3.7
  - Cluster 10.10.3.8
  - Cluster 10.10.3.9
- RabbitMQ - 10.10.4.0
- Postgresql - 10.10.5.0
- Memcached - 10.10.6.0
- Elasticsearch - 10.10.7.0
- Kafka - 10.10.8.0
- MongoDB - 10.10.9.0
- PHP - 10.10.10.0
- Consul - 10.10.11.0
- Etcd - 10.10.12.0
- Zentao - 10.10.13.0



