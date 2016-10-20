#包大小分析工具
##利用 nm 命令生产 csv 文件

#命令

cd .a文件路径

nm/size.py .a文件名


#输出  

.a文件名.csv 文件大小

.a文件名.func.csv 函数大小

.a文件名.unused.csv 未使用类


#未使用图片

cd 图片目录

nm/image.py .m类文件目录


#输出

unused.csv 未使用图片

