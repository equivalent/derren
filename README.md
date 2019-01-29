> this was a proof of concept that One can deploy compiled SPAs to Azure storage accounts BLOB (general purpose 2)  as a static website and then Nginx proxy (hosted on www.mywebsite.com) to different Azure storage accounts static websites (E.g. www.mywebsite.com/ -> 1st SPA hosted on one Azure storage account, www.mywebsite.com/management -> 2nd SPA on another Azure storage account) 

# Derren

Deploy static websites (or SPAs) on Azure Storage Accounts Blobs.  

...**it's freaking magic !**

![](https://cdn-static.denofgeek.com/sites/denofgeek/files/styles/main_wide/public/2017/09/derren_brown_main.jpg)


```
az extension add --name storage-preview
./run
```

