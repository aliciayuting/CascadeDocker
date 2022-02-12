This dockerfile creates an development environment for cascade.

1. CONFIGURATION  
   
Please put your public ssh key, which usually can be found at ~/.ssh/id_rsa.pub, into the folder, and name it as id_rsa.pub.  

2. USEAGE  
  
To create the image:
```
sudo docker build -t cascade_devel .
```
It takes a couple of minutes to finish. Then, create an container as following:
```
sudo docker run --privileged -d -p 22622:22 -it --name cascade_devel cascade_devel
```
You should have a container named as 'cascade_devel' up and running. To access it,
```
docker exec -it  -u0 cascade_devel bash
```
After logging in, please run the following command.
```
sysctl -w vm.overcommit_memory=1
```
