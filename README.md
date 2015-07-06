# Selenium Docker container

This project creates a Docker image prepared with Selenium and a VNC server running on a Centos7 box with Xvfb and soon fluxbox as WM.


To get it started:  
1. docker build -t selenium /path/to/folder/containing/Dockerfile  
2. docker run -d -p 5900:5900 -p 4444:4444 selenium  

To stop it:  
1. docker ps  
2. docker stop <hash>  


# VNC access
You can connect to any VNC viewer to running container and be able to see the Xvfb memory display with the help of x11vnc.
The password is "vnc".
