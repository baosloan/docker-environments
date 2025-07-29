# Docker Development Environments
Just to record the docker development environment。

## 网络

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
docker network create develop
docker network create --driver bridge --subnet 192.168.100.0/24 --gateway 192.168.100.1 develop
```
gateway(网关)的作用
1.内外网流量的路由
- 角色：网关是网络的“出口”，负责转发容器到外部网络的请求(如访问互联网)。
- 典型值：通常为子网的第一个IP(如192.168.100.1)。

2.跨网段通信
场景：容器访问非本地子网的目标(如另一物理网络中的数据)。
通信流程：
- 容器内执行ping 8.8.8.8(Google DNS).
- 数据包目标8.8.8.8不在192.168.100.0/24子网内。
- 容器将数据包发送给网关192.168.100.1(网关通常为子网的第一个IP).
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

2.应用层网络(backend-net)
用途：运行业务应用(如Java/Go/Python微服务).
```shell
docker network create --driver bridge --subnet 10.10.20/24 --gateway 10.10.2.1 backend-net
```
策略：
- 禁止外部直接访问(不映射端口到宿主机)。
- 允许接收来自`frontend-net`的请求。
- 允许访问`database-net`的数据库端口（如MySQL的3306）。

3.数据库网络(database-net)
用途：运行数据库(MySQL、PostgreSQL)、缓存(Redis)。
```shell
docker network create --driver bridge --subnet 10.10.3.0/24 --gateway 10.10.3.1 --internal database-net
```
--internal：禁止容器访问外网

策略：
- 仅允许`backend-net`的应用层容器访问。
- 完全隔离外部互联网(无NAT出站)。

4.监控与日志网络(monitoring-net)
用途：部署Prometheus、Grafana、ELK等监控组件。
```shell
docker network create --driver bridge --subnet 10.10.4.0/24 --gateway 10.10.4.1 monitoring-net
```

策略：
- 允许所有网络访问监控的API端口（如9090、3000）。
- 监控组件主动抓取其他网络的容器（需显式连接）。