## 构建镜像

构建单架构

```shell
docker build -t baosloan/elasticsearch-ik:8.19.7 .
```

构建多架构镜像

```shell
$ docker buildx build --platform linux/amd64,linux/arm64 -t baosloan/elasticsearch-ik:8.19.7 -t baosloan/elasticsearch-ik:latest --push .
```



## 开发环境

```yaml
services:
  elasticsearch:
    image: baosloan/elasticsearch-ik:8.19.7
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "TZ=Asia/Shanghai"
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
      - xpack.security.enabled=false # 禁用安全功能(仅用于开发环境)
      - xpack.security.enrollment.enabled=false
      - xpack.security.http.ssl.enabled=false
      - xpack.security.transport.ssl.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      # 单独挂载配置文件（最安全，保留了官方的主词典）
      - ${PWD}/data:/usr/share/elasticsearch/data
      - ${PWD}/logs:/usr/share/elasticsearch/logs
      # IK分词器会从 /usr/share/elasticsearch/config/analysis-ik/ 目录加载配置
      - ${PWD}/ik-config/IKAnalyzer.cfg.xml:/usr/share/elasticsearch/config/analysis-ik/IKAnalyzer.cfg.xml:ro
      - ${PWD}/ik-config/custom.dic:/usr/share/elasticsearch/config/analysis-ik/custom.dic:ro
      - ${PWD}/ik-config/stop.dic:/usr/share/elasticsearch/config/analysis-ik/stop.dic:ro
    ports:
      - "9200:9200"
    networks:
      - develop

  kibana:
    image: kibana:8.19.7
    container_name: kibana
    depends_on:
      - elasticsearch
    environment:
      - I18N_LOCALE=zh-CN
      - "TZ=Asia/Shanghai"
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - SERVER_PUBLICBASEURL=http://localhost:5601
    ports:
      - "5601:5601"
    networks:
      - develop
networks:
  develop:
    external: true
```

## 生产环境

```yaml
services:
  elasticsearch:
    image: baosloan/elasticsearch-ik:8.19.7
    container_name: elasticsearch
    restart: unless-stopped
    environment:
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "TZ=Asia/Shanghai"
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
      # 启用安全但使用密码认证
      - xpack.security.enabled=true
      - xpack.security.enrollment.enabled=false  # 禁用注册令牌
      - xpack.security.http.ssl.enabled=false    # 禁用 HTTPS
      - xpack.security.transport.ssl.enabled=false
      # 设置初始密码
      - ELASTIC_PASSWORD=Avx-MZT-oXD-iWS
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      # 单独挂载配置文件（最安全，保留了官方的主词典）
      - ${PWD}/data:/usr/share/elasticsearch/data
      - ${PWD}/logs:/usr/share/elasticsearch/logs
      # IK分词器会从 /usr/share/elasticsearch/config/analysis-ik/ 目录加载配置
      - ${PWD}/ik-config/IKAnalyzer.cfg.xml:/usr/share/elasticsearch/config/analysis-ik/IKAnalyzer.cfg.xml:ro
      - ${PWD}/ik-config/custom.dic:/usr/share/elasticsearch/config/analysis-ik/custom.dic:ro
      - ${PWD}/ik-config/stop.dic:/usr/share/elasticsearch/config/analysis-ik/stop.dic:ro
    ports:
      - "9200:9200"
    networks:
      - develop
    healthcheck:
      test: ["CMD-SHELL", "curl -u elastic:Avx-MZT-oXD-iWS http://localhost:9200 || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5

  kibana:
    image: kibana:8.19.7
    container_name: kibana
    restart: unless-stopped
    depends_on:
      elasticsearch:
        condition: service_healthy
    environment:
      - I18N_LOCALE=zh-CN
      - "TZ=Asia/Shanghai"
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - SERVER_PUBLICBASEURL=http://localhost:5601
      - ELASTICSEARCH_USERNAME=kibana_system
      - ELASTICSEARCH_PASSWORD=bpc-Seb-DSt-BeT
      - XPACK_SECURITY_ENABLED=true
      - XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=8H3kL9mP2qR5sT7vW0xY1zA3bC6dE9fG
    ports:
      - "5601:5601"
    networks:
      - develop
networks:
  develop:
    external: true
```



1.启动elasticsearch

```shell
$ docker compose -f compose.production.yaml up -d elasticsearch
```

2.生成kibana_systemd访问密码

方式一(推荐)：

```shell
docker exec -it elasticsearch curl -X POST -u elastic:Avx-MZT-oXD-iWS \
  "http://localhost:9200/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  -d '{"password":"bpc-Seb-DSt-BeT"}'
```

方式二：

```shell
$ docker exec -it elasticsearch bash
bin/elasticsearch-reset-password -u kibana_system -i
bpc-Seb-DSt-BeT
```

3.启动kibana

```shell
$ docker compose -f compose.production.yaml up -d kibana
```

4.登录

```shell
账号：elastic
密码：Avx-MZT-oXD-iWS
```

