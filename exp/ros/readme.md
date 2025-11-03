# 实验过程

## 环境

-   fedora43
-   conda 25.7.0
-   cmake 4.1.2
-   python 3.11
-   gcc 15.2.1

### 创建并激活虚拟环境

```shell
conda create -n .conda python=3.11
conda activate .conda
```

### 修改 channels

```shell
conda config --env --add channels conda-forge
conda config --env --remove channels defaults
conda config --env --add channels robostack-noetic
```

### 下载

```shell
conda install ros-noetic-desktop
```

### 验证

```shell
roscore
```

如果一切正常，输出类似如下

```txt
... logging to /home/arshtyi/.ros/log/c2b2763e-b7ae-11f0-908d-8c3223573ba7/roslaunch-Trantor-49299.log
Checking log directory for disk usage. This may take a while.
Press Ctrl-C to interrupt
Done checking log file disk usage. Usage is <1GB.

started roslaunch server http://Trantor:36643/
ros_comm version 1.17.0


SUMMARY
========

PARAMETERS
 * /rosdistro: noetic
 * /rosversion: 1.17.0

NODES

auto-starting new master
process[master]: started with pid [49323]
ROS_MASTER_URI=http://Trantor:11311/

setting /run_id to c2b2763e-b7ae-11f0-908d-8c3223573ba7
process[rosout-1]: started with pid [49354]
started core service [/rosout]
```

那么环境搭建结束

> 下面实验均需要在该虚拟环境中进行,activate 略

## 实验一

启动 roscore 后启动海龟

```shell
rosrun turtlesim turtlesim_node
```

接着启动输入

```shell
rosrun turtlesim turtle_teleop_key
```

完成

## 实验二

按如下实现(手册上的跑不起来)

```shell
mkdir src
cd src
catkin_init_workspace
catkin_create_pkg hello_world roscpp rospy
cat > hello_world/src/my_hello_world_node.cpp << 'EOF'
#include<ros/ros.h>
int main(int argc,char**argv)
{
    ros::init(argc,argv,"hello_node");
    ros::NodeHandle nh;
    ROS_INFO_STREAM("hello world!!!");
}
EOF
cat >> hello_world/CMakeLists.txt << 'EOF'
add_compile_options(-std=c++14)
add_executable(hello_world src/my_hello_world_node.cpp)
target_link_libraries(${PROJECT_NAME}
  ${catkin_LIBRARIES}
)
EOF
```

编译并运行

```shell
cd ..
catkin_make -DCMAKE_POLICY_VERSION_MINIMUM=3.5
source devel/setup.zsh
rosrun hello_world hello_world
```

python:

```shell
mkdir  src/hello_world/scripts
cat > src/hello_world/scripts/hello.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
# -*- coding: utf-8 -*-
import rospy
rospy.init_node("pyhello")
print("hello ros python")
EOF
chmod +x src/hello_world/scripts/hello.py
rosrun hello_world hello.py
```

完成

## 实验三

运行 海龟

```shell
roscore
rosrun turtlesim turtlesim_node
rosrun turtlesim turtle_teleop_key
```

给一个稳定的命令流让海龟旋转

```shell
rostopic pub /turtle1/cmd_vel geometry_msgs/Twist -r 1 -- '[2.0, 0.0, 0.0]' '[0.0, 0.0, 1.8]'
```

展示坐标(选择/turtle1/pose)

```shell
rosrun rqt_plot rqt_plot
```

完成

## 实验四

运行 海龟

```shell
roscore
rosrun turtlesim turtlesim_node
rosrun turtlesim turtle_teleop_key
```

通过命令`rosservice` 生成第二只小海龟

```shell
rosservice call spawn 2 2 0.2 ""
```

使用命令`rosparam list`查看参数

```txt
/rosdistro
/roslaunch/uris/host_trantor__35185
/rosversion
/run_id
/turtlesim/background_b
/turtlesim/background_g
/turtlesim/background_r
```

这个时候可以通过`set`修改参数了

```shell
rosparam set /turtlesim/background_r 150
rosservice call clear
```

完成

## 实验五

实现如下

