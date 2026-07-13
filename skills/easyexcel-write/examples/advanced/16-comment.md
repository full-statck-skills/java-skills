# 批注

```java
WriteCellData<String> comment = new WriteCellData<>("备注的单元格信息");
writeCellDemoData.setCommentData(comment);
CommentData commentData = new CommentData();
comment.setCommentData(commentData);
commentData.setAuthor("Jiaju Zhuang");
commentData.setRichTextStringData(new RichTextStringData("这是一个备注"));
commentData.setRelativeLastColumnIndex(1);
commentData.setRelativeLastRowIndex(1);
```

> **官方原文**："inMemory 要设置为true，才能支持批注"
