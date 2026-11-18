# 纸上山河 · 懒猫微服打包（LPK）

[lxfater/poetry-popup-book](https://github.com/lxfater/poetry-popup-book)（MIT）的懒猫微服打包仓库。上游是一本会动、会朗诵的古诗立体书：纸雕书页、注释、朗诵音频，纯静态站点（Three.js）。

本仓库**不保存上游源码**：`UPSTREAM.conf` 固定仓库与 commit，构建时由 `build.sh` 拉取该提交的压缩包，只把运行需要的静态文件放进 `content/web`，再用官方 nginx 镜像托管。

## 为什么这样打包

- 上游没有 Release / tag / 镜像，只有静态文件，所以不走镜像模式，也不需要构建镜像。
- 站点完全离线（无任何外部请求），因此不声明网络权限。
- 版本号由本仓库 `package.yml` 决定（当前 1.0.1）；上游仍是滚动提交、没有版本标签，暂不能按上游版本自动升级。

## 升级做法

1. 改 `UPSTREAM.conf` 里的 `COMMIT` 为新提交。
2. 同步改 `package.yml` 的 `version`（例如 1.0.1）。
3. 手动触发 `Publish Poetry Pop-up Book to MiaoMiao` 工作流。

## 说明

- 图标按应用内的书本封面风格自绘（`icon.png`，512×512）。
- `content/` 是构建产物，已加入 `.gitignore`。
- 静态文件随 LPK 放在 `/lzcapp/pkg/content/web`；容器启动时由 `setup_script` 复制到镜像内的 `/usr/share/nginx/html` 再托管，避免直接依赖内容目录的权限位。