```shell
mkdir src
cd src
catkin_create_pkg learning_topic roscpp rospy std_msgs geometry_msgs turtlesim message_generation
mkdir -p learning_topic/scripts
cat > learning_topic/scripts/velocity_publisher.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import rospy
from geometry_msgs.msg import Twist
def velocity_publisher():
    rospy.init_node('velocity_publisher', anonymous=True)
    turtle_vel_pub = rospy.Publisher('/turtle1/cmd_vel', Twist, queue_size=10)
    rate =rospy.Rate(10)
    while not rospy.is_shutdown():
        vel_msg = Twist()
        vel_msg.linear.x=0.5
        vel_msg.angular.z =0.2
        turtle_vel_pub.publish(vel_msg)
        rospy.loginfo("Publsh turtle velocity command[%0.2fm/s, %0.2frad/s]",
        vel_msg.linear.x, vel_msg.angular.z)
        rate.sleep()
if __name__ == '__main__':
    try:
        velocity_publisher()
    except rospy.ROSInterruptException:
        pass
EOF
cat > learning_topic/scripts/pose_subscriber.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import rospy
from turtlesim.msg import Pose
def poseCallback(msg):
    rospy.loginfo("Turtle pose: x:%0.6f, y:%0.6f", msg.x, msg.y)
def pose_subscriber():
    rospy.init_node('pose_subscriber', anonymous=True)
    rospy.Subscriber("/turtle1/pose", Pose, poseCallback)
    rospy.spin()
if __name__== '__main__':
    pose_subscriber()
EOF
cat > learning_topic/scripts/person_subscriber.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import rospy
from learning_topic.msg import Person

def personInfoCallback(msg):
    rospy.loginfo("Subcribe Person Info: name:%s age:%d sex:%d",msg.name, msg.age,msg.sex)

def person_subscriber():
    rospy.init_node('person_subscriber', anonymous=True)
    rospy.Subscriber("/person_info", Person, personInfoCallback)
    rospy.spin()
if  __name__== '__main__':
    person_subscriber()
EOF
cat > learning_topic/scripts/person_publisher.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import rospy
from learning_topic.msg import Person
import time
def velocity_publisher():
    rospy.init_node('person_publisher', anonymous=True)
    person_info_pub = rospy.Publisher('/person_info', Person, queue_size=10)
    rate =rospy.Rate(10)
    while not rospy.is_shutdown():
        person_msg = Person()
        person_msg.name = "Tom"; person_msg.age=18;
        person_msg.sex=Person.male;
        person_info_pub.publish(person_msg)
        rospy.loginfo("Publsh person message[%s, %d, %d]",person_msg.name, person_msg.age, person_msg.sex)
        rate.sleep()
        time.sleep(1)
if __name__ =='__main__':
    try:
        velocity_publisher()
    except rospy.ROSInterruptException:
        pass
EOF
chmod +x learning_topic/scripts/*.py
mkdir -p learning_topic/msg
cat > learning_topic/msg/Person.msg << 'EOF'
string name
uint8 sex
uint8 age
uint8 unknown=0
uint8 male=1
uint8 female=2
EOF
```

修改`src/learning_topic/CMakeLists.txt`:

```cmake
add_message_files(
  FILES
  Person.msg
)
generate_messages()
catkin_package(
  INCLUDE_DIRS include
  LIBRARIES learning_topic
  CATKIN_DEPENDS geometry_msgs roscpp rospy std_msgs turtlesim message_runtime
  DEPENDS system_lib
)
```

然后插入下面两句到`src/learning_topic/package.xml`

```xml
<build_depend>message_generation</build_depend>
<exec_depend>message_runtime</exec_depend>
```

编译

```shell
cd ..
catkin_make -DCMAKE_POLICY_VERSION_MINIMUM=3.5
```

先运行海龟

```shell
roscore
rosrun turtlesim turtlesim_node
```

运行

```shell
source devel/setup.zsh
rosrun learning_topic person_subscriber.py
rosrun learning_topic velocity_publisher.py
rosrun learning_topic person_subscriber.py
rosrun learning_topic person_publisher.py
```

完成

## 实验六

实现如下

