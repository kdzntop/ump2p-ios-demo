# ump2p-ios-demo
UMP2P 产品iOS 客户端Demo


## LocalPods说明
```
UMViewUtils（工具模块）
UMLaunchKit（功能配置模块）
UMP2PApiClientLaunch（UM SDK初加载模块）
UMP2PPushLaunch（UM 推送初加载模块）
UMP2PAccount（UM账号系统模块）
UMP2PVisual（UM设备播放模块）
```

## Launch.json 文件说明
```
UMP2PApiClientLaunch->opts：
    hosts：各个版本服务器地址配置
    logs：各个版本的LOG开启配置
    port：服务器端口配置
    appId：APP应用ID，通过UM公司申请
    account：是否使用UM平台账号系统，如果设置为false，启动demo直接进入播放界面，直接使用UMID进行播放
    push：是否使用推送功能，如果使用，需要配置UMP2PPushLaunch模块

UMP2PPushLaunch->opts 
    appId：第三方推送平台appId(废弃)
    appKey：第三方推送平台appKey(废弃)
    appSecret：第三方推送平台appSecret(废弃)

当前Demo由服务端直连APNs推送

```

## UMLaunchKit.json 文件说明
```
buildConfig：当前版本（test/pre/release），决定使用Launch.json里面具体数据，进行修改以后需要重新pod update才生效
```
