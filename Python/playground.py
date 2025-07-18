from pprint import pprint
mtx = []
n = 5
dxy = [(0, 1), (1, 0), (0, -1), (-1, 0)]  #  튜블
    #    0        1        2        3
      
# 매트릭스 만들기
for i in range(n):
    r = []
    for j in range(n):
        r.append(0)
    mtx.append(r)

# nx, ny -> 가능하면
# x = nx
# y = ny

# 현재 위치점을 영점 위치로 [0, 0] 으로 세팅
x = 0
y = 0
next_x = 0
next_y = 0
number = 1  # 채울 숫자

while 0 <= next_x < n and 0 <= next_y < n and mtx[next_x][next_y] == 0:
    mtx[x][y] = number
    number += 1
    next_x, next_y = x + dxy[0][0], y + dxy[0][1]
    if 0 <= next_x < n and 0 <= next_y < n and mtx[next_x][next_y] == 0:
        x = next_x
        y = next_y
        mtx[x][y] = number
        number += 1
        x = next_x
        y = next_y
    print(x, y)
    pprint(mtx)
    print()
    
    
    
# dot = [x,y]
# while dot[0] in range(n) and mtx[x][y] == 0:  # 아래쪽로 이동
#     mtx[x][y] = number
#     number += 1
#     x += 1
#     dot[0] = x
# y -= 1
# x -= 1
# dot = [x,y]
# while dot[1] in range(n) and mtx[x][y] == 0:  # 왼쪽으로 이동
#     mtx[x][y] = number
#     number += 1
#     y -= 1
#     dot[1] = y
# y += 1
# x -= 1
# dot = [x,y]    
# while dot[0] in range(n) and mtx[x][y] == 0:  # 위쪽로 이동
#     mtx[x][y] = number
#     number += 1
#     x -= 1
#     dot[0] = x
# y += 1
# x += 1
# while dot[1] in range(n) and mtx[x][y] == 0:  # 다시 오른쪽으로 이동
#     mtx[x][y] = number
#     number += 1
#     y += 1
#     dot[1] = y

    # 매트릭스 값 직접 수정
    # 현재 위치
      
# pprint(mtx)  
print(mtx[0]) 
print(mtx[1])  
print(mtx[2])  
print(mtx[3])
print(mtx[3])
print(mtx[4])
print('숫자:', number)
print('현재 좌표 x y:', x, y)
print('다음 좌표 x y:', next_x, next_y)