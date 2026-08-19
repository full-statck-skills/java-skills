#!/bin/bash
# SDK 仓库（xxx-java-sdk）单分支发布：去 SNAPSHOT → deploy Central → tag → bump SNAPSHOT → push。
# 仅用于三分支：feature/1.0.x（JDK 8）/ feature/2.0.x（JDK 17）/ feature/3.0.x（JDK 21）。
# starter 仓库请用 release-starter.sh。
#
# 用法: release-sdk.sh <branch> <release-date> <next-date> [repo-dir]
# 例如: release-sdk.sh feature/2.0.x 20260630 20260730 ~/workspaces/.../openclaw-java-sdk
# 环境变量：DRY_RUN=1 演练；EASY4J_JDK_HOME= 显式指定 JDK。
#
# 发布不可逆——调用方（Agent）必须先获得用户明确授权。
set -euo pipefail

BRANCH="${1:?usage: release-sdk.sh <feature/1.0.x|2.0.x|3.0.x> <release-date> <next-date> [repo-dir]}"
REL_DATE="${2:?missing release date}"
NEXT_DATE="${3:?missing next snapshot date}"
REPO_DIR="${4:-.}"

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

LINE="${BRANCH#feature/}"
case "$LINE" in
  1.0.x) JDKV=8 ;; 2.0.x) JDKV=17 ;; 3.0.x) JDKV=21 ;;
  *) echo "ERROR: '$BRANCH' 不在 SDK 分支白名单（1.0.x / 2.0.x / 3.0.x）。starter 仓库请用 release-starter.sh"; exit 1 ;;
esac
JAVA_HOME=$(resolve_jdk_home "$JDKV") || { echo "ERROR: 未找到 JDK$JDKV，请安装或设置 EASY4J_JDK_HOME"; exit 1; }
export JAVA_HOME

run() { if [[ "${DRY_RUN:-0}" = "1" ]]; then echo "[dry-run] $*"; else "$@"; fi; }

cd "$REPO_DIR"
# 仓库类型守卫：starter 仓库误用本脚本时直接拒绝
if grep -q 'spring-boot-starter-parent' pom.xml 2>/dev/null; then
  echo "ERROR: 这是 starter 仓库（含 spring-boot-starter-parent），请用 release-starter.sh"; exit 1
fi
git checkout "$BRANCH"
[[ -z "$(git status --short)" ]] || { echo "working tree dirty, abort"; exit 1; }

REL_VER="$LINE.$REL_DATE"
NEXT_VER="$LINE.$NEXT_DATE-SNAPSHOT"
echo "SDK $BRANCH → release $REL_VER, JDK $(basename "$(dirname "$(dirname "$JAVA_HOME")")")"

echo "### 1/4 bump $REL_VER"
run mvn versions:set -DnewVersion="$REL_VER" -DgenerateBackupPoms=false -q
run git add pom.xml && run git commit -q -m "chore(release): bump version to $REL_VER"

echo "### 2/4 deploy to Maven Central"
run mvn clean deploy -P release -DskipTests

echo "### 3/4 tag $REL_VER"
run git tag -a "$REL_VER" -m "Release $REL_VER"
run git push origin "$REL_VER"

echo "### 4/4 bump $NEXT_VER + push"
run mvn versions:set -DnewVersion="$NEXT_VER" -DgenerateBackupPoms=false -q
run git add pom.xml && run git commit -q -m "chore: bump version to $NEXT_VER"
run git push origin "$BRANCH"

echo "DONE: $REL_VER released; $BRANCH now at $NEXT_VER"
