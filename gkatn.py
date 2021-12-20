def open_account():
    print("새로운 계좌 생성.")
open_account()

def deposit(balance, money):
    print("입금이 완료되었습니다. 잔액은 {}원 입니다.".format(balance+money))
    return balance+money

balance = 0
balance = deposit(balance,1000)
print(balance)