# 문자열 처리함수
pythion = "Pythion is Amaziong"
index = pythion.index("Pythion")
#print(index)
index = pythion.index("n", index + 1)
print(index)

#슬라이싱
# jumin = "990120-1234567"
# print("성별: " + jumin[7])
# print("년: " + jumin[0:2]) #0번째부터 2번째 직전까지
# print("월: " + jumin[2:4])
# print("일: " + jumin[4:6])

# print("생년월일: " + jumin[:6]) # 처음부터 6 직전까지
# print("뒤 7자리: " + jumin[7:]) #7번째 부터 끝까지
# print("뒤 7자리 (뒤에서부터): " + jumin[-7:])

#문자열 처리
# 방법1
# print("나는 %d살 입니다." % 20) # %d 정수값
# print("나는 %s을(를) 좋아해요" % "파이썬") # %s 문자열
# print("Apple 은 %c로 시작해요" %'A') # %c 한문자
# print("나는 %s색과 %s색을 좋아해요" %("파랑","빨강"))
# 방법2
# print("나는 {}살 입니다." .format(20))
# print("나는 {}색과 {}색을 좋아해요".format("파랑","빨강"))
# print("나는 {1}색과 {0}색을 좋아해요".format("파랑","빨강"))

# 방법3
# print("나는 {age}살이며, {color}색을 좋아해요".format(color="빨강",age=20))

# 방법4(v3.6 이상)
# age = 20
# color = "빨강"
# print(f"나는 {age}살이며, {color}색을 좋아해요")

#탈출문자
# print("백문이 불여일견 \n백견이 불여일타")
# print("백문이 불여일견 \
#    백견이 불여일타")

#리스트
# subway = ["유재석","조세호","박명수"]
# print(subway)
# #조세호씨는 몇번째 칸에 타고 있는가?
# print(subway.index("조세호"))

# #하하씨가 다음 정류장에서 탑승
# subway.append("하하") # 다음칸에 탐
# print(subway)

# # 정형돈씨를 유재석 / 조세호 사이에 탑승
# subway.insert(1,"정형돈")
# print(subway)

# #지하철에 있는사람을 한명씩 뒤에서 꺼냄
# print(subway.pop())
# print(subway)


# answer = input("값을 입력하세요: ")
# print("입력값은 {}입니다.".format(input))