# 一格多图 + 文字

```java
WriteCellData<Void> writeCellData = new WriteCellData<>();
imageDemoData.setWriteCellDataFile(writeCellData);
writeCellData.setType(CellDataTypeEnum.STRING);
writeCellData.setStringValue("额外的放一些文字");

List<ImageData> imageDataList = new ArrayList<>();
ImageData imageData = new ImageData();
imageDataList.add(imageData);
writeCellData.setImageDataList(imageDataList);
imageData.setImage(FileUtils.readFileToByteArray(new File(imagePath)));
imageData.setImageType(ImageType.PICTURE_TYPE_PNG);
imageData.setTop(5);
imageData.setRight(40);
imageData.setBottom(5);
imageData.setLeft(5);

// 第二张图
imageData = new ImageData();
imageDataList.add(imageData);
imageData.setImage(FileUtils.readFileToByteArray(new File(imagePath)));
imageData.setImageType(ImageType.PICTURE_TYPE_PNG);
imageData.setTop(5);
imageData.setRight(5);
imageData.setBottom(5);
imageData.setLeft(50);
imageData.setRelativeFirstRowIndex(0);
imageData.setRelativeFirstColumnIndex(0);
imageData.setRelativeLastRowIndex(0);
imageData.setRelativeLastColumnIndex(1);  // 跨 2 列
```
