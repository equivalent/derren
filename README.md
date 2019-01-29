> this was a proof of concept that one can deploy compiled SPAs to Azure storage accounts BLOB (general purpose 2)  as a static website and then Nginx proxy (hosted on www.mywebsite.com) to different Azure storage accounts static websites (E.g. www.mywebsite.com/ ->  proxy 1st SPA hosted on one Azure storage account https//my-root.azure-storage....com , www.mywebsite.com/management ->proxy 2nd SPA on another Azure storage accounthttps//my-management.azure-storage....com) 
> 
> ...and it works!
>
> I'm not working on this project anymore if you have any questions pls create an issue in the project. I may turn it into Artile one day if there is enough interest in this

# Derren

Deploy static websites (or SPAs) on Azure Storage Accounts Blobs.  

...**it's freaking magic !**

![](https://cdn-static.denofgeek.com/sites/denofgeek/files/styles/main_wide/public/2017/09/derren_brown_main.jpg)


```
az extension add --name storage-preview
./run
```

