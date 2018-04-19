# DownLoadDome
下载数据的方法 目前只实现了断点续传功能，未实现多个任务同时下载、未实现后台下载 
# - (NSURLSessionDataTask *)downloadURL:(NSString *) downloadURL progress:(void (^)(DownLoadModel * downloadModel))progress success:(void (^)(NSString *filePath))success failure:(void(^)(NSError *error))faliure;
