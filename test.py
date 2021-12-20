# from os import error
# import paramiko, time

# from paramiko import channel
 
# def waitStrems(chan):
#     time.sleep(1)
#     outdata=errdata = ""
#     while chan.recv_ready():
#         outdata += str(chan.recv(1000))
#     while chan.recv_stderr_ready():
#         errdata += str(chan.recv_stderr(1000))
#     return outdata, errdata

# passwd=input("pw:")
# connection = paramiko.SSHClient()
# connection.set_missing_host_key_policy(paramiko.AutoAddPolicy())
# connection.connect("192.168.0.230", username="root", password="nostech123", look_for_keys=False, allow_agent=False)
# channel = connection.invoke_shell()
# channel.send("df\n")
# outdata, errdata = waitStrems(channel)
# print(outdata)
# channel.close()

import paramiko

try:
    ssh=paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    ssh.connect("192.168.0.237", username="root", password="nostech123")
    print("ssh connected")
    while True:
        command = input()
        #print("코멘트:"+command)
        if str(command) == "exit":
            ssh.close()
        stdin, stdout, stderr = ssh.exec_command(command)
        lines = stdout.readlines()
        for i in lines:
            re = str(i).replace('\n',"")
            print(re)
       

except Exception as err:
    print(err)