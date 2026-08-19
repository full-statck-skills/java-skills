#!/bin/bash
# Starter 仓库（xxx-spring-boot-starter）单分支发布：
#   依赖转正式版（*java-sdk.version / *extension.version 去 -SNAPSHOT）
#   → 去 SNAPSHOT → deploy Central → tag → bump SNAPSHOT（依赖保持正式版）→ push。
# 仅用于十分支：2.3.x / 2.7.x（JDK 8）、3.0.x~3.5.x（JDK 17）、4.0.x / 4.1.x（JDK 17 或 21）。
# JDK 自动取 max(自身 java.version, 全部依赖线字节码)；SDK 仓库请用 release-sdk.sh。
#
# 用法: release-starter.sh <branch> <release-date> <next-date> [repo-dir]
# 例如: release-starter.sh 2.7.x 20260630 20260730 ~/workspaces/.../openclaw-spring-boot-starter
# 环境变量：DRY_RUN=1 演练；EASY4J_JDK_HOME= 显式指定 JDK（默认经 /usr/libexec/java_home 按需解析）。
#
# 发布不可逆——调用方（Agent）必须先获得用户明确授权。
set -euo pipefail

BRANCH="${1:?usage: release-starter.sh <2.3.x|2.7.x|3.0.x..3.5.x|4.0.x|4.1.x> <release-date> <next-date> [repo-dir]}"
REL_DATE="${2:?missing release date}"
NEXT_DATE="${3:?missing next snapshot date}"
REPO_DIR="${4:-.}"

LINE="${BRANCH#feature/}"
case "$LINE" in
  2.3.x|2.7.x|3.0.x|3.1.x|3.2.x|3.3.x|3.4.x|3.5.x|4.0.x|4.1.x) : ;;
  *) echo "ERROR: '$BRANCH' 不在 starter 分支白名单（2.3.x~4.1.x 共 10 条）。SDK 仓库请用 release-sdk.sh"; exit 1 ;;
esac

run() { if [[ "${DRY_RUN:-0}" = "1" ]]; then echo "[dry-run] $*"; else "$@"; fi; }

# JDK 解析：EASY4J_JDK_HOME > /usr/libexec/java_home -v <v>（macOS，8 兼容 1.8）> 失败中止
resolve_jdk_home() {
  local v="$1" h real
  [[ -n "${EASY4J_JDK_HOME:-}" ]] && { echo "$EASY4J_JDK_HOME"; return 0; }
  if [[ -x /usr/libexec/java_home ]]; then
    # 候选顺序：8 优先 1.8（部分 macOS 上 -v 8 会误匹配高版本 JDK）
    local cands=("$v")
    [[ "$v" = "8" ]] && cands=("1.8" "8")
    for c in "${cands[@]}"; do
      h=$(/usr/libexec/java_home -v "$c" 2>/dev/null || true)
      [[ -n "$h" ]] || continue
      # 校验解析结果的真实版本，防 java_home 误匹配
      real=$("$h/bin/java" -version 2>&1 | head -1)
      case "$v" in
        8)  [[ "$real" == *'"1.8'* || "$real" == *'"8.'* ]] && { echo "$h"; return 0; } ;;
        17) [[ "$real" == *'"17.'* ]] && { echo "$h"; return 0; } ;;
        21) [[ "$real" == *'"21.'* ]] && { echo "$h"; return 0; } ;;
      esac
    done
  fi
  return 1
}

cd "$REPO_DIR"
# 仓库类型守卫：必须是 starter 仓库
if ! grep -q 'spring-boot-starter-parent' pom.xml 2>/dev/null; then
  echo "ERROR: 这不是 starter 仓库（未发现 spring-boot-starter-parent），请用 release-sdk.sh"; exit 1
fi
git checkout "$BRANCH"
[[ -z "$(git status --short)" ]] || { echo "working tree dirty, abort"; exit 1; }

# ---- JDK 推断：max(自身 java.version, 所有依赖线) ----
if [[ -n "${EASY4J_JDK_HOME:-}" ]]; then
  export JAVA_HOME="$EASY4J_JDK_HOME"
else
  jv=$( { grep -oE '<java\.version>[^<]+' pom.xml || true; } | head -1 | sed 's|.*>||')
  case "$jv" in
    1.8|8) need=8 ;; 17) need=17 ;; 2[1-9]|2[1-9].*) need=21 ;;
    *) echo "ERROR: 无法识别 java.version: $jv"; exit 1 ;;
  esac
  # 遍历全部 *java-sdk.version / *extension.version 依赖线，取最高要求（避免多属性时漏判）
  for dep in $( { grep -oE '<[A-Za-z0-9._-]*(java-sdk|extension)\.version>[0-9]+\.[0-9]+\.[0-9x]+\.' pom.xml || true; } \
                | grep -oE '[0-9]+\.[0-9]+\.[0-9x]+\.' ); do
    case "$dep" in
      3.0.x.) [[ $need -lt 21 ]] && need=21 ;;
      2.0.x.) [[ $need -lt 17 ]] && need=17 ;;
      1.0.x.) : ;;
      *) echo "note: 未识别依赖线 '$dep'，维持 JDK$need" ;;
    esac
  done
  JAVA_HOME=$(resolve_jdk_home "$need") || { echo "ERROR: 未找到 JDK$need，请安装或设置 EASY4J_JDK_HOME"; exit 1; }
  export JAVA_HOME
  echo "JDK resolution: java.version=$jv, deps=max -> build with JDK$need"
fi

REL_VER="$LINE.$REL_DATE"
NEXT_VER="$LINE.$NEXT_DATE-SNAPSHOT"

# ---- 0. 依赖转正式版 ----
if grep -qE '<[A-Za-z0-9._-]*(java-sdk|extension)\.version>[^<]+-SNAPSHOT' pom.xml; then
  echo "### 0/5 promote sdk/extension deps to release versions"
  if [[ "${DRY_RUN:-0}" = "1" ]]; then
    echo "[dry-run] perl -i -pe 's{(<[\\w.-]*(?:java-sdk|extension)\\.version>[^<]*?)-SNAPSHOT(</)}{\$1\$2}g' pom.xml"
  else
    perl -i -pe 's{(<[\w.-]*(?:java-sdk|extension)\.version>[^<]*?)-SNAPSHOT(</)}{$1$2}g' pom.xml
    git add pom.xml && git commit -q -m "chore(deps): promote sdk/extension dependencies to release versions"
  fi
fi

echo "### 1/5 bump $REL_VER"
run mvn versions:set -DnewVersion="$REL_VER" -DgenerateBackupPoms=false -q
run git add pom.xml && run git commit -q -m "chore(release): bump version to $REL_VER"

echo "### 2/5 deploy to Maven Central"
run mvn clean deploy -P release -DskipTests

echo "### 3/5 tag $REL_VER"
run git tag -a "$REL_VER" -m "Release $REL_VER"
run git push origin "$REL_VER"

echo "### 4/5 bump $NEXT_VER (deps stay at release versions)"
run mvn versions:set -DnewVersion="$NEXT_VER" -DgenerateBackupPoms=false -q
run git add pom.xml && run git commit -q -m "chore: bump version to $NEXT_VER"

echo "### 5/5 push $BRANCH"
run git push origin "$BRANCH"

echo "DONE: $REL_VER released; $BRANCH now at $NEXT_VER"
