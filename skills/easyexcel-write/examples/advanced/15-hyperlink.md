# 超链接

```java
WriteCellData<String> hyperlink = new WriteCellData<>("官方网站");
writeCellDemoData.setHyperlink(hyperlink);
HyperlinkData hyperlinkData = new HyperlinkData();
hyperlink.setHyperlinkData(hyperlinkData);
hyperlinkData.setAddress("https://github.com/alibaba/easyexcel");
hyperlinkData.setHyperlinkType(HyperlinkType.URL);
```

> **官方提示**：`HyperlinkType` 可选 URL/EMAIL/FILE/DOCUMENT