```shell
mkdir src
cd src
catkin_create_pkg learning_service roscpp rospy std_msgs geometry_msgs turtlesim  message_generation
mkdir -p learning_service/src learning_service/scripts learning_service/srv
cat > learning_service/src/person_client.cpp << 'EOF'
#include <ros/ros.h>
#include "learning_service/Person.h"
int main(int argc, char **argv)
{
    // 初始化ROS 节点
    ros::init(argc, argv, "person_client");
    // 创建节点句柄
    ros::NodeHandle node;
    //  发现/spawn服务后，创建一个服务客户端，连接名为/spawn的service
    ros::service::waitForService("/show_person");
    ros::ServiceClient person_client = node.serviceClient<learning_service::Person>("/show_person");
    // 初始化learning_service::Person的请求数据
    learning_service::Person srv;
    srv.request.name = "Tom";
    srv.request.age = 20;
    srv.request.sex = learning_service::Person::Request::male;
    // 请求服务调用
    ROS_INFO("Call service to show person[name:%s, age:%d, sex:%d]",srv.request.name.c_str(), srv.request.age, srv.request.sex);
    person_client.call(srv);
    // 显示服务调用结果
    ROS_INFO("Show person result ; %s", srv.response.result.c_str());
    return 0;
}
EOF
cat > learning_service/src/person_server.cpp << 'EOF'
#include <ros/ros.h>
#include "learning_service/Person.h"
// service 回调函数，输入参数req，输出参数res
bool personCallback(learning_service::Person::Request &req, learning_service::Person::Response &res)
{
    // 显示请求数据
    ROS_INFO("Person: name:%s age:%d sex:%d", req.name.c_str(), req.age, req.sex);
    // 设置反馈数据
    res.result = "OK";
    return true;
}

int main(int argc, char **argv)
{
    // ROS 节点初始化
    ros::init(argc, argv, "person_server");
    // 创建节点句柄
    ros::NodeHandle n;
    // 创建一个名为/show_person的server，注册回调函数 personCallback
    ros::ServiceServer person_service = n.advertiseService("/show_person", personCallback);
    // 循环等待回调函数
    ROS_INFO("Ready to show person informtion.");
    ros::spin();
    return 0;
}
EOF
cat > learning_service/src/turtle_command_server.cpp << 'EOF'
#include <ros/ros.h>
#include <geometry_msgs/Twist.h>
#include <std_srvs/Trigger.h>
ros::Publisher turtle_vel_pub; // 全局变量
bool pubCommand = false;
// service 回调函数，输入参数req，输出参数res
bool commandCallback(std_srvs::Trigger::Request &req, std_srvs::Trigger::Response &res)
{
    pubCommand = !pubCommand;
    // 显示请求数据
    ROS_INFO("Publish turtle velocity command [%s]", pubCommand == true ? "Yes" : "No");
    // 设置反馈数据 res.success =true;
    res.message = "Change turtle command state!";
    return true;
}
int main(int argc, char **argv)
{
    // ROS 节点初始化
    ros::init(argc, argv, "turtle_command_server");
    // 创建节点句柄
    ros::NodeHandle n;
    // 创建一个名为/turtle_command的server，注册回调函数commandCallback
    ros::ServiceServer command_service = n.advertiseService("/turtle_command", commandCallback);
    // 创建一个 Publisher，发布名为/turtle1/cmd_vel的topic，消息类型为 geometry_msgs::Twist,队列长度10
    turtle_vel_pub = n.advertise<geometry_msgs::Twist>("/turtle1/cmd_vel", 10);
    // 循环等待回调函数
    ROS_INFO("Ready to receive turtle command. "); // 设置循环的频率
    ros::Rate loop_rate(10);
    while (ros::ok())
    {
        // 查看一次回调函数队列
        ros::spinOnce();
        // 如果标志为true,则发布速度指令
        if (pubCommand)
        {
            geometry_msgs::Twist vel_msg;
            vel_msg.linear.x = 0.5;
            vel_msg.angular.z = 0.2;
            turtle_vel_pub.publish(vel_msg);
        }
        // 按照循环频率延时
        loop_rate.sleep();
    }
    return 0;
}
EOF
cat > learning_service/src/turtle_spawn.cpp << 'EOF'
#include <ros/ros.h>
#include <turtlesim/Spawn.h>
int main(int argc, char **argv)
{
    // 初始化ROS节点
    ros::init(argc, argv, "turtle_spawn");
    // 创建节点句柄
    ros::NodeHandle node;
    // 发现/spawn 服务后，创建一个服务客户端，连接名为/spawn的service
    ros::service::waitForService("/spawn");
    ros::ServiceClient add_turtle = node.serviceClient<turtlesim::Spawn>("/spawn");
    // 初始化turtlesim::Spawn的请求数据
    turtlesim::Spawn srv;
    srv.request.x = 2.0;
    srv.request.y = 2.0;
    srv.request.name = "turtle2";
    // 请求服务调用
    ROS_INFO("Call service to spwan turtle[x:%0.6f, y:%0.6f, name:%s]",
             srv.request.x, srv.request.y, srv.request.name.c_str());
    add_turtle.call(srv);
    // 显示服务调用结果
    ROS_INFO("Spwan turtle successfully [name:%s]", srv.response.name.c_str());
    return 0;
}
EOF
cat > learning_service/scripts/person_client.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import sys
import rospy
from learning_service.srv import Person, PersonRequest
def person_client():#ROS节点初始化
    rospy.init_node('person_client')
#发现/spawn服务后，创建一个服务客户端，连接名为/spawn的service
    rospy.wait_for_service('/show_person')
    try:
        person_client = rospy.ServiceProxy('/show_person', Person)
#请求服务调用，输入请求数据
        response = person_client("Tom", 20,PersonRequest.male)
        return response.result
    except rospy.ServiceException as e:
        print("Service call failed: %s",e)
if __name__== "__main__":#服务调用并显示调用结果
    print ("Show person result : %s",(person_client()))
EOF
cat > learning_service/scripts/person_server.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import rospy
from learning_service.srv import Person, PersonResponse
def personCallback(req):#显示请求数据
    rospy.loginfo("Person: name:%s age:%d sex:%d", req.name, req.age, req.sex)
#反馈数据
    return PersonResponse("OK")
def person_server():
#ROS 节点初始化
    rospy.init_node('person_server')
# 创建一个名为/show_person的server，注册回调函数personCallback
    s = rospy.Service('/show_person', Person, personCallback)
# 循环等待回调函数
    print("Ready to show person informtion.")
    rospy.spin()
if __name__ == "__main__":
    person_server()
EOF
cat > learning_service/scripts/turtle_command_server.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import rospy
import _thread,time
from geometry_msgs.msg import Twist
from std_srvs.srv import Trigger,TriggerResponse
pubCommand = False
turtle_vel_pub = rospy.Publisher('/turtle1/cmd_vel', Twist, queue_size=10)
def command_thread():
    while True:
        if pubCommand:
            vel_msg =Twist()
            vel_msg.linear.x = 0.5
            vel_msg.angular.z =0.2
            turtle_vel_pub.publish(vel_msg)
        time.sleep(1)
def commandCallback(req):
    global pubCommand
    pubCommand = bool(1-pubCommand)
#显示请求数据
    rospy.loginfo("Publish turtle velocity command![%d]", pubCommand)
#反馈数据
    return TriggerResponse(1,"Change turtle command state!")
def turtle_command_server():# ROS 节点初始化
    rospy.init_node('turtle_command_server')
#创建一个名为/turtle_command的server，注册回调函数commandCallback
    s = rospy.Service('/turtle_command', Trigger, commandCallback)
# 循环等待回调函数
    print("Ready to receive turtle command.")
    _thread.start_new_thread(command_thread, ())
    rospy.spin()
if __name__== "__main__":
    turtle_command_server()
EOF
cat > learning_service/scripts/turtle_spawn.py << 'EOF'
#!/home/arshtyi/miniconda3/envs/.conda/bin/python
import sys
import rospy
from turtlesim.srv import Spawn
def turtle_spawn():# ROS 节点初始化
    rospy.init_node('turtle_spawn')
# 发现/spawn 服务后，创建一个服务客户端，连接名为/spawn的service
    rospy.wait_for_service('/spawn')
    try:
        add_turtle = rospy.ServiceProxy('/spawn', Spawn)
#请求服务调用,输入请求数据
        response = add_turtle(2.0, 2.0, 0.0,"turtle2")
        return response.name
    except rospy.ServiceException as e:
        print("Service call failed: %s",e)
if  __name__== "__main__":#服务调用并显示调用结果
    print ("Spwan turtle successfully [name:%s]" %(turtle_spawn()))
EOF
cat > learning_service/srv/Person.srv << 'EOF'
string name
uint8 age
uint8 sex
uint8 unknown=0
uint8 male=1
uint8 female=2
---
string result
EOF
cat >> learning_service/CMakeLists.txt << 'EOF'
add_executable(turtle_spawn src/turtle_spawn.cpp)
target_link_libraries(turtle_spawn ${catkin_LIBRARIES})
add_executable(turtle_command_server src/turtle_command_server.cpp)
target_link_libraries(turtle_command_server ${catkin_LIBRARIES})
add_executable(person_server src/person_server.cpp)
target_link_libraries(person_server ${catkin_LIBRARIES})
add_dependencies(person_server ${PROJECT_NAME}_gencpp)
add_executable(person_client src/person_client.cpp)
target_link_libraries(person_client ${catkin_LIBRARIES})
add_dependencies(person_client ${PROJECT_NAME}_gencpp)
EOF
chmod +x learning_service/scripts/*.py
```

修改`src/learning_service/CMakeLists.txt`:

```cmake
add_service_files(
  FILES
  Person.srv
)
generate_messages()
catkin_package(
    CATKIN_DEPENDS geometry_msgs roscpp rospy std_msgs turtlesim message_runtime
)
```

插入下面一句到`learning_service/package.xml`

```xml
<exec_depend>message_runtime</exec_depend>
```

编译

```shell
cd ..
catkin_make -DCMAKE_POLICY_VERSION_MINIMUM=3.5
```

先运行海龟

```shell
roscore
rosrun turtlesim turtlesim_node
```

运行

```shell
source devel/setup.zsh
rosrun learning_service turtle_command_server
```

生成小海龟

```shell
rosrun learning_service turtle_spawn
```

转圈,二次执行则停止

```shell
rosservice call /turtle_command "{}"
```

运行

```shell
rosrun learning_service person_server
rosrun learning_service person_client
```
