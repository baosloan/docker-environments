FROM elasticsearch:7.17.28

# 设置工作目录
WORKDIR /usr/share/elasticsearch

# 安装IK分词器
# 加上 || true 是为了防止插件已存在导致构建失败
RUN bin/elasticsearch-plugin install --batch https://get.infini.cloud/elasticsearch/analysis-ik/7.17.28 || true

# 创建 IK 配置文件的存放目录 (确保目录存在，防止挂载报错)
RUN mkdir -p /usr/share/elasticsearch/plugins/analysis-ik/config