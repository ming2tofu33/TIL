
N, S = map(int, input().split())
nums = list(map(int, input().split()))
cnt = 0
if S == 0:  # S가 0인 경우 공집합 예외처리
    cnt -= 1

for i in range(1 << N):
    temp = 0
    for j in range(N):
        if i & (1 << j):
            temp += nums[j]

    if temp == S:
        cnt += 1

print(cnt)

# import sys
# input = sys.stdin.readline

# N, S = map(int, input().split())

# l = list(map(int, input().split()))

# cnt = 0

# for i in range(1 << N):
#     selected = []
#     for j in range(N):
#         if i & (1 << j):
#             selected.append(l[j])
    
#     # print(selected)  ###
    
#     if selected and sum(selected) == S:
#         # print(selected)   ###
#         cnt += 1

# print(cnt)