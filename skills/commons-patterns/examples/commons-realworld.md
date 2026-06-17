# Commons IO 大文件逐行读示例

```java
// 大文件逐行读(避免OOM)
LineIterator it = FileUtils.lineIterator(new File("large.csv"), "UTF-8");
try {
    while (it.hasNext()) {
        String line = it.nextLine();
        processLine(line);
    }
} finally {
    LineIterator.closeQuietly(it);
}
```

---

> 来源：[https://commons.apache.org/proper/commons-io/](https://commons.apache.org/proper/commons-io/)
