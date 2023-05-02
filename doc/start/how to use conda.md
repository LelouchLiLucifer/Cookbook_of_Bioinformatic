# conda 的用法
conda 是一种创建和管理虚拟环境的工具，用conda创建一个环境后，在此环境中安装和配置的软件和包就只会在此环境中存在  

为什么我们要花费时间装一些只能在特定环境下运行的包呢， 这个问题并没有合适的答案。事实上，如果我们直接在主环境中配置软件，很可能会出现一些科学难以解释的状况，而一旦出现了这种状况，即使你把安装的包全部删除，把配置全部复原，也无济于事。有过编程经验的同学们一定已经明白了，但是不论是我还是大家都无法有逻辑地解释，这种现象或许只有《道德经》中的一句话：“道可道，非常道”可以解释了  

以上是一个小玩笑，它的笑点是:我把“玄学”这个远古老梗进行了一本正经的解释，甚至引用了著名的谚语。  

实际上，我们使用conda的最主要原因还是它太方便了，它可以把你的服务器分割出许多小空间，这些空间不会相互影响，就像葡萄一样，更重要的是，这些葡萄不仅仅都连接在你租来的细藤蔓上，它们也连接在一个更大的根系上，这个根系就是全球互联网。

废话少说，让我们直接创建一个conda环境吧
## conda环境的创建

创建环境的前提是你们的服务器已经安装了anaconda软件，同学们在加入项目的时候应该已经配置好了，但如果有的同学想要从零开始搭建自己的分析服务器，可以留言，我们以后可能会讲。  

创建环境的命令如下： 

` conda create --name 麻辣烫 `

这样，我们就创建了一个名叫“麻辣烫”的环境，然而现在的麻辣烫还只是原味的，我们没有备注要不要香菜和葱花，因此，我们加入一些内容:

` conda create --name 麻辣烫 python=4.10 `

` conda create --name 麻辣烫 R=3.6.0 `

` conda create --name 麻辣烫 python=4.10 R=3.6.0 `

这是三种不同的创建方式，我们可以用它们创建不同口味的conda环境

## conda环境的启用
要应用conda环境，首先需要将其激活：

`conda activate 麻辣烫` 

这样我们就激活了麻辣烫环境，环境启用后，在命令提示符前会出现当前环境名

## conda装软件
现在我们选好了，麻辣烫的口味，煮好了麻辣烫，但是。这个麻辣烫里居然连一点正经的食材都没有！我们需要现在安装几乎所有你需要的软件，用以下命令来安装软件包： 

`conda install 肉丸` 

这是一个基础的安装“肉丸”这个软件的命令 

当然，和众多linux命令一样，这个安装命令可用添加参数，虽然大多数时候不需要： 

`conda install [-h] [--revision REVISION] [-n ENVIRONMENT | -p PATH] 

                     [-c CHANNEL] [--use-local] [--override-channels] 
                     
                     [--repodata-fn REPODATA_FNS] [--experimental {jlap,lock}] 
                     
                     [--strict-channel-priority] [--no-channel-priority] 
                     
                     [--no-deps | --only-deps] [--no-pin] [--copy] [-C] [-k] 
                     
                     [--offline] [-d] [--json] [-q] [-v] [-y] 
                     
                     [--download-only] [--show-channel-urls] [--file FILE] 
                     
                     [--solver {classic} | --experimental-solver {classic}] 
                     
                     [--force-reinstall] 
                     
                     [--freeze-installed | --update-deps | -S | --update-all | --update-specs] 
                     
                     [-m] [--clobber] [--dev] 
                     
                     [package_spec ...] `
                     
关于参数的详细讲解可以参考[这里](https://docs.conda.io/projects/conda/en/latest/commands/install.html)

特别地，如果你拥有高级权限，你可以使用 

`pip install 肉丸 -i https://pypi.tuna.tsinghua.edu.cn/simple ` 

其中 -i  链接后的为清华的镜像站，你可以在网上找到其他的镜像 

同样地，你可以用 

`conda list 
pip list ` 

查询当前环境下安装了哪些包

**然而，在实际应用中，我们不会直接这样自己写一个命令来尝试安装。通常我们会先查阅anaconda的官网[anaconda.org](https://anaconda.org/)，它可以直接给出我们需要的包的安装命令，并且可以显示包的版本和提供者，也可以查阅相关的github项目，寻找其他的安装方式。**

而如果我们需要升级某个包，我们可以重新安装或者使用如下命令 

`conda update 肉丸 `

## conda环境的清理
如果我们不想要某个包可以使用如下命令删除 

`conda uninstall 肉丸 ` 

或者使用如下命令，快捷管理 

`conda clean -p #清理无用软件包
conda clean -t #清理压缩包 `

## conda环境的退出和删除
`deactivate 肉丸 ` 

退出环境“肉丸” 

`conda remove -n 肉丸 --all ` 

删除环境

## conda环境的管理
你可以用如下命令查看关于服务器上的conda的信息 

` conda --version #查看conda版本
conda config --show  #查看conda配置 `

如果你发现你的服务器安装包非常慢，你可以尝试修改conda镜像站到国内的镜像 

首先 

` vim ~/.condarc ` 

打开配置文件，然后将以下命令写入，替换原本的配置： 

` channels:
https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda -forge/
https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
ss1_ verify: true `

如果conda版本过低无法兼容某些软件，可以使用如下命令 

`conda update conda ` 
