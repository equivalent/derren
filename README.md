> this was a proof of concept that one can deploy compiled SPAs to Azure storage accounts BLOB (general purpose 2)  as a static website and then Nginx proxy (hosted on www.mywebsite.com) to different Azure storage accounts static websites (E.g. www.mywebsite.com/ ->  proxy 1st SPA hosted on one Azure storage account https//my-root.azure-storage....com , www.mywebsite.com/management ->proxy 2nd SPA on another Azure storage accounthttps//my-management.azure-storage....com) 
> 
> ...and it works!
>
> I'm not working on this project anymore if you have any questions pls create an issue in the project. I may turn it into Artile one day if there is enough interest in this
>
> More info [here](http://www.rubyflow.com/p/ti5a72-hosting-microservice-spas-on-azure-storage-account-blobs-peroxided-by-nginx)

# Derren

Deploy static websites (or SPAs) on Azure Storage Accounts Blobs.  

...**it's freaking magic !**

![](https://user-images.githubusercontent.com/721990/102477219-5c060780-405c-11eb-9e34-44fcc1bf71eb.jpeg)


```
az extension add --name storage-preview
./run
```

### Dummy project

https://github.com/equivalent/derren-example-project

Imagine each folder is own SPA hosted on seperate Azure storage. You Derren (this repo) would deploy the project + generate Nginx conf. All you need to do is copy the Nginx conf to VM running nginx 

> plan was to make this full project that would compile Docker image running nginx, push to container registry and tell VM to pull latest proxy image.

### How does the proxy works ?

It's just simple Nginx proxy simmilar to this:

```
        location /auth {
           proxy_pass https://my-auth-spa.microsoft-blob-url.com;
         }

         location /auth/ {
           proxy_pass https://my-auth-spa.microsoft-blob-url.com/;
         }
```

### Useful resoures

* https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website  note: you need General Pursouse 2 Active Storage account to host static website. Otherwise it will not work
* https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/
